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

**52エージェント（orchestrator × 1 + department leads × 12 + メンバー × 38 + lead兼任 × 1）**で構成。詳細は以下を参照:

- 全体構成・部門一覧 → [`docs/PLAN.md`](docs/PLAN.md)
- 各エージェントの定義（役割・責務・ツール）→ [`organization.yaml`](organization.yaml)
- エージェントファイル → [`.claude/agents/`](.claude/agents/)

### 組織階層

```
Yohei → orchestrator [Opus] → department leads [Sonnet] → individual agents [Sonnet]
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

## ファイル構成

```
agentic-company/
├── CLAUDE.md               # このファイル
├── organization.yaml       # 組織構成 SSOT
├── docs/
│   └── PLAN.md             # 設計方針・変更履歴・部門詳細
├── scripts/
│   ├── start_worktrees.sh  # パイプライン選択式起動
│   ├── stop_worktrees.sh   # 停止 + Obsidianアーカイブ
│   └── watch_inbox.sh      # inbox監視（バックグラウンド）
└── .claude/
    ├── agents/             # エージェント定義（orchestrator + 14部門）
    ├── messages/
    │   ├── inbox/          # 各エージェントのメッセージ受信ボックス
    │   ├── sent/           # 送信済みメッセージ
    │   └── processed/      # 処理済みメッセージ
    ├── state/              # agent_status.json（idle/busy管理）
    ├── logs/               # watch_inbox.shのログ
    └── worktrees/          # git worktreeマウント先
```

## Worktree パイプライン起動

```bash
# 起動（パイプライン選択: プロダクト開発 or カスタム）
bash scripts/start_worktrees.sh

# 停止（メッセージアーカイブ → tmux終了）
bash scripts/stop_worktrees.sh
```

### パイプライン: プロダクト開発

orchestrator → product-lead → engineering-lead → qa-lead → release-manager

起動エージェント（10名）: orchestrator[Opus], product-lead, product-manager, engineering-lead, frontend-developer, backend-architect, qa-lead, test-engineer, e2e-tester, release-manager

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
