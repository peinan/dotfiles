import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  integrations: [tailwind()],
  output: 'static',
  base: '/dotfiles/',
  outDir: './dist',
  build: {
    assets: '_assets'
  }
});

