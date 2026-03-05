#!/bin/bash
# =============================================================================
# post-commit フック（push型同期）
# agentic-company でコミットしたら、登録済みプロダクトリポに自動同期する
#
# インストール方法:
#   cp hooks/post-commit-sync.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
#
# 登録ファイル:
#   hooks/product_repos.txt に同期先のパスを1行ずつ記載
# =============================================================================

AGENTIC_COMPANY_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PRODUCT_REPOS_FILE="$AGENTIC_COMPANY_ROOT/hooks/product_repos.txt"

if [ ! -f "$PRODUCT_REPOS_FILE" ]; then
  exit 0
fi

# エージェント定義の変更があるかチェック
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)
AGENT_CHANGED=false

echo "$CHANGED_FILES" | grep -qE '^(\.claude/agents/|organization\.yaml|scripts/|CLAUDE\.md)' && AGENT_CHANGED=true

if [ "$AGENT_CHANGED" = false ]; then
  exit 0
fi

echo "[post-commit-sync] エージェント定義の変更を検出。プロダクトリポに同期します..."

while IFS= read -r product_path; do
  # コメント行・空行をスキップ
  [[ "$product_path" =~ ^#.*$ ]] && continue
  [[ -z "$product_path" ]] && continue

  if [ -d "$product_path" ] && [ -f "$product_path/scripts/sync_agents.sh" ]; then
    echo "  → $product_path"
    (cd "$product_path" && bash scripts/sync_agents.sh) 2>&1 | sed 's/^/    /'
  else
    echo "  ⚠ スキップ（無効なパス）: $product_path"
  fi
done < "$PRODUCT_REPOS_FILE"

echo "[post-commit-sync] 同期完了"
