---
name: changelog
description: >-
  CHANGELOG.md の作成・更新スキル。バージョンリリース時に GitHub Issues、
  git タグ、コミット履歴をもとに Keep a Changelog 形式で変更履歴を記録する。
  使用場面: 新バージョンのリリース記録、既存 CHANGELOG への追記、変更履歴の整理。
  ユーザーが「チェンジログ」「changelog」「変更履歴」「リリースノート」と言った場合や、
  /changelog で起動した場合に使用する。
  引数: バージョン番号（スペース区切りで複数可）。例: /changelog 1.2.0, /changelog 1.0.0 1.1.1
---

# changelog

GitHub Issues・git タグ・コミット履歴から Keep a Changelog 形式の CHANGELOG.md を生成・更新する。

## 引数

```
/changelog <バージョン番号...>
```

- `/changelog 1.2.0` — 単一バージョンのエントリを追加
- `/changelog 1.0.0 1.1.1` — 複数バージョンをまとめて追加
- `/changelog` — 引数なしの場合はユーザーにバージョンを確認

`v` prefix あり/なしどちらも受け付ける（`v1.2.0` → `1.2.0` として処理）。

## ワークフロー概要

1. **情報収集** — タグ、コミット、Issue/milestone を取得
2. **分類** — label/commit prefix からカテゴリを決定
3. **CHANGELOG 生成** — Keep a Changelog 形式で記述・更新
4. **ユーザー確認** — 生成結果を提示し、フィードバックを反映

## カテゴリマッピング

### Label → カテゴリ

| Label | カテゴリ |
|---|---|
| `new feature`, `enhancement` | Added |
| `bug` | Fixed |
| `documentation` | Docs |
| `refactor`, `chore`, `maintenance` | Changed |
| `deprecation` | Deprecated |
| `removal` | Removed |
| `security` | Security |

### Commit prefix → カテゴリ

| Prefix | カテゴリ |
|---|---|
| `feat` | Added |
| `fix` | Fixed |
| `docs` | Docs |
| `refactor`, `chore`, `build`, `ci` | Changed |
| `perf` | Changed |

Label が存在する場合は label を優先する。

## フォーマット規約

### セクション順

```markdown
## [X.Y.Z](compare-link) - YYYY-MM-DD

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
### Docs
```

空のセクションは省略する。

### リンク形式

- Issue: `([#N](https://github.com/{owner}/{repo}/issues/N))`
- Commit: `([`hash`](https://github.com/{owner}/{repo}/commit/hash))`
- バージョン見出し: `[X.Y.Z](https://github.com/{owner}/{repo}/compare/vPREV...vCURR)`
  - 初回バージョンの場合: `[X.Y.Z](https://github.com/{owner}/{repo}/releases/tag/vX.Y.Z)`

### CHANGELOG ヘッダ

新規作成時のみ以下を先頭に付与:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).
```

## 注意事項

- 既存の CHANGELOG.md がある場合は、既存エントリを保持して新しいバージョンを追記する
- バージョンは降順（新しい順）に並べる
- リポジトリの owner/repo は `gh repo view --json owner,name` で取得する
- milestone が設定されている場合は milestone でフィルタ、なければタグ間のコミットから判定

詳細なワークフローは [references/workflow.md](references/workflow.md) を参照。
