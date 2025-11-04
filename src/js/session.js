// Simple session management for admin panel
import { supabase } from './client.js';

export async function checkAuth() {
  // Check Supabase session first
  const { data: { session } } = await supabase.auth.getSession();
  
  if (!session) {
      // Not logged in via Supabase, redirect to login
      sessionStorage.clear();
      window.location.href = '/admin-login';
    return false;
  }
  
  // Has valid Supabase session
  sessionStorage.setItem('adminLoggedIn', 'true');
  sessionStorage.setItem('adminUser', session.user.email);
  sessionStorage.setItem('adminUserId', session.user.id);
  return true;
}

export function getAdminUser() {
  return {
    username: sessionStorage.getItem('adminUser'),
    userId: sessionStorage.getItem('adminUserId'),
    isLoggedIn: sessionStorage.getItem('adminLoggedIn') === 'true'
  };
}

export async function signOut() {
  // Sign out from Supabase
  const { error } = await supabase.auth.signOut();
  if (error) {
    console.error('Error signing out:', error);
  }
  
  // Clear all session storage
  sessionStorage.clear();
} 