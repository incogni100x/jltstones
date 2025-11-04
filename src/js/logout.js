import { signOut } from './session.js';

// Logout functionality for admin panel
export async function logout() {
  await signOut();
  window.location.href = '/admin-login';
} 