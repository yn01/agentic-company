#!/bin/bash
# =============================================================================
# エージェント定義同期スクリプト
# 使い方: bash scripts/sync_agents.sh
# - agentic-company（組織マスター）からエージェント定義を同期
# - CLAUDE.md の SYNC:BEGIN〜SYNC:END 範囲のみ上書き（プロダクト固有部分は保持）
# =============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SYNC_CONF="$PROJECT_ROOT/.claude/sync_source.conf"

echo -e "${BLUE}[sync] エージェント定義同期を開始...${NC}"

# =============================================================================
# [1] 同期元パスの読み込み
# =============================================================================
if [ ! -f "$SYNC_CONF" ]; then
  echo -e "${RED}ERROR: $SYNC_CONF が見つかりません。${NC}"
  echo "  .claude/sync_source.conf に agentic-company のパスを設定してください："
  echo "  AGENTIC_COMPANY_ROOT=/path/to/agentic-company"
  exit 1
fi

source "$SYNC_CONF"

if [ -z "$AGENTIC_COMPANY_ROOT" ]; then
  echo -e "${RED}ERROR: AGENTIC_COMPANY_ROOT が設定されていません。${NC}"
  exit 1
fi

if [ ! -d "$AGENTIC_COMPANY_ROOT/.claude/agents" ]; then
  echo -e "${RED}ERROR: $AGENTIC_COMPANY_ROOT は有効な agentic-company リポジトリではありません。${NC}"
  exit 1
fi

echo "  同期元: $AGENTIC_COMPANY_ROOT"

# =============================================================================
# [2] エージェント定義の同期
# =============================================================================
echo -e "${YELLOW}[sync] .claude/agents/ を同期中...${NC}"
rsync -a --delete \
  "$AGENTIC_COMPANY_ROOT/.claude/agents/" \
  "$PROJECT_ROOT/.claude/agents/"
echo -e "${GREEN}  ✓ .claude/agents/ 同期完了${NC}"

# =============================================================================
# [3] organization.yaml の同期
# =============================================================================
echo -e "${YELLOW}[sync] organization.yaml を同期中...${NC}"
cp "$AGENTIC_COMPANY_ROOT/organization.yaml" "$PROJECT_ROOT/organization.yaml"
echo -e "${GREEN}  ✓ organization.yaml 同期完了${NC}"

# =============================================================================
# [4] scripts/ の同期（sync_agents.sh 自身も含む）
# =============================================================================
echo -e "${YELLOW}[sync] scripts/ を同期中...${NC}"
for script in start_worktrees.sh stop_worktrees.sh watch_inbox.sh sync_agents.sh; do
  if [ -f "$AGENTIC_COMPANY_ROOT/scripts/$script" ]; then
    cp "$AGENTIC_COMPANY_ROOT/scripts/$script" "$PROJECT_ROOT/scripts/$script"
    chmod +x "$PROJECT_ROOT/scripts/$script"
  fi
done
echo -e "${GREEN}  ✓ scripts/ 同期完了${NC}"

# =============================================================================
# [5] CLAUDE.md の SYNC:BEGIN〜SYNC:END 範囲を更新
# =============================================================================
echo -e "${YELLOW}[sync] CLAUDE.md のorg共通部分を同期中...${NC}"

CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
SOURCE_CLAUDE_MD="$AGENTIC_COMPANY_ROOT/CLAUDE.md"

if [ ! -f "$CLAUDE_MD" ]; then
  echo -e "${YELLOW}  CLAUDE.md が存在しません。スキップ。${NC}"
elif [ ! -f "$SOURCE_CLAUDE_MD" ]; then
  echo -e "${YELLOW}  同期元の CLAUDE.md が見つかりません。スキップ。${NC}"
else
  # SYNC:BEGIN〜SYNC:END の範囲を置換
  if grep -q "<!-- SYNC:BEGIN -->" "$CLAUDE_MD" && grep -q "<!-- SYNC:END -->" "$CLAUDE_MD"; then
    # マーカー前の部分を保持
    head_content=$(sed '/<!-- SYNC:BEGIN -->/,$d' "$CLAUDE_MD")
    # マーカー後の部分を保持
    tail_content=$(sed '1,/<!-- SYNC:END -->/d' "$CLAUDE_MD")
    # 新しい同期内容
    sync_content=$(cat "$SOURCE_CLAUDE_MD")

    # 結合して書き出し
    {
      echo "$head_content"
      echo "<!-- SYNC:BEGIN - agentic-companyから自動同期。この範囲を手動編集しないこと -->"
      echo ""
      echo "$sync_content"
      echo ""
      echo "<!-- SYNC:END -->"
      echo "$tail_content"
    } > "$CLAUDE_MD"
    echo -e "${GREEN}  ✓ CLAUDE.md 同期完了（SYNC:BEGIN〜SYNC:END 更新）${NC}"
  else
    echo -e "${YELLOW}  CLAUDE.md にSYNCマーカーがありません。スキップ。${NC}"
    echo "  手動で <!-- SYNC:BEGIN --> と <!-- SYNC:END --> を追加してください。"
  fi
fi

# =============================================================================
# [6] inbox ディレクトリの確認・作成
# =============================================================================
echo -e "${YELLOW}[sync] inbox ディレクトリを確認中...${NC}"

# agents/ 内のエージェント名を取得してinboxを作成
for agent_file in "$PROJECT_ROOT/.claude/agents/"*.md "$PROJECT_ROOT/.claude/agents/"**/*.md; do
  if [ -f "$agent_file" ]; then
    agent_name=$(grep -m1 '^name:' "$agent_file" | sed 's/name: *//' | tr -d ' ')
    if [ -n "$agent_name" ]; then
      mkdir -p "$PROJECT_ROOT/.claude/messages/inbox/$agent_name"
      touch "$PROJECT_ROOT/.claude/messages/inbox/$agent_name/.gitkeep"
    fi
  fi
done
mkdir -p "$PROJECT_ROOT/.claude/messages/sent"
mkdir -p "$PROJECT_ROOT/.claude/messages/processed"
echo -e "${GREEN}  ✓ inbox ディレクトリ確認完了${NC}"

echo ""
echo -e "${GREEN}[sync] 同期完了${NC}"
