// Generate unique partner code: JLX + 6 random numbers
export function generatePartnerCode() {
  const randomNumbers = Math.floor(100000 + Math.random() * 900000);
  return `JLX${randomNumbers}`;
}

// Generate unique order number: ORD-YYYY-XXXX
export function generateOrderNumber() {
  const year = new Date().getFullYear();
  const randomNum = Math.floor(1000 + Math.random() * 9000);
  return `ORD-${year}-${randomNum}`;
}

// Example usage:
// const partnerCode = generatePartnerCode(); // JLX123456
// const orderNumber = generateOrderNumber(); // ORD-2025-5678

