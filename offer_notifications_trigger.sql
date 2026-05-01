-- SQL Script to automatically notify all users when a new offer is created
-- Run this in the Supabase SQL Editor

-- 1. Create the function that will be executed by the trigger
CREATE OR REPLACE FUNCTION notify_users_on_new_offer()
RETURNS trigger AS $$
BEGIN
  -- Insert a notification for every user in the customer_profiles table
  INSERT INTO notifications (user_id, title, message, icon)
  SELECT 
    id, 
    'Exclusive Offer: ' || NEW.name, 
    'Use code ' || COALESCE(NEW.coupon_code, NEW.name) || ' to get amazing discounts!', 
    'tag.fill'
  FROM customer_profiles;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Drop the trigger if it already exists (to allow safe re-running)
DROP TRIGGER IF EXISTS on_new_offer ON offers;

-- 3. Create the trigger to fire after any INSERT on the offers table
CREATE TRIGGER on_new_offer
  AFTER INSERT ON offers
  FOR EACH ROW
  EXECUTE FUNCTION notify_users_on_new_offer();

-- Optional: To test it, you can run an insert like this:
-- INSERT INTO offers (name, discount_type, discount_value, coupon_code) VALUES ('Summer Sale', 'percentage', 20, 'SUMMER20');
