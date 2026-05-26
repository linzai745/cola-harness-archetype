# cola-harness-archetype

`cola-harness-archetype` 是一个 Maven Archetype，用于生成基于 COLA 分层思想的 Java 多模块工程模板。生成后的项目内置 Agentic Coding 约束文档、任务模板和验证脚本，目标是让业务代码分层清晰，并让 AI 编码任务有明确的执行边界和验证闭环。

## 特性

- 基于 Maven Archetype 生成标准 Java 多模块项目。
- 默认生成 `client`、`adapter`、`app`、`domain`、`infrastructure`、`start` 六个模块。
- 支持 Java 版本和 Spring Boot 版本在生成时参数化。
- 内置 `.harness` 目录，包含任务模板、执行流程、检查脚本和评审清单。
- 内置 `AGENTS.md`，约束 AI Agent 的分层规则、编码规则和任务执行流程。
- 内置 ArchUnit 架构测试和轻量级 shell 架构边界检查。

## 环境要求

- JDK 21 或更高版本
- Maven 3.8 或更高版本

生成后的项目默认参数：

| 参数 | 默认值 |
| --- | --- |
| `javaVersion` | `21` |
| `springBootVersion` | `3.3.5` |
| `package` | `org.puti.example` |

## 当前仓库结构

```text
.
├── pom.xml
└── src/main/resources
    ├── META-INF/maven/archetype-metadata.xml
    └── archetype-resources
        ├── README.md
        ├── AGENTS.md
        ├── .harness
        ├── scripts
        ├── pom.xml
        ├── __gitignore__
        ├── __rootArtifactId__-client
        ├── __rootArtifactId__-adapter
        ├── __rootArtifactId__-app
        ├── __rootArtifactId__-domain
        ├── __rootArtifactId__-infrastructure
        └── __rootArtifactId__-start
```

关键文件说明：

| 文件 | 说明 |
| --- | --- |
| `pom.xml` | Archetype 项目自身的 Maven 配置 |
| `src/main/resources/META-INF/maven/archetype-metadata.xml` | Archetype 元数据，定义必填参数、文件集和模块 |
| `src/main/resources/archetype-resources/pom.xml` | 生成后项目的父 POM 模板 |
| `src/main/resources/archetype-resources/README.md` | 生成后项目的 README 模板 |
| `src/main/resources/archetype-resources/AGENTS.md` | 生成后项目的 AI 编码规则模板 |
| `src/main/resources/archetype-resources/.harness` | 生成后项目的任务、流程、检查和评审模板 |

## 安装到本地 Maven 仓库

在本仓库根目录执行：

```bash
mvn clean install
```

安装完成后，本地会得到以下 archetype 坐标：

```text
groupId: org.puti.coder
artifactId: cola-harness-archetype
version: 1.0.0
```

## 使用 Archetype 生成项目

安装到本地 Maven 仓库后，可以执行：

```bash
mvn archetype:generate \
  -DarchetypeGroupId=org.puti.coder \
  -DarchetypeArtifactId=cola-harness-archetype \
  -DarchetypeVersion=1.0.0 \
  -DgroupId=com.example \
  -DartifactId=demo-service \
  -Dversion=1.0.0-SNAPSHOT \
  -Dpackage=com.example.demo \
  -DjavaVersion=21 \
  -DspringBootVersion=3.3.5 \
  -DinteractiveMode=false
```

生成后的目录示例：

```text
demo-service
├── pom.xml
├── README.md
├── AGENTS.md
├── .harness
├── scripts
├── demo-service-client
├── demo-service-adapter
├── demo-service-app
├── demo-service-domain
├── demo-service-infrastructure
└── demo-service-start
```

## 生成后项目的模块职责

| 模块 | 职责 |
| --- | --- |
| `*-client` | 对外契约，放 DTO、Command、Query、Response、API 接口、gRPC proto |
| `*-adapter` | 接入层，放 HTTP Controller、gRPC Service 实现、MQ Listener、请求响应转换 |
| `*-app` | 应用层，负责编排用例、事务边界、调用 domain 和 infrastructure |
| `*-domain` | 领域层，放领域模型、领域服务、领域规则和领域枚举 |
| `*-infrastructure` | 基础设施层，放 DO、Mapper、Repository、Gateway 和外部系统调用实现 |
| `*-start` | 启动层，放 Spring Boot 启动类、配置装配和架构测试 |

默认依赖方向：

```text
start -> adapter
adapter -> client
adapter -> app
app -> client
app -> domain
app -> infrastructure
infrastructure -> domain
infrastructure -> client
domain -> 尽量不依赖外部技术框架
client -> 尽量保持轻量
```

## 生成后项目的常用命令

在生成后的项目根目录执行：

```bash
# 编译整个多模块工程
./.harness/checks/compile-all.sh

# 执行架构边界检查
./.harness/checks/arch-check.sh

# 执行 ArchUnit 架构测试
./.harness/checks/arch-test.sh

# 执行推荐的完整验证流程
./.harness/checks/verify-all.sh
```

如果使用内置的 Agent 任务脚本：

```bash
./scripts/agent-task.sh 用例/UC-001-创建订单.md
```

任务文件默认放在：

```text
.harness/任务
```

## 维护模板

修改模板时需要区分两类文件：

| 修改目标 | 文件位置 |
| --- | --- |
| 修改 archetype 本身 | 根目录 `pom.xml`、`src/main/resources/META-INF/maven/archetype-metadata.xml` |
| 修改生成后项目内容 | `src/main/resources/archetype-resources/**` |

新增模板文件后，如果希望它被生成到目标项目中，需要检查 `archetype-metadata.xml` 中对应的 `fileSet` 或 `module` 是否包含该文件。

模板中需要被 Maven Archetype 替换的变量包括：

```text
${groupId}
${artifactId}
${rootArtifactId}
${version}
${package}
${javaVersion}
${springBootVersion}
```

## 验证本 Archetype

建议至少执行：

```bash
mvn clean install
```

然后使用上面的 `mvn archetype:generate` 命令生成一个临时项目，并在生成后的项目中执行：

```bash
./.harness/checks/verify-all.sh
```

## 版本信息

当前版本：`1.0.0`
