# Agentic Company

B2B SaaS（React / TypeScript + Node.js / Express）を提供するWebサービスベンダーの、エージェント組織定義リポジトリ。

---

## Principles

- 要件・仕様が曖昧な場合は **AskUserQuestion Tool** で確認してから進めること
- **コンテキスト節約のためサブエージェントへの委託を徹底**すること
  - Explore: コードベース探索・検索
  - Plan: 実装前の設計・計画策定
  - general-purpose: 実装・編集・ドキュメント更新等の実作業
- 大きなタスクは **Agent Teams を活用して並列実行**すること（→ [エージェント構成](#エージェント構成)）
- `organization.yaml` が組織構成の **Single Source of Truth**。エージェント `.md` はこれに準拠すること
- 新しいエージェントを追加・削除・変更する場合は、`organization.yaml` と `.claude/agents/` の両方を更新すること

---

## エージェント構成

**14部門・40エージェント**で構成。詳細は以下を参照:

- 全体構成・部門一覧 → [`docs/PLAN.md`](docs/PLAN.md)
- 各エージェントの定義（役割・責務・ツール）→ [`organization.yaml`](organization.yaml)
- エージェントファイル → [`.claude/agents/`](.claude/agents/)

### 部門一覧（クイックリファレンス）

| 部門 | 人数 | 主な用途 |
|------|------|---------|
| executive/ | 2 | OKR管理・事業開発・経営参謀 |
| engineering/ | 5 | フロントエンド・バックエンド・DB・DevOps・セキュリティ |
| product/ | 2 | 要件定義・市場調査・ロードマップ |
| design/ | 3 | UI設計・UXリサーチ・ブランド管理 |
| quality-assurance/ | 4 | ユニット/E2E/APIテスト・パフォーマンス分析 |
| sales/ | 4 | 新規開拓・インサイドセールス・既存拡販・営業支援 |
| marketing/ | 3 | コンテンツ・SEO・グロース |
| customer-success/ | 3 | CSM・オンボーディング・サポート |
| people/ | 2 | 人事・採用 |
| finance/ | 2 | 財務管理・請求・SaaSメトリクス |
| legal/ | 3 | 法務・コンプライアンス・内部監査 |
| it-systems/ | 1 | 社内IT・SaaSツール管理 |
| operations/ | 2 | SRE・データ分析 |
| project-management/ | 4 | PM・スクラム・スプリント計画・リリース管理 |

---

## ファイル構成

```
agentic-company/
├── CLAUDE.md               # このファイル
├── organization.yaml       # 組織構成 SSOT
├── docs/
│   └── PLAN.md             # 設計方針・変更履歴・部門詳細
└── .claude/
    └── agents/             # エージェント定義（14部門）
```

---

## 運用ガイドライン

### エージェント定義の更新手順
1. `organization.yaml` を更新（SSOT）
2. 対応する `.claude/agents/<department>/<agent>.md` を更新
3. `docs/PLAN.md` のテーブルを更新

### 新部門・エージェントの追加
```
1. organization.yaml に department / agent エントリを追記
2. mkdir .claude/agents/<新部門名>/
3. <agent-id>.md を作成（フロントマター: name, description, tools）
4. docs/PLAN.md に追記
```

### Agent Teams としての使い方
このリポジトリのエージェントは **`subagent_type: general-purpose`** で起動し、
タスクの性質に応じて適切な部門のエージェントを `Agent` ツールで呼び出す。

```
例: フロントエンド実装タスク
→ .claude/agents/engineering/frontend-developer.md のシステムプロンプトを
  Agent ツールの prompt に組み込んで起動
```
