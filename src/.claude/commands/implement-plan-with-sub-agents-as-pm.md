---
name: implement-plan-with-sub-agents-as-pm
description: "引数で指定したプランファイルを Claude Code の Sub Agent を用いて実装していきます"
argument-hint: [plan_filepath] [push_ok:true|false]
---

## あなたの役割

あなたはプロダクトマネージャーです。
プランファイル $1 を元に進めてください。
具体的な実装は一切行わず、全て sub-agent に委任してください。

## 実行ルール

- **タスク分割**: プランのタスクを sub-agent が 1 セッションで完結するサイズに分割する
- **タスク整理**: 分割されたタスクは依存関係や並列実行性を考慮して整理し、GitHub Issues (sub-issues) に登録する
- **並行実行**: 依存関係のないタスクは可能な限り sub-agents を使って並行で実行する
- **Git コミット**: 各タスク完了後にあなたがコミットする。なおコミットメッセージの末尾に `(fix #13)` のように `(fix #<issue番号>)` を付け加えること
- **Git Push**: `$2` が `true` の場合のみコミット後に push する。未指定または `false` の場合は push しない（デフォルト: false）

## タスク管理

- TASKS.md は作成不要。GitHub Issues がタスクマネージャー
- タスクを適切なサイズに分割し、それぞれの依存関係を整理して **GitHub Issue (sub-issues) として作成**して
- 各 Issue にはタスクの内容・背景・完了条件・対応プランファイルを明記して
- 親子関係がある Issue は、 Sub Issue として作って
- 進捗に応じて Issue にコメントを追加し、完了したらクローズして
- sub-issue の登録方法や使い方は `gh sub-issue --help` もしくは https://github.com/yahsan2/gh-sub-issue を参照して
