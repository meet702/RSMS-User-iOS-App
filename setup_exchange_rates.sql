-- Create exchange_rates table
CREATE TABLE IF NOT EXISTS public.exchange_rates (
    currency_code text PRIMARY KEY,
    rate numeric NOT NULL, -- Rate relative to 1 INR. e.g. 1 INR = 0.012 USD
    symbol text NOT NULL,
    locale_id text NOT NULL
);

-- Enable RLS
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access
CREATE POLICY "Allow public read access to exchange_rates" ON public.exchange_rates FOR SELECT USING (true);

-- Insert seed data
INSERT INTO public.exchange_rates (currency_code, rate, symbol, locale_id) VALUES
('INR', 1.0, '₹', 'en_IN'),
('USD', 0.012, '$', 'en_US'),
('EUR', 0.011, '€', 'fr_FR'),
('GBP', 0.0095, '£', 'en_GB'),
('JPY', 1.8, '¥', 'ja_JP'),
('CNY', 0.086, '¥', 'zh_CN'),
('KRW', 16.5, '₩', 'ko_KR')
ON CONFLICT (currency_code) DO UPDATE 
SET rate = EXCLUDED.rate, symbol = EXCLUDED.symbol, locale_id = EXCLUDED.locale_id;
