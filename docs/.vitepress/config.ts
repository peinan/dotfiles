import { defineConfig } from 'vitepress'

// 環境変数でbaseパスを制御
// VITEPRESS_BASEが設定されている場合（空文字列も含む）はそれを使用
// それ以外は、NODE_ENVがproductionの場合は'/dotfiles/'、それ以外は'/'を使用
const base = process.env.VITEPRESS_BASE !== undefined
  ? process.env.VITEPRESS_BASE
  : (process.env.NODE_ENV === 'production' ? '/dotfiles/' : '/')

export default defineConfig({
  base,
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

