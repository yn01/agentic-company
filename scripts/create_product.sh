#!/bin/bash
# =============================================================================
# プロダクトリポジトリ生成スクリプト
# 使い方: bash scripts/create_product.sh /path/to/new-product [product-name]
# - 新しいプロダクトプロジェクトを一式生成
# - agentic-companyからエージェント定義を同期
# - git init済みの状態で完成
# =============================================================================

set -e

AGENTIC_COMPANY_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# =============================================================================
# 引数チェック
# =============================================================================
PRODUCT_PATH="$1"
PRODUCT_NAME="${2:-$(basename "$PRODUCT_PATH")}"

if [ -z "$PRODUCT_PATH" ]; then
  echo "使い方: bash scripts/create_product.sh /path/to/new-product [product-name]"
  echo ""
  echo "例:"
  echo "  bash scripts/create_product.sh /path/to/my-saas-app"
  echo "  bash scripts/create_product.sh /path/to/my-saas-app my-saas"
  exit 1
fi

if [ -d "$PRODUCT_PATH" ]; then
  echo "ERROR: $PRODUCT_PATH は既に存在します。"
  exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  プロダクトリポジトリ生成${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "  プロダクトパス: $PRODUCT_PATH"
echo "  プロダクト名:   $PRODUCT_NAME"
echo "  組織マスター:   $AGENTIC_COMPANY_ROOT"
echo ""

# =============================================================================
# [1/6] ディレクトリ構成を作成
# =============================================================================
echo -e "${YELLOW}[1/6] ディレクトリ構成を作成...${NC}"

mkdir -p "$PRODUCT_PATH"
mkdir -p "$PRODUCT_PATH/src/frontend"
mkdir -p "$PRODUCT_PATH/src/backend"
mkdir -p "$PRODUCT_PATH/docs"
mkdir -p "$PRODUCT_PATH/scripts"
mkdir -p "$PRODUCT_PATH/.claude/agents"
mkdir -p "$PRODUCT_PATH/.claude/messages/sent"
mkdir -p "$PRODUCT_PATH/.claude/messages/processed"
mkdir -p "$PRODUCT_PATH/.claude/state"
mkdir -p "$PRODUCT_PATH/.claude/logs"
mkdir -p "$PRODUCT_PATH/.claude/worktrees"

echo -e "${GREEN}  ✓ ディレクトリ作成完了${NC}"

# =============================================================================
# [2/6] sync_source.conf を生成
# =============================================================================
echo -e "${YELLOW}[2/6] sync_source.conf を生成...${NC}"

cat > "$PRODUCT_PATH/.claude/sync_source.conf" << EOF
# agentic-company（組織マスター）のローカルパス
# sync_agents.sh がこのパスからエージェント定義を同期する
AGENTIC_COMPANY_ROOT=$AGENTIC_COMPANY_ROOT
EOF

echo -e "${GREEN}  ✓ sync_source.conf 生成完了${NC}"

# =============================================================================
# [3/6] エージェント定義・スクリプトを同期
# =============================================================================
echo -e "${YELLOW}[3/6] agentic-companyからエージェント定義を同期...${NC}"

# agents
rsync -a "$AGENTIC_COMPANY_ROOT/.claude/agents/" "$PRODUCT_PATH/.claude/agents/"

# organization.yaml
cp "$AGENTIC_COMPANY_ROOT/organization.yaml" "$PRODUCT_PATH/organization.yaml"

# scripts
for script in start_worktrees.sh stop_worktrees.sh watch_inbox.sh sync_agents.sh; do
  cp "$AGENTIC_COMPANY_ROOT/scripts/$script" "$PRODUCT_PATH/scripts/$script"
  chmod +x "$PRODUCT_PATH/scripts/$script"
done

echo -e "${GREEN}  ✓ 同期完了${NC}"

# =============================================================================
# [4/6] inbox ディレクトリを生成
# =============================================================================
echo -e "${YELLOW}[4/6] inbox ディレクトリを生成...${NC}"

for agent_file in "$PRODUCT_PATH/.claude/agents/"*.md "$PRODUCT_PATH/.claude/agents/"**/*.md; do
  if [ -f "$agent_file" ]; then
    agent_name=$(grep -m1 '^name:' "$agent_file" | sed 's/name: *//' | tr -d ' ')
    if [ -n "$agent_name" ]; then
      mkdir -p "$PRODUCT_PATH/.claude/messages/inbox/$agent_name"
      touch "$PRODUCT_PATH/.claude/messages/inbox/$agent_name/.gitkeep"
    fi
  fi
done
touch "$PRODUCT_PATH/.claude/messages/sent/.gitkeep"
touch "$PRODUCT_PATH/.claude/messages/processed/.gitkeep"
touch "$PRODUCT_PATH/.claude/state/.gitkeep"
touch "$PRODUCT_PATH/.claude/logs/.gitkeep"
touch "$PRODUCT_PATH/.claude/worktrees/.gitkeep"

echo -e "${GREEN}  ✓ inbox ディレクトリ生成完了${NC}"

# =============================================================================
# [5/6] CLAUDE.md を生成
# =============================================================================
echo -e "${YELLOW}[5/6] CLAUDE.md を生成...${NC}"

SOURCE_CLAUDE="$AGENTIC_COMPANY_ROOT/CLAUDE.md"
SYNC_CONTENT=""
if [ -f "$SOURCE_CLAUDE" ]; then
  SYNC_CONTENT=$(cat "$SOURCE_CLAUDE")
fi

cat > "$PRODUCT_PATH/CLAUDE.md" << 'CLAUDEEOF'
<!-- SYNC:BEGIN - agentic-companyから自動同期。この範囲を手動編集しないこと -->

CLAUDEEOF

echo "$SYNC_CONTENT" >> "$PRODUCT_PATH/CLAUDE.md"

cat >> "$PRODUCT_PATH/CLAUDE.md" << 'CLAUDEEOF'

<!-- SYNC:END -->

---

# プロダクト固有の指針

## 概要

このプロダクトの概要をここに記述してください。

## 技術スタック

```
Frontend: React / TypeScript
Backend:  Node.js / Express
Database: PostgreSQL
Testing:  Jest / Playwright
```

## プロダクト固有のルール

- ここにプロダクト固有のルール・規約を追記してください
- SYNC:BEGIN〜SYNC:END の範囲外であれば自由に編集可能です
CLAUDEEOF

echo -e "${GREEN}  ✓ CLAUDE.md 生成完了${NC}"

# =============================================================================
# [6/6] .gitignore と git init
# =============================================================================
echo -e "${YELLOW}[6/6] git init...${NC}"

cat > "$PRODUCT_PATH/.gitignore" << 'EOF'
# OS
.DS_Store

# Node
node_modules/
dist/
build/
.env
.env.local
.env.*.local

# Logs
*.log
.claude/logs/*.log

# IDE
.vscode/
.idea/

# Worktrees (git worktree managed)
.claude/worktrees/*/
!.claude/worktrees/.gitkeep
EOF

cd "$PRODUCT_PATH"
git init
git add -A
git commit -m "Initial commit: product scaffold from agentic-company

Synced from: $AGENTIC_COMPANY_ROOT
Generated by: scripts/create_product.sh

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  プロダクトリポジトリ生成完了${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  パス:   $PRODUCT_PATH"
echo "  名前:   $PRODUCT_NAME"
echo ""
echo "次のステップ:"
echo "  cd $PRODUCT_PATH"
echo "  bash scripts/start_worktrees.sh"
echo ""
echo "同期元の変更を反映:"
echo "  bash scripts/sync_agents.sh"
echo ""
