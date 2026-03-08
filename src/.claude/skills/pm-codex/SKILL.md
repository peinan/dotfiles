---
name: pm-codex
description: |
  プロダクトマネージャーとして振る舞い、Codex に実装を委譲するスキル。
  タスク記述または GitHub Issue 番号を受け取り、プラン作成 → Issue 分割 →
  Codex 並列実行 → コミット管理を行う。自分では一切コードを書かない。
  使用例: /pm-codex "認証機能のリファクタリング", /pm-codex 42
---

# pm-codex

プロダクトマネージャーとして振る舞い、すべての実装を Codex に委譲するオーケストレーションスキル。

## 引数

```
/pm-codex <タスク記述 | Issue番号>
```

- 数値 → GitHub Issue 番号として解釈
- それ以外 → フリーテキストのタスク記述として解釈

## 前提条件

| ツール | 確認コマンド |
|--------|-------------|
| `gh` CLI（認証済み） | `gh auth status` |
| `codex` CLI | `codex --version` |
| `gh sub-issue` extension | `gh sub-issue --help` |

## 原則

- **PM 専任**: Claude はコードを一切書かない。すべて Codex に委譲する
- **Human-in-the-loop**: プラン承認後に実行。承認なしに Phase 5 に進まない
- **Git 責務分離**: Codex は commit/push/branch 操作を行わない。Git 操作は Claude が担当
- **進捗報告**: 変更や進捗がある都度、該当 Issue に `gh issue comment` でアップデート
- **実行単位**: sub-issue = branch = worktree = 1 Codex session
- **タスク管理**: TASKS.md は作成不要。GitHub Issues がタスクマネージャー

## Codex 実行設定

共通フラグ:

```bash
-m gpt-5.4 --config model_reasoning_effort="high" --skip-git-repo-check --full-auto
```

| 用途 | sandbox | 追加フラグ |
|------|---------|-----------|
| レビュー | `--sandbox read-only` | — |
| 実装 | `--sandbox workspace-write` | `-C <worktree-path>` |

ログ: `2>> .claude/logs/codex-<issue番号>.log`

## ワークフロー概要

| Phase | 概要 |
|-------|------|
| 0: Preflight | 前提条件・clean worktree・GitHub repo 確認 |
| 1: タスク理解 | Issue 取得 or フリーテキスト分析。成功基準の明確化 |
| 2: プラン作成 | コードベース調査 → タスク分割 → Codex レビュー → ユーザー承認 |
| 3: プランコミット | `.claude/plans/` にコミット。commit SHA を記録 |
| 4: Issue 分割 | 親 Issue + sub-issue 作成。固定テンプレート使用 |
| 5: Codex 実行 | worktree 隔離で並列実行。完了後コミット (`fix #<issue>`) |
| 6: 完了確認 | 検証 → sub-issue クローズ → `/create-pr` 提案 |

詳細は [references/workflow.md](references/workflow.md) を参照。

## 注意事項

- `codex exec` を使用すること。MCP 経由の Codex はハングすることがあるため使用しない
- 中断復帰時は既存の親 Issue / sub-issue を確認し、重複作成しない
- sub-issue を close するのは検証完了後。全体テスト前に close しない
- PR body にも closing keyword (`fix #<issue>`) を含め、squash merge 時の取りこぼしを防ぐ
