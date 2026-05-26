#!/usr/bin/env bash

# 作用：
#   根据任务文件中的「允许修改范围」检查当前 Git 工作区是否出现越界修改。
#
# 用法：
#   ./.harness/checks/scope-check.sh <任务文件路径>
#
# 示例：
#   ./.harness/checks/scope-check.sh .harness/任务/01-client模块.md
#
# 说明：
#   - 本脚本依赖 Git。
#   - 它会读取任务文件中的「## 允许修改范围」。
#   - 然后检查 git diff 中的修改文件是否都落在允许范围内。
#   - 如果发现越界修改，脚本会失败。
#   - 允许修改任务文件本身，因为任务执行过程中可能需要补充说明。

set -euo pipefail

TASK_FILE="${1:-}"

if [ -z "$TASK_FILE" ]; then
  echo "用法：./.harness/checks/scope-check.sh <任务文件路径>"
  exit 1
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "任务文件不存在：$TASK_FILE"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "当前目录不是 Git 仓库，无法执行范围检查。"
  exit 1
fi

extract_allowed_scopes() {
  awk '
    BEGIN { in_section=0 }
    /^## 允许修改范围/ { in_section=1; next }
    /^## / && in_section { exit }
    in_section && /^- / {
      line=$0
      sub(/^- /, "", line)
      gsub(/`/, "", line)
      gsub(/\/\*\*$/, "", line)
      print line
    }
  ' "$TASK_FILE"
}

is_allowed_file() {
  local file="$1"
  local allowed_scope

  # 允许任务文件自身被修改
  if [ "$file" = "$TASK_FILE" ]; then
    return 0
  fi

  while IFS= read -r allowed_scope; do
    [ -z "$allowed_scope" ] && continue

    if [[ "$file" == "$allowed_scope"* ]]; then
      return 0
    fi
  done < <(extract_allowed_scopes)

  return 1
}

echo "开始检查修改范围..."

ALLOWED_SCOPES="$(extract_allowed_scopes)"

if [ -z "$ALLOWED_SCOPES" ]; then
  echo "未找到允许修改范围，请检查任务文件中的「## 允许修改范围」。"
  exit 1
fi

CHANGED_FILES="$(git status --short | awk '{print $2}')"

if [ -z "$CHANGED_FILES" ]; then
  echo "当前没有检测到 Git 工作区修改。"
  exit 0
fi

VIOLATION=0

while IFS= read -r file; do
  [ -z "$file" ] && continue

  if ! is_allowed_file "$file"; then
    echo "范围违规：$file 不在允许修改范围内。"
    VIOLATION=1
  fi
done <<< "$CHANGED_FILES"

if [ "$VIOLATION" -ne 0 ]; then
  echo "修改范围检查失败。"
  exit 1
fi

echo "修改范围检查通过。"