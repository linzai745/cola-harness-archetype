#!/usr/bin/env bash

# 作用：
#   对 COLA 多模块工程做轻量级架构边界检查。
#
# 用法：
#   ./.harness/checks/arch-check.sh
#
# 检查内容：
#   - domain 模块不允许出现基础设施层或接入层相关依赖。
#   - adapter 模块不允许直接访问 Mapper。
#   - client 模块只允许放契约，不允许出现 Repository、Mapper、DO 等实现细节。
#
# 说明：
#   - 这个脚本是轻量级检查，不替代 ArchUnit 或完整静态分析。
#   - 第一阶段用于约束 Agent 不要破坏基础分层边界。
#   - 项目稳定后，可以升级为 ArchUnit 测试。

set -euo pipefail

ROOT_DIR="$(pwd)"
ARTIFACT_ID="$(basename "$ROOT_DIR")"

CLIENT_DIR="${ARTIFACT_ID}-client/src/main/java"
ADAPTER_DIR="${ARTIFACT_ID}-adapter/src/main/java"
DOMAIN_DIR="${ARTIFACT_ID}-domain/src/main/java"

echo "开始检查架构边界..."

if [ -d "$DOMAIN_DIR" ]; then
  if grep -R -n -E "Mapper|DO|RedisTemplate|StpUtil|Controller|RequestMapping|Grpc|ServiceGrpc" "$DOMAIN_DIR"; then
    echo "架构违规：domain 模块出现了不允许的技术依赖。"
    exit 1
  fi
fi

if [ -d "$ADAPTER_DIR" ]; then
  if grep -R -n -E "Mapper" "$ADAPTER_DIR"; then
    echo "架构违规：adapter 模块不允许直接访问 Mapper。"
    exit 1
  fi
fi

if [ -d "$CLIENT_DIR" ]; then
  if grep -R -n -E "Repository|Mapper|DO" "$CLIENT_DIR"; then
    echo "架构违规：client 模块只允许放契约，不允许出现实现细节。"
    exit 1
  fi
fi

echo "架构边界检查通过。"