#!/bin/bash
# =============================================================================
# CRMイベント監視スクリプト
# 使い方: bash scripts/watch_crm_events.sh
# - data/crm/events/*.json の status:pending イベントを検知
# - routing_hint に基づき対応する部門leadのinboxにメッセージを投入
# - イベント処理後に status を "processing" → "done" に更新
# =============================================================================

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CRM_EVENTS_DIR="$PROJECT_ROOT/data/crm/events"
INBOX_BASE="$PROJECT_ROOT/.claude/messages/inbox"
SENT_DIR="$PROJECT_ROOT/.claude/messages/sent"
WATCH_INTERVAL=10

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p "$SENT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  CRMイベント監視 起動${NC}"
echo -e "${BLUE}  監視ディレクトリ: $CRM_EVENTS_DIR${NC}"
echo -e "${BLUE}  ポーリング間隔: ${WATCH_INTERVAL}秒${NC}"
echo -e "${BLUE}========================================${NC}"

# -------------------------------------------------------------------
# イベントJSONからフィールドを取得（jq優先、なければgrep）
# -------------------------------------------------------------------
get_field() {
  local file="$1" field="$2"
  if command -v jq &>/dev/null; then
    jq -r "$field // empty" "$file" 2>/dev/null
  else
    # 簡易grep（ネスト非対応）
    grep -o "\"${field#.}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" \
      | head -1 | sed 's/.*: *"\(.*\)"/\1/'
  fi
}

# イベントのstatusを更新
set_event_status() {
  local file="$1" new_status="$2"
  if command -v jq &>/dev/null; then
    local tmp
    tmp=$(mktemp)
    jq --arg s "$new_status" '.status = $s' "$file" > "$tmp" && mv "$tmp" "$file"
  elif command -v node &>/dev/null; then
    node -e "
      const fs = require('fs');
      const obj = JSON.parse(fs.readFileSync('$file'));
      obj.status = '$new_status';
      fs.writeFileSync('$file', JSON.stringify(obj, null, 2));
    " 2>/dev/null
  fi
}

# -------------------------------------------------------------------
# routing_hint → inbox ディレクトリ名のマッピング
# -------------------------------------------------------------------
resolve_inbox() {
  local hint="$1"
  case "$hint" in
    marketing_lead|marketing-lead) echo "marketing-lead" ;;
    sales_lead|sales-lead)         echo "sales-lead" ;;
    cs_lead|cs-lead)               echo "cs-lead" ;;
    orchestrator)                  echo "orchestrator" ;;
    *)                             echo "$hint" ;;
  esac
}

# -------------------------------------------------------------------
# イベント種別ごとの優先度ラベル
# -------------------------------------------------------------------
priority_label() {
  case "$1" in
    critical) echo "🔴 CRITICAL" ;;
    high)     echo "🟠 HIGH" ;;
    medium)   echo "🟡 MEDIUM" ;;
    low)      echo "🟢 LOW" ;;
    *)        echo "$1" ;;
  esac
}

# -------------------------------------------------------------------
# inboxへメッセージ投入
# -------------------------------------------------------------------
enqueue_to_inbox() {
  local event_file="$1"
  local event_id routing_hint inbox_agent inbox_dir

  event_id=$(get_field "$event_file" ".id")
  event_type=$(get_field "$event_file" ".type")
  priority=$(get_field "$event_file" ".priority")
  routing_hint=$(get_field "$event_file" ".routing_hint")
  entity_type=$(get_field "$event_file" ".subject.entity_type")
  entity_id=$(get_field "$event_file" ".subject.entity_id")
  normalized_ref=$(get_field "$event_file" ".subject.normalized_ref")
  required_actions=$(jq -r '.required_actions | join(", ")' "$event_file" 2>/dev/null \
    || grep -o '"[^"]*"' "$event_file" | tail -5 | tr '\n' ',')

  inbox_agent=$(resolve_inbox "$routing_hint")
  inbox_dir="$INBOX_BASE/$inbox_agent"
  mkdir -p "$inbox_dir"

  local msg_file="$inbox_dir/${event_id}.md"
  local prio_label
  prio_label=$(priority_label "$priority")

  # メッセージ本文を生成
  cat > "$msg_file" << MSGEOF
# CRMイベント通知: ${event_id}

**優先度**: ${prio_label}
**イベント種別**: \`${event_type}\`
**タイムスタンプ**: $(get_field "$event_file" ".timestamp")

## 対象エンティティ

- **種別**: ${entity_type}
- **ID**: ${entity_id}
- **正規化データ**: \`${normalized_ref}\`（PROJECT_ROOT基準の相対パスから読み込み可）

## イベント詳細

\`\`\`json
$(cat "$event_file")
\`\`\`

## 要求アクション

${required_actions}

## 指示

1. 上記の正規化データ（normalized_ref）を読み込み、対象の状況を把握してください
2. 要求アクションを担当メンバーに委託し、成果物を \`data/crm/output/${event_id}/\` に保存してください
3. 成果物ファイル:
   - \`summary.md\` — 対応方針・意思決定のサマリー
   - \`email_draft.md\` — 送信メール文案（該当する場合）
   - \`next_actions.md\` — 次のアクションと担当者・期日
4. 完了後、orchestratorのinboxに完了報告を送ってください

**イベントファイル**: \`${event_file#$PROJECT_ROOT/}\`
MSGEOF

  echo -e "${GREEN}[crm-watcher] ${event_id} → ${inbox_agent} inbox に投入${NC}"

  # sentにコピー（ログ用）
  cp "$msg_file" "$SENT_DIR/${event_id}_to_${inbox_agent}.md"
}

# -------------------------------------------------------------------
# メインループ
# -------------------------------------------------------------------
while true; do
  if [ ! -d "$CRM_EVENTS_DIR" ]; then
    echo -e "${RED}[crm-watcher] イベントディレクトリが見つかりません: $CRM_EVENTS_DIR${NC}" >&2
    sleep "$WATCH_INTERVAL"
    continue
  fi

  for event_file in "$CRM_EVENTS_DIR"/*.json; do
    [ -f "$event_file" ] || continue

    status=$(get_field "$event_file" ".status")
    event_id=$(get_field "$event_file" ".id")

    if [ "$status" = "pending" ]; then
      echo -e "${YELLOW}[crm-watcher] 新規イベント検出: $event_id ($(basename "$event_file"))${NC}"

      # statusを processing に更新（二重処理防止）
      set_event_status "$event_file" "processing"

      # inboxに投入
      enqueue_to_inbox "$event_file"

    fi
  done

  sleep "$WATCH_INTERVAL"
done
