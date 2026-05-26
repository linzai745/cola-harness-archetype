#!/usr/bin/env bash

# 作用：
#   执行 ArchUnit 架构测试。
#
# 用法：
#   ./.harness/checks/arch-test.sh
#
# 说明：
#   - ArchUnit 测试放在 start 模块。
#   - start 模块依赖其他业务模块，因此可以做全局架构边界检查。
#   - 本脚本用于执行更正式的架构测试。
#   - arch-check.sh 是轻量脚本检查，arch-test.sh 是基于测试框架的架构约束。

set -euo pipefail

ROOT_DIR="$(pwd)"
ARTIFACT_ID="$(basename "$ROOT_DIR")"
START_MODULE="${ARTIFACT_ID}-start"

mvn test -pl "$START_MODULE" -am -Dtest=ArchitectureTest