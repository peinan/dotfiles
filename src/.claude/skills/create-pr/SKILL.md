---
name: create-pr
description: >-
  Pull Request を自動作成するスキル。現在のブランチのコミットと diff を分析し、
  PR タイトル・本文を生成して gh pr create で作成する。
  使用場面: 新機能やバグ修正の PR 作成、コードレビュー依頼の準備。
  ユーザーが「PR 作成」「プルリク」「pull request」「create pr」と言った場合や、
  /create-pr で起動した場合に使用する。
  引数: [--lang ja|en] [base-branch]。例: /create-pr, /create-pr --lang ja, /create-pr main
---

# create-pr

現在のブランチのコミットと diff を分析し、PR タイトル・本文を生成して GitHub に PR を作成する。

## 引数

```
/create-pr [--lang ja|en] [base-branch]
```

- `--lang en` — PR タイトル・本文を英語で生成（デフォルト）
- `--lang ja` — PR タイトル・本文を日本語で生成
- `base-branch` — ベースブランチ指定（省略時はリポジトリのデフォルトブランチ）

## ワークフロー

### Phase 1: 前提確認

以下を並列で取得:

```bash
git branch --show-current
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

確認事項:

| 状況 | 対応 |
|---|---|
| ベースブランチ上にいる | エラーメッセージを表示して中止 |
| 未コミット変更あり (`git status --porcelain`) | 警告し、続行/中止をユーザーに確認 |
| PR が既に存在 (`gh pr view --json url`) | URL を表示して中止 |
| `gh` 未認証 | `gh auth login` を案内して中止 |

### Phase 2: 情報収集

ベースブランチを `<base>` として、以下を並列実行:

```bash
git log <base>..HEAD --oneline
git log <base>..HEAD --format='%h %s%n%n%b' --no-merges
git diff <base>...HEAD --stat
git diff <base>...HEAD
```

コミットが 0 件の場合は中止。

### Phase 3: PR タイトル・本文生成

コミット履歴と diff の内容から PR タイトルと本文を生成する。

**言語**: `--lang` 引数に従う（デフォルト: en）。

**タイトル規約**:
- 70 文字以内
- en: 命令形（例: "Add font weight customization"）
- ja: 体言止め or 動詞終止形（例: "フォントウェイトのカスタマイズを追加"）
- コミットが 1 件の場合、コミットメッセージをタイトルの起点にする

**本文フォーマット**（en の場合）:

```markdown
## Summary
- <変更内容の箇条書き>

## Test plan
- [ ] <検証ステップ>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**本文フォーマット**（ja の場合）:

```markdown
## 概要
- <変更内容の箇条書き>

## テスト計画
- [ ] <検証ステップ>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Phase 4: ユーザー承認

生成したタイトルと本文を提示し、ユーザーの承認を待つ。
修正依頼があれば反映して再提示する。

**承認されるまで Phase 5 に進まない。**

### Phase 5: Push & PR 作成

1. リモートに push されていない場合: `git push -u origin HEAD`
2. PR 作成:

```bash
gh pr create --title "タイトル" --body "$(cat <<'EOF'
本文
EOF
)"
```

3. 作成された PR の URL を報告

**Push 失敗時**: エラーを報告して中止。

## 注意事項

- `gh` CLI が必要。未インストールの場合はインストールを案内
- `--lang` を省略した場合は英語で生成
- ベースブランチの引数は `--lang` の後に指定可能
