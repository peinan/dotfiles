# changelog 詳細ワークフロー

## Phase 1: 情報収集

### 1.1 リポジトリ情報の取得

```bash
gh repo view --json owner,name
```

これで `{owner}` と `{repo}` を確定する。全リンクの生成に使用。

### 1.2 引数の正規化

- `v` prefix を除去: `v1.2.0` → `1.2.0`
- 引数なしの場合は `AskUserQuestion` でバージョンを確認

### 1.3 タグ一覧の取得

```bash
git tag -l --sort=-v:refname
```

対象バージョンの前後のタグを特定する。

### 1.4 バージョン間のコミット取得

```bash
# 前のタグから対象バージョンタグまでのコミット
git log --oneline vPREV...vCURR

# 初回バージョン（前のタグなし）の場合
git log --oneline vCURR
```

### 1.5 Closed Issue の取得

```bash
gh issue list --state closed --json number,title,labels,milestone,closedAt --limit 200
```

### 1.6 Issue のフィルタリング

優先順: milestone > タグ間の期間

1. **milestone あり**: milestone 名がバージョンに一致する Issue を抽出
2. **milestone なし**: タグの作成日時間に close された Issue を抽出
3. **コミットメッセージ参照**: `fix #N`, `close #N` 等のパターンからも抽出

## Phase 2: 分類とマッピング

### 2.1 Issue の分類

各 Issue の label を確認し、カテゴリにマッピング:

| Label | カテゴリ |
|---|---|
| `new feature`, `enhancement` | Added |
| `bug` | Fixed |
| `documentation` | Docs |
| `refactor`, `chore`, `maintenance` | Changed |
| `deprecation` | Deprecated |
| `removal` | Removed |
| `security` | Security |

複数ラベルがある場合の優先順位:
1. `security`（最優先）
2. `bug`
3. `new feature` / `enhancement`
4. その他

label なしの Issue は commit prefix で判定する。

### 2.2 Issue に紐付かないコミットの分類

コミットメッセージの prefix からカテゴリを判定:

| Prefix | カテゴリ |
|---|---|
| `feat` | Added |
| `fix` | Fixed |
| `docs` | Docs |
| `refactor`, `chore`, `build`, `ci` | Changed |
| `perf` | Changed |

prefix パターン: `^(feat|fix|docs|refactor|chore|build|ci|perf)(\(.+\))?[!]?:`

### 2.3 エントリの構成

各エントリの形式:

```markdown
- Issue あり: {Issue タイトル} ([#N](issue-link))
- Issue なし: {コミットメッセージ要約} ([`hash`](commit-link))
```

### 2.4 除外ルール

以下のコミットは CHANGELOG に含めない:

- merge commit（`Merge branch`, `Merge pull request`）
- バージョンタグコミット（`1.2.0`, `v1.2.0` のみのメッセージ）
- `chore: release` 系

## Phase 3: CHANGELOG 生成

### 3.1 既存ファイルの確認

```bash
# CHANGELOG.md の存在確認
ls CHANGELOG.md
```

- **存在する場合**: 内容を読み込み、適切な位置に新エントリを挿入
- **存在しない場合**: ヘッダ付きで新規作成

### 3.2 ヘッダ（新規作成時のみ）

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).
```

### 3.3 バージョンエントリの生成

```markdown
## [X.Y.Z](https://github.com/{owner}/{repo}/compare/vPREV...vCURR) - YYYY-MM-DD

### Added

- 新機能の説明 ([#12](https://github.com/{owner}/{repo}/issues/12))

### Fixed

- バグ修正の説明 ([#15](https://github.com/{owner}/{repo}/issues/15))

### Changed

- リファクタリングの説明 ([`abc1234`](https://github.com/{owner}/{repo}/commit/abc1234))
```

### 3.4 バージョン日付の決定

優先順:
1. タグの日付: `git log -1 --format=%ai vX.Y.Z`
2. タグがまだない場合: 本日の日付

### 3.5 挿入位置

既存 CHANGELOG への追記時:
- ヘッダ（`# Changelog` + 説明文）の直後
- 既存のバージョンエントリの直前
- バージョンは降順（新しい順）を維持

### 3.6 複数バージョンの処理

引数に複数バージョンが指定された場合:
1. バージョンを昇順にソート
2. 各バージョンを順に処理
3. 最終的な CHANGELOG では降順に配置

## Phase 4: ユーザー確認

### 4.1 生成結果の提示

生成した CHANGELOG エントリをユーザーに提示する。

確認ポイント:
- カテゴリの分類は正しいか
- 不足しているエントリはないか
- エントリの説明文は適切か
- 不要なエントリが含まれていないか

### 4.2 フィードバック対応

ユーザーからの修正指示に応じて調整:
- カテゴリの変更
- エントリの追加・削除
- 文言の修正

### 4.3 ファイル書き込み

ユーザーの承認後に CHANGELOG.md へ書き込む。

## エッジケース対処

### タグが存在しない場合

- `git log --oneline` で全コミットを使用
- compare リンクの代わりに release tag リンクを使用

### Issue も milestone もない場合

- コミット履歴のみから CHANGELOG を生成
- 全エントリが commit リンク形式になる

### 既存 CHANGELOG のフォーマットが異なる場合

- 既存のフォーマットを尊重しつつ、新エントリは Keep a Changelog 形式で追記
- フォーマット不一致が大きい場合はユーザーに確認
