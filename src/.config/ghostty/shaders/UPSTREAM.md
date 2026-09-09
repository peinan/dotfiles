# Upstream

The `.glsl` files and `README.md` in this directory are a vendored copy of:

- Source: https://github.com/sahaj-b/ghostty-cursor-shaders
- Commit: `4faa83e4b9306750fc8de64b38c6f53c57862db8` ("update readme")
- License: MIT, as declared in the upstream `README.md` ("## License / MIT").
  Upstream ships no `LICENSE` file and no copyright line, so there is no
  verbatim notice to reproduce here. Copyright belongs to the upstream author
  (GitHub user `sahaj-b`).

They used to be a nested Git clone inside this repository, which showed up as a
`160000` gitlink with no matching `.gitmodules` entry and broke every
`git submodule` invocation. They are plain tracked files now.

`../config` selects one with `custom-shader = shaders/<name>.glsl`.

## Re-syncing with upstream

```bash
tmp=$(mktemp -d)
git clone --depth 1 https://github.com/sahaj-b/ghostty-cursor-shaders "$tmp"
git -C "$tmp" rev-parse HEAD          # record it in the section above
cp "$tmp"/*.glsl "$tmp"/README.md .
rm -rf "$tmp"
```
