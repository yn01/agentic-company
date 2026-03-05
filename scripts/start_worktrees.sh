#!/bin/bash
# =============================================================================
# Worktree 起動スクリプト
# 使い方: bash scripts/start_worktrees.sh
# - パイプライン/ユースケースを選択して必要なエージェントのみ起動
# - 前回メッセージをObsidianにアーカイブしてからinboxをリセット
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

OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/Obsidian/Claude-Dev}"
OBSIDIAN_MESSAGES_DIR="$OBSIDIAN_VAULT/agent-messages"

# =============================================================================
# パイプライン定義
# 新しいパイプラインを追加する場合はここに追記する
# =============================================================================

# パイプライン1: プロダクト開発 (product → engineering → QA → release)
PIPELINE_PRODUCT_DEV=(
  "orchestrator"
  "product-lead"
  "product-manager"
  "engineering-lead"
  "frontend-developer"
  "backend-architect"
  "qa-lead"
  "test-engineer"
  "e2e-tester"
  "release-manager"
)

# モデル定義 (macOS bash 3.2対応のためcase文を使用)
get_model() {
  case "$1" in
    orchestrator) echo "claude-opus-4-6" ;;
    *)            echo "claude-sonnet-4-6" ;;
  esac
}

# =============================================================================
# ヘルパー: 全パイプラインのエージェントリスト（アーカイブ用）
# =============================================================================
get_all_pipeline_agents() {
  local -a all=()
  for a in "${PIPELINE_PRODUCT_DEV[@]}"; do
    all+=("$a")
  done
  # 重複除去して出力
  printf '%s\n' "${all[@]}" | sort -u
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Agentic Company - Worktree 起動スクリプト${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# =============================================================================
# [0/6] エージェント定義の自動同期（プロダクトリポで実行時のみ）
# =============================================================================
SYNC_CONF="$PROJECT_ROOT/.claude/sync_source.conf"
if [ -f "$SYNC_CONF" ]; then
  echo -e "${YELLOW}[0/6] エージェント定義を同期中...${NC}"
  bash "$PROJECT_ROOT/scripts/sync_agents.sh"
  echo ""
else
  echo -e "${YELLOW}[info] sync_source.conf なし（agentic-company本体で実行中）。同期をスキップ。${NC}"
  echo ""
fi

# =============================================================================
# [1/6] 事前チェック
# =============================================================================
echo -e "${YELLOW}[1/6] 事前チェック...${NC}"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${RED}ERROR: Gitリポジトリではありません。${NC}"
  exit 1
fi

if ! command -v tmux &> /dev/null; then
  echo -e "${RED}ERROR: tmuxがインストールされていません。brew install tmux を実行してください。${NC}"
  exit 1
fi

if ! command -v claude &> /dev/null; then
  echo -e "${RED}ERROR: claude CLIがインストールされていません。${NC}"
  exit 1
fi

echo -e "${GREEN}✓ 事前チェック完了${NC}"
echo ""

# =============================================================================
# [2/6] パイプライン選択
# =============================================================================
echo -e "${YELLOW}[2/6] 起動するパイプラインを選択してください...${NC}"
echo ""
echo "  1) プロダクト開発  (product → engineering → QA → release)"
echo "     エージェント: orchestrator, product-lead, product-manager,"
echo "                   engineering-lead, frontend-developer, backend-architect,"
echo "                   qa-lead, test-engineer, e2e-tester, release-manager"
echo ""
echo "  2) カスタム  (エージェントを個別に選択)"
echo ""
read -p "選択 [1-2]: " pipeline_choice

LAUNCH_AGENTS=()
PIPELINE_NAME=""

case $pipeline_choice in
  1)
    PIPELINE_NAME="プロダクト開発"
    LAUNCH_AGENTS=("${PIPELINE_PRODUCT_DEV[@]}")
    ;;
  2)
    PIPELINE_NAME="カスタム"
    # 全エージェント候補（アルファベット順）
    ALL_AGENTS=(
      "orchestrator"
      "product-lead" "product-manager" "trend-researcher"
      "engineering-lead" "frontend-developer" "backend-architect"
      "database-engineer" "devops-engineer" "security-engineer"
      "qa-lead" "test-engineer" "e2e-tester" "api-tester" "performance-analyst"
      "release-manager"
      "chief-of-staff" "biz-dev-strategist"
      "scrum-master" "sprint-planner" "project-lead"
    )
    echo ""
    echo "各エージェントを起動するか選んでください（y/n）："
    for agent in "${ALL_AGENTS[@]}"; do
      model="$(get_model $agent)"
      read -p "  $agent (${model}) [y/n]: " yn
      case $yn in
        [Yy]*) LAUNCH_AGENTS+=("$agent") ;;
        *) ;;
      esac
    done
    if [ ${#LAUNCH_AGENTS[@]} -eq 0 ]; then
      echo -e "${RED}エージェントが1つも選択されていません。終了します。${NC}"
      exit 1
    fi
    ;;
  *)
    echo -e "${RED}無効な選択です。${NC}"
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}パイプライン: $PIPELINE_NAME${NC}"
echo "起動エージェント: ${LAUNCH_AGENTS[*]}"
echo ""

# =============================================================================
# [3/6] 前回メッセージのアーカイブ → inboxリセット
# =============================================================================
echo -e "${YELLOW}[3/6] 前回メッセージのアーカイブ...${NC}"

# アーカイブ対象: 起動予定エージェント + sent
HAS_MESSAGES=false
for agent in "${LAUNCH_AGENTS[@]}"; do
  INBOX=".claude/messages/inbox/$agent"
  if [ -d "$INBOX" ]; then
    count=$(find "$INBOX" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
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

  for agent in "${LAUNCH_AGENTS[@]}"; do
    INBOX=".claude/messages/inbox/$agent"
    if [ -d "$INBOX" ]; then
      count=$(find "$INBOX" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$count" -gt 0 ]; then
        mkdir -p "$ARCHIVE_DIR/$agent"
        find "$INBOX" -name "*.md" -exec cp {} "$ARCHIVE_DIR/$agent/" \;
        echo "  ✓ $agent ($count件) → アーカイブ済み"
      fi
    fi
  done

  if [ -d ".claude/messages/sent" ]; then
    count=$(find ".claude/messages/sent" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      mkdir -p "$ARCHIVE_DIR/sent"
      find ".claude/messages/sent" -name "*.md" -exec cp {} "$ARCHIVE_DIR/sent/" \;
      echo "  ✓ sent ($count件) → アーカイブ済み"
    fi
  fi

  echo -e "  ${BLUE}保存先: $ARCHIVE_DIR${NC}"

  for agent in "${LAUNCH_AGENTS[@]}"; do
    find ".claude/messages/inbox/$agent" -name "*.md" -delete 2>/dev/null || true
  done
  find ".claude/messages/sent" -name "*.md" -delete 2>/dev/null || true
  echo -e "  ${GREEN}✓ inboxリセット完了${NC}"
else
  echo "  前回のメッセージなし（スキップ）"
fi

echo -e "${GREEN}✓ アーカイブ完了${NC}"
echo ""

# =============================================================================
# [4/6] メッセージキュー初期化 / Worktree確認・作成
# =============================================================================
echo -e "${YELLOW}[4/6] メッセージキュー初期化 & Worktree確認...${NC}"

# inbox・状態ディレクトリを初期化
for agent in "${LAUNCH_AGENTS[@]}"; do
  mkdir -p ".claude/messages/inbox/$agent"
  touch ".claude/messages/inbox/$agent/.gitkeep"
done
mkdir -p ".claude/messages/sent"
mkdir -p ".claude/messages/processed"
mkdir -p ".claude/state"
mkdir -p ".claude/logs"

# agent_status.json 生成・更新
STATUS_FILE=".claude/state/agent_status.json"
if [ ! -f "$STATUS_FILE" ]; then
  # 新規作成
  echo '{' > "$STATUS_FILE"
  echo '  "last_updated": "",' >> "$STATUS_FILE"
  echo '  "pipeline": "'"$PIPELINE_NAME"'",' >> "$STATUS_FILE"
  echo '  "agents": {' >> "$STATUS_FILE"
  first=true
  for agent in "${LAUNCH_AGENTS[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      echo ',' >> "$STATUS_FILE"
    fi
    printf '    "%s": { "status": "idle", "current_task": null }' "$agent" >> "$STATUS_FILE"
  done
  echo '' >> "$STATUS_FILE"
  echo '  }' >> "$STATUS_FILE"
  echo '}' >> "$STATUS_FILE"
else
  # 既存ファイルのstatusをidleにリセット
  if command -v node &> /dev/null; then
    node -e "
      const fs = require('fs');
      const p = '$STATUS_FILE';
      try {
        const s = JSON.parse(fs.readFileSync(p));
        Object.keys(s.agents).forEach(k => {
          s.agents[k].status = 'idle';
          s.agents[k].current_task = null;
        });
        s.last_updated = new Date().toISOString();
        s.pipeline = '$PIPELINE_NAME';
        fs.writeFileSync(p, JSON.stringify(s, null, 2));
      } catch(e) {}
    "
  fi
fi

# watch_pids.txtをクリア
> ".claude/state/watch_pids.txt"

# Worktree確認・作成
for agent in "${LAUNCH_AGENTS[@]}"; do
  WORKTREE_PATH=".claude/worktrees/$agent"
  if git worktree list | grep -q "$WORKTREE_PATH"; then
    echo "  ✓ $agent worktree (既存)"
  else
    echo "  + $agent worktree を作成中..."
    git worktree add "$WORKTREE_PATH" -b "worktree/$agent" 2>/dev/null || \
    git worktree add "$WORKTREE_PATH" "worktree/$agent" 2>/dev/null || \
    echo -e "  ${YELLOW}⚠ $agent のworktree作成をスキップ（ブランチが既に存在する可能性）${NC}"
  fi
done

echo -e "${GREEN}✓ 初期化完了${NC}"
echo ""

# =============================================================================
# [5/6] エージェント起動
# =============================================================================
echo -e "${YELLOW}[5/6] エージェントを起動します...${NC}"
echo ""

for agent in "${LAUNCH_AGENTS[@]}"; do
  model="$(get_model $agent)"
  WORKTREE_PATH="$PROJECT_ROOT/.claude/worktrees/$agent"
  echo -e "  Starting: $agent (${model})..."

  # tmuxウィンドウで起動
  tmux new-window -n "$agent" "cd '$WORKTREE_PATH' && claude --model $model; exec zsh" 2>/dev/null || \
  tmux new-session -d -s "agents" -n "$agent" "cd '$WORKTREE_PATH' && claude --model $model; exec zsh" 2>/dev/null || \
  echo -e "    ${YELLOW}⚠ 手動起動: cd $WORKTREE_PATH && claude --model $model${NC}"
  sleep 0.5

  # orchestrator以外のinbox監視をバックグラウンドで起動
  if [ "$agent" != "orchestrator" ]; then
    bash "$PROJECT_ROOT/scripts/watch_inbox.sh" "$agent" \
      >> "$PROJECT_ROOT/.claude/logs/watch_${agent}.log" 2>&1 &
    echo "    → inbox監視開始 (PID: $!)"
    echo "$!" >> "$PROJECT_ROOT/.claude/state/watch_pids.txt"
  fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  起動完了！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "パイプライン: $PIPELINE_NAME"
echo "起動エージェント数: ${#LAUNCH_AGENTS[@]}"
echo ""
echo "次のステップ："
echo "  orchestratorセッションで以下を入力："
echo ""
echo -e "${BLUE}  あなたはAgentic CompanyのOrchestratorです。${NC}"
echo -e "${BLUE}  CLAUDE.mdとdocs/PLAN.mdを読み、ユーザーの指示に従って${NC}"
echo -e "${BLUE}  適切な部門leadのinboxにメッセージを送信してください。${NC}"
echo ""
echo "停止時: bash scripts/stop_worktrees.sh"
echo ""
