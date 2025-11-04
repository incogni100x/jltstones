-- ==============================================================
-- COMPLETE DATABASE SETUP FOR JLX GEMSTONE
-- Run this entire file in Supabase SQL Editor
-- ==============================================================

-- ==============================================================
-- PART 1: STORAGE BUCKET SETUP
-- ==============================================================

-- Create storage bucket for order images
INSERT INTO storage.buckets (id, name, public)
VALUES ('order_images', 'order_images', true)
ON CONFLICT (id) DO NOTHING;

-- NOTE: RLS is already enabled on storage.objects in Supabase
-- No need to ALTER TABLE storage.objects

-- Drop existing policies if they exist (cleanup)
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- Create storage policies
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'order_images');

CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'order_images');

CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'order_images')
WITH CHECK (bucket_id = 'order_images');

CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'order_images');

-- ==============================================================
-- PART 2: ORDERS TABLE
-- ==============================================================

-- Drop table if exists (for clean setup)
DROP TABLE IF EXISTS public.orders CASCADE;

CREATE TABLE public.orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Basic Information
    order_date DATE NOT NULL,
    user_image_url TEXT,
    
    -- Partner Information
    partner_code VARCHAR(50) NOT NULL,
    partner_name VARCHAR(255) NOT NULL,
    iso VARCHAR(50),
    
    -- Staff Information
    sales_person VARCHAR(255) NOT NULL,
    manager VARCHAR(255) NOT NULL,
    
    -- Payment & Distribution
    payment_type VARCHAR(50) NOT NULL,
    distribution_carat NUMERIC(12, 2) NOT NULL,
    external_employees INTEGER NOT NULL,
    
    -- Stone Details
    stone_name VARCHAR(255) NOT NULL,
    quantity_carat NUMERIC(12, 2) NOT NULL,
    purchase_price NUMERIC(12, 2) NOT NULL,
    market_selling_price NUMERIC(12, 2) NOT NULL,
    profit_per_carat NUMERIC(12, 2) GENERATED ALWAYS AS (market_selling_price - purchase_price) STORED,
    total_profit NUMERIC(15, 2) GENERATED ALWAYS AS ((market_selling_price - purchase_price) * quantity_carat) STORED,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_orders_order_number ON public.orders(order_number);
CREATE INDEX idx_orders_order_date ON public.orders(order_date);
CREATE INDEX idx_orders_partner_code ON public.orders(partner_code);
CREATE INDEX idx_orders_partner_name ON public.orders(partner_name);

-- Enable RLS on orders table
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- RLS Policies for orders table
DROP POLICY IF EXISTS "Allow authenticated users to insert orders" ON public.orders;
DROP POLICY IF EXISTS "Allow authenticated users to read orders" ON public.orders;
DROP POLICY IF EXISTS "Allow authenticated users to update orders" ON public.orders;
DROP POLICY IF EXISTS "Allow authenticated users to delete orders" ON public.orders;

CREATE POLICY "Allow authenticated users to insert orders"
ON public.orders FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated users to read orders"
ON public.orders FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated users to update orders"
ON public.orders FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated users to delete orders"
ON public.orders FOR DELETE
TO authenticated
USING (true);

-- ==============================================================
-- PART 3: PROFILES TABLE
-- ==============================================================

-- Drop table if exists
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

CREATE POLICY "Users can view their own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- ==============================================================
-- PART 4: TRIGGERS & FUNCTIONS
-- ==============================================================

-- Function to update updated_at timestamp
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for orders table
DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to create profile for new user
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- ==============================================================
-- SETUP COMPLETE!
-- ==============================================================
-- 
-- Next steps:
-- 1. Verify bucket exists: Dashboard > Storage > order_images
-- 2. Verify tables: Dashboard > Table Editor > orders, profiles
-- 3. Create admin user: Dashboard > Authentication > Users > Add User
-- 4. Test upload from admin panel
-- ==============================================================

