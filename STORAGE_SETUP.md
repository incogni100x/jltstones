# 📦 Storage Setup Guide

## Step 1: Create Storage Bucket in Supabase Dashboard

### Option A: Via Dashboard (Easiest)

1. Go to **Storage** in your Supabase Dashboard
2. Click **"New bucket"**
3. Settings:
   - **Name**: `order_images` (with underscore!)
   - **Public bucket**: ✅ YES (check this box)
   - **File size limit**: 5 MB (optional)
4. Click **"Create bucket"**

### Option B: Via SQL Editor

Run this SQL in **SQL Editor**:

```sql
-- Create storage bucket for order images
INSERT INTO storage.buckets (id, name, public)
VALUES ('order_images', 'order_images', true)
ON CONFLICT (id) DO NOTHING;
```

---

## Step 2: Set Up RLS Policies

Go to **SQL Editor** and run the entire `database/storage_setup.sql` file:

```sql
-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to upload
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'order_images');

-- Allow public reads
CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'order_images');

-- Allow authenticated updates
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'order_images')
WITH CHECK (bucket_id = 'order_images');

-- Allow authenticated deletes
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'order_images');
```

---

## Step 3: Verify Setup

### Check Bucket Exists:
1. Go to **Storage** → **order_images**
2. Should show empty bucket (ready for uploads)

### Check RLS Policies:
1. Go to **Storage** → **Policies**
2. Should see 4 policies for `order_images` bucket:
   - ✅ Allow authenticated uploads
   - ✅ Allow public reads
   - ✅ Allow authenticated updates
   - ✅ Allow authenticated deletes

---

## Step 4: Test Upload

1. Login to admin panel: `http://localhost:5173/admin-login.html`
2. Select an image file
3. Watch browser console:
   ```
   Starting upload... {fileName: "test.jpg", ...}
   Uploading to bucket: order_images, path: 1730000000-abc123.jpg
   Upload successful, data: {...}
   Public URL: https://...
   ```
4. Check Supabase **Storage** → **order_images** → Should see your file!

---

## Troubleshooting

### ❌ Error: "new row violates row-level security policy"
**Fix**: RLS policies not set up correctly. Re-run `storage_setup.sql`

### ❌ Error: "Bucket not found"
**Fix**: 
1. Check bucket name is `order_images` (with underscore)
2. Create bucket via dashboard or SQL

### ❌ Error: "Invalid JWT"
**Fix**: 
1. Make sure you're logged in to admin panel
2. Check `.env` has correct `VITE_SUPABASE_ANON_KEY`

### ❌ Files not uploading (no error)
**Fix**:
1. Open browser console (F12)
2. Check for errors
3. Verify session is active: `supabase.auth.getSession()`

---

## Your Storage URLs

- **Supabase URL**: `https://teutldrhbjmarupsqrix.supabase.co`
- **Storage Endpoint**: `https://teutldrhbjmarupsqrix.supabase.co/storage/v1`
- **Bucket**: `order_images`
- **Public URLs**: `https://teutldrhbjmarupsqrix.supabase.co/storage/v1/object/public/order_images/filename.jpg`

You **don't need to configure these URLs manually** - the Supabase client handles this automatically!

---

## Edge Function vs Frontend Upload

### 🔷 Edge Function (`create-order`)
- **Purpose**: Create order records in database
- **Does NOT handle**: Image uploads
- **URL**: `https://teutldrhbjmarupsqrix.supabase.co/functions/v1/create-order`

### 🔷 Frontend Upload (`orderService.js`)
- **Purpose**: Upload images to Storage
- **Uses**: Supabase JS client
- **When**: Immediately when user selects file

### Flow:
1. User selects image → **Frontend uploads to Storage** → Get URL
2. User fills form → Click Save → **Edge Function creates order** (with image URL)

---

## Storage Limits (Free Tier)

- **Storage**: 1 GB
- **Bandwidth**: 2 GB
- **File size**: 50 MB (default)

For production, consider upgrading or using a CDN.

