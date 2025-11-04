# Create Order Edge Function

This Edge Function handles order creation with backend validation and security.

## Setup

### 1. Install Supabase CLI
```bash
npm install -g supabase
```

### 2. Login to Supabase
```bash
supabase login
```

### 3. Link to your project
```bash
supabase link --project-ref your-project-ref
```

### 4. Deploy the function
```bash
supabase functions deploy create-order
```

### 5. Set environment variables (if needed)
```bash
supabase secrets set MY_SECRET=value
```

## Usage

### From Frontend (using orderService.js)

```javascript
import { createOrderViaEdgeFunction } from './orderService.js';

const formData = {
  order_date: '2025-02-13',
  partner_name: 'Walter Phillips',
  partner_code: 'JLX123456', // Optional, will be generated if not provided
  iso: '516807:2025',
  sales_person: 'Lawrence Andre',
  manager: 'Sarah Alexandre',
  payment_type: 'BANK TRANSFER',
  distribution_carat: 12050.00,
  external_employees: 132,
  stone_name: 'Grandidierite',
  quantity_carat: 12050.00,
  purchase_price: 19690.00,
  market_selling_price: 21500.00,
  user_image_url: 'https://...' // Optional
};

const result = await createOrderViaEdgeFunction(formData);

if (result.success) {
  console.log('Order created:', result.order);
} else {
  console.error('Error:', result.error);
}
```

## Features

- ✅ Authentication verification
- ✅ Input validation
- ✅ Auto-generate partner code (JLX + 6 digits)
- ✅ Auto-generate order number (ORD-YYYY-XXXX)
- ✅ CORS headers for frontend access
- ✅ Error handling
- ✅ Row Level Security (RLS) compatible

## API Endpoint

```
POST https://your-project.supabase.co/functions/v1/create-order
```

### Headers
```
Authorization: Bearer <session_token>
Content-Type: application/json
```

### Request Body
```json
{
  "order_date": "2025-02-13",
  "partner_name": "Walter Phillips",
  "sales_person": "Lawrence Andre",
  ...
}
```

### Response
```json
{
  "success": true,
  "order": {
    "id": 1,
    "order_number": "ORD-2025-5432",
    "partner_code": "JLX123456",
    ...
  },
  "message": "Order created successfully"
}
```

## Testing

Test the function locally:
```bash
supabase functions serve create-order
```

Then call it:
```bash
curl -i --location --request POST 'http://localhost:54321/functions/v1/create-order' \
  --header 'Authorization: Bearer YOUR_TOKEN' \
  --header 'Content-Type: application/json' \
  --data '{"order_date":"2025-02-13","partner_name":"Test",...}'
```

## Monitoring

View logs:
```bash
supabase functions logs create-order
```

## Security

- Requires authentication (JWT token)
- Validates all required fields
- Uses RLS policies from database schema
- CORS enabled for your frontend domain

