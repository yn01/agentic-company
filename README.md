# Agentic Company

> B2B SaaS Webサービスベンダーを模した、Claude Code 向けエージェント組織定義リポジトリ

Claude Code の [`.claude/agents/`](https://docs.anthropic.com/ja/docs/claude-code/sub-agents) 機能を使い、実際の会社組織に対応した**14部門・40エージェント**を定義しています。各エージェントは役割・責務・ツール・行動指針を持ち、Claude Code のタスク実行時にサブエージェントとして呼び出せます。

---

## 概要

```
14部門 / 40エージェント
├── executive/          経営・事業開発         (2)
├── engineering/        エンジニアリング        (5)
├── product/            プロダクト              (2)
├── design/             デザイン                (3)
├── quality-assurance/  品質保証                (4)
├── sales/              営業                    (4)
├── marketing/          マーケティング          (3)
├── customer-success/   カスタマーサクセス      (3)
├── people/             人事・組織              (2)
├── finance/            財務・経理              (2)
├── legal/              法務・コンプライアンス  (3)
├── it-systems/         情報システム            (1)
├── operations/         運用・SRE               (2)
└── project-management/ プロジェクト管理        (4)
```

---

## ファイル構成

```
agentic-company/
├── README.md               # このファイル
├── CLAUDE.md               # Claude Code 向け運用指針
├── organization.yaml       # 組織構成の SSOT（全エージェント定義）
├── docs/
│   └── PLAN.md             # 設計方針・部門詳細・変更履歴
└── .claude/
    └── agents/             # エージェント定義ファイル（14部門）
        ├── executive/
        │   ├── chief-of-staff.md
        │   └── biz-dev-strategist.md
        ├── engineering/
        │   ├── frontend-developer.md
        │   ├── backend-architect.md
        │   ├── database-engineer.md
        │   ├── devops-engineer.md
        │   └── security-engineer.md
        ├── ... （以下14部門）
```

---

## エージェント一覧

| 部門 | エージェント | 役割 |
|------|-------------|------|
| **executive** | chief-of-staff | 全社OKR管理・経営会議運営・部門横断調整 |
| | biz-dev-strategist | パートナーシップ戦略・新規事業開発・M&A探索 |
| **engineering** | frontend-developer | React/TypeScript UIコンポーネント実装 |
| | backend-architect | Node.js/Express API設計・認証フロー |
| | database-engineer | PostgreSQLスキーマ設計・クエリ最適化 |
| | devops-engineer | CI/CD・Docker・インフラ自動化 |
| | security-engineer | 脆弱性対策・セキュリティレビュー |
| **product** | product-manager | 要件定義・ロードマップ管理・優先順位付け |
| | trend-researcher | 市場調査・競合分析・技術トレンド |
| **design** | ui-designer | デザインシステム・UIコンポーネント設計 |
| | ux-researcher | ユーザビリティ分析・UX改善提案 |
| | brand-guardian | ブランド一貫性・スタイルガイド管理 |
| **quality-assurance** | test-engineer | ユニット/統合テスト（Jest） |
| | e2e-tester | E2Eテスト（Playwright） |
| | api-tester | APIテスト・負荷テスト・契約テスト |
| | performance-analyst | パフォーマンス計測・ボトルネック分析 |
| **sales** | account-executive | 新規顧客獲得・商談推進・クロージング |
| | sales-development-rep | インサイドセールス・リード開拓 |
| | account-manager | 既存顧客拡販・QBR・更新交渉 |
| | sales-enabler | 営業資料・デモ準備・競合比較資料 |
| **marketing** | content-writer | 技術ブログ・ホワイトペーパー・ドキュメント |
| | seo-strategist | SEO戦略・テクニカルSEO・キーワード分析 |
| | growth-hacker | グロース施策・A/Bテスト・ファネル最適化 |
| **customer-success** | customer-success-manager | ヘルススコア管理・チャーン防止・Success Plan |
| | onboarding-specialist | 新規顧客導入支援・トレーニング |
| | support-responder | 問い合わせ対応・FAQ管理・バグトリアージ |
| **people** | hr-generalist | 評価制度・育成・組織文化・労務管理 |
| | recruiter | 採用活動・JD作成・候補者選考 |
| **finance** | finance-controller | 財務管理・予算・SaaSメトリクス分析 |
| | billing-specialist | 請求処理・価格設計・収益認識 |
| **legal** | legal-counsel | 契約審査・知財管理・法的リスク評価 |
| | compliance-checker | GDPR/個人情報法・SOC2対応 |
| | internal-auditor | 内部監査・内部統制評価・ガバナンス |
| **it-systems** | it-administrator | 社内IT管理・SSO/MFA・SaaSツール管理 |
| **operations** | infrastructure-maintainer | インフラ監視・障害対応・SLO管理 |
| | analytics-reporter | データ分析・KPIダッシュボード |
| **project-management** | project-lead | プロジェクト統括・進捗管理 |
| | scrum-master | スクラムプロセス運営・障害除去 |
| | sprint-planner | スプリント計画・タスク分解・見積もり |
| | release-manager | リリース計画・デプロイ調整 |

---

## 使い方

### エージェントを呼び出す

Claude Code のセッション内で、タスクに応じたエージェントが自動的に選択されます。
明示的に呼び出す場合は、`Agent` ツールで対象エージェントの `name` を指定します。

```
例：「APIのセキュリティレビューをしてほしい」
→ security-engineer が呼び出される

例：「スプリント計画を立てたい」
→ sprint-planner が呼び出される
```

### 組織構成を変更する

`organization.yaml` が **Single Source of Truth** です。変更時は以下の順で更新します。

```
1. organization.yaml を更新
2. .claude/agents/<department>/<agent>.md を更新
3. docs/PLAN.md のテーブルを更新
```

詳細な運用指針は [`CLAUDE.md`](CLAUDE.md) を参照してください。

---

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [`CLAUDE.md`](CLAUDE.md) | Claude Code 向け運用指針・原則 |
| [`organization.yaml`](organization.yaml) | 全エージェントの定義（役割・責務・ツール） |
| [`docs/PLAN.md`](docs/PLAN.md) | 設計方針・部門詳細・v1→v2変更履歴 |
