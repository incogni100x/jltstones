// Admin form handler - connects admin.html form to database
import { createOrderDirect, createOrderViaEdgeFunction, uploadOrderImage } from './orderService.js';
import { generatePartnerCode } from './generateOrderCode.js';

// Initialize form
document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('admin-form');
  const partnerCodeInput = document.getElementById('partner-code');
  const generateCodeBtn = document.getElementById('generate-code-btn');
  const imageInput = document.getElementById('user-image');
  
  // Auto-generate partner code button
  if (generateCodeBtn) {
    generateCodeBtn.addEventListener('click', (e) => {
      e.preventDefault();
      partnerCodeInput.value = generatePartnerCode();
    });
  }
  
  // Auto-generate on page load if empty
  if (partnerCodeInput && !partnerCodeInput.value) {
    partnerCodeInput.value = generatePartnerCode();
  }
  
  // Handle instant image upload
  if (imageInput) {
    imageInput.addEventListener('change', handleImageUpload);
  }
  
  // Form submission
  if (form) {
    form.addEventListener('submit', handleFormSubmit);
  }
});

// Handle instant image upload when file is selected
async function handleImageUpload(e) {
  const file = e.target.files[0];
  if (!file) return;
  
  const uploadingDiv = document.getElementById('image-uploading');
  const previewDiv = document.getElementById('image-preview');
  const previewImg = document.getElementById('preview-img');
  const uploadedUrlInput = document.getElementById('uploaded-image-url');
  
  try {
    // Show uploading state
    uploadingDiv.classList.remove('hidden');
    previewDiv.classList.add('hidden');
    
    console.log('Uploading image...', file.name);
    
    // Upload to Supabase Storage
    const uploadResult = await uploadOrderImage(file);
    
    if (uploadResult.success) {
      console.log('Image uploaded successfully:', uploadResult.url);
      
      // Hide uploading, show preview
      uploadingDiv.classList.add('hidden');
      previewDiv.classList.remove('hidden');
      
      // Set preview image
      previewImg.src = uploadResult.url;
      
      // Store URL in hidden input
      uploadedUrlInput.value = uploadResult.url;
    } else {
      throw new Error(uploadResult.error);
    }
  } catch (error) {
    console.error('Error uploading image:', error);
    uploadingDiv.classList.add('hidden');
    alert('Failed to upload image: ' + error.message);
    e.target.value = ''; // Reset file input
  }
}

async function handleFormSubmit(e) {
  e.preventDefault();
  
  console.log('Form submitted!'); // Debug log
  
  const submitBtn = e.target.querySelector('button[type="submit"]');
  const originalText = submitBtn.textContent;
  
  try {
    // Disable submit button
    submitBtn.disabled = true;
    submitBtn.textContent = 'Creating Order...';
    
    // Get form data
    const formData = getFormData();
    
    // Get uploaded image URL (already uploaded on file selection)
    const uploadedImageUrl = document.getElementById('uploaded-image-url').value;
    if (uploadedImageUrl) {
      formData.user_image_url = uploadedImageUrl;
    }
    
    console.log('Form data:', formData); // Debug log
    
    // Submit order
    submitBtn.textContent = 'Saving Order...';
    console.log('Submitting to database...'); // Debug log
    
    // CHOOSE YOUR APPROACH:
    // Option 1: Direct database insert (simple)
    const result = await createOrderDirect(formData);
    
    // Option 2: Via Edge Function (recommended for production)
    // const result = await createOrderViaEdgeFunction(formData);
    
    console.log('Result:', result); // Debug log
    
    if (result.success) {
      // Show success overlay instead of alert
      showSuccessOverlay(result.order.order_number);
      
      // Reset form
      e.target.reset();
      
      // Reset image preview
      document.getElementById('image-preview').classList.add('hidden');
      document.getElementById('uploaded-image-url').value = '';
      
      // Re-generate partner code for next order
      document.getElementById('partner-code').value = generatePartnerCode();
    } else {
      throw new Error(result.error);
    }
    
  } catch (error) {
    console.error('Error submitting form:', error);
    alert('Error creating order: ' + error.message);
  } finally {
    // Re-enable submit button
    submitBtn.disabled = false;
    submitBtn.textContent = originalText;
  }
}

// Show success overlay
function showSuccessOverlay(orderNumber) {
  document.getElementById('order-number-display').textContent = orderNumber;
  document.getElementById('success-overlay').classList.remove('hidden');
}

function getFormData() {
  return {
    order_date: document.getElementById('date').value,
    partner_code: document.getElementById('partner-code').value,
    partner_name: document.getElementById('partner-name').value,
    iso: document.getElementById('iso').value,
    sales_person: document.getElementById('sales-person').value,
    manager: document.getElementById('manager').value,
    payment_type: document.getElementById('payment-type').value,
    distribution_carat: parseFloat(document.getElementById('distribution').value),
    external_employees: parseInt(document.getElementById('external-employees').value),
    stone_name: document.getElementById('stone-name').value,
    quantity_carat: parseFloat(document.getElementById('quantity').value),
    purchase_price: parseFloat(document.getElementById('purchase-price').value),
    market_selling_price: parseFloat(document.getElementById('market-price').value),
  };
}

