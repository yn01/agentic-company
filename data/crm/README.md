# CRM モックデータ

マーケティング・営業業務のClaude Code再現用モックデータ。

## ディレクトリ構成

```
data/crm/
├── raw/                    # Salesforce形式（SF APIエクスポートに近い生データ）
│   ├── Account/            # アカウント（SFオブジェクト形式）
│   │   ├── 001A1001.json   # テック株式会社
│   │   └── 001A1002.json   # グローバル商事
│   ├── Lead/               # リード（SFオブジェクト形式）
│   │   ├── 00QL2001.json   # フューチャー工業
│   │   └── 00QL2002.json   # スタートアップ株式会社
│   └── Opportunity/        # 商談（SFオブジェクト形式）
│       ├── 006O2001.json   # フューチャー工業 - Enterprise導入
│       └── 006O2002.json   # グローバル商事 - Enterprise Upsell
├── normalized/             # Claude Agentが読みやすい正規化済みデータ
│   ├── accounts/           # アカウント（正規化形式）
│   │   ├── account_001.json
│   │   └── account_002.json
│   ├── leads/              # リード（正規化形式）
│   │   ├── lead_001.json
│   │   └── lead_002.json
│   └── opportunities/      # 商談（正規化形式）
│       ├── opportunity_001.json
│       └── opportunity_002.json
├── events/                 # イベントキュー（処理待ちイベント）
├── campaigns/              # キャンペーン定義・結果
└── output/                 # エージェントが生成した成果物
```

## raw/ と normalized/ の使い分け

### raw/（Salesforce形式）

- **用途**: Salesforce APIエクスポートに近い生データ。SF連携・データ同期・外部システムとの統合時に使用。
- **特徴**:
  - SF標準フィールド名（`Id`, `Name`, `StageName` など PascalCase）
  - カスタム項目は `Custom_XXX__c` 形式
  - `attributes` ブロックにオブジェクト種別とAPIパスを含む
  - ID形式はSFレコードID（例: `001A1001`, `00QL2001`）
- **推奨**: SF連携ロジックの検証、データ取り込みシナリオのテスト

### normalized/（正規化形式）

- **用途**: Claude Agentが推論・分析・アクション生成を行う際のメイン参照データ。
- **特徴**:
  - snake_case フィールド名で読みやすい
  - 配列・ネストオブジェクトで構造化（セミコロン区切り文字列なし）
  - 内部ID形式（例: `A-1001`, `L-2001`）
  - 不要なメタデータを除いたシンプルな構造
- **推奨**: エージェントの意思決定、レポート生成、アクション判断

### イベントからのデータ参照

イベントファイルの `subject` フィールドに `raw_ref` と `normalized_ref` の両方を記載。
用途に応じて適切な方を参照すること。

```json
"subject": {
  "entity_type": "Lead",
  "entity_id": "00QL2001",
  "raw_ref": "../raw/Lead/00QL2001.json",
  "normalized_ref": "../normalized/leads/lead_001.json"
}
```

## IDマッピング

| normalized ID | Salesforce ID | エンティティ |
|---------------|---------------|-------------|
| A-1001 | 001A1001 | テック株式会社 (Account) |
| A-1002 | 001A1002 | グローバル商事 (Account) |
| L-2001 | 00QL2001 | フューチャー工業 (Lead) |
| L-2002 | 00QL2002 | スタートアップ株式会社 (Lead) |
| O-2001 | 006O2001 | フューチャー工業 - Enterprise導入 (Opportunity) |
| O-2002 | 006O2002 | グローバル商事 - Enterprise Upsell (Opportunity) |

## イベントスキーマ

```json
{
  "id": "EVT-XXXX",
  "type": "<event_type>",
  "priority": "critical | high | medium | low",
  "timestamp": "<ISO8601>",
  "status": "pending | processing | done | error",
  "subject": {
    "entity_type": "Lead | Account | Opportunity",
    "entity_id": "<Salesforce形式ID>",
    "raw_ref": "<raw/形式JSONへの相対パス>",
    "normalized_ref": "<normalized/形式JSONへの相対パス>"
  },
  "payload": { ... },
  "routing_hint": "<部門lead名>",
  "required_actions": ["<アクション>"]
}
```

## イベント種別とルーティング

| type | priority | routing_hint | 担当部門 |
|------|----------|-------------|---------|
| `lead_status_change` | high | sales_lead | 営業部門 |
| `renewal_risk_alert` | critical | cs_lead | カスタマーサクセス |
| `upsell_signal` | medium | sales_lead | 営業部門 |
| `new_mql` | medium | marketing_lead | マーケティング |
| `support_escalation` | critical | cs_lead | カスタマーサクセス |
| `competitor_mention` | high | sales_lead | 営業部門 |
| `nps_detractor` | high | cs_lead | カスタマーサクセス |
| `campaign_response` | low | marketing_lead | マーケティング |

## イベント処理フロー

```
events/*.json (status: pending)
  ↓ orchestratorが検知
  ↓ event.type と routing_hint に基づき部門leadへ送信
  ↓ 各leadが担当メンバーに委託
  ↓ 成果物を output/<EVT-ID>/ に保存
  ↓ event.status を "done" に更新
```

## 成果物フォーマット（output/）

```
output/
└── EVT-3001/
    ├── summary.md          # 対応方針サマリー
    ├── email_draft.md      # メール文案
    ├── proposal.md         # 提案書（必要な場合）
    └── next_actions.md     # 次のアクションリスト
```
