// Order Service - Handle order creation
import { supabase } from './client.js';
import { generatePartnerCode, generateOrderNumber } from './generateOrderCode.js';

/**
 * OPTION 1: Direct Database Insert (Simple approach)
 * Uses Supabase client directly from frontend
 */
export async function createOrderDirect(formData) {
  try {
    // Generate codes if not provided
    if (!formData.partner_code) {
      formData.partner_code = generatePartnerCode();
    }
    formData.order_number = generateOrderNumber();

    // Insert into database
    const { data, error } = await supabase
      .from('orders')
      .insert([formData])
      .select()
      .single();

    if (error) throw error;

    return { success: true, order: data };
  } catch (error) {
    console.error('Error creating order:', error);
    return { success: false, error: error.message };
  }
}

/**
 * OPTION 2: Via Edge Function (Recommended for production)
 * More secure, backend validation
 */
export async function createOrderViaEdgeFunction(formData) {
  try {
    // Get current session token
    const { data: { session } } = await supabase.auth.getSession();
    
    if (!session) {
      throw new Error('Not authenticated');
    }

    // Call Edge Function
    const edgeFunctionUrl = 'https://teutldrhbjmarupsqrix.supabase.co/functions/v1/create-order';
    
    const response = await fetch(edgeFunctionUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(formData),
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.error || 'Failed to create order');
    }

    return result;
  } catch (error) {
    console.error('Error creating order:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Upload image to Supabase Storage
 */
export async function uploadOrderImage(file) {
  try {
    console.log('Starting upload...', {
      fileName: file.name,
      fileSize: file.size,
      fileType: file.type
    });

    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;
    const filePath = `${fileName}`;

    console.log('Uploading to bucket: order_images, path:', filePath);

    const { data, error } = await supabase.storage
      .from('order_images')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false
      });

    if (error) {
      console.error('Upload error:', error);
      throw error;
    }

    console.log('Upload successful, data:', data);

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('order_images')
      .getPublicUrl(filePath);

    console.log('Public URL:', publicUrl);

    return { success: true, url: publicUrl, path: data.path };
  } catch (error) {
    console.error('Error uploading image:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Get all orders (for admin dashboard listing)
 */
export async function getOrders(limit = 20, offset = 0) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return { success: true, orders: data };
  } catch (error) {
    console.error('Error fetching orders:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Get single order by order number
 */
export async function getOrderByNumber(orderNumber) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('order_number', orderNumber)
      .single();

    if (error) throw error;

    return { success: true, order: data };
  } catch (error) {
    console.error('Error fetching order:', error);
    return { success: false, error: error.message };
  }
}

