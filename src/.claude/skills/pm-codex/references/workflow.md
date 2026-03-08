# pm-codex ワークフロー詳細

## Phase 0: Preflight

以下を並列で確認し、失敗があれば中止して案内する:

```bash
gh auth status
codex --version
gh sub-issue --help
git status --porcelain
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

確認事項:
- worktree が clean であること（未コミット変更がある場合は警告しユーザーに確認）
- `.claude/plans/` ディレクトリが存在すること（なければ作成）
- `.claude/logs/` ディレクトリが存在すること（なければ作成）

## Phase 1: タスク理解

### Issue 番号の場合

```bash
gh issue view <番号> --json title,body,labels,comments,assignees,state
```

- Issue が closed の場合は警告
- Issue の内容から成功基準を抽出

### フリーテキストの場合

- タスク記述を分析
- 成功基準を明確化
- 親 Issue を作成:

```bash
gh issue create --title "<タスクタイトル>" --body "<タスク詳細と成功基準>"
```

### 中断復帰チェック

既存の親 Issue に紐づく sub-issue がないか確認:

```bash
gh sub-issue list <親Issue番号>
```

既存の sub-issue がある場合は状態を確認し、未完了分から再開する。

## Phase 2: プラン作成

### 2-1: コードベース調査

Explore エージェントを使用して関連ファイル・パターンを特定する。

### 2-2: プラン策定

1. 解決アプローチの候補を列挙
2. 各アプローチの tradeoff を分析
3. 推奨アプローチを選択
4. タスクを Codex が 1 セッションで完結するサイズに分割
5. 依存関係と並列実行性を整理
6. テスト計画を明記

### 2-3: Codex レビュー

プランを Codex に送り、致命的な欠陥がないかレビューさせる:

```bash
echo "<プラン全文>" | codex exec \
  --skip-git-repo-check \
  -m gpt-5.4 \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  --full-auto \
  2>> .claude/logs/codex-review.log
```

レビュー結果を反映し、必要に応じて修正。

### 2-4: ユーザー承認

プランを提示し、承認を待つ。**承認されるまで Phase 3 に進まない。**

## Phase 3: プランコミット

```bash
git add .claude/plans/<slug>.md
git commit -m "docs(plan): <タスクサマリ>"
```

commit SHA を記録し、以降の Issue に含める。

## Phase 4: Issue 分割

### 親 Issue の準備

Phase 1 で作成済み、または既存の Issue を使用。

### sub-issue 作成

各タスクを以下のテンプレートで sub-issue として登録:

```bash
gh sub-issue create --parent <親Issue番号> --title "タスクN: <タイトル>" --body "$(cat <<'EOF'
## 概要
<タスクの説明>

## 背景
<なぜ必要か>

## 対象範囲
- <変更するファイル/モジュール>

## 非対象
- <触らないもの>

## 完了条件
- [ ] <具体的な条件>

## 検証コマンド
```bash
<検証コマンド>
```

## 期待出力
<期待される結果>

## ブロック時
<依存タスクが未完了の場合の対応>

## プラン
<plan の commit SHA / permalink>
EOF
)"
```

依存関係がある場合は Issue body の「ブロック時」セクションに明記する。

## Phase 5: Codex 実行

### 5-1: worktree 作成

sub-issue ごとに専用 worktree を作成:

```bash
git worktree add .worktrees/issue-<番号> -b issue-<番号>/task
```

### 5-2: Codex 実行

Issue body を元に Codex プロンプトを構成し実行:

```bash
echo "<wrapper prompt + issue body>" | codex exec \
  --skip-git-repo-check \
  -m gpt-5.4 \
  --config model_reasoning_effort="high" \
  --sandbox workspace-write \
  --full-auto \
  -C .worktrees/issue-<番号> \
  2>> .claude/logs/codex-<番号>.log
```

**並列実行**: 依存関係のない sub-issue は複数の Bash tool call で同時に実行する。
**順次実行**: 依存関係がある sub-issue は前のタスク完了後に実行する。

### 5-3: 変更のマージとコミット

Codex 完了後:

1. worktree の変更を確認
2. 変更をメインブランチにマージ:

```bash
cd .worktrees/issue-<番号>
git add -A
git stash
cd -
git stash pop
git add <変更ファイル>
git commit -m "<type>(<scope>): <description> (fix #<issue番号>)"
```

3. worktree を削除:

```bash
git worktree remove .worktrees/issue-<番号>
```

### 5-4: 進捗報告

各タスク完了後、Issue にコメントを追加:

```bash
gh issue comment <番号> --body "実装完了。コミット: <SHA>"
```

問題が発生した場合も Issue にコメントして報告する。

## Phase 6: 完了確認

### 6-1: 全 sub-issue の検証

各 sub-issue の検証コマンドを実行し、期待出力と一致するか確認する。
検証完了した sub-issue をクローズ:

```bash
gh issue close <番号> --comment "検証完了"
```

### 6-2: 全体テスト

プロジェクトのテストスイートを実行（存在する場合）。

### 6-3: サマリ報告

完了した全タスクのサマリをユーザーに報告する。

### 6-4: PR 提案

feature ブランチ上にいる場合、`/create-pr` を提案する。
PR body には全 sub-issue の closing keyword を含める:

```markdown
## Summary
- ...

Fixes #<親Issue番号>
- fix #<sub-issue-1>
- fix #<sub-issue-2>
- ...
```
