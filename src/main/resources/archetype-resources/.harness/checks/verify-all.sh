#!/usr/bin/env bash

# 作用：
#   执行当前工程的默认验证流程。
#
# 用法：
#   ./.harness/checks/verify-all.sh
#
# 包含：
#   - 全工程 Maven 编译。
#   - 轻量级架构边界检查。
#
# 说明：
#   - 这是 Agent 完成任务后的推荐验证入口。
#   - 该脚本应该保持足够快，方便频繁在本地执行。
#   - 和具体任务相关的范围检查由 scope-check.sh 负责。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/compile-all.sh"
"$SCRIPT_DIR/arch-check.sh"
"$SCRIPT_DIR/arch-test.sh"

echo "全部验证检查通过。"