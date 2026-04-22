-- 1. Fix Cart Uniqueness Constraint
ALTER TABLE public.customer_cart
DROP CONSTRAINT IF EXISTS customer_cart_user_id_product_id_variant_key;

ALTER TABLE public.customer_cart
ADD CONSTRAINT customer_cart_user_id_product_id_variant_key 
UNIQUE (user_id, product_id, variant);


-- 2. Create standard RPC for Order Placement with IDEMPOTENCY
CREATE OR REPLACE FUNCTION public.complete_luxe_order(
  p_items_payload JSONB,
  p_order_payload JSONB,
  p_points_earned INT,
  p_points_redeemed INT,
  p_user_id UUID,
  p_store_id UUID
) RETURNS VOID AS $$
DECLARE
  v_order_id UUID;
  v_order_num TEXT;
BEGIN
  v_order_num := p_order_payload->>'order_number';

  -- A. IDEMPOTENCY CHECK
  IF EXISTS (SELECT 1 FROM public.customer_orders WHERE order_number = v_order_num AND user_id = p_user_id) THEN
    DELETE FROM public.customer_cart WHERE user_id = p_user_id;
    RETURN;
  END IF;

  -- B. Insert into customer_orders
  INSERT INTO public.customer_orders (
    user_id,
    order_number,
    status,
    subtotal,
    taxes,
    delivery_fee,
    shipping_address,
    payment_method,
    estimated_delivery,
    points_earned,
    points_redeemed,
    discount_amount,
    store_id
  ) VALUES (
    p_user_id,
    v_order_num,
    'placed',
    (p_order_payload->>'subtotal')::numeric,
    (p_order_payload->>'taxes')::numeric,
    (p_order_payload->>'delivery_fee')::numeric,
    COALESCE(p_order_payload->>'shipping_address', 'Selected Address'),
    COALESCE(p_order_payload->>'payment_method', 'Razorpay'),
    NULLIF(p_order_payload->>'estimated_delivery', '')::timestamptz,
    p_points_earned,
    p_points_redeemed,
    (p_order_payload->>'discount_amount')::numeric,
    p_store_id
  ) RETURNING id INTO v_order_id;

  -- C. Insert Individual Items into customer_order_items
  INSERT INTO public.customer_order_items (
    order_id,
    product_id,
    variant,
    quantity,
    price_at_purchase,
    product_name,
    product_image_url
  )
  SELECT
    v_order_id,
    (item->>'product_id')::uuid,
    item->>'variant',
    (item->>'quantity')::int,
    (item->>'price_at_purchase')::numeric,
    item->>'product_name',
    item->>'product_image_url'
  FROM jsonb_array_elements(p_items_payload) AS item;

  -- D. Update Customer Loyalty Points
  UPDATE public.customer_profiles
  SET loyalty_points = loyalty_points + p_points_earned - p_points_redeemed
  WHERE id = p_user_id;

  -- E. CLEAR Successful Cart
  DELETE FROM public.customer_cart
  WHERE user_id = p_user_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3. CRITICAL: FORCE SUPABASE TO REFRESH ITS CACHE
-- If you do not run this, Supabase will not "see" the function above!
NOTIFY pgrst, 'reload schema';


-- 4. FULLY FLEDGED STRUCTURED ADDRESS BOOK
DROP TABLE IF EXISTS public.customer_addresses CASCADE;

CREATE TABLE public.customer_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.customer_profiles(id) ON DELETE CASCADE,
    label TEXT DEFAULT 'Home', -- e.g. Home, Work, Office
    
    -- Structured Fields
    building_name TEXT,       -- House No, Building, Suite
    area_street TEXT,         -- Street, Area, Colony
    landmark TEXT,            -- Near X, Landmark
    city TEXT NOT NULL,
    state TEXT,
    pincode TEXT,
    country TEXT DEFAULT 'India',
    
    -- Cache for quick display
    full_address TEXT NOT NULL, 
    
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Enable RLS
ALTER TABLE public.customer_addresses ENABLE ROW LEVEL SECURITY;

-- Allow ALL operations for the Fixed Dev User (even if anon)
CREATE POLICY "Address Management Policy" 
ON public.customer_addresses FOR ALL 
USING (
    user_id = '00000000-0000-0000-0000-000000000000' 
    OR auth.uid() = user_id
);


-- 5. ORDER & APPOINTMENT POLICIES (Fix disappearing orders)
ALTER TABLE public.customer_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Orders Management Policy" ON public.customer_orders;
CREATE POLICY "Orders Management Policy" 
ON public.customer_orders FOR ALL 
USING (
    user_id = '00000000-0000-0000-0000-000000000000' 
    OR auth.uid() = user_id
);

DROP POLICY IF EXISTS "Items Visibility Policy" ON public.customer_order_items;
CREATE POLICY "Items Visibility Policy" 
ON public.customer_order_items FOR ALL 
USING (
    EXISTS (
        SELECT 1 FROM public.customer_orders 
        WHERE id = customer_order_items.order_id 
        AND (user_id = '00000000-0000-0000-0000-000000000000' OR user_id = auth.uid())
    )
);


-- 6. Ensure Dev User exists and has a default address
INSERT INTO public.customer_profiles (id, first_name, last_name, email, tier, loyalty_points)
VALUES ('00000000-0000-0000-0000-000000000000', 'Dev', 'User', 'dev@dior.com', 'platinum', 1850)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.customer_addresses (user_id, label, building_name, area_street, city, pincode, full_address, is_default)
VALUES (
    '00000000-0000-0000-0000-000000000000', 
    'Home', 
    'Suite 404', 
    'LUXE Towers, Bandra West', 
    'Mumbai', 
    '400050',
    'Suite 404, LUXE Towers, Bandra West, Mumbai, 400050',
    true
)
ON CONFLICT DO NOTHING;

-- Reload cache again to see everything fresh
NOTIFY pgrst, 'reload schema';

-- 7. Enforce strictly 3 statuses for customer_orders
ALTER TABLE public.customer_orders 
DROP CONSTRAINT IF EXISTS customer_orders_status_check;

ALTER TABLE public.customer_orders
ADD CONSTRAINT customer_orders_status_check 
CHECK (status IN ('placed', 'shipped', 'delivered'));
