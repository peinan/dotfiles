# Ghostty

## Use Raycast to toggle background transparency

1. Copy `ghostty-toggle-blur.sh` to `~/raycast-scripts/`
2. Add Script Directory from the Raycast Scripts Settings

## Cursor shader

`shaders/cursor_tail.glsl` is selected by `config` via
`custom-shader = shaders/cursor_tail.glsl`. Only the shader in use is kept here.

Credit: [sahaj-b/ghostty-cursor-shaders](https://github.com/sahaj-b/ghostty-cursor-shaders),
commit `4faa83e4b9306750fc8de64b38c6f53c57862db8`, MIT licensed (declared in the
upstream README; upstream ships no `LICENSE` file). Copyright belongs to the
upstream author.

The upstream repository has six other cursor effects. To swap one in:

```bash
curl -fsSLO https://raw.githubusercontent.com/sahaj-b/ghostty-cursor-shaders/main/cursor_warp.glsl
# then point custom-shader at it in `config`
```
