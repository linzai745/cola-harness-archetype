#set( $symbol_pound = "#" )
${symbol_pound} ${rootArtifactId}

本项目基于 **COLA 多模块分层架构** 创建，并内置了一套用于 Agentic Coding 的 **Harness 工程化脚手架**。

它的目标是：

```text
让业务代码有清晰分层；
让 Coding Agent 在规则内改代码；
让每次修改都可以被编译、检查和 Review 验证。
```

---

${symbol_pound}${symbol_pound} 一、工程结构

```text
${rootArtifactId}
├── pom.xml
├── README.md
├── AGENTS.md
├── .harness
│   ├── 项目上下文.md
│   ├── 执行流程.md
│   ├── 任务
│   │   ├── 00-任务模板.md
│   │   ├── 用例
│   │   │   └── UC-000-用例任务示例.md
│   │   ├── 缺陷
│   │   │   └── BUG-000-缺陷修复示例.md
│   │   └── 重构
│   │       └── RF-000-重构任务示例.md
│   ├── checks
│   │   ├── compile-module.sh
│   │   ├── compile-all.sh
│   │   ├── test-module.sh
│   │   ├── arch-test.sh
│   │   ├── arch-check.sh
│   │   ├── scope-check.sh
│   │   └── verify-all.sh
│   └── review
│       └── 评审清单.md
├── scripts
│   └── agent-task.sh
├── ${rootArtifactId}-client
├── ${rootArtifactId}-adapter
├── ${rootArtifactId}-app
├── ${rootArtifactId}-domain
├── ${rootArtifactId}-infrastructure
└── ${rootArtifactId}-start
```

---

${symbol_pound}${symbol_pound} 二、模块职责

${symbol_pound}${symbol_pound}${symbol_pound} 1. `${rootArtifactId}-client`

对外契约模块。

用于放：

```text
DTO
Command
Query
Response / Result
API 接口
gRPC proto
```

不应该放：

```text
业务实现
Repository
Mapper
DO
Redis
MyBatis
Sa-Token
Controller
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 2. `${rootArtifactId}-adapter`

接入层模块。

用于放：

```text
HTTP Controller
gRPC Service 实现
MQ Listener
Request / Response
参数校验
请求响应转换
```

不应该放：

```text
业务编排
数据库访问
Mapper 调用
Repository 实现
复杂业务规则
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 3. `${rootArtifactId}-app`

应用层模块。

用于放：

```text
应用服务
用例编排
事务边界
Command / Query 处理
调用 domain
调用 infrastructure
```

说明：

```text
app 可以依赖 infrastructure。
事务边界优先放在 app 层。
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 4. `${rootArtifactId}-domain`

领域层模块。

用于放：

```text
领域模型
领域服务
领域规则
领域枚举
```

不应该放：

```text
Spring Web
MyBatis
Redis
gRPC
Sa-Token
Mapper
DO
Controller
MQ Listener
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 5. `${rootArtifactId}-infrastructure`

基础设施模块。

用于放：

```text
DO
Mapper
Repository
Gateway
MapStruct Converter
外部系统调用
Redis / MQ / OSS / 第三方 SDK 等技术实现
```

不应该放：

```text
HTTP Controller
gRPC Service 实现
完整业务流程编排
领域规则定义
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 6. `${rootArtifactId}-start`

启动模块。

用于放：

```text
Spring Boot 启动类
application.yml
配置装配
包扫描
MapperScan
ArchUnit 架构测试
```

不应该放：

```text
业务逻辑
应用服务实现
Controller 业务编排
Repository 实现
领域规则
```

---

${symbol_pound}${symbol_pound} 三、模块依赖关系

默认依赖关系：

```text
${rootArtifactId}-start
  -> ${rootArtifactId}-adapter
  -> ${rootArtifactId}-app
  -> ${rootArtifactId}-domain
  -> ${rootArtifactId}-infrastructure

${rootArtifactId}-adapter
  -> ${rootArtifactId}-client
  -> ${rootArtifactId}-app

${rootArtifactId}-app
  -> ${rootArtifactId}-client
  -> ${rootArtifactId}-domain
  -> ${rootArtifactId}-infrastructure

${rootArtifactId}-infrastructure
  -> ${rootArtifactId}-domain
  -> ${rootArtifactId}-client 可选

${rootArtifactId}-domain
  -> 尽量不依赖外部技术框架

${rootArtifactId}-client
  -> 尽量保持轻量
```

核心约束：

```text
adapter 不直接访问 Mapper
domain 不依赖 infrastructure
client 不写业务实现
start 不写业务逻辑
```

说明：

```text
start 模块只作为启动装配模块和架构测试承载模块；
start 不作为 ArchUnit 的独立分层建模对象。
```

---

${symbol_pound}${symbol_pound} 四、默认技术栈

默认包含：

```text
Java ${javaVersion}
Spring Boot ${springBootVersion}
Maven 多模块
COLA 分层思想
Lombok
MapStruct
MyBatis-Plus
gRPC 基础依赖
ArchUnit
```

按需扩展：

```text
Redis
Sa-Token
MQ
Nacos
OpenFeign
Elasticsearch
Prometheus / Micrometer
```

---

${symbol_pound}${symbol_pound} 五、包结构约定

各模块默认包结构如下：

```text
${rootArtifactId}-client/src/main/java/${package}/client
${rootArtifactId}-adapter/src/main/java/${package}/adapter
${rootArtifactId}-app/src/main/java/${package}/app
${rootArtifactId}-domain/src/main/java/${package}/domain
${rootArtifactId}-infrastructure/src/main/java/${package}/infrastructure
${rootArtifactId}-start/src/main/java/Application.java
```

代码必须放入对应包路径：

```text
client 模块代码放在 ${package}.client..
adapter 模块代码放在 ${package}.adapter..
app 模块代码放在 ${package}.app..
domain 模块代码放在 ${package}.domain..
infrastructure 模块代码放在 ${package}.infrastructure..
start 模块只放启动类和配置，不承载业务代码。
```

注意：

```text
Application.java 保持 package ${package};
ArchitectureTest.java 保持 package ${package};
start 模块不单独建模为 ArchUnit 分层；
ArchUnit 只检查 client、adapter、app、domain、infrastructure 五个业务分层。
```

---

${symbol_pound}${symbol_pound} 六、首次使用

${symbol_pound}${symbol_pound}${symbol_pound} 1. 初始化 Git

```bash
git init
git add .
git commit -m "初始化 COLA Harness 工程"
```

${symbol_pound}${symbol_pound}${symbol_pound} 2. 给脚本授权

```bash
chmod +x .harness/checks/*.sh
chmod +x scripts/*.sh
```

${symbol_pound}${symbol_pound}${symbol_pound} 3. 执行默认验证

```bash
./.harness/checks/verify-all.sh
```

如果模板刚生成后验证失败，优先检查：

```text
Maven 依赖是否能下载
Java 版本是否正确
脚本是否已授权
当前目录是否是项目根目录
```

---

${symbol_pound}${symbol_pound} 七、Harness 目录说明

${symbol_pound}${symbol_pound}${symbol_pound} 1. `AGENTS.md`

仓库级 AI 编码规则。

用于约束 Coding Agent：

```text
架构规范
模块职责
依赖方向
禁止事项
编码规范
任务执行规范
验证要求
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 2. `.harness/项目上下文.md`

当前项目上下文。

项目创建后，建议优先补充：

```text
当前服务的业务边界
当前服务不负责什么
当前服务暴露的接口
当前服务依赖的外部系统
是否使用 Redis
是否使用 MQ
是否使用 Sa-Token
是否使用 gRPC
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 3. `.harness/执行流程.md`

Agent 执行任务时必须遵守的流程。

核心要求：

```text
先读规则
再读上下文
再读任务
只改允许范围
执行验证命令
失败自动修复
再次验证
输出结果
不自动进入下一个任务
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 4. `.harness/任务`

任务文件目录。

本项目的任务目录分为三类：

```text
.harness/任务
├── 00-任务模板.md
├── 用例
├── 缺陷
└── 重构
```

Archetype 已经负责生成分层模块，所以任务系统不再负责初始化模块。

任务系统只负责后续开发：

```text
用例开发
用例迭代
缺陷修复
重构优化
测试补充
配置调整
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 5. `.harness/checks`

检查脚本目录。

默认包含：

```text
compile-module.sh
compile-all.sh
test-module.sh
arch-test.sh
arch-check.sh
scope-check.sh
verify-all.sh
```

作用：

```text
compile-module.sh   编译指定模块
compile-all.sh      编译整个工程
test-module.sh      测试指定模块
arch-test.sh        执行 ArchUnit 架构测试
arch-check.sh       执行轻量级脚本架构检查
scope-check.sh      检查当前任务是否越界修改
verify-all.sh       默认全量验证入口
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 6. `.harness/review/评审清单.md`

人工 Review 清单。

用于检查：

```text
架构边界
依赖方向
对象转换
事务边界
Agent 修改范围
验证结果
核心业务语义
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 7. `scripts/agent-task.sh`

统一执行 Agent 任务的入口。

示例：

```bash
./scripts/agent-task.sh 用例/UC-001-创建订单.md
```

它会自动完成：

```text
调用 Agent 执行任务
提取任务文件中的验证命令
执行验证命令
失败后把日志反馈给 Agent 修复
再次验证
输出修改文件和验证结果
```

如果使用的不是 Codex，可以修改该脚本中的 Agent 命令。

---

${symbol_pound}${symbol_pound} 八、任务目录说明

${symbol_pound}${symbol_pound}${symbol_pound} 1. 用例任务

路径：

```text
.harness/任务/用例
```

用于新增或迭代一个完整业务用例。真实业务开发时，优先使用用例任务。

执行示例：

```bash
./scripts/agent-task.sh 用例/UC-001-创建订单.md
./scripts/agent-task.sh 用例/UC-002-创建订单支持优惠券.md
```

用例任务分为：

```text
用例开发：新增一个完整业务能力。
用例迭代：调整或增强一个已有业务能力。
```

用例任务应该描述：

```text
业务目标
原有行为
本次新增或调整行为
不变行为
业务边界
参与角色
前置条件
主流程
异常流程
业务规则
涉及模块
允许修改范围
禁止修改范围
验收标准
验证命令
```

适合场景：

```text
创建订单
取消订单
创建订单支持优惠券
短信登录支持图形验证码
支付回调增加幂等校验
查询订单详情增加履约信息
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 2. 缺陷任务

路径：

```text
.harness/任务/缺陷
```

用于修复一个明确缺陷。

执行示例：

```bash
./scripts/agent-task.sh 缺陷/BUG-001-修复金额计算.md
```

缺陷任务应该描述：

```text
问题现象
影响范围
复现步骤
期望行为
原因分析
允许修改范围
禁止修改范围
修复要求
验收标准
验证命令
```

适合场景：

```text
参数为空时报系统异常
金额计算错误
状态判断遗漏
某个接口返回字段缺失
某个 Mapper 查询条件错误
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 3. 重构任务

路径：

```text
.harness/任务/重构
```

用于执行一个明确边界的重构。

执行示例：

```bash
./scripts/agent-task.sh 重构/RF-001-抽取订单Assembler.md
```

重构任务应该描述：

```text
重构目标
当前问题
重构边界
允许修改范围
禁止修改范围
重构要求
验收标准
验证命令
```

适合场景：

```text
抽取 Assembler
拆分过大的 AppService
统一异常处理
整理包结构
替换重复转换逻辑
收敛 Gateway 调用
```

---

${symbol_pound}${symbol_pound} 九、任务拆分原则

Archetype 已经负责生成分层模块，所以任务系统不再负责初始化模块。

任务系统只负责后续开发：

```text
用例开发
用例迭代
缺陷修复
重构优化
测试补充
配置调整
```

核心原则：

```text
用例开发解决“新增业务能力怎么跑”；
用例迭代解决“已有业务能力怎么增强，并且不破坏旧行为”；
缺陷任务解决“问题怎么修”；
重构任务解决“结构怎么改，并且默认不改变业务行为”。
```

不要让 Agent 直接执行：

```text
实现完整系统
重构整个项目
顺便优化所有代码
```

每个任务都必须有：

```text
明确目标
明确边界
明确允许范围
明确禁止范围
明确验证命令
```

如果是用例迭代，还必须有：

```text
原有行为
本次新增或调整行为
不变行为
```

---

${symbol_pound}${symbol_pound} 十、Agentic Coding 使用流程

${symbol_pound}${symbol_pound}${symbol_pound} 1. 补充项目上下文

编辑：

```text
.harness/项目上下文.md
```

补充当前服务的业务边界、外部依赖、通信方式和技术选型。

---

${symbol_pound}${symbol_pound}${symbol_pound} 2. 创建任务文件

优先从用例示例复制：

```bash
cp .harness/任务/用例/UC-000-用例任务示例.md .harness/任务/用例/UC-001-创建订单.md
```

如果是缺陷修复：

```bash
cp .harness/任务/缺陷/BUG-000-缺陷修复示例.md .harness/任务/缺陷/BUG-001-修复金额计算.md
```

如果是重构：

```bash
cp .harness/任务/重构/RF-000-重构任务示例.md .harness/任务/重构/RF-001-抽取订单Assembler.md
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 3. 编写任务内容

任务文件必须写清楚：

```text
目标
业务边界
主流程 / 问题现象 / 重构目标
允许修改范围
禁止修改范围
验收标准
验证命令
```

尤其是：

```text
允许修改范围
禁止修改范围
验证命令
```

这三个字段会直接影响 Agent 的执行边界和自动验证闭环。

---

${symbol_pound}${symbol_pound}${symbol_pound} 4. 执行任务

```bash
./scripts/agent-task.sh 用例/UC-001-创建订单.md
```

脚本会自动执行：

```text
读取 AGENTS.md
读取 .harness/项目上下文.md
读取 .harness/执行流程.md
读取指定任务文件
调用 Agent 执行任务
提取验证命令
执行验证命令
失败后反馈给 Agent 修复
再次验证
输出结果
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 5. 人工 Review

查看修改：

```bash
git status
git diff --stat
git diff
```

重点检查：

```text
有没有修改禁止范围内的文件
有没有破坏 COLA 分层
adapter 有没有直接访问 Mapper
domain 有没有引入技术依赖
client 有没有写业务实现
app 有没有泄漏 DO
是否乱加依赖
是否为了编译通过做了错误妥协
业务语义是否正确
```

可以参考：

```text
.harness/review/评审清单.md
```

---

${symbol_pound}${symbol_pound}${symbol_pound} 6. 提交代码

确认无误后提交：

```bash
git add .
git commit -m "完成创建订单用例"
```

---

${symbol_pound}${symbol_pound} 十一、常用命令

${symbol_pound}${symbol_pound}${symbol_pound} 执行用例任务

```bash
./scripts/agent-task.sh 用例/UC-001-创建订单.md
```

${symbol_pound}${symbol_pound}${symbol_pound} 执行缺陷任务

```bash
./scripts/agent-task.sh 缺陷/BUG-001-修复金额计算.md
```

${symbol_pound}${symbol_pound}${symbol_pound} 执行重构任务

```bash
./scripts/agent-task.sh 重构/RF-001-抽取订单Assembler.md
```

${symbol_pound}${symbol_pound}${symbol_pound} 编译指定模块

```bash
./.harness/checks/compile-module.sh ${rootArtifactId}-client
```

${symbol_pound}${symbol_pound}${symbol_pound} 测试指定模块

```bash
./.harness/checks/test-module.sh ${rootArtifactId}-app
```

${symbol_pound}${symbol_pound}${symbol_pound} 编译全工程

```bash
./.harness/checks/compile-all.sh
```

${symbol_pound}${symbol_pound}${symbol_pound} 执行 ArchUnit 架构测试

```bash
./.harness/checks/arch-test.sh
```

${symbol_pound}${symbol_pound}${symbol_pound} 检查架构边界

```bash
./.harness/checks/arch-check.sh
```

${symbol_pound}${symbol_pound}${symbol_pound} 检查修改范围

```bash
./.harness/checks/scope-check.sh .harness/任务/用例/UC-001-创建订单.md
```

${symbol_pound}${symbol_pound}${symbol_pound} 默认全量验证

```bash
./.harness/checks/verify-all.sh
```

---

${symbol_pound}${symbol_pound} 十二、架构边界检查说明

本项目提供两类架构边界检查：

```text
arch-test.sh
  基于 ArchUnit 的架构测试，放在 start 模块中执行。
  用于检查 COLA 分层依赖、domain 技术依赖、adapter 直接访问 Mapper 等问题。

arch-check.sh
  基于 shell + grep 的轻量检查。
  用于快速发现明显的分层污染。
```

`verify-all.sh` 会同时执行：

```bash
./.harness/checks/compile-all.sh
./.harness/checks/arch-test.sh
./.harness/checks/arch-check.sh
```

当前 ArchUnit 主要检查：

```text
COLA 分层依赖关系
domain 不依赖技术框架
adapter 不直接访问 Mapper
adapter 不依赖 DO
client 不依赖业务实现和基础设施实现
app 不包含 HTTP / gRPC 接入实现
```

当前 shell 脚本主要检查：

```text
domain 不允许出现 Mapper / DO / RedisTemplate / StpUtil / Controller / RequestMapping / Grpc
adapter 不允许直接访问 Mapper
client 不允许出现 Repository / Mapper / DO
```

说明：

```text
arch-test.sh 是正式架构测试；
arch-check.sh 是轻量补充检查；
两者都会被 verify-all.sh 执行；
start 模块只作为启动装配和测试承载模块，不作为 ArchUnit 分层建模对象。
```

如果项目后续引入新的技术框架，需要根据实际架构调整 `ArchitectureTest`，但不要为了绕过检查随意删除规则。

---

${symbol_pound}${symbol_pound} 十三、修改范围检查说明

`scope-check.sh` 会读取任务文件中的：

```text
${symbol_pound}${symbol_pound} 允许修改范围
```

并检查当前 Git 工作区修改文件是否都在允许范围内。

例如任务只允许：

```text
- ${rootArtifactId}-client/**
```

但 Agent 修改了：

```text
${rootArtifactId}-app/**
```

则范围检查失败。

这能防止 Agent 越界修改。

---

${symbol_pound}${symbol_pound} 十四、gRPC 说明

默认在 `${rootArtifactId}-client/src/main/proto` 下提供了一个占位 `service.proto`。

真实项目中应根据业务替换：

```text
service
message
rpc 方法
package
java_package
```

gRPC 生成代码位于：

```text
${rootArtifactId}-client/target/generated-sources/protobuf/java
${rootArtifactId}-client/target/generated-sources/protobuf/grpc-java
```

生成命令：

```bash
./.harness/checks/compile-module.sh ${rootArtifactId}-client
```

---

${symbol_pound}${symbol_pound} 十五、注意事项

1. 生成项目后，先修改 `.harness/项目上下文.md`。
2. 不要把所有需求都塞给 Agent 一次完成。
3. 每次只执行一个任务。
4. 每次任务完成后必须经过验证命令。
5. 认证、权限、资金、订单状态流转等关键逻辑必须人工 Review。
6. `arch-test.sh` 是正式架构测试，但不能替代人工设计判断。
7. `arch-check.sh` 是轻量检查，不能替代 ArchUnit 和代码评审。
8. `scope-check.sh` 只能检查文件范围，不能判断业务正确性。
9. `start` 模块不要写业务逻辑。
10. `adapter` 模块不要直接访问 Mapper。
11. `domain` 模块不要引入技术细节。
12. `client` 模块不要写业务实现。
13. 不要为了让检查通过而删除或弱化检查规则。
14. 不要为了让编译通过而破坏 COLA 分层。

---

${symbol_pound}${symbol_pound} 十六、目标

这个工程不是普通多模块项目，而是：

```text
COLA 分层工程骨架 + Agent Harness 执行体系
```

目标是让项目具备：

```text
清晰分层
明确边界
任务可拆
结果可验
Agent 可控
```