-- Trigger to automatically calculate total_amount for orders
CREATE OR REPLACE FUNCTION calculate_order_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Formula: total = subtotal + taxes + delivery_fee - discount_amount
    NEW.total_amount := NEW.subtotal + NEW.taxes + NEW.delivery_fee - COALESCE(NEW.discount_amount, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists to avoid errors
DROP TRIGGER IF EXISTS tr_calculate_order_total ON public.customer_orders;

-- Create trigger to run before insert or update
CREATE TRIGGER tr_calculate_order_total
BEFORE INSERT OR UPDATE ON public.customer_orders
FOR EACH ROW
EXECUTE FUNCTION calculate_order_total();

-- Optional: Fix existing orders that have 0 total_amount
UPDATE public.customer_orders
SET total_amount = subtotal + taxes + delivery_fee - COALESCE(discount_amount, 0)
WHERE total_amount = 0;
