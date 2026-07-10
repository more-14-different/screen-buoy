import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  // Vite options tailored for Tauri development and only applied in `tauri dev` or `tauri build`
  clearScreen: false,
  // tauri expects a fixed port, fail if that port is not available
  server: {
    port: 1420,
    strictPort: true,
  },
  // to make use of `TAURI_DEBUG` and other env variables
  // https://tauri.studio/v1/api/config#buildconfig.beforedevcommand
  envPrefix: ["VITE_", "TAURI_"],
  build: {
    // Tauri supports es2021
    target: process.env.TAURI_PLATFORM === "windows" ? "chrome105" : "safari13",
    // don't minify for debug builds
    minify: !process.env.TAURI_DEBUG ? "esbuild" : false,
    // produce sourcemaps for debug builds
    sourcemap: !!process.env.TAURI_DEBUG,
    rollupOptions: {
      input: {
        main: 'index.html',
        overlay: 'overlay.html'
      },
      output: {
        manualChunks(id) {
          if (!id.includes('node_modules')) {
            return;
          }
          if (id.includes('/react/') || id.includes('/react-dom/')) {
            return 'react';
          }
          if (id.includes('/i18next/') || id.includes('/react-i18next/')) {
            return 'i18n';
          }
          if (id.includes('/@ant-design/icons/')) {
            return 'ant-icons';
          }
          if (id.includes('/@ant-design/') || id.includes('/antd/')) {
            return 'antd';
          }
          if (id.includes('/rc-') || id.includes('/@rc-component/')) {
            return 'rc-components';
          }
          return 'vendor';
        },
      },
    }
  },
}); 
