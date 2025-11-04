# JLX Gemstone Database Documentation

## Overview
This database schema supports the JLX Gemstone admin panel for managing orders, partners, staff, and gemstone transactions.

## Database Schema

### Tables

#### 1. **partners**
Stores partner/client information
- `id` - Primary key
- `partner_code` - Unique partner identifier
- `partner_name` - Partner's full name
- `iso` - ISO certification number
- Timestamps for tracking

#### 2. **staff**
Stores employee information (sales persons, managers)
- `id` - Primary key
- `staff_name` - Employee name
- `role` - Employee role (sales_person, manager, other)
- `email` - Contact email
- `is_active` - Active status flag
- Timestamps for tracking

#### 3. **orders**
Main orders/receipts table
- `id` - Primary key
- `order_number` - Unique order identifier (e.g., ORD-2025-0001)
- `order_date` - Date of order
- `partner_id` - Foreign key to partners
- `sales_person_id` - Foreign key to staff (salesperson)
- `manager_id` - Foreign key to staff (manager)
- `payment_type` - Payment method
- `total_distribution_carat` - Total carats in order
- `external_employees` - Number of external employees
- `user_image_url` - Optional user/item image
- `status` - Order status (pending, processing, completed, cancelled)
- Timestamps for tracking

#### 4. **stones**
Catalog of available gemstones
- `id` - Primary key
- `stone_name` - Name of gemstone
- `description` - Optional description
- `is_active` - Active status flag
- Timestamps for tracking

#### 5. **order_items**
Individual stone line items for each order
- `id` - Primary key
- `order_id` - Foreign key to orders
- `stone_id` - Foreign key to stones
- `quantity_carat` - Quantity in carats
- `purchase_price` - Price paid per carat
- `market_selling_price` - Selling price per carat
- `profit_per_carat` - Calculated field (selling - purchase)
- `total_profit` - Calculated field (profit_per_carat × quantity)
- Timestamps for tracking

#### 6. **admin_users**
Admin panel user accounts
- `id` - Primary key
- `username` - Unique username
- `password_hash` - Bcrypt hashed password
- `full_name` - Full name
- `email` - Email address
- `role` - User role (super_admin, admin, viewer)
- `is_active` - Active status flag
- `last_login` - Last login timestamp
- Timestamps for tracking

#### 7. **audit_logs**
Audit trail for all changes
- `id` - Primary key
- `user_id` - Admin user who made the change
- `action` - Action performed (CREATE, UPDATE, DELETE)
- `table_name` - Affected table
- `record_id` - Affected record ID
- `old_values` - JSON of old values
- `new_values` - JSON of new values
- `ip_address` - User's IP address
- `created_at` - Timestamp

### Views

#### **order_details_view**
Complete order information joining all related tables for easy querying.

## Setup Instructions

### 1. Create Database
```sql
CREATE DATABASE jlx_gemstone;
USE jlx_gemstone;
```

### 2. Run Schema
```bash
mysql -u your_username -p jlx_gemstone < database/schema.sql
```

### 3. Load Sample Data (Optional)
```bash
mysql -u your_username -p jlx_gemstone < database/sample_data.sql
```

## Key Features

### Auto-Calculated Fields
- `profit_per_carat` - Automatically calculated in order_items
- `total_profit` - Automatically calculated in order_items

### Data Integrity
- Foreign key constraints prevent orphaned records
- CASCADE delete on order_items when order is deleted
- RESTRICT on critical relationships to prevent accidental deletions

### Indexes
- Optimized indexes on frequently queried columns
- Composite indexes for common query patterns

### Security
- Password hashing for admin users (use bcrypt)
- Audit logging for accountability
- Role-based access control

## Common Operations

### Create Order (from admin.html)
See `queries.sql` section 1 for the complete flow:
1. Insert/get partner
2. Insert/get staff members
3. Insert/get stone
4. Create order
5. Add order items

### Get Order for Receipt (order.html)
Use the query in section 2 to retrieve all order details for display.

### Dashboard Statistics
Use queries in sections 7-9 for analytics and reporting.

## Backend Integration Notes

When integrating with your backend (Node.js, Python, PHP, etc.):

1. **Use Transactions** - Wrap order creation in a transaction
2. **Validate Input** - Sanitize all user inputs
3. **Hash Passwords** - Use bcrypt for admin passwords
4. **Handle Images** - Store uploaded images in cloud storage (S3, Cloudinary) and save URLs in database
5. **API Authentication** - Use JWT tokens for API security
6. **Audit Everything** - Log all CREATE, UPDATE, DELETE operations

## Example Workflow

### Admin Creates Order:
1. Admin fills out form on `admin.html`
2. Frontend sends POST request to `/api/orders`
3. Backend validates data
4. Backend creates order in database (transaction)
5. Backend returns order_number
6. Frontend redirects to `order.html?order=ORD-2025-0001`

### Customer Tracks Order:
1. Customer visits `order.html`
2. Frontend loads order details from `/api/orders/{order_number}`
3. Display receipt with all details

## Database Maintenance

### Regular Tasks
```sql
-- Backup database
mysqldump -u root -p jlx_gemstone > backup_$(date +%Y%m%d).sql

-- Optimize tables
OPTIMIZE TABLE orders, order_items, partners, staff;

-- Archive old audit logs (older than 1 year)
DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

### Performance Monitoring
```sql
-- Check slow queries
SHOW FULL PROCESSLIST;

-- Analyze table usage
SHOW TABLE STATUS;
```

## Migration Strategy

When deploying to production:
1. Test schema on staging environment
2. Create backup of production database
3. Run migrations during low-traffic period
4. Verify data integrity
5. Test all critical operations
6. Monitor error logs

## Support

For questions or issues with the database schema, refer to the queries.sql file for common operations and examples.

