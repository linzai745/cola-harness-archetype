#!/usr/bin/env bash

# 作用：
#   执行指定 Maven 子模块的测试，并同时编译它依赖的上游模块。
#
# 用法：
#   ./.harness/checks/test-module.sh <模块名>
#
# 示例：
#   ./.harness/checks/test-module.sh order-service-app
#
# 说明：
#   - 使用 Maven 的 -pl 参数指定要测试的模块。
#   - 使用 -am 参数自动编译该模块依赖的上游模块。
#   - 不跳过测试。

set -euo pipefail

MODULE="${1:-}"

if [ -z "$MODULE" ]; then
  echo "用法：./.harness/checks/test-module.sh <模块名>"
  exit 1
fi

mvn test -pl "$MODULE" -am