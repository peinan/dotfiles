---
name: appstore-release-notes
description: >-
  App Store 向けリリースノートを生成するスキル。
  CHANGELOG.md や git log から変更内容を取得し、日本語・英語の簡潔なリリースノートを出力する。
  使用場面: App Store 提出前のリリースノート作成、アップデート情報の多言語化。
  ユーザーが「リリースノート」「release notes」「App Store のアップデート情報」と言った場合や、
  /appstore-release-notes で起動した場合に使用する。
  引数: バージョン番号（任意）。省略時は最新バージョンを対象とする。
  例: /appstore-release-notes 1.2.0, /appstore-release-notes
---

# appstore-release-notes

CHANGELOG.md や git log から App Store 掲載用のリリースノート（日本語・英語）を生成する。

## 引数

```
/appstore-release-notes [バージョン番号]
```

- `/appstore-release-notes 1.2.0` — 指定バージョンのリリースノートを生成
- `/appstore-release-notes` — 最新バージョンを自動検出して生成

`v` prefix あり/なしどちらも受け付ける（`v1.2.0` → `1.2.0` として処理）。

## ワークフロー

### Step 1: バージョン特定

- 引数があればそのバージョンを対象とする
- 引数がなければ以下の順で最新バージョンを特定:
  1. `git tag --sort=-v:refname | head -1`
  2. `package.json` の `version` フィールド

### Step 2: 情報収集

以下の順で変更内容を取得する:

1. **CHANGELOG.md**（優先）: 対象バージョンのセクションを読み取る
2. **git log**（フォールバック）: 前バージョンのタグから対象タグまでのコミットを取得

```bash
# CHANGELOG がない場合
git log v1.0.0..v1.1.0 --oneline --no-merges
```

### Step 3: リリースノート生成

#### フィルタリング

- **含める**: ユーザーが体感できる変更（新機能、バグ修正、UI 変更、パフォーマンス改善）
- **除外する**: 内部リファクタ、CI/CD 変更、テスト追加、ドキュメント更新、依存関係更新

#### 文体ルール

- 簡潔かつ平易な表現（技術用語を避ける）
- 箇条書きは `•` を使用（`-` は使わない）
- 各項目は体言止めまたは短い文（日本語）、動詞で始める（英語）
- 項目数は 2〜5 程度に絞る（多すぎる場合はまとめる）
- 初回リリース（v1.0.0 等）の場合は主要機能を簡潔に列挙

#### 出力フォーマット

日本語 → 英語の順で、それぞれコードブロックで囲む:

````
**日本語**

```
（1行サマリー — 任意）

• 変更点1
• 変更点2
• 変更点3
```

**English**

```
(One-line summary — optional)

• Change 1
• Change 2
• Change 3
```
````

1行サマリーは大きなテーマがある場合のみ付与する。バグ修正のみの場合は省略可。

### Step 4: ユーザー確認

生成結果を提示し、修正要望があれば反映する。

## 注意事項

- App Store の文字数制限は 4000 文字。通常のリリースノートなら余裕があるが、極端に長くならないよう注意
- 翻訳は意訳を優先（直訳にしない）
- 日本語と英語で項目数・順序は揃える

実例は [references/examples.md](references/examples.md) を参照。
