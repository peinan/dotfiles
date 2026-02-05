---
name: fix-issue
description: |
  GitHub Issue を調査し解決プランを作成するスキル。
  Issue 番号を引数として受け取り、コードベースを詳細調査して解決策を提案。
  ユーザー承認後に実装まで行う。Human-in-the-loop で安全に進行。
  使用例: /fix-issue 13, /fix-issue 42
---

# fix-issue

GitHub Issue を解決するためのワークフロースキル。

## 引数

- `<issue番号>`: 解決対象の GitHub Issue 番号（必須）

## クイックスタート

1. Issue 取得: `gh issue view <番号> --json title,body,labels,comments`
2. コードベース調査: Explore エージェントで関連ファイル特定
3. プラン作成: 解決アプローチと実装ステップを提示
4. 承認後実装: ユーザー確認を経て変更を実行

## ワークフロー

### Phase 1: Issue 理解

Issue の内容を取得し分析する。

```bash
gh issue view <番号> --json title,body,labels,comments,assignees
```

分析ポイント:
- 問題の本質は何か
- 再現手順はあるか
- 期待される動作は何か
- **成功基準**: 何をもって解決とするか明確化

### Phase 2: コードベース調査

Explore エージェントを使用して詳細調査:
- Issue で言及されているファイル・関数
- エラーメッセージに含まれるキーワード
- 関連する既存のパターン・ユーティリティ

**セキュリティ評価**: auth, payments, infra 関連の場合は特に慎重に。

### Phase 3: プラン作成

1. 解決アプローチの候補を列挙
2. 各アプローチの tradeoff を分析
3. 推奨アプローチを選択
4. 実装ステップを詳述
5. **テスト計画**: 変更の検証方法を明記

### Phase 4: ユーザー承認

プランを提示し、質問・懸念点を確認。
承認されるまで実装に進まない。

### Phase 5: 実装

承認後、プランに従ってコード変更を実行。

## 注意事項

- AI はコードを提案するが、所有しない（Human-in-the-loop）
- セキュリティ関連の変更は特に慎重にレビュー
- 不明点があれば実装前に確認

詳細なワークフローは [references/workflow.md](references/workflow.md) を参照。
