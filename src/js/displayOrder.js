// Display tracked order on order.html
document.addEventListener('DOMContentLoaded', () => {
  // Get order data from sessionStorage
  const orderDataString = sessionStorage.getItem('trackedOrder');
  
  if (!orderDataString) {
    // No order data, show message
    showNoOrderMessage();
    return;
  }
  
  try {
    const order = JSON.parse(orderDataString);
    displayOrder(order);
  } catch (error) {
    console.error('Error parsing order data:', error);
    showNoOrderMessage();
  }
});

function showNoOrderMessage() {
  // Redirect to homepage to track order
  window.location.href = 'index.html';
}

function displayOrder(order) {
  console.log('Displaying order:', order);
  
  // Format date
  const orderDate = new Date(order.order_date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
  
  // Format numbers
  const formatNumber = (num) => parseFloat(num).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const formatCurrency = (num) => '$' + formatNumber(num);
  
  // Update page elements
  document.getElementById('order-date').textContent = orderDate;
  document.getElementById('order-number').textContent = order.order_number;
  document.getElementById('distribution-text').textContent = `Distribution of ${formatNumber(order.distribution_carat)} carat of ${order.stone_name} stones`;
  
  // Update image if exists (keep logo as default)
  // Image display removed as per template
  
  // Partner Information
  document.getElementById('partner-code').textContent = order.partner_code;
  document.getElementById('partner-name').textContent = order.partner_name;
  document.getElementById('iso').textContent = order.iso || 'N/A';
  
  // Staff Information
  document.getElementById('sales-person').textContent = order.sales_person;
  document.getElementById('manager').textContent = order.manager;
  
  // Payment & Distribution
  document.getElementById('payment-type').textContent = order.payment_type;
  document.getElementById('distribution-carat').textContent = formatNumber(order.distribution_carat) + ' carat';
  document.getElementById('external-employees').textContent = order.external_employees;
  
  // Stone Details Table
  document.getElementById('stone-name').textContent = order.stone_name;
  document.getElementById('quantity-carat').textContent = formatNumber(order.quantity_carat);
  document.getElementById('purchase-price').textContent = formatCurrency(order.purchase_price);
  document.getElementById('market-price').textContent = formatCurrency(order.market_selling_price);
  document.getElementById('profit-per-carat').textContent = formatCurrency(order.profit_per_carat);
  document.getElementById('total-profit').textContent = formatCurrency(order.total_profit);
}

