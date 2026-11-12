import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      strategies: 'injectManifest',
      srcDir: 'src',
      filename: 'sw.js',
      registerType: 'autoUpdate',
      devOptions: { enabled: true, type: 'module' },
      manifest: {
        name: 'Exam Timetable',
        short_name: 'Exams',
        description: 'Personalised exam timetable for students',
        theme_color: '#4f46e5',
        background_color: '#f4f5fb',
        display: 'standalone',
        start_url: '/',
        scope: '/',
        icons: [
          {
            src: '/icon.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any'
          }
        ]
      },
      injectManifest: {
        globPatterns: ['**/*.{js,css,html,svg,png,ico}']
      }
    })
  ],
  server: {
    host: '0.0.0.0', // Allows access from your local network
    port: 5173,
    allowedHosts: true, // <--- ADD THIS FOR NGROK
    proxy: {
      '/api': 'http://localhost:5000'
    }
  }
});
