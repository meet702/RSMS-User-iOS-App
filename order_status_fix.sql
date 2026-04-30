-- Fix the customer_orders status constraint to allow 'cancelled'
-- and ensure any 'Cancelled' orders move to past orders correctly.

-- 1. Drop the old constraint
ALTER TABLE public.customer_orders 
DROP CONSTRAINT IF EXISTS customer_orders_status_check;

-- 2. Add the new constraint with 'cancelled' included
ALTER TABLE public.customer_orders 
ADD CONSTRAINT customer_orders_status_check 
CHECK (status = ANY (ARRAY['placed'::text, 'shipped'::text, 'delivered'::text, 'cancelled'::text]));

-- 3. Standardize any existing 'Order Placed' or other variations to simple 'placed' or 'cancelled'
-- to ensure the app's isActive logic works perfectly.
UPDATE public.customer_orders SET status = 'placed' WHERE status = 'Order Placed';
UPDATE public.customer_orders SET status = 'cancelled' WHERE status = 'Cancelled';
UPDATE public.customer_orders SET status = 'shipped' WHERE status = 'Shipped';
UPDATE public.customer_orders SET status = 'delivered' WHERE status = 'Delivered';
