import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import process from 'node:process';

export default defineConfig(({ mode }) => {
  // Ładujemy zmienne z plików .env (jeśli istnieją lokalnie)
  // Używamy process.cwd() dla pewności ścieżki
  const env = loadEnv(mode, process.cwd(), '');
  
  // Priorytet: 
  // 1. Zmienna systemowa (przekazana przez Docker ARG -> ENV)
  // 2. Zmienna z pliku .env
  const apiKey = process.env.API_KEY || env.API_KEY;

  return {
    plugins: [react()],
    define: {
      // Wstrzykujemy wartość klucza bezpośrednio do kodu JS podczas budowania
      'process.env.API_KEY': JSON.stringify(apiKey)
    },
    server: {
      host: true,
      port: 5173
    }
  };
});