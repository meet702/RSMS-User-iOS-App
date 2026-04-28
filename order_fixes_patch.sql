-- ============================================================
-- ORDER FIXES PATCH
-- Fix 1: Each ordered item gets its own entry in transactions
-- Fix 2: category is stored per item (not grouped/aggregated)
-- ============================================================

-- Step 1: Add 'category' column to customer_order_items if not present
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'customer_order_items'
          AND column_name = 'category'
    ) THEN
        ALTER TABLE public.customer_order_items ADD COLUMN category TEXT;
    END IF;
END $$;


-- Step 2: Replace the RPC with a corrected version
-- Key changes:
--   C. Now includes 'category' when inserting into customer_order_items
--   D. Creates ONE transactions row PER ITEM (not grouped by category)
CREATE OR REPLACE FUNCTION public.complete_luxe_order(
  p_user_id UUID,
  p_store_id UUID,
  p_total_amount NUMERIC,
  p_order_payload JSONB,
  p_items_payload JSONB
) RETURNS VOID AS $$
DECLARE
  v_order_id UUID;
  v_order_num TEXT;
  v_item RECORD;
BEGIN
  v_order_num := p_order_payload->>'order_number';

  -- A. IDEMPOTENCY CHECK
  IF EXISTS (SELECT 1 FROM public.customer_orders WHERE order_number = v_order_num AND user_id = p_user_id) THEN
    DELETE FROM public.customer_cart WHERE user_id = p_user_id;
    RETURN;
  END IF;

  -- B. Insert Main Order
  INSERT INTO public.customer_orders (
    user_id, order_number, status, subtotal, taxes, delivery_fee,
    shipping_address, payment_method, estimated_delivery,
    discount_amount, store_id, total_amount
  ) VALUES (
    p_user_id, v_order_num, p_order_payload->>'status',
    (p_order_payload->>'subtotal')::numeric, (p_order_payload->>'taxes')::numeric,
    (p_order_payload->>'delivery_fee')::numeric,
    COALESCE(p_order_payload->>'shipping_address', 'Selected Address'),
    COALESCE(p_order_payload->>'payment_method', 'Razorpay'),
    NULLIF(p_order_payload->>'estimated_delivery', '')::timestamptz,
    (p_order_payload->>'discount_amount')::numeric,
    p_store_id, p_total_amount
  ) RETURNING id INTO v_order_id;

  -- C. Insert Individual Items (NOW WITH category)
  INSERT INTO public.customer_order_items (
    order_id, product_id, variant, quantity, price_at_purchase,
    product_name, product_image_url, category
  )
  SELECT
    v_order_id,
    (item->>'product_id')::uuid,
    item->>'variant',
    (item->>'quantity')::int,
    (item->>'price_at_purchase')::numeric,
    item->>'product_name',
    item->>'product_image_url',
    COALESCE(item->>'category', 'Miscellaneous')
  FROM jsonb_array_elements(p_items_payload) AS item;

  -- D. RECORD GRANULAR TRANSACTIONS — ONE ROW PER ITEM (not grouped)
  --    This means 2 jewellery items = 2 separate transaction rows
  FOR v_item IN (
    SELECT
      COALESCE(item->>'category', 'Miscellaneous')           AS category_name,
      item->>'product_name'                                   AS product_name,
      (item->>'quantity')::int                               AS item_qty,
      (item->>'quantity')::int * (item->>'price_at_purchase')::numeric AS item_revenue
    FROM jsonb_array_elements(p_items_payload) AS item
  )
  LOOP
    INSERT INTO public.transactions (
      order_id, store_id, category, item_count, total_amount
    ) VALUES (
      v_order_id, p_store_id, v_item.category_name, v_item.item_qty, v_item.item_revenue
    );
  END LOOP;

  -- E. CLEAR Successful Cart
  DELETE FROM public.customer_cart
  WHERE user_id = p_user_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Step 3: Force PostgREST cache refresh
NOTIFY pgrst, 'reload schema';
