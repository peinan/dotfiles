import { h } from 'vue'
import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import * as LucideIcons from 'lucide-vue-next'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    // すべての Lucide アイコンをグローバルコンポーネントとして登録
    Object.keys(LucideIcons).forEach(key => {
      if (key !== 'default' && typeof LucideIcons[key] === 'object') {
        app.component(key, LucideIcons[key])
      }
    })
  }
} satisfies Theme

