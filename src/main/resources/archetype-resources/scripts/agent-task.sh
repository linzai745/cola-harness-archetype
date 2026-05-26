#!/usr/bin/env bash

# 作用：
#   统一触发 Coding Agent 执行指定任务，并自动完成验证闭环。
#
# 用法：
#   ./scripts/agent-task.sh <任务文件名>
#
# 示例：
#   ./scripts/agent-task.sh 用例/UC-001-创建订单.md
#
# 完整流程：
#   1. 调用 Agent 执行任务。
#   2. 从任务文件中提取「验证命令」。
#   3. 自动执行验证命令。
#   4. 如果验证失败，将错误日志反馈给 Agent 修复。
#   5. 重试验证，直到通过或超过最大重试次数。
#   6. 输出修改文件清单和最终结果。
#
# 说明：
#   - 默认使用 codex 命令。
#   - 如果你使用其他 Agent 工具，可以替换 run_agent_task 和 run_agent_fix 中的命令。
#   - 默认最大修复次数为 2。
#   - 可通过环境变量 MAX_RETRY 调整，例如：MAX_RETRY=3 ./scripts/agent-task.sh 用例/UC-001-创建订单.md

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "用法：./scripts/agent-task.sh <任务文件名>"
  echo "示例：./scripts/agent-task.sh 用例/UC-001-创建订单.md"
  exit 1
fi

TASK="$1"

MAX_RETRY_VALUE="$(printenv MAX_RETRY || true)"
if [ -z "$MAX_RETRY_VALUE" ]; then
  MAX_RETRY_VALUE="2"
fi

TASK_FILE=".harness/任务/$TASK"

if [ ! -f "$TASK_FILE" ]; then
  echo "任务文件不存在：$TASK_FILE"
  exit 1
fi

LOG_DIR=".harness/checks/logs"
mkdir -p "$LOG_DIR"

VALIDATION_LOG="$LOG_DIR/last-validation.log"

extract_validation_commands() {
  awk '
    BEGIN { in_section=0; in_code=0 }
    /^## 验证命令/ { in_section=1; next }
    in_section && /^```bash/ { in_code=1; next }
    in_section && /^```/ && in_code { exit }
    in_section && in_code { print }
  ' "$TASK_FILE"
}

run_validation() {
  local commands
  commands="$(extract_validation_commands)"

  if [ -z "$commands" ]; then
    echo "未找到验证命令，请检查任务文件中的「## 验证命令」。"
    exit 1
  fi

  echo "开始执行验证命令："
  echo "$commands"
  echo

  bash -lc "$commands"
}

run_agent_task() {
  codex "请阅读 AGENTS.md、.harness/项目上下文.md、.harness/执行流程.md，以及 $TASK_FILE。

请只执行该任务，不要修改无关模块。
如果需要修改代码，只能修改任务文件中「允许修改范围」内的文件。
不要进入下一个任务。
完成后停止。"
}

run_agent_fix() {
  local log_file="$1"

  codex "请阅读 AGENTS.md、.harness/项目上下文.md、.harness/执行流程.md，以及 $TASK_FILE。

刚才任务执行后的验证失败，错误日志如下：

$(cat "$log_file")

请只在该任务「允许修改范围」内修复问题。
不要修改无关模块。
不要进入下一个任务。
修复后停止。"
}

print_result() {
  echo
  echo "修改文件："
  git status --short || true
  echo
  echo "最近一次验证日志：$VALIDATION_LOG"
}

echo "开始执行任务：$TASK_FILE"
echo

run_agent_task

attempt=0

while true; do
  attempt=$((attempt + 1))

  echo
  echo "开始第 $attempt 次验证..."
  echo

  if run_validation > "$VALIDATION_LOG" 2>&1; then
    cat "$VALIDATION_LOG"
    echo
    echo "任务验证通过。"
    print_result
    exit 0
  fi

  cat "$VALIDATION_LOG"
  echo
  echo "任务验证失败。"

  if [ "$attempt" -gt "$MAX_RETRY_VALUE" ]; then
    echo "已超过最大修复次数：$MAX_RETRY_VALUE"
    echo "请人工查看错误日志：$VALIDATION_LOG"
    print_result
    exit 1
  fi

  echo
  echo "开始让 Agent 修复验证失败问题..."
  echo

  run_agent_fix "$VALIDATION_LOG"
done