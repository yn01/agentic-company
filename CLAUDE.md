# Agentic Company

B2B SaaS（React / TypeScript + Node.js / Express）を提供するWebサービスベンダーの、**エージェント組織マスター定義リポジトリ**。

本リポジトリは組織定義のマスターであり、実際のプロダクト開発は **プロダクトリポジトリ** で行う（Pattern D 方式）。

---

## Principles

- 要件・仕様が曖昧な場合は **AskUserQuestion Tool** で確認してから進めること
- **コンテキスト節約のためサブエージェントへの委託を徹底**すること
  - Explore: コードベース探索・検索
  - Plan: 実装前の設計・計画策定
  - general-purpose: 実装・編集・ドキュメント更新等の実作業
- 大きなタスクは **Agent Teams を活用して並列実行**すること
- `organization.yaml` が組織構成の **Single Source of Truth**。エージェント `.md` はこれに準拠すること
- 新しいエージェントを追加・削除・変更する場合は、`organization.yaml` と `.claude/agents/` の両方を更新すること
- **個人情報（氏名・メールアドレス・ローカルパス等）をコードやドキュメントに含めないこと**。ユーザー固有の値は環境変数や `$HOME` で参照する

---

## エージェント構成

**53エージェント（orchestrator x 1 + department leads x 12 + メンバー x 39 + lead兼任 x 1）**

- 全体構成・部門一覧 → [`docs/PLAN.md`](docs/PLAN.md)
- 各エージェントの定義（役割・責務・ツール）→ [`organization.yaml`](organization.yaml)
- エージェントファイル → [`.claude/agents/`](.claude/agents/)

### 組織階層

```
ユーザー → orchestrator [Opus] → department leads [Sonnet] → individual agents [Sonnet]
```

### メッセージルーティング原則

- **orchestratorは部門leadのinboxにのみ送信する（個別エージェントへの直接送信は禁止）**
- 例外: `chief-of-staff`（executive 1人部門）・`it-administrator`（it-systems 1人部門）は直接窓口

### 部門一覧（クイックリファレンス）

| 部門 | lead | メンバー | activation |
|------|------|---------|-----------|
| orchestrator | — | orchestrator | always [Opus] |
| executive/ | chief-of-staff（直接窓口） | biz-dev-strategist | always/on-demand |
| engineering/ | engineering-lead | frontend/backend/DB/DevOps/security | always |
| product/ | product-lead | product-manager, trend-researcher | always |
| design/ | design-lead | ui-designer, ux-researcher, brand-guardian | always |
| quality-assurance/ | qa-lead | test/e2e/api/performance | always |
| sales/ | sales-lead | AE, SDR, AM, sales-enabler | always |
| marketing/ | marketing-lead | content, SEO, growth | always |
| customer-success/ | cs-lead | CSM, onboarding, support | always |
| people/ | people-lead | hr-generalist, recruiter | always |
| finance/ | finance-lead | finance-controller, billing-specialist | always |
| legal/ | legal-lead | legal-counsel, compliance, auditor | on-demand |
| it-systems/ | it-administrator（直接窓口） | — | always |
| operations/ | operations-lead | infra-maintainer, analytics-reporter | always |
| project-management/ | project-lead（兼任） | scrum-master, sprint-planner, release-manager | always |

---

## リポジトリの役割

### agentic-company（このリポ）= 組織マスター

エージェント定義・スクリプト・組織構成のマスターを管理する。プロダクトコードは置かない。

```
agentic-company/
├── CLAUDE.md               # このファイル（プロダクトリポにも同期される）
├── README.md
├── organization.yaml       # 組織構成 SSOT
├── docs/
│   └── PLAN.md             # 設計方針・変更履歴・部門詳細
├── scripts/
│   ├── create_product.sh   # 新プロダクトリポ生成
│   ├── sync_agents.sh      # エージェント定義同期
│   ├── start_worktrees.sh  # パイプライン選択式起動（プロダクトリポにコピーされる）
│   ├── stop_worktrees.sh   # 停止（プロダクトリポにコピーされる）
│   ├── watch_inbox.sh      # inbox監視（プロダクトリポにコピーされる）
│   └── watch_crm_events.sh # CRMイベント監視（CRMパイプライン用）
├── data/
│   └── crm/                # CRMモックデータ（マーケティングパイプライン用）
│       ├── raw/             # Salesforce形式（Account/Lead/Opportunity）
│       ├── normalized/      # Claude Agent向け正規化データ
│       ├── events/          # イベントキュー（status: pending → 自動検知）
│       ├── campaigns/       # キャンペーン定義・結果
│       └── output/          # エージェントが生成した成果物
├── hooks/
│   ├── post-commit-sync.sh # push型自動同期フック
│   └── product_repos.txt   # 同期先プロダクトリポ一覧
└── .claude/
    └── agents/             # エージェント定義（52エージェント）
```

### プロダクトリポ = 実際の開発場所

`create_product.sh` で生成。ここでWorktreeを起動してプロダクトを開発する。

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
│   ├── frontend/
│   └── backend/
└── docs/
```

---

## プロダクト開発の始め方

```bash
# 1. 新プロダクトリポを生成
bash scripts/create_product.sh /path/to/my-saas-app

# 2. プロダクトリポに移動
cd /path/to/my-saas-app

# 3. Worktreeパイプラインを起動
bash scripts/start_worktrees.sh
# → 起動時にagentic-companyから最新のエージェント定義が自動同期される

# 4. orchestratorのtmuxウィンドウで要件を入力
# → パイプラインが自動で流れる
```

### パイプライン: プロダクト開発

orchestrator → product-lead → engineering-lead → qa-lead → release-manager

起動エージェント（10名）: orchestrator[Opus], product-lead, product-manager, engineering-lead, frontend-developer, backend-architect, qa-lead, test-engineer, e2e-tester, release-manager

---

## 同期の仕組み

### Pull型（起動時自動同期）— メイン

`start_worktrees.sh` の冒頭で `sync_agents.sh` を実行。**起動するたびに必ず最新が同期される**。

### Push型（コミット時自動同期）— バックアップ

`hooks/post-commit-sync.sh` をgit hookとしてインストールすると、agentic-companyで変更をコミットした時に登録済みプロダクトリポに自動同期する。

```bash
# インストール（オプション）
cp hooks/post-commit-sync.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit

# 同期先を登録
echo "/path/to/my-saas-app" >> hooks/product_repos.txt
```

---

## 運用ガイドライン

### エージェント定義の更新手順
1. **agentic-company** で `organization.yaml` を更新（SSOT）
2. 対応する `.claude/agents/<department>/<agent>.md` を更新
3. `docs/PLAN.md` のテーブルを更新
4. コミット → push型同期が作動、またはプロダクトリポで `start_worktrees.sh` 実行時にpull型同期

### 新プロダクトの追加
```bash
bash scripts/create_product.sh /path/to/new-product
echo "/path/to/new-product" >> hooks/product_repos.txt
```
