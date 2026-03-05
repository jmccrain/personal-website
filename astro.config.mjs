// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://joshuamccrain.com',
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
    cacheDir: process.env.TEMP ? process.env.TEMP + '/.vite-mccrain' : '.vite-cache'
  }
});
