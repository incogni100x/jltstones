-- Common SQL Queries for JLX Gemstone Admin Panel

-- ==============================================
-- 1. CREATE NEW ORDER (from admin.html form)
-- ==============================================

-- Step 1: Insert or get partner
INSERT INTO partners (partner_code, partner_name, iso) 
VALUES ('0562789341', 'Walter Phillips', '516807:2025')
ON DUPLICATE KEY UPDATE 
    partner_name = VALUES(partner_name),
    iso = VALUES(iso);

SET @partner_id = LAST_INSERT_ID();

-- Step 2: Insert or get sales person
INSERT INTO staff (staff_name, role) 
VALUES ('Lawrence Andre', 'sales_person')
ON DUPLICATE KEY UPDATE staff_name = staff_name;

SET @sales_person_id = LAST_INSERT_ID();

-- Step 3: Insert or get manager
INSERT INTO staff (staff_name, role) 
VALUES ('Sarah Alexandre', 'manager')
ON DUPLICATE KEY UPDATE staff_name = staff_name;

SET @manager_id = LAST_INSERT_ID();

-- Step 4: Insert or get stone
INSERT INTO stones (stone_name) 
VALUES ('Grandidierite')
ON DUPLICATE KEY UPDATE stone_name = stone_name;

SET @stone_id = LAST_INSERT_ID();

-- Step 5: Create order
INSERT INTO orders (
    order_number,
    order_date,
    partner_id,
    sales_person_id,
    manager_id,
    payment_type,
    total_distribution_carat,
    external_employees,
    user_image_url,
    status
) VALUES (
    CONCAT('ORD-', YEAR(CURDATE()), '-', LPAD((SELECT COUNT(*) + 1 FROM orders o WHERE YEAR(o.order_date) = YEAR(CURDATE())), 4, '0')),
    '2025-02-13',
    @partner_id,
    @sales_person_id,
    @manager_id,
    'BANK TRANSFER',
    12050.00,
    132,
    NULL,
    'pending'
);

SET @order_id = LAST_INSERT_ID();

-- Step 6: Add order items
INSERT INTO order_items (
    order_id,
    stone_id,
    quantity_carat,
    purchase_price,
    market_selling_price
) VALUES (
    @order_id,
    @stone_id,
    12050.00,
    19690.00,
    21500.00
);

-- ==============================================
-- 2. GET ORDER DETAILS FOR RECEIPT (order.html)
-- ==============================================

SELECT 
    o.order_number,
    o.order_date,
    p.partner_code,
    p.partner_name,
    p.iso,
    sp.staff_name AS sales_person,
    m.staff_name AS manager,
    o.payment_type,
    o.total_distribution_carat,
    o.external_employees,
    o.user_image_url,
    s.stone_name,
    oi.quantity_carat,
    oi.purchase_price,
    oi.market_selling_price,
    oi.profit_per_carat,
    oi.total_profit
FROM orders o
JOIN partners p ON o.partner_id = p.id
JOIN staff sp ON o.sales_person_id = sp.id
JOIN staff m ON o.manager_id = m.id
JOIN order_items oi ON o.id = oi.order_id
JOIN stones s ON oi.stone_id = s.id
WHERE o.order_number = 'ORD-2025-0001';

-- ==============================================
-- 3. GET ALL ORDERS (for admin dashboard listing)
-- ==============================================

SELECT 
    o.id,
    o.order_number,
    o.order_date,
    p.partner_name,
    o.payment_type,
    o.total_distribution_carat,
    o.status,
    SUM(oi.total_profit) AS total_order_profit,
    o.created_at
FROM orders o
JOIN partners p ON o.partner_id = p.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id
ORDER BY o.order_date DESC, o.created_at DESC
LIMIT 50;

-- ==============================================
-- 4. UPDATE ORDER
-- ==============================================

UPDATE orders 
SET 
    order_date = '2025-02-13',
    payment_type = 'WIRE TRANSFER',
    total_distribution_carat = 12050.00,
    external_employees = 132,
    status = 'completed',
    updated_at = CURRENT_TIMESTAMP
WHERE order_number = 'ORD-2025-0001';

-- Update order items
UPDATE order_items 
SET 
    quantity_carat = 12050.00,
    purchase_price = 19690.00,
    market_selling_price = 21500.00
WHERE order_id = (SELECT id FROM orders WHERE order_number = 'ORD-2025-0001');

-- ==============================================
-- 5. DELETE ORDER
-- ==============================================

-- Order items will be deleted automatically due to CASCADE
DELETE FROM orders WHERE order_number = 'ORD-2025-0001';

-- ==============================================
-- 6. SEARCH ORDERS BY PARTNER NAME
-- ==============================================

SELECT 
    o.order_number,
    o.order_date,
    p.partner_name,
    o.status,
    SUM(oi.total_profit) AS total_profit
FROM orders o
JOIN partners p ON o.partner_id = p.id
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE p.partner_name LIKE '%Phillips%'
GROUP BY o.id
ORDER BY o.order_date DESC;

-- ==============================================
-- 7. GET ORDER STATISTICS
-- ==============================================

SELECT 
    COUNT(*) AS total_orders,
    SUM(o.total_distribution_carat) AS total_carats,
    SUM(oi.total_profit) AS total_profit,
    AVG(oi.total_profit) AS avg_profit_per_order,
    COUNT(DISTINCT o.partner_id) AS unique_partners
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.status = 'completed'
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- ==============================================
-- 8. GET TOP PARTNERS BY PROFIT
-- ==============================================

SELECT 
    p.partner_name,
    p.partner_code,
    COUNT(o.id) AS total_orders,
    SUM(oi.total_profit) AS total_profit
FROM partners p
JOIN orders o ON p.id = o.partner_id
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.status = 'completed'
GROUP BY p.id
ORDER BY total_profit DESC
LIMIT 10;

-- ==============================================
-- 9. GET MOST POPULAR STONES
-- ==============================================

SELECT 
    s.stone_name,
    COUNT(oi.id) AS times_sold,
    SUM(oi.quantity_carat) AS total_carats_sold,
    SUM(oi.total_profit) AS total_profit
FROM stones s
JOIN order_items oi ON s.id = oi.stone_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'completed'
GROUP BY s.id
ORDER BY times_sold DESC, total_profit DESC
LIMIT 10;

-- ==============================================
-- 10. AUTHENTICATE ADMIN USER
-- ==============================================

SELECT 
    id,
    username,
    full_name,
    email,
    role,
    password_hash
FROM admin_users
WHERE username = 'admin' 
    AND is_active = TRUE;

-- Update last login after successful authentication
UPDATE admin_users 
SET last_login = CURRENT_TIMESTAMP 
WHERE id = 1;

-- ==============================================
-- 11. LOG AUDIT ENTRY
-- ==============================================

INSERT INTO audit_logs (
    user_id,
    action,
    table_name,
    record_id,
    new_values,
    ip_address
) VALUES (
    1,
    'CREATE',
    'orders',
    @order_id,
    JSON_OBJECT(
        'order_number', 'ORD-2025-0001',
        'partner_id', @partner_id,
        'total_distribution_carat', 12050.00
    ),
    '192.168.1.100'
);

