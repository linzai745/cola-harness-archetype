#set( $symbol_pound = "#" )
${symbol_pound} AI 编码规则
${symbol_pound}${symbol_pound} 一、架构规范
本项目采用 COLA 多模块分层架构。
模块职责如下：
- client：对外契约包，放 DTO、Command、Query、Response、API 接口、gRPC proto。
- adapter：接入层，放 HTTP Controller、gRPC Service 实现、MQ Listener、请求响应转换。
- app：应用层，负责编排用例、事务边界、调用 domain 和 infrastructure。
- domain：领域层，只放领域模型、领域服务、领域规则。
- infrastructure：基础设施层，放 DO、Mapper、Repository、Gateway、外部系统调用。
- start：启动层，只负责 Spring Boot 启动和配置装配。
---
${symbol_pound}${symbol_pound} 二、依赖规则
默认模块依赖关系：
```text
start -> adapter
adapter -> client
adapter -> app
app -> client
app -> domain
app -> infrastructure
infrastructure -> domain
infrastructure -> client 可选
domain -> 尽量不依赖外部技术框架
client -> 尽量保持轻量
```
说明：
- app 可以依赖 infrastructure。
- domain 不依赖 infrastructure。
- adapter 不直接访问 Mapper。
- client 不写业务实现。
- start 不写业务逻辑。
- start 不作为 ArchUnit 的独立分层建模对象，只作为启动装配模块和架构测试承载模块。
---
${symbol_pound}${symbol_pound} 三、强约束
- domain 不允许出现 MyBatis、Mapper、DO、Redis、Sa-Token、gRPC、HTTP Controller。
- adapter 不允许直接访问 Mapper。
- adapter 不允许写业务编排逻辑。
- client 不允许写业务实现。
- infrastructure 不允许反向调用 adapter。
- start 不允许写业务逻辑。
- 未明确要求时，不允许修改模块依赖方向。
- 未明确要求时，不允许修改无关模块。
- 未明确要求时，不允许新增框架。
- 不允许为了编译通过而破坏分层边界。
- 不允许修改 `.harness/checks/**` 来绕过检查。
- 不允许修改 `scope-check.sh` 来绕过范围检查。
- 不允许修改 `arch-check.sh` 或 `ArchitectureTest` 来绕过架构检查，除非任务明确要求调整架构规则。
---
${symbol_pound}${symbol_pound} 四、编码规范
- DTO、Command、Query、Response、DO 优先使用 Lombok。
- 对象转换优先使用 MapStruct。
- 数据库访问优先使用 MyBatis-Plus。
- gRPC proto 必须放在 client 模块。
- gRPC 实现必须放在 adapter 模块。
- 事务边界优先放在 app 层。
- 领域规则优先放在 domain 层。
- Repository、Gateway、Mapper、DO 放在 infrastructure 层。
- Controller、gRPC Service、MQ Listener 放在 adapter 层。
- Spring Boot 启动类和配置放在 start 层。
- Converter / Assembler 只做对象转换，不写业务规则、不查数据库、不调外部服务。
- DO 不允许泄漏到 adapter 层。
- DTO / Response 不应该反向污染 domain 层。
- 业务异常、错误码、统一返回结构应按项目既有规范实现，未明确要求时不要自创一套新规范。
- DomainService 按领域能力命名，不按实体名泛化命名。
- DomainService 只封装业务规则、业务计算、业务决策、领域对象协作，不做 CRUD、不碰基础设施。
- DomainService 的 public 方法要少，通常一个核心方法表达一个领域能力。
- DomainService 的入参和返回值必须是领域对象，不允许直接使用 Request、Response、DTO、DO、Map、JSON、第三方 Response。
- 判断结果、规则结果、策略结果可以作为领域结果对象建模，大多数情况下属于值对象。
- 值对象不要求一定是实体属性，只要没有身份、没有生命周期、用属性值表达业务概念，就可以作为值对象。
- 资源操作结果要重点判断：只是检查结果就是值对象；如果有 ID、状态、确认、释放、过期、追踪需求，就是实体或聚合根。
- AppService 负责编排用例和事务边界，DomainService 负责领域能力，Repository/Gateway 负责隔离持久化和外部系统。
- 聚合根维护一致性边界，Repository 面向聚合根，不面向普通 DTO 或 DO。
- 领域层只表达业务，不表达技术实现。
- Gateway 是外部能力抽象，不是 FeignClient、Mapper、RedisTemplate、第三方 SDK 的别名。
- Gateway 按业务能力或外部限界上下文命名，例如 InventoryGateway、PaymentGateway、RiskControlGateway、AiModelGateway。
- Gateway 接口不使用技术名；技术名只允许出现在 infrastructure 的实现类中，例如 WechatPaymentGatewayImpl、RemoteInventoryGatewayImpl。
- Gateway 方法名必须表达业务动作，不允许出现 callApi、sendHttp、queryByFeign、getFromRedis 这类技术动作。
- Gateway 入参必须是领域对象、值对象、上下文对象、快照对象或 Gateway 专用 Request，不允许直接使用 Controller Request、App Command、DO、PO、第三方 DTO。
- Gateway 返回值必须是业务对象，例如 Snapshot、Result、Decision、Reservation、Confirmation，不允许返回第三方 Response、JSONObject、Map、boolean 泛化结果。
- 跨领域查询优先返回 Snapshot，不返回对方领域完整聚合根。
- 资源操作不要只返回 boolean，应该返回可追踪的业务凭证，例如 InventoryReservation、CouponLock、BalanceFreeze。
- Repository 面向本领域聚合根，Gateway 面向外部系统或外部限界上下文，不要混用。 
- Client / SDK / FeignClient 只存在于 infrastructure 层，GatewayImpl 负责把外部协议对象转换成领域可理解的对象。
---
${symbol_pound}${symbol_pound} 五、包结构规范
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
- client 模块代码放在 `${package}.client..`
- adapter 模块代码放在 `${package}.adapter..`
- app 模块代码放在 `${package}.app..`
- domain 模块代码放在 `${package}.domain..`
- infrastructure 模块代码放在 `${package}.infrastructure..`
- start 模块只放启动类和配置，不承载业务代码。
  不要把业务代码直接放在 `${package}` 根包下。
  ArchUnit 架构测试会按上述包结构识别分层边界。
  注意：
- `Application.java` 保持 `package ${package};`。
- `ArchitectureTest.java` 保持 `package ${package};`。
- start 模块不单独建模为 ArchUnit 分层。
- ArchUnit 只检查 client、adapter、app、domain、infrastructure 五个业务分层。
---
${symbol_pound}${symbol_pound} 六、任务执行规范
每次执行任务必须：
1. 先阅读本文件。
2. 再阅读 `.harness/项目上下文.md`。
3. 再阅读 `.harness/执行流程.md`。
4. 再阅读具体任务文件。
5. 明确任务类型。
6. 明确允许修改范围。
7. 明确禁止修改范围。
8. 只修改任务允许范围内的文件。
9. 执行任务文件中的验证命令。
10. 如果验证失败，只能在任务允许范围内修复。
11. 修复后再次执行验证命令。
12. 输出修改文件清单、验证结果、范围检查结果、遗留风险。
13. 不自动进入下一个任务。
---
${symbol_pound}${symbol_pound} 七、任务类型规范
本项目任务分为六类：
```text
用例开发：用于新增一个完整业务能力。
用例迭代：用于调整或增强一个已有业务能力。
缺陷修复：用于修复一个明确问题。
重构优化：用于完成一个明确边界的结构优化，默认不改变业务行为。
测试补充：用于补充测试，不改变业务逻辑。
配置调整：用于调整配置、依赖或环境接入。
```
Archetype 已经生成基础模块结构，因此不要再创建“初始化模块任务”。
---
${symbol_pound}${symbol_pound} 八、用例任务规范
业务开发应优先使用用例任务。
用例任务包括：
```text
用例开发：从 0 到 1 新增一个业务能力。
用例迭代：在已有业务能力上做增强或调整。
```
用例任务必须描述：
- 业务目标
- 原有行为
- 本次新增或调整行为
- 不变行为
- 业务边界
- 参与角色
- 前置条件
- 主流程
- 异常流程
- 业务规则
- 涉及模块
- 允许修改范围
- 禁止修改范围
- 验收标准
- 验证命令
  用例任务应该解决：
```text
业务怎么跑
流程怎么走
规则在哪里表达
哪些异常要处理
哪些边界不负责
哪些历史行为不能破坏
```
不要把一个完整业务用例拆成零散的“修改 client / 修改 domain / 修改 app”任务。
模块是代码组织方式，不是业务任务边界。
---
${symbol_pound}${symbol_pound} 九、缺陷任务规范
缺陷修复任务必须描述：
- 问题现象
- 影响范围
- 复现步骤
- 期望行为
- 原因分析
- 允许修改范围
- 禁止修改范围
- 修复要求
- 验收标准
- 验证命令
  缺陷修复必须遵守：
- 只修复当前缺陷。
- 不顺手重构无关代码。
- 不扩大业务边界。
- 不修改无关模块。
- 如果发现问题根因不在允许范围内，停止并说明原因。
---
${symbol_pound}${symbol_pound} 十、重构任务规范
重构优化任务必须描述：
- 当前问题
- 重构目标
- 重构边界
- 允许修改范围
- 禁止修改范围
- 重构要求
- 验收标准
- 验证命令
  重构任务必须明确：
```text
是否允许改变外部接口
是否允许改变业务行为
是否允许调整数据结构
是否允许调整模块依赖
```
默认情况下，重构不允许改变业务行为。
如果需要改变业务行为，应拆成用例任务或缺陷任务。
---
${symbol_pound}${symbol_pound} 十一、测试补充任务规范
测试补充任务用于增加或完善测试，不应改变业务逻辑。
测试补充任务必须描述：
- 要覆盖的业务场景
- 要覆盖的异常场景
- 目标测试模块
- 是否需要 Mock 外部依赖
- 允许修改范围
- 禁止修改范围
- 验证命令
  测试补充任务必须遵守：
- 不修改业务主流程。
- 不修改生产代码来迎合测试，除非任务明确要求。
- 不删除已有测试。
- 不降低已有断言强度。
- 如果发现生产代码存在缺陷，应停止并建议创建缺陷任务。
---
${symbol_pound}${symbol_pound} 十二、配置调整任务规范
配置调整任务用于调整依赖、配置、中间件接入或运行环境。
配置调整任务必须描述：
- 调整目标
- 涉及配置文件
- 涉及依赖
- 是否影响启动
- 是否影响运行环境
- 回滚方式
- 验证命令
  配置调整任务必须遵守：
- 不修改业务逻辑。
- 不修改生产敏感配置，除非任务明确要求。
- 不提交真实密钥、Token、密码、证书。
- 不引入任务未要求的新框架。
- 不删除已有配置项，除非任务明确要求。
---
${symbol_pound}${symbol_pound} 十三、允许修改范围规则
任务文件中的：
```text
${symbol_pound}${symbol_pound} 允许修改范围
```
用于约束 Agent 可以修改哪些文件。
示例：
```text
- ${rootArtifactId}-client/**
- ${rootArtifactId}-domain/**
- ${rootArtifactId}-app/**
```
Agent 不允许修改允许范围之外的文件。
如果发现任务必须修改允许范围之外的文件，应该停止并说明原因，不要擅自修改。
---
${symbol_pound}${symbol_pound} 十四、禁止修改范围规则
任务文件中的：
```text
${symbol_pound}${symbol_pound} 禁止修改范围
```
用于明确 Agent 绝对不应该修改哪些文件。
常见禁止范围：
```text
- pom.xml
- AGENTS.md
- .harness/checks/**
- scripts/**
- ${rootArtifactId}-start/**
```
如果任务没有明确要求，不允许修改：
```text
安全配置
认证逻辑
权限逻辑
资金逻辑
生产配置
CI/CD 配置
架构检查规则
Agent 执行脚本
```
---
${symbol_pound}${symbol_pound} 十五、验证规范
每个任务文件必须包含：
```text
${symbol_pound}${symbol_pound} 验证命令
```
验证命令必须使用 `bash` 代码块。
示例：
```bash
./.harness/checks/verify-all.sh
./.harness/checks/scope-check.sh .harness/任务/用例/UC-001-创建订单.md
```
验证命令必须至少覆盖：
```text
编译检查
ArchUnit 架构测试
轻量级架构边界检查
修改范围检查
```
通常任务文件中可以直接使用：
```bash
./.harness/checks/verify-all.sh
./.harness/checks/scope-check.sh .harness/任务/用例/UC-xxx-xxx.md
```
其中 `verify-all.sh` 已包含：
```text
compile-all.sh
arch-test.sh
arch-check.sh
```
如果任务涉及测试，应补充对应测试命令，例如：
```bash
./.harness/checks/test-module.sh ${rootArtifactId}-app
```
---
${symbol_pound}${symbol_pound} 十六、架构检查规范
本项目提供两类架构检查：
```text
arch-test.sh：
  执行 ArchUnit 架构测试，检查正式分层依赖规则。
arch-check.sh：
  执行 shell 轻量检查，快速发现明显分层污染。
```
`ArchitectureTest` 主要检查：
- COLA 分层依赖关系。
- domain 不依赖技术框架。
- adapter 不直接访问 Mapper。
- adapter 不依赖 DO。
- client 不依赖业务实现和基础设施实现。
- app 不包含 HTTP / gRPC 接入实现。
  `arch-check.sh` 主要检查：
- domain 不允许出现 Mapper / DO / RedisTemplate / StpUtil / Controller / RequestMapping / Grpc。
- adapter 不允许直接访问 Mapper。
- client 不允许出现 Repository / Mapper / DO。
  如果项目后续引入新的技术框架，需要根据实际架构调整 `ArchitectureTest`，但必须通过明确任务进行，不允许为了绕过检查随意删除规则。
---
${symbol_pound}${symbol_pound} 十七、失败修复规范
如果验证失败：
1. 先阅读失败日志。
2. 判断失败是否属于当前任务范围。
3. 如果属于当前任务范围，可以修复。
4. 如果不属于当前任务范围，停止并说明原因。
5. 不允许为了通过验证而删除测试、降低检查强度、扩大修改范围。
6. 不允许修改 `.harness/checks/**` 来绕过检查。
7. 不允许修改 `scope-check.sh` 来绕过范围检查。
8. 不允许修改 `arch-check.sh` 或 `ArchitectureTest` 来绕过架构检查。
9. 不允许为了通过架构检查而把代码移动到错误分层包中。
10. 不允许为了通过编译而删除必要业务逻辑。
---
${symbol_pound}${symbol_pound} 十八、禁止行为
- 不允许一次性跨多个任务连续修改。
- 不允许在任务结束后自动进入下一个任务。
- 不允许修改任务禁止范围内的文件。
- 不允许删除已有业务代码，除非任务明确要求。
- 不允许修改安全、认证、权限、资金、生产配置相关逻辑，除非任务明确要求。
- 不允许为了让编译通过而把业务逻辑塞进 adapter。
- 不允许为了让编译通过而让 domain 依赖 infrastructure。
- 不允许为了省事绕过 app 层。
- 不允许在 client 层写业务实现。
- 不允许在 start 层写业务逻辑。
- 不允许引入任务没有要求的新框架。
- 不允许在任务没有要求时修改 Maven 父工程依赖管理。
- 不允许在任务没有要求时修改 Agent Harness 脚本和规则文档。
---
${symbol_pound}${symbol_pound} 十九、输出要求
任务完成后必须输出：
```text
修改文件：
- xxx
- xxx
验证结果：
- 执行命令：xxx
- 是否通过：是 / 否
范围检查：
- 是否越界：是 / 否
遗留风险：
- xxx
建议下一步：
- xxx
```
如果验证失败，必须输出：
```text
失败命令：
- xxx
失败原因：
- xxx
是否已尝试修复：
- 是 / 否
是否需要人工介入：
- 是 / 否
```
如果发现任务描述不足，必须输出：
```text
缺失信息：
- xxx
建议补充：
- xxx
```
---
${symbol_pound}${symbol_pound} 二十、最终原则
Agent 负责：
```text
按任务文件执行
按允许范围修改
按验证命令检查
根据失败日志修复
输出结果
```
人负责：
```text
定义业务边界
编写任务文件
判断领域模型
判断业务语义
Review 最终 diff
决定是否合并
```
本项目不是让 Agent 自由开发系统，而是让 Agent 在 Harness 约束下完成可验证的小闭环任务。