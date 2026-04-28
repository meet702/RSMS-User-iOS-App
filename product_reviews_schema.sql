-- 0. Ensure the products table has the necessary columns
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS rating NUMERIC(2,1) DEFAULT 0.0;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0;

-- SQL to create the product_reviews table
CREATE TABLE IF NOT EXISTS public.product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.product_reviews ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read reviews (Drop first to avoid "already exists" error)
DROP POLICY IF EXISTS "Allow public read access" ON public.product_reviews;
CREATE POLICY "Allow public read access" ON public.product_reviews
    FOR SELECT USING (true);

-- Allow authenticated users to insert reviews
DROP POLICY IF EXISTS "Allow authenticated insert" ON public.product_reviews;
CREATE POLICY "Allow authenticated insert" ON public.product_reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);
-- Function to update product rating and review count
CREATE OR REPLACE FUNCTION update_product_metrics()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.products
    SET 
        rating = (
            SELECT COALESCE(AVG(rating)::NUMERIC(2,1), 0.0)
            FROM public.product_reviews
            WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)
        ),
        review_count = (
            SELECT COUNT(*)
            FROM public.product_reviews
            WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)
        )
    WHERE id = COALESCE(NEW.product_id, OLD.product_id);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to run after insert, update, or delete on product_reviews
DROP TRIGGER IF EXISTS tr_update_product_metrics ON public.product_reviews;
CREATE TRIGGER tr_update_product_metrics
AFTER INSERT OR UPDATE OR DELETE ON public.product_reviews
FOR EACH ROW
EXECUTE FUNCTION update_product_metrics();

-- ONE-TIME UPDATE: Recalculate everything for existing products
UPDATE public.products p
SET 
    rating = (
        SELECT COALESCE(AVG(rating)::NUMERIC(2,1), 0.0)
        FROM public.product_reviews
        WHERE product_id = p.id
    ),
    review_count = (
        SELECT COUNT(*)
        FROM public.product_reviews
        WHERE product_id = p.id
    );
