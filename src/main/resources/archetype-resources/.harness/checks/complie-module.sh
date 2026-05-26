#!/usr/bin/env bash

# 作用：
#   编译指定的 Maven 子模块，并同时编译它依赖的上游模块。
#
# 用法：
#   ./.harness/checks/compile-module.sh <模块名>
#
# 示例：
#   ./.harness/checks/compile-module.sh order-service-client
#
# 说明：
#   - 使用 Maven 的 -pl 参数指定要编译的模块。
#   - 使用 -am 参数自动编译该模块依赖的上游模块。
#   - 默认跳过测试，用于 Agent 编码过程中的快速反馈。

set -euo pipefail

MODULE="${1:-}"

if [ -z "$MODULE" ]; then
  echo "用法：./.harness/checks/compile-module.sh <模块名>"
  exit 1
fi

mvn clean compile -pl "$MODULE" -am -DskipTests