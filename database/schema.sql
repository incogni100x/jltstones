-- JLX Gemstone Database Schema for Supabase (PostgreSQL)
-- Simple schema matching admin.html form - all order data in one table

-- Orders Table (All order information from admin.html form)
CREATE TABLE orders (
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
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_partner_code ON orders(partner_code);
CREATE INDEX idx_orders_partner_name ON orders(partner_name);

-- Admin Profiles Table (for authentication)
CREATE TABLE profiles (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(255),
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for username lookup
CREATE INDEX idx_profiles_username ON profiles(username);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for orders table
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for profiles table
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS) for Supabase
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for orders (authenticated users can do everything)
CREATE POLICY "Enable all access for authenticated users on orders"
    ON orders
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Create policies for profiles (authenticated users can read their own profile)
CREATE POLICY "Enable read access for own profile"
    ON profiles
    FOR SELECT
    TO authenticated
    USING (auth.uid()::text = id::text);

CREATE POLICY "Enable update access for own profile"
    ON profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid()::text = id::text)
    WITH CHECK (auth.uid()::text = id::text);

