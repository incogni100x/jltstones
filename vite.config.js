import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  root: '.',
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        order: resolve(__dirname, 'order.html'),
        admin: resolve(__dirname, 'admin.html'),
        'admin-login': resolve(__dirname, 'admin-login.html')
      }
    }
  },
  server: {
    port: 3000,
    open: true
  }
});

