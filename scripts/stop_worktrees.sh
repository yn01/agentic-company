#!/bin/bash
# =============================================================================
# Worktree 停止スクリプト
# 使い方: bash scripts/stop_worktrees.sh
# - inbox監視プロセスを終了
# - メッセージをObsidianにアーカイブ
# - 全tmuxセッション/ウィンドウを終了
# =============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

OBSIDIAN_VAULT="/Users/yoheinakanishi/Documents/Obsidian/Claude-Dev"
OBSIDIAN_MESSAGES_DIR="$OBSIDIAN_VAULT/agent-messages"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Agentic Company - Worktree 停止スクリプト${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# =============================================================================
# [1/4] Release Manager 確認
# =============================================================================
echo -e "${YELLOW}[1/4] Release Manager 起動確認...${NC}"

RELEASE_MANAGER_RUNNING=false
if tmux list-windows 2>/dev/null | grep -q "release-manager"; then
  RELEASE_MANAGER_RUNNING=true
fi
if tmux list-sessions 2>/dev/null | grep -q "release-manager"; then
  RELEASE_MANAGER_RUNNING=true
fi

if [ "$RELEASE_MANAGER_RUNNING" = false ]; then
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  警告: Release Manager が未起動です${NC}"
  echo -e "${RED}========================================${NC}"
  echo ""
  echo -e "${YELLOW}Gitコミット・プッシュが未実行の可能性があります。${NC}"
  echo ""
  echo "対応オプション："
  echo "  1) Release Managerを今すぐ起動してコミット後に停止"
  echo "  2) このまま停止する（後で手動 git commit & push）"
  echo "  3) キャンセル"
  echo ""
  read -p "選択 [1-3]: " git_choice

  case $git_choice in
    1)
      WORKTREE_PATH="$PROJECT_ROOT/.claude/worktrees/release-manager"
      if [ ! -d "$WORKTREE_PATH" ]; then
        mkdir -p "$WORKTREE_PATH"
        git worktree add "$WORKTREE_PATH" -b "worktree/release-manager" 2>/dev/null || \
        git worktree add "$WORKTREE_PATH" "worktree/release-manager" 2>/dev/null || true
      fi
      echo -e "  Starting release-manager..."
      tmux new-window -n "release-manager" \
        "cd '$WORKTREE_PATH' && claude --model claude-sonnet-4-6; exec zsh" 2>/dev/null || \
      tmux new-session -d -s "agents" -n "release-manager" \
        "cd '$WORKTREE_PATH' && claude --model claude-sonnet-4-6; exec zsh" 2>/dev/null
      echo ""
      echo -e "${YELLOW}release-managerのセッションで以下を入力してください：${NC}"
      echo -e "${BLUE}  あなたはRelease Managerです。現在の変更をコミット・プッシュしてください。${NC}"
      echo ""
      read -p "コミット・プッシュ完了後にEnterを押してください..."
      ;;
    2)
      echo -e "${YELLOW}⚠ 停止後に手動でコミット・プッシュを実行してください。${NC}"
      echo "  git add -A && git commit -m 'message' && git push"
      ;;
    3)
      echo "キャンセルしました。"
      exit 0
      ;;
    *)
      echo -e "${RED}無効な選択です。${NC}"
      exit 1
      ;;
  esac
else
  echo -e "${GREEN}✓ Release Manager は起動中です${NC}"
  echo ""
  echo -e "${YELLOW}停止前に最終コミット・プッシュが完了していることを確認してください。${NC}"
  read -p "確認できたらEnterを押してください..."
fi

echo ""

# =============================================================================
# [2/4] メッセージをObsidianにアーカイブ
# =============================================================================
echo -e "${YELLOW}[2/4] メッセージをObsidianにアーカイブ...${NC}"

# 起動中のエージェントをtmuxウィンドウから取得
ACTIVE_AGENTS=()
while IFS= read -r line; do
  agent=$(echo "$line" | grep -o '[0-9]*: [^ ]*' | sed 's/[0-9]*: //')
  if [ -n "$agent" ]; then
    ACTIVE_AGENTS+=("$agent")
  fi
done < <(tmux list-windows 2>/dev/null || true)

# inboxを全部スキャン
HAS_MESSAGES=false
for inbox_dir in .claude/messages/inbox/*/; do
  if [ -d "$inbox_dir" ]; then
    count=$(find "$inbox_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      HAS_MESSAGES=true
      break
    fi
  fi
done

if [ "$HAS_MESSAGES" = true ]; then
  TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
  ARCHIVE_DIR="$OBSIDIAN_MESSAGES_DIR/${TIMESTAMP}_${PROJECT_NAME}"
  mkdir -p "$ARCHIVE_DIR"

  TOTAL=0
  for inbox_dir in .claude/messages/inbox/*/; do
    if [ -d "$inbox_dir" ]; then
      agent=$(basename "$inbox_dir")
      count=$(find "$inbox_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$count" -gt 0 ]; then
        mkdir -p "$ARCHIVE_DIR/$agent"
        find "$inbox_dir" -name "*.md" -exec cp {} "$ARCHIVE_DIR/$agent/" \;
        echo "  ✓ $agent ($count件)"
        TOTAL=$((TOTAL + count))
      fi
    fi
  done

  if [ -d ".claude/messages/sent" ]; then
    count=$(find ".claude/messages/sent" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      mkdir -p "$ARCHIVE_DIR/sent"
      find ".claude/messages/sent" -name "*.md" -exec cp {} "$ARCHIVE_DIR/sent/" \;
      echo "  ✓ sent ($count件)"
      TOTAL=$((TOTAL + count))
    fi
  fi

  # agent_status.jsonも保存
  if [ -f ".claude/state/agent_status.json" ]; then
    cp ".claude/state/agent_status.json" "$ARCHIVE_DIR/agent_status_final.json"
  fi

  echo ""
  echo -e "  ${GREEN}合計 ${TOTAL}件 → $ARCHIVE_DIR${NC}"
else
  echo "  メッセージなし（スキップ）"
fi

echo -e "${GREEN}✓ アーカイブ完了${NC}"
echo ""

# =============================================================================
# [3/4] inbox監視プロセスを終了
# =============================================================================
echo -e "${YELLOW}[3/4] inbox監視プロセスを停止...${NC}"

PIDS_FILE="$PROJECT_ROOT/.claude/state/watch_pids.txt"
if [ -f "$PIDS_FILE" ]; then
  while IFS= read -r pid; do
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null && echo "  ✓ watch PID $pid 終了" || true
    fi
  done < "$PIDS_FILE"
  rm -f "$PIDS_FILE"
  echo -e "${GREEN}✓ 監視プロセス停止完了${NC}"
else
  echo "  監視プロセスなし（スキップ）"
fi

echo ""

# =============================================================================
# [4/4] tmuxセッション/ウィンドウ終了
# =============================================================================
echo -e "${YELLOW}[4/4] tmuxセッションを終了...${NC}"

CLOSED=0

# 全ウィンドウを終了（agentsセッション内）
if tmux has-session -t agents 2>/dev/null; then
  tmux kill-session -t agents 2>/dev/null && echo "  ✓ agentsセッション終了" && CLOSED=$((CLOSED + 1)) || true
fi

# 個別セッションも終了
ALL_POSSIBLE_AGENTS=(
  "orchestrator"
  "product-lead" "product-manager" "trend-researcher"
  "engineering-lead" "frontend-developer" "backend-architect"
  "database-engineer" "devops-engineer" "security-engineer"
  "qa-lead" "test-engineer" "e2e-tester" "api-tester" "performance-analyst"
  "release-manager"
  "chief-of-staff" "biz-dev-strategist"
  "scrum-master" "sprint-planner" "project-lead"
)
for agent in "${ALL_POSSIBLE_AGENTS[@]}"; do
  if tmux has-session -t "agent-$agent" 2>/dev/null; then
    tmux kill-session -t "agent-$agent" 2>/dev/null && \
      echo "  ✓ agent-$agent セッション終了" && CLOSED=$((CLOSED + 1)) || true
  fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  停止完了${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "アーカイブ先: $OBSIDIAN_MESSAGES_DIR"
echo ""
if [ "$RELEASE_MANAGER_RUNNING" = false ]; then
  echo -e "${YELLOW}⚠ 未コミットの変更がある場合は手動でpushしてください：${NC}"
  echo "  git status"
  echo "  git add -A && git commit -m 'message' && git push"
  echo ""
fi
