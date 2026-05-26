#!/usr/bin/env bash

# 作用：
#   编译整个 Maven 多模块工程。
#
# 用法：
#   ./.harness/checks/compile-all.sh
#
# 说明：
#   - 这是一个快速的全工程编译检查。
#   - 默认跳过测试。
#   - 当任务修改了多个模块，或者不确定影响范围时，建议执行这个脚本。

set -euo pipefail

mvn clean compile -DskipTests