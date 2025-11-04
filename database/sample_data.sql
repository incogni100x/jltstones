-- Sample Data for JLX Gemstone Database

-- Insert Sample Orders
INSERT INTO orders (
    order_number,
    order_date,
    user_image_url,
    partner_code,
    partner_name,
    iso,
    sales_person,
    manager,
    payment_type,
    distribution_carat,
    external_employees,
    stone_name,
    quantity_carat,
    purchase_price,
    market_selling_price
) VALUES
(
    'ORD-2025-0001',
    '2025-02-13',
    NULL,
    '0562789341',
    'Walter Phillips',
    '516807:2025',
    'Lawrence Andre',
    'Sarah Alexandre',
    'BANK TRANSFER',
    12050.00,
    132,
    'Grandidierite',
    12050.00,
    19690.00,
    21500.00
),
(
    'ORD-2025-0002',
    '2025-02-14',
    NULL,
    '0562789342',
    'John Anderson',
    '516808:2025',
    'Michael Torres',
    'Emily Chen',
    'WIRE TRANSFER',
    8500.50,
    98,
    'Painite',
    8500.50,
    25000.00,
    27500.00
),
(
    'ORD-2025-0003',
    '2025-02-15',
    NULL,
    '0562789343',
    'Maria Garcia',
    '516809:2025',
    'Lawrence Andre',
    'Sarah Alexandre',
    'CASH',
    15000.00,
    150,
    'Red Beryl',
    15000.00,
    18000.00,
    20000.00
);

-- Insert Sample Admin Profile (password: 'admin123' - should be properly hashed in production)
-- Use bcrypt to hash: $2b$10$rBV2KVc7qZfE8.hZxGr4AuYnX.jBk5YVK5qPxR5BqXYZ9Qm5Y6Zy2
INSERT INTO profiles (username, password_hash, full_name, email) VALUES
('admin', '$2b$10$rBV2KVc7qZfE8.hZxGr4AuYnX.jBk5YVK5qPxR5BqXYZ9Qm5Y6Zy2', 'Admin User', 'admin@jlxgems.com');

