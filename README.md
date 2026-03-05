# Agentic Company

> B2B SaaS Webサービスベンダーを模した、Claude Code 向けエージェント組織定義リポジトリ

Claude Code の [`.claude/agents/`](https://docs.anthropic.com/ja/docs/claude-code/sub-agents) 機能と Worktree を使い、実際の会社組織に対応した **52エージェント** を定義しています。

本リポジトリは**組織定義のマスター**であり、実際のプロダクト開発は `create_product.sh` で生成した**プロダクトリポジトリ**で行います（Pattern D 方式）。

---

## 組織構成

```
ユーザー
  └─ orchestrator [Opus]          全社指揮・ルーティング
       ├─ product-lead            → product-manager, trend-researcher
       ├─ engineering-lead        → frontend-developer, backend-architect, database-engineer, devops-engineer, security-engineer
       ├─ qa-lead                 → test-engineer, e2e-tester, api-tester, performance-analyst
       ├─ design-lead             → ui-designer, ux-researcher, brand-guardian
       ├─ sales-lead              → account-executive, sales-development-rep, account-manager, sales-enabler
       ├─ marketing-lead          → content-writer, seo-strategist, growth-hacker
       ├─ cs-lead                 → customer-success-manager, onboarding-specialist, support-responder
       ├─ people-lead             → hr-generalist, recruiter
       ├─ finance-lead            → finance-controller, billing-specialist
       ├─ legal-lead              → legal-counsel, compliance-checker, internal-auditor  [on-demand]
       ├─ operations-lead         → infrastructure-maintainer, analytics-reporter
       ├─ project-lead            → scrum-master, sprint-planner, release-manager
       ├─ chief-of-staff          （executive 1人部門・直接窓口）
       └─ it-administrator        （it-systems 1人部門・直接窓口）
```

### メッセージルーティング原則

- orchestrator は **必ず部門 lead のinboxにのみ** メッセージを送る
- 個別エージェントへの orchestrator からの直接送信は**禁止**
- 例外: `chief-of-staff`・`it-administrator`（1人部門）は直接窓口

---

## パイプライン: プロダクト開発

```
orchestrator
  → product-lead → product-manager（要件定義・仕様書）
  → engineering-lead → frontend-developer + backend-architect（実装）
  → qa-lead → test-engineer + e2e-tester（テスト・品質承認）
  → release-manager（リリース・コミット）
```

### Worktree 起動

```bash
# パイプライン選択式起動（プロダクト開発 or カスタム）
bash scripts/start_worktrees.sh

# 停止（Obsidianアーカイブ + tmux終了）
bash scripts/stop_worktrees.sh
```

---

## ファイル構成

### agentic-company（このリポ）= 組織マスター

```
agentic-company/
├── README.md               # このファイル
├── CLAUDE.md               # 運用指針（プロダクトリポにも同期）
├── organization.yaml       # 組織構成 SSOT
├── docs/
│   └── PLAN.md             # 設計方針・部門詳細・変更履歴
├── scripts/
│   ├── create_product.sh   # 新プロダクトリポ生成
│   ├── sync_agents.sh      # エージェント定義同期
│   ├── start_worktrees.sh  # パイプライン起動（プロダクトにコピー）
│   ├── stop_worktrees.sh   # 停止（プロダクトにコピー）
│   └── watch_inbox.sh      # inbox監視（プロダクトにコピー）
├── hooks/
│   ├── post-commit-sync.sh # push型自動同期フック
│   └── product_repos.txt   # 同期先プロダクトリポ一覧
└── .claude/
    └── agents/             # エージェント定義のみ（52エージェント）
```

### プロダクトリポ（`create_product.sh` で生成）

```
my-saas-app/
├── CLAUDE.md               # org共通(自動同期) + プロダクト固有
├── organization.yaml       # agentic-companyから同期
├── scripts/                # agentic-companyから同期
├── .claude/
│   ├── sync_source.conf    # 同期元パス設定
│   ├── agents/             # agentic-companyから同期
│   ├── messages/inbox/     # エージェント間メッセージ
│   ├── state/              # idle/busy管理
│   ├── logs/               # watchログ
│   └── worktrees/          # git worktreeマウント先
├── src/                    # プロダクトソースコード
└── docs/
```

---

## エージェント一覧

| 部門 | lead | メンバーエージェント |
|------|------|---------------------|
| **executive** | chief-of-staff（直接窓口） | biz-dev-strategist |
| **engineering** | engineering-lead | frontend-developer, backend-architect, database-engineer, devops-engineer, security-engineer |
| **product** | product-lead | product-manager, trend-researcher |
| **design** | design-lead | ui-designer, ux-researcher, brand-guardian |
| **quality-assurance** | qa-lead | test-engineer, e2e-tester, api-tester, performance-analyst |
| **sales** | sales-lead | account-executive, sales-development-rep, account-manager, sales-enabler |
| **marketing** | marketing-lead | content-writer, seo-strategist, growth-hacker |
| **customer-success** | cs-lead | customer-success-manager, onboarding-specialist, support-responder |
| **people** | people-lead | hr-generalist, recruiter |
| **finance** | finance-lead | finance-controller, billing-specialist |
| **legal** | legal-lead（on-demand） | legal-counsel, compliance-checker, internal-auditor |
| **it-systems** | it-administrator（直接窓口） | — |
| **operations** | operations-lead | infrastructure-maintainer, analytics-reporter |
| **project-management** | project-lead（兼任） | scrum-master, sprint-planner, release-manager |

---

## 使い方

### 1. 新プロダクトリポを生成

```bash
bash scripts/create_product.sh /path/to/my-saas-app
```

### 2. プロダクトリポでパイプラインを起動

```bash
cd /path/to/my-saas-app
bash scripts/start_worktrees.sh
# → 起動時にagentic-companyから最新を自動同期
# → 1) プロダクト開発  2) カスタム を選択
# → orchestrator のウィンドウに要件を入力するだけ
```

### 3. 同期の仕組み

| 方式 | タイミング | 仕組み |
|------|-----------|--------|
| Pull型（メイン） | `start_worktrees.sh` 実行時 | 冒頭で `sync_agents.sh` が自動実行 |
| Push型（バックアップ） | agentic-companyでコミット時 | `post-commit-sync.sh` が登録済みリポに同期 |

### 4. 組織構成を変更する

`organization.yaml` が **Single Source of Truth** です。

```
1. agentic-company で organization.yaml を更新
2. .claude/agents/<department>/<agent>.md を更新
3. docs/PLAN.md のテーブルを更新
4. コミット → プロダクトリポに自動同期
```

---

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [`CLAUDE.md`](CLAUDE.md) | Claude Code 向け運用指針・ルーティング原則 |
| [`organization.yaml`](organization.yaml) | 全エージェントの定義（役割・責務・ツール・activation） |
| [`docs/PLAN.md`](docs/PLAN.md) | 組織階層・部門詳細・設計方針・変更履歴 |
