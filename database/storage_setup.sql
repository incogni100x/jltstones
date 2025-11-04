-- Supabase Storage Setup for Order Images
-- Run this in your Supabase SQL Editor

-- STEP 1: Create storage bucket (or use Dashboard)
-- Dashboard > Storage > New Bucket > Name: order_images > Public: YES

INSERT INTO storage.buckets (id, name, public)
VALUES ('order_images', 'order_images', true)
ON CONFLICT (id) DO NOTHING;

-- NOTE: RLS is already enabled on storage.objects in Supabase by default
-- You cannot and should not run: ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY

-- STEP 2: Drop existing policies (if any)
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- STEP 3: Create RLS Policies for the bucket

-- Policy: Allow authenticated users to upload images
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'order_images');

-- Policy: Allow public read access to images
CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'order_images');

-- Policy: Allow authenticated users to update their uploads
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'order_images')
WITH CHECK (bucket_id = 'order_images');

-- Policy: Allow authenticated users to delete their uploads
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'order_images');

-- VERIFICATION:
-- After running this, check:
-- 1. Dashboard > Storage > Should see 'order_images' bucket
-- 2. Dashboard > Storage > Policies > Should see 4 policies for order_images
