# API Endpoints for JLX Gemstone Admin Panel

This document outlines the REST API endpoints needed to connect `admin.html` and `order.html` to a backend database.

## Base URL
```
Production: https://api.jlxgemstone.com/v1
Development: http://localhost:3001/api/v1
```

## Authentication

All endpoints (except public order tracking) require JWT authentication.

```http
Authorization: Bearer <jwt_token>
```

---

## Authentication Endpoints

### POST /auth/login
Login to admin panel

**Request:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "full_name": "Admin User",
      "role": "super_admin"
    }
  }
}
```

### POST /auth/logout
Logout from admin panel

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### GET /auth/verify
Verify JWT token validity

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "username": "admin",
    "role": "super_admin"
  }
}
```

---

## Orders Endpoints

### GET /orders
Get all orders (paginated)

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `status` (optional: pending, processing, completed, cancelled)
- `partner_name` (optional: search by partner)
- `date_from` (optional: YYYY-MM-DD)
- `date_to` (optional: YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": 1,
        "order_number": "ORD-2025-0001",
        "order_date": "2025-02-13",
        "partner_name": "Walter Phillips",
        "payment_type": "BANK TRANSFER",
        "total_distribution_carat": 12050.00,
        "total_profit": 21810500.00,
        "status": "completed",
        "created_at": "2025-02-13T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

### GET /orders/:order_number
Get specific order details (for order.html receipt)

**Response:**
```json
{
  "success": true,
  "data": {
    "order_number": "ORD-2025-0001",
    "order_date": "2025-02-13",
    "partner": {
      "code": "0562789341",
      "name": "Walter Phillips",
      "iso": "516807:2025"
    },
    "staff": {
      "sales_person": "Lawrence Andre",
      "manager": "Sarah Alexandre"
    },
    "payment": {
      "type": "BANK TRANSFER",
      "distribution_carat": 12050.00,
      "external_employees": 132
    },
    "items": [
      {
        "stone_name": "Grandidierite",
        "quantity_carat": 12050.00,
        "purchase_price": 19690.00,
        "market_selling_price": 21500.00,
        "profit_per_carat": 1810.00,
        "total_profit": 21810500.00
      }
    ],
    "user_image_url": "https://cdn.jlxgemstone.com/uploads/order-image-123.jpg",
    "status": "completed"
  }
}
```

### POST /orders
Create new order (from admin.html form)

**Request:**
```json
{
  "order_date": "2025-02-13",
  "partner": {
    "code": "0562789341",
    "name": "Walter Phillips",
    "iso": "516807:2025"
  },
  "staff": {
    "sales_person": "Lawrence Andre",
    "manager": "Sarah Alexandre"
  },
  "payment": {
    "type": "BANK TRANSFER",
    "distribution_carat": 12050.00,
    "external_employees": 132
  },
  "items": [
    {
      "stone_name": "Grandidierite",
      "quantity_carat": 12050.00,
      "purchase_price": 19690.00,
      "market_selling_price": 21500.00
    }
  ],
  "user_image": "base64_encoded_image_or_url"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "order_number": "ORD-2025-0001",
    "id": 1,
    "message": "Order created successfully"
  }
}
```

### PUT /orders/:order_number
Update existing order

**Request:** Same as POST /orders

**Response:**
```json
{
  "success": true,
  "message": "Order updated successfully"
}
```

### DELETE /orders/:order_number
Delete order

**Response:**
```json
{
  "success": true,
  "message": "Order deleted successfully"
}
```

---

## Partners Endpoints

### GET /partners
Get all partners

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "partner_code": "0562789341",
      "partner_name": "Walter Phillips",
      "iso": "516807:2025"
    }
  ]
}
```

### GET /partners/search?q=Phillips
Search partners by name or code

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "partner_code": "0562789341",
      "partner_name": "Walter Phillips"
    }
  ]
}
```

---

## Staff Endpoints

### GET /staff
Get all staff members

**Query Parameters:**
- `role` (optional: sales_person, manager)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "staff_name": "Lawrence Andre",
      "role": "sales_person",
      "is_active": true
    }
  ]
}
```

---

## Stones Endpoints

### GET /stones
Get all available stones

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "stone_name": "Grandidierite",
      "description": "Rare blue-green gemstone",
      "is_active": true
    }
  ]
}
```

### GET /stones/search?q=Grand
Search stones by name

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "stone_name": "Grandidierite"
    }
  ]
}
```

---

## Statistics Endpoints

### GET /statistics/dashboard
Get dashboard statistics

**Response:**
```json
{
  "success": true,
  "data": {
    "total_orders": 150,
    "total_profit": 45000000.00,
    "total_carats": 50000.00,
    "unique_partners": 35,
    "orders_this_month": 12,
    "profit_this_month": 3500000.00
  }
}
```

### GET /statistics/top-partners
Get top partners by profit

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "partner_name": "Walter Phillips",
      "total_orders": 25,
      "total_profit": 12500000.00
    }
  ]
}
```

### GET /statistics/top-stones
Get most popular stones

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "stone_name": "Grandidierite",
      "times_sold": 45,
      "total_carats": 150000.00,
      "total_profit": 25000000.00
    }
  ]
}
```

---

## File Upload Endpoint

### POST /upload/image
Upload user/item image

**Request:**
- Content-Type: multipart/form-data
- Field: `image`

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.jlxgemstone.com/uploads/image-123.jpg",
    "filename": "image-123.jpg"
  }
}
```

---

## Error Responses

All endpoints follow this error format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "partner_code",
      "issue": "Partner code is required"
    }
  }
}
```

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error

---

## Frontend Integration Examples

### JavaScript (Fetch API)

```javascript
// Login
async function login(username, password) {
  const response = await fetch('/api/v1/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });
  const data = await response.json();
  if (data.success) {
    localStorage.setItem('token', data.data.token);
  }
  return data;
}

// Create Order
async function createOrder(orderData) {
  const token = localStorage.getItem('token');
  const response = await fetch('/api/v1/orders', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(orderData)
  });
  return await response.json();
}

// Get Order Details
async function getOrder(orderNumber) {
  const response = await fetch(`/api/v1/orders/${orderNumber}`);
  return await response.json();
}
```

---

## Rate Limiting

All endpoints are rate-limited:
- **Authentication:** 5 requests per minute
- **Read Operations:** 100 requests per minute
- **Write Operations:** 30 requests per minute

---

## CORS Configuration

For development, configure CORS to allow requests from:
```
http://localhost:3000
http://localhost:5173 (Vite dev server)
```

For production:
```
https://jlxgemstone.com
https://www.jlxgemstone.com
```

