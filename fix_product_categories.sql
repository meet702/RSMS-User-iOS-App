-- Add foreign key constraint between products and categories
ALTER TABLE public.products
ADD CONSTRAINT products_category_id_fkey 
FOREIGN KEY (category_id) REFERENCES public.categories(id)
ON DELETE SET NULL;

-- Reload Supabase Schema Cache
NOTIFY pgrst, 'reload schema';
