// Track Order functionality
import { supabase } from './client.js';

// Edge Function URL
const EDGE_FUNCTION_URL = 'https://teutldrhbjmarupsqrix.supabase.co/functions/v1/get-order';

// Open modal
window.openTrackOrderModal = function() {
  const modal = document.getElementById('track-order-modal');
  const input = document.getElementById('partner-code-input');
  const error = document.getElementById('track-order-error');
  
  // Reset form
  input.value = '';
  error.classList.add('hidden');
  
  // Show modal
  modal.classList.remove('hidden');
  
  // Focus input
  setTimeout(() => input.focus(), 100);
}

// Close modal
window.closeTrackOrderModal = function() {
  const modal = document.getElementById('track-order-modal');
  modal.classList.add('hidden');
}

// Close modal on backdrop click
document.addEventListener('click', (e) => {
  const modal = document.getElementById('track-order-modal');
  if (e.target === modal) {
    closeTrackOrderModal();
  }
});

// Handle form submission
document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('track-order-form');
  
  if (form) {
    form.addEventListener('submit', handleTrackOrder);
  }
});

async function handleTrackOrder(e) {
  e.preventDefault();
  
  const input = document.getElementById('partner-code-input');
  const submitBtn = document.getElementById('track-order-submit');
  const error = document.getElementById('track-order-error');
  const originalText = submitBtn.textContent;
  
  const partnerCode = input.value.trim();
  
  if (!partnerCode) {
    error.textContent = 'Please enter a partner code';
    error.classList.remove('hidden');
    return;
  }
  
  try {
    // Disable button and show loading
    submitBtn.disabled = true;
    submitBtn.textContent = 'Searching...';
    error.classList.add('hidden');
    
    console.log('Tracking order with partner code:', partnerCode);
    
    // Call Edge Function to get order
    const { data: { session } } = await supabase.auth.getSession();
    
    const response = await fetch(
      `${EDGE_FUNCTION_URL}?partner_code=${encodeURIComponent(partnerCode)}`,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'apikey': import.meta.env.VITE_SUPABASE_ANON_KEY,
        },
      }
    );
    
    const result = await response.json();
    
    console.log('Track order result:', result);
    
    if (result.success && result.order) {
      // Store order data in sessionStorage
      sessionStorage.setItem('trackedOrder', JSON.stringify(result.order));
      
      // Redirect to order page
      window.location.href = 'order.html';
    } else {
      // Show error
      error.textContent = result.message || 'Order not found. Please check your partner code and try again.';
      error.classList.remove('hidden');
      submitBtn.disabled = false;
      submitBtn.textContent = originalText;
    }
    
  } catch (err) {
    console.error('Error tracking order:', err);
    error.textContent = 'An error occurred. Please try again.';
    error.classList.remove('hidden');
    submitBtn.disabled = false;
    submitBtn.textContent = originalText;
  }
}

