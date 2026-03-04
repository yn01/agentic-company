# Agentic Company - B2B SaaS Web Service Vendor の組織構成

## Context
B2B SaaS（React + Node.js）を提供するWebサービスベンダーとしてのエージェント組織。
実際の会社運営に必要な全部門を網羅した構成。

**実装方式**: `.claude/agents/` でエージェント定義 + `organization.yaml`（Single Source of Truth）

---

## 組織構成（14部門・44エージェント）

### 1. executive/ — 経営・事業開発（2名）
| エージェント | 役割 |
|---|---|
| chief-of-staff | 全社OKR管理、経営会議運営、部門横断調整、取締役会資料 |
| biz-dev-strategist | パートナーシップ戦略、新規事業開発、M&A探索 |

### 2. engineering/ — エンジニアリング（5名）
| エージェント | 役割 |
|---|---|
| frontend-developer | React/TypeScriptによるフロントエンド開発 |
| backend-architect | Node.js/Express APIの設計・実装 |
| database-engineer | DB設計、クエリ最適化、マイグレーション |
| devops-engineer | CI/CD、Docker、インフラ自動化 |
| security-engineer | 認証認可、脆弱性対策、セキュリティレビュー |

### 3. product/ — プロダクト（2名）
| エージェント | 役割 |
|---|---|
| product-manager | 要件定義、優先順位付け、ロードマップ管理 |
| trend-researcher | 市場調査、競合分析、技術トレンド調査 |

### 4. design/ — デザイン（3名）
| エージェント | 役割 |
|---|---|
| ui-designer | UIコンポーネント設計、デザインシステム |
| ux-researcher | ユーザビリティ分析、UX改善提案 |
| brand-guardian | ブランド一貫性、スタイルガイド管理 |

### 5. quality-assurance/ — 品質保証（4名）
| エージェント | 役割 |
|---|---|
| test-engineer | ユニット/統合テスト設計・実装 |
| e2e-tester | E2Eテスト、Playwright自動化 |
| api-tester | APIテスト、負荷テスト、契約テスト |
| performance-analyst | パフォーマンス計測、ボトルネック分析 |

### 6. sales/ — 営業（4名）
| エージェント | 役割 |
|---|---|
| account-executive | 新規顧客獲得、商談推進、クロージング |
| sales-development-rep | インサイドセールス、リード開拓・qualification |
| account-manager | 既存顧客拡販、QBR、更新交渉 |
| sales-enabler | 営業資料、デモ準備、競合比較資料 |

### 7. marketing/ — マーケティング（3名）
| エージェント | 役割 |
|---|---|
| content-writer | ブログ、ホワイトペーパー、ドキュメント作成 |
| seo-strategist | SEO戦略、キーワード分析、テクニカルSEO |
| growth-hacker | グロース施策、A/Bテスト、ファネル最適化 |

### 8. customer-success/ — カスタマーサクセス（3名）
| エージェント | 役割 |
|---|---|
| customer-success-manager | ヘルススコア管理、チャーン防止、Success Plan |
| onboarding-specialist | 新規顧客導入支援、トレーニング、Time-to-Value最短化 |
| support-responder | カスタマーサポート、FAQ管理、バグトリアージ |

### 9. people/ — 人事・組織（2名）
| エージェント | 役割 |
|---|---|
| hr-generalist | 評価制度、育成、組織文化、労務管理 |
| recruiter | 採用活動、JD作成、候補者選考、オファー |

### 10. finance/ — 財務・経理（2名）
| エージェント | 役割 |
|---|---|
| finance-controller | 財務管理、予算策定、SaaSメトリクス分析 |
| billing-specialist | 請求処理、価格設計、収益認識、サブスク管理 |

### 11. legal/ — 法務・コンプライアンス・内部監査（3名）
| エージェント | 役割 |
|---|---|
| legal-counsel | 契約審査、知財管理、法的リスク評価 |
| compliance-checker | GDPR/個人情報法、SOC2、ベンダーリスク評価 |
| internal-auditor | 内部監査、内部統制評価、ガバナンス |

### 12. it-systems/ — 情報システム（1名）
| エージェント | 役割 |
|---|---|
| it-administrator | 社内IT管理、SSO/MFA、SaaSツール管理、ゼロトラスト |

### 13. operations/ — 運用・SRE・データ分析（2名）
| エージェント | 役割 |
|---|---|
| infrastructure-maintainer | インフラ監視、障害対応、SLO管理、SRE |
| analytics-reporter | データ分析、KPIダッシュボード、レポート作成 |

### 14. project-management/ — プロジェクト管理（4名）
| エージェント | 役割 |
|---|---|
| project-lead | プロジェクト全体統括、進捗管理 |
| scrum-master | スクラムプロセス運営、障害除去 |
| sprint-planner | スプリント計画、タスク分解、見積もり |
| release-manager | リリース計画、バージョン管理、デプロイ調整 |

---

## ファイル構成

```
agentic-company/
├── organization.yaml          # 組織構成の正（SSOT）
├── docs/
│   └── PLAN.md                # このファイル
├── .claude/
│   └── agents/
│       ├── executive/
│       │   ├── chief-of-staff.md
│       │   └── biz-dev-strategist.md
│       ├── engineering/
│       │   ├── frontend-developer.md
│       │   ├── backend-architect.md
│       │   ├── database-engineer.md
│       │   ├── devops-engineer.md
│       │   └── security-engineer.md
│       ├── product/
│       │   ├── product-manager.md
│       │   └── trend-researcher.md
│       ├── design/
│       │   ├── ui-designer.md
│       │   ├── ux-researcher.md
│       │   └── brand-guardian.md
│       ├── quality-assurance/
│       │   ├── test-engineer.md
│       │   ├── e2e-tester.md
│       │   ├── api-tester.md
│       │   └── performance-analyst.md
│       ├── sales/
│       │   ├── account-executive.md
│       │   ├── sales-development-rep.md
│       │   ├── account-manager.md
│       │   └── sales-enabler.md
│       ├── marketing/
│       │   ├── content-writer.md
│       │   ├── seo-strategist.md
│       │   └── growth-hacker.md
│       ├── customer-success/
│       │   ├── customer-success-manager.md
│       │   ├── onboarding-specialist.md
│       │   └── support-responder.md
│       ├── people/
│       │   ├── hr-generalist.md
│       │   └── recruiter.md
│       ├── finance/
│       │   ├── finance-controller.md
│       │   └── billing-specialist.md
│       ├── legal/
│       │   ├── legal-counsel.md
│       │   ├── compliance-checker.md
│       │   └── internal-auditor.md
│       ├── it-systems/
│       │   └── it-administrator.md
│       ├── operations/
│       │   ├── infrastructure-maintainer.md
│       │   └── analytics-reporter.md
│       └── project-management/
│           ├── project-lead.md
│           ├── scrum-master.md
│           ├── sprint-planner.md
│           └── release-manager.md
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
