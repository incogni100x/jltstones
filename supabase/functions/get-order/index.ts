// Supabase Edge Function to get order by partner code
// Deploy: supabase functions deploy get-order

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get partner code from query params or body
    let partnerCode: string | null = null;
    
    if (req.method === 'GET') {
      const url = new URL(req.url);
      partnerCode = url.searchParams.get('partner_code');
    } else if (req.method === 'POST') {
      const body = await req.json();
      partnerCode = body.partner_code;
    }

    if (!partnerCode) {
      return new Response(
        JSON.stringify({ error: 'Partner code is required' }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    // Query order by partner code
    const { data, error } = await supabaseClient
      .from('orders')
      .select('*')
      .eq('partner_code', partnerCode)
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    if (error) {
      // Check if it's a "not found" error
      if (error.code === 'PGRST116') {
        return new Response(
          JSON.stringify({ 
            error: 'Order not found',
            message: 'No order found with this partner code. Please check and try again.'
          }),
          { 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 404 
          }
        )
      }
      
      console.error('Database error:', error);
      return new Response(
        JSON.stringify({ error: error.message }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    if (!data) {
      return new Response(
        JSON.stringify({ 
          error: 'Order not found',
          message: 'No order found with this partner code. Please check and try again.'
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 404 
        }
      )
    }

    // Return success response
    return new Response(
      JSON.stringify({ 
        success: true, 
        order: data
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})

