import { defineConfig } from 'vitepress'

export default defineConfig({
  base: process.env.NODE_ENV === 'production' ? '/dotfiles/' : '/',
  title: "peinan's dotfiles",
  description: "Configuration files for OS, shell, Neovim, tmux and others",
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Install', link: '/install' },
      { text: 'Config', link: '/config' },
      { text: 'Submodules', link: '/submodules' }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/peinan/dotfiles' }
    ],
    footer: {
      copyright: `© ${new Date().getFullYear()} Peinan Zhang. Licensed under <a href="https://github.com/peinan/dotfiles/blob/main/LICENSE" target="_blank" rel="noopener">MIT</a>.`
    },
    search: {
      provider: 'local'
    }
  }
})

