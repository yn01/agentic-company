# Agentic Company - B2B SaaS Web Service Vendor の組織構成

## Context
B2B SaaS（React + Node.js）を提供するWebサービスベンダーとしてのエージェント組織。
実際の会社運営に必要な全部門を網羅した構成。

**実装方式**: `.claude/agents/` でエージェント定義 + `organization.yaml`（Single Source of Truth）

---

## 組織階層

```
Yohei（ユーザー）
  └─ orchestrator [Opus]  ← 全社指揮・クロス部門調整
       ├─ product-lead [Sonnet]       → product-manager, trend-researcher
       ├─ engineering-lead [Sonnet]   → frontend-developer, backend-architect, database-engineer, devops-engineer, security-engineer
       ├─ qa-lead [Sonnet]            → test-engineer, e2e-tester, api-tester, performance-analyst
       ├─ design-lead [Sonnet]        → ui-designer, ux-researcher, brand-guardian
       ├─ sales-lead [Sonnet]         → account-executive, sales-development-rep, account-manager, sales-enabler
       ├─ marketing-lead [Sonnet]     → content-writer, seo-strategist, growth-hacker
       ├─ cs-lead [Sonnet]            → customer-success-manager, onboarding-specialist, support-responder
       ├─ people-lead [Sonnet]        → hr-generalist, recruiter
       ├─ finance-lead [Sonnet]       → finance-controller, billing-specialist
       ├─ legal-lead [Sonnet]         → legal-counsel, compliance-checker, internal-auditor  ※on-demand
       ├─ operations-lead [Sonnet]    → infrastructure-maintainer, analytics-reporter
       ├─ project-lead [Sonnet]       → scrum-master, sprint-planner, release-manager
       ├─ chief-of-staff [Sonnet]     （executive部門・1人のため直接窓口）
       └─ it-administrator [Sonnet]   （it-systems部門・1人のため直接窓口）
```

### メッセージルーティング原則

- orchestrator は **必ず部門lead のinboxにのみ** メッセージを送る
- 個別エージェント（frontend-developer 等）への orchestrator からの直接送信は**禁止**
- 例外: `chief-of-staff`（executive 1人部門）・`it-administrator`（it-systems 1人部門）は直接窓口

### パイプライン: プロダクト開発

```
orchestrator
  → product-lead → product-manager（要件定義・仕様書）
  → engineering-lead → frontend-developer + backend-architect（実装）
  → qa-lead → test-engineer + e2e-tester（テスト・品質承認）
  → release-manager（リリース・コミット）
```

### Worktree起動

```bash
bash scripts/start_worktrees.sh   # パイプライン選択: プロダクト開発 or カスタム
bash scripts/stop_worktrees.sh    # 停止 + Obsidianアーカイブ
```

---

## 組織構成（合計52エージェント）

| カテゴリ | 数 | 内訳 |
|---|---|---|
| orchestrator | 1 | orchestrator |
| department leads（専任） | 11 | product/engineering/qa/design/sales/marketing/cs/people/finance/legal/operations |
| lead兼任（既存） | 2 | chief-of-staff（executive）, project-lead（project-management） |
| メンバーエージェント | 38 | 各部門の個別エージェント |
| **合計** | **52** | |

### orchestrator — 全社オーケストレーター
| エージェント | 役割 | activation | model |
|---|---|---|---|
| orchestrator | 全社指揮・ルーティング・進捗追跡 | always | Opus |

### department leads — 部門リード一覧
| エージェント | 管轄部門 | 管轄エージェント | activation |
|---|---|---|---|
| product-lead | product | product-manager, trend-researcher | always |
| engineering-lead | engineering | frontend-developer, backend-architect, database-engineer, devops-engineer, security-engineer | always |
| qa-lead | quality-assurance | test-engineer, e2e-tester, api-tester, performance-analyst | always |
| design-lead | design | ui-designer, ux-researcher, brand-guardian | always |
| sales-lead | sales | account-executive, sales-development-rep, account-manager, sales-enabler | always |
| marketing-lead | marketing | content-writer, seo-strategist, growth-hacker | always |
| cs-lead | customer-success | customer-success-manager, onboarding-specialist, support-responder | always |
| people-lead | people | hr-generalist, recruiter | always |
| finance-lead | finance | finance-controller, billing-specialist | always |
| legal-lead | legal | legal-counsel, compliance-checker, internal-auditor | on-demand |
| operations-lead | operations | infrastructure-maintainer, analytics-reporter | always |
| project-lead | project-management | scrum-master, sprint-planner, release-manager | always |
| chief-of-staff | executive（1人部門） | biz-dev-strategist | always（直接窓口） |
| it-administrator | it-systems（1人部門） | — | always（直接窓口） |

---

### 1. executive/ — 経営・事業開発
| エージェント | 役割 | activation |
|---|---|---|
| chief-of-staff | OKR管理、経営会議運営、取締役会資料（＋orchestrator直接窓口） | always |
| biz-dev-strategist | パートナーシップ戦略、新規事業開発、M&A探索 | on-demand |

### 2. engineering/ — エンジニアリング（lead: engineering-lead）
| エージェント | 役割 | activation |
|---|---|---|
| engineering-lead | engineering部門サブオーケストレーター | always |
| frontend-developer | React/TypeScriptによるフロントエンド開発 | always |
| backend-architect | Node.js/Express APIの設計・実装 | always |
| database-engineer | DB設計、クエリ最適化、マイグレーション | always |
| devops-engineer | CI/CD、Docker、インフラ自動化 | always |
| security-engineer | 認証認可、脆弱性対策、セキュリティレビュー | on-demand |

### 3. product/ — プロダクト（lead: product-lead）
| エージェント | 役割 | activation |
|---|---|---|
| product-lead | product部門サブオーケストレーター | always |
| product-manager | 要件定義、優先順位付け、ロードマップ管理 | always |
| trend-researcher | 市場調査、競合分析、技術トレンド調査 | on-demand |

### 4. design/ — デザイン（lead: design-lead）
| エージェント | 役割 | activation |
|---|---|---|
| design-lead | design部門サブオーケストレーター | always |
| ui-designer | UIコンポーネント設計、デザインシステム | always |
| ux-researcher | ユーザビリティ分析、UX改善提案 | on-demand |
| brand-guardian | ブランド一貫性、スタイルガイド管理 | on-demand |

### 5. quality-assurance/ — 品質保証（lead: qa-lead）
| エージェント | 役割 | activation |
|---|---|---|
| qa-lead | QA部門サブオーケストレーター | always |
| test-engineer | ユニット/統合テスト設計・実装 | always |
| e2e-tester | E2Eテスト、Playwright自動化 | always |
| api-tester | APIテスト、負荷テスト、契約テスト | always |
| performance-analyst | パフォーマンス計測、ボトルネック分析 | on-demand |

### 6. sales/ — 営業（lead: sales-lead）
| エージェント | 役割 | activation |
|---|---|---|
| sales-lead | sales部門サブオーケストレーター | always |
| account-executive | 新規顧客獲得、商談推進、クロージング | always |
| sales-development-rep | インサイドセールス、リード開拓・qualification | always |
| account-manager | 既存顧客拡販、QBR、更新交渉 | always |
| sales-enabler | 営業資料、デモ準備、競合比較資料 | on-demand |

### 7. marketing/ — マーケティング（lead: marketing-lead）
| エージェント | 役割 | activation |
|---|---|---|
| marketing-lead | marketing部門サブオーケストレーター | always |
| content-writer | ブログ、ホワイトペーパー、ドキュメント作成 | always |
| seo-strategist | SEO戦略、キーワード分析、テクニカルSEO | always |
| growth-hacker | グロース施策、A/Bテスト、ファネル最適化 | on-demand |

### 8. customer-success/ — カスタマーサクセス（lead: cs-lead）
| エージェント | 役割 | activation |
|---|---|---|
| cs-lead | customer-success部門サブオーケストレーター | always |
| customer-success-manager | ヘルススコア管理、チャーン防止、Success Plan | always |
| onboarding-specialist | 新規顧客導入支援、Time-to-Value最短化 | always |
| support-responder | カスタマーサポート、FAQ管理、バグトリアージ | always |

### 9. people/ — 人事・組織（lead: people-lead）
| エージェント | 役割 | activation |
|---|---|---|
| people-lead | people部門サブオーケストレーター | always |
| hr-generalist | 評価制度、育成、組織文化、労務管理 | always |
| recruiter | 採用活動、JD作成、候補者選考、オファー | always |

### 10. finance/ — 財務・経理（lead: finance-lead）
| エージェント | 役割 | activation |
|---|---|---|
| finance-lead | finance部門サブオーケストレーター | always |
| finance-controller | 財務管理、予算策定、SaaSメトリクス分析 | always |
| billing-specialist | 請求処理、価格設計、収益認識、サブスク管理 | always |

### 11. legal/ — 法務・コンプライアンス・内部監査（lead: legal-lead）
| エージェント | 役割 | activation |
|---|---|---|
| legal-lead | legal部門サブオーケストレーター | on-demand |
| legal-counsel | 契約・交渉・知財（対外的法律行為） | on-demand |
| compliance-checker | 利用規約・プライバシー・SOC2/GDPR（内部コンプライアンス） | on-demand |
| internal-auditor | 内部監査、内部統制評価、ガバナンス | on-demand |

### 12. it-systems/ — 情報システム（直接窓口）
| エージェント | 役割 | activation |
|---|---|---|
| it-administrator | 社内IT管理、SSO/MFA、SaaSツール管理（lead兼任・直接窓口） | always |

### 13. operations/ — 運用・SRE・データ分析（lead: operations-lead）
| エージェント | 役割 | activation |
|---|---|---|
| operations-lead | operations部門サブオーケストレーター | always |
| infrastructure-maintainer | インフラ監視、障害対応、SLO管理、SRE | always |
| analytics-reporter | データ分析、KPIダッシュボード、レポート作成 | always |

### 14. project-management/ — プロジェクト管理（lead: project-lead）
| エージェント | 役割 | activation |
|---|---|---|
| project-lead | 実行レイヤー統括・lead兼任（スプリント計画・進捗管理） | always |
| scrum-master | スクラムプロセス運営、障害除去 | always |
| sprint-planner | スプリント計画、タスク分解、見積もり | always |
| release-manager | リリース計画、バージョン管理、デプロイ調整 | always |

---

## ファイル構成

```
agentic-company/
├── CLAUDE.md                  # プロジェクト指示・クイックリファレンス
├── organization.yaml          # 組織構成 SSOT
├── docs/
│   └── PLAN.md                # このファイル（設計方針・部門詳細）
├── scripts/
│   ├── start_worktrees.sh     # パイプライン選択式起動
│   ├── stop_worktrees.sh      # 停止 + Obsidianアーカイブ
│   └── watch_inbox.sh         # inbox監視（バックグラウンド）
└── .claude/
    ├── agents/
    │   ├── orchestrator.md            # 全社オーケストレーター [Opus]
    │   ├── executive/
    │   │   ├── chief-of-staff.md      # 戦略レイヤー・直接窓口
    │   │   └── biz-dev-strategist.md
    │   ├── engineering/
    │   │   ├── engineering-lead.md    # 部門lead
    │   │   ├── frontend-developer.md
    │   │   ├── backend-architect.md
    │   │   ├── database-engineer.md
    │   │   ├── devops-engineer.md
    │   │   └── security-engineer.md
    │   ├── product/
    │   │   ├── product-lead.md        # 部門lead
    │   │   ├── product-manager.md
    │   │   └── trend-researcher.md
    │   ├── design/
    │   │   ├── design-lead.md         # 部門lead
    │   │   ├── ui-designer.md
    │   │   ├── ux-researcher.md
    │   │   └── brand-guardian.md
    │   ├── quality-assurance/
    │   │   ├── qa-lead.md             # 部門lead
    │   │   ├── test-engineer.md
    │   │   ├── e2e-tester.md
    │   │   ├── api-tester.md
    │   │   └── performance-analyst.md
    │   ├── sales/
    │   │   ├── sales-lead.md          # 部門lead
    │   │   ├── account-executive.md
    │   │   ├── sales-development-rep.md
    │   │   ├── account-manager.md
    │   │   └── sales-enabler.md
    │   ├── marketing/
    │   │   ├── marketing-lead.md      # 部門lead
    │   │   ├── content-writer.md
    │   │   ├── seo-strategist.md
    │   │   └── growth-hacker.md
    │   ├── customer-success/
    │   │   ├── cs-lead.md             # 部門lead
    │   │   ├── customer-success-manager.md
    │   │   ├── onboarding-specialist.md
    │   │   └── support-responder.md
    │   ├── people/
    │   │   ├── people-lead.md         # 部門lead
    │   │   ├── hr-generalist.md
    │   │   └── recruiter.md
    │   ├── finance/
    │   │   ├── finance-lead.md        # 部門lead
    │   │   ├── finance-controller.md
    │   │   └── billing-specialist.md
    │   ├── legal/
    │   │   ├── legal-lead.md          # 部門lead（on-demand）
    │   │   ├── legal-counsel.md
    │   │   ├── compliance-checker.md
    │   │   └── internal-auditor.md
    │   ├── it-systems/
    │   │   └── it-administrator.md    # 1人部門・直接窓口
    │   ├── operations/
    │   │   ├── operations-lead.md     # 部門lead
    │   │   ├── infrastructure-maintainer.md
    │   │   └── analytics-reporter.md
    │   └── project-management/
    │       ├── project-lead.md        # 部門lead兼任（実行レイヤー）
    │       ├── scrum-master.md
    │       ├── sprint-planner.md
    │       └── release-manager.md
    ├── messages/
    │   ├── inbox/                     # 各エージェントのメッセージ受信ボックス
    │   │   ├── orchestrator/
    │   │   ├── product-lead/
    │   │   ├── engineering-lead/
    │   │   ├── qa-lead/
    │   │   ├── design-lead/
    │   │   ├── sales-lead/
    │   │   ├── marketing-lead/
    │   │   ├── cs-lead/
    │   │   ├── people-lead/
    │   │   ├── finance-lead/
    │   │   ├── legal-lead/
    │   │   ├── operations-lead/
    │   │   ├── project-lead/
    │   │   ├── chief-of-staff/
    │   │   └── [個別エージェント]/
    │   ├── sent/                      # 送信済みメッセージ
    │   └── processed/                 # 処理済みメッセージ
    ├── state/
    │   └── agent_status.json          # idle/busy管理
    ├── logs/                          # watch_inbox.shのログ
    └── worktrees/                     # git worktreeマウント先
```

---

## v1 → v2 の変更サマリー

### 新設部門（7部門）
| 部門 | 理由 |
|---|---|
| executive | 全社OKR・経営参謀・事業開発は必須機能 |
| sales | 営業なしにB2B SaaSは成立しない。sales-enablerだけでは不十分 |
| customer-success | サポートと区別。プロアクティブな顧客成功支援 |
| people | 採用・評価・組織文化は会社の根幹 |
| finance | 財務管理・請求・SaaSメトリクスは独立した専門領域 |
| legal | コンプライアンスと法務・内部監査は別機能として分離 |
| it-systems | 社内IT環境・SaaSツール管理は独立した役割 |

### エージェントの移動
| 移動前 | 移動後 | 理由 |
|---|---|---|
| marketing/sales-enabler | sales/sales-enabler | 営業部門の機能として正確 |
| operations/support-responder | customer-success/support-responder | CSの一機能として統合 |
| operations/compliance-checker | legal/compliance-checker | 法務部門の機能として正確 |
| product/sprint-planner | project-management/sprint-planner | PM部門より開発プロセス管理に属する |

### 新規エージェント（12名）
- executive: chief-of-staff, biz-dev-strategist
- sales: account-executive, sales-development-rep, account-manager
- customer-success: customer-success-manager, onboarding-specialist
- people: hr-generalist, recruiter
- finance: finance-controller, billing-specialist
- legal: legal-counsel, internal-auditor
- it-systems: it-administrator

### 削除・統合
- operations の規模を4名→2名に縮小（support/compliance は他部門へ移動）
- product を3名→2名に縮小（sprint-planner は project-management へ移動）
- marketing を4名→3名に縮小（sales-enabler は sales へ移動）

---

## 設計方針

1. **責務の明確な分離**: サポート（reactive）とCS（proactive）、法務と監査など機能を正確に配置
2. **B2B SaaS の収益構造を反映**: ARR成長に直結するSales/CS部門を充実
3. **コーポレート機能の整備**: HR/Finance/Legal/IT は会社運営の基盤として必須
4. **エージェントは呼ばれるために存在する**: 各エージェントの `description` に「いつ使うか」を明記
