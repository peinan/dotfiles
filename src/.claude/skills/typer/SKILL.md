---
name: typer
description: >-
  Python の Typer ライブラリで CLI を実装する際の規約・パターンを提供するスキル。
  使用場面: typer ベースの CLI 実装、コマンドラインオプション設計、help 周りの設定。
  ユーザーが「typer」と言及した、または `typer.Typer` / `@app.command` / `@app.callback` を含むコードを書く・読む際に使用する。
---

# typer

Python の Typer で CLI を書くときの規約集。

## ルール

### `-h` を `--help` のエイリアスとして有効化

`typer.Typer()` の `context_settings` に `help_option_names` を渡す。

```python
app = typer.Typer(context_settings={"help_option_names": ["-h", "--help"]})
```

単一コマンドの app では constructor 経由で効かないケースがある。その場合は `@app.callback` 側に指定する。

```python
app = typer.Typer()

@app.callback(context_settings={"help_option_names": ["-h", "--help"]})
def main(ctx: typer.Context):
    ...
```

参考: https://github.com/fastapi/typer/issues/201
