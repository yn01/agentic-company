# Agentic Company

> B2B SaaS Webサービスベンダーを模した、Claude Code 向けエージェント組織定義リポジトリ

Claude Code の [`.claude/agents/`](https://docs.anthropic.com/ja/docs/claude-code/sub-agents) 機能と Worktree を使い、実際の会社組織に対応した **1 orchestrator + 12 leads + 14部門・45エージェント** を定義しています。

---

## 組織構成

```
Yohei（ユーザー）
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

```
agentic-company/
├── README.md               # このファイル
├── CLAUDE.md               # Claude Code 向け運用指針
├── organization.yaml       # 組織構成 SSOT（全エージェント定義）
├── docs/
│   └── PLAN.md             # 設計方針・部門詳細・変更履歴
├── scripts/
│   ├── start_worktrees.sh  # パイプライン選択式起動
│   ├── stop_worktrees.sh   # 停止 + Obsidianアーカイブ
│   └── watch_inbox.sh      # inbox監視（バックグラウンド）
└── .claude/
    ├── agents/             # エージェント定義（orchestrator + 14部門）
    ├── messages/inbox/     # 各エージェントのメッセージ受信ボックス
    ├── state/              # agent_status.json（idle/busy管理）
    ├── logs/               # watch_inbox.sh ログ
    └── worktrees/          # git worktree マウント先
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

### Worktree パイプラインで動かす

```bash
bash scripts/start_worktrees.sh
# → 1) プロダクト開発  2) カスタム
# → 選択後、必要なエージェントが tmux + git worktree で起動
# → orchestrator のウィンドウにタスクを入力するだけ
```

### エージェントを直接呼び出す

Claude Code のセッション内で、タスクに応じたエージェントが自動選択されます。

```
例：「APIのセキュリティレビューをして」 → security-engineer が呼び出される
例：「スプリント計画を立てて」          → sprint-planner が呼び出される
```

### 組織構成を変更する

`organization.yaml` が **Single Source of Truth** です。変更時は以下の順で更新します。

```
1. organization.yaml を更新
2. .claude/agents/<department>/<agent>.md を更新（新規または編集）
3. docs/PLAN.md のテーブルを更新
4. CLAUDE.md のクイックリファレンスを更新
```

---

## ドキュメント

| ファイル | 内容 |
|---------|------|
| [`CLAUDE.md`](CLAUDE.md) | Claude Code 向け運用指針・ルーティング原則 |
| [`organization.yaml`](organization.yaml) | 全エージェントの定義（役割・責務・ツール・activation） |
| [`docs/PLAN.md`](docs/PLAN.md) | 組織階層・部門詳細・設計方針・変更履歴 |
