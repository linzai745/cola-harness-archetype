package ${package};

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.library.Architectures.layeredArchitecture;

/**
 * 架构边界测试。
 *
 * 作用：
 * 1. 用 ArchUnit 对 COLA 多模块分层做自动化约束。
 * 2. 防止 Agent 为了编译通过破坏分层。
 * 3. 防止 domain 层引入 MyBatis、Redis、Sa-Token、gRPC、Web 等技术细节。
 * 4. 防止 adapter 层直接访问 Mapper。
 * 5. 防止 client 层出现 Repository、Mapper、DO 等实现细节。
 *
 * 说明：
 * 1. 本测试位于 start 模块，因为 start 模块能看到其他业务模块。
 * 2. shell 脚本 arch-check.sh 是轻量检查；本测试是更正式的架构约束。
 * 3. 如需新增允许依赖，必须明确调整规则，不要绕过测试。
 */
@AnalyzeClasses(
        packages = "${package}",
        importOptions = ImportOption.DoNotIncludeTests.class
)
class ArchitectureTest {

    /**
     * COLA 分层依赖规则。
     *
     * 允许依赖方向：
     * - adapter 可以依赖 client、app
     * - app 可以依赖 client、domain、infrastructure
     * - infrastructure 可以依赖 client、domain
     * - domain 尽量保持纯净
     * - start 负责启动装配
     */
    @ArchTest
    static final ArchRule cola_layer_dependencies_should_be_respected =
            layeredArchitecture()
                    .consideringOnlyDependenciesInLayers()
                    .layer("Client").definedBy("${package}.client..")
                    .layer("Adapter").definedBy("${package}.adapter..")
                    .layer("App").definedBy("${package}.app..")
                    .layer("Domain").definedBy("${package}.domain..")
                    .layer("Infrastructure").definedBy("${package}.infrastructure..")
                    .layer("Start").definedBy("${package}..")
                    .whereLayer("Client").mayOnlyBeAccessedByLayers("Adapter", "App", "Infrastructure", "Start")
                    .whereLayer("Adapter").mayOnlyBeAccessedByLayers("Start")
                    .whereLayer("App").mayOnlyBeAccessedByLayers("Adapter", "Start")
                    .whereLayer("Domain").mayOnlyBeAccessedByLayers("App", "Infrastructure", "Start")
                    .whereLayer("Infrastructure").mayOnlyBeAccessedByLayers("App", "Start");

    /**
     * domain 层不允许依赖基础设施和接入层技术。
     */
    @ArchTest
    static final ArchRule domain_should_not_depend_on_technical_frameworks =
            noClasses()
                    .that()
                    .resideInAPackage("${package}.domain..")
                    .should()
                    .dependOnClassesThat()
                    .resideInAnyPackage(
                            "org.springframework.web..",
                            "org.springframework.data.redis..",
                            "org.mybatis..",
                            "com.baomidou.mybatisplus..",
                            "cn.dev33.satoken..",
                            "io.grpc..",
                            "net.devh.boot.grpc..",
                            "${package}.adapter..",
                            "${package}.infrastructure.mapper..",
                            "${package}.infrastructure.dataobject.."
                    )
                    .because("domain 层只表达领域模型和领域规则，不应该依赖技术实现。");

    /**
     * adapter 层不允许直接访问 Mapper。
     */
    @ArchTest
    static final ArchRule adapter_should_not_access_mapper_directly =
            noClasses()
                    .that()
                    .resideInAPackage("${package}.adapter..")
                    .should()
                    .dependOnClassesThat()
                    .resideInAPackage("${package}.infrastructure.mapper..")
                    .because("adapter 层只做协议适配，不能直接访问 Mapper。");

    /**
     * adapter 层不允许直接依赖 DO。
     */
    @ArchTest
    static final ArchRule adapter_should_not_depend_on_data_objects =
            noClasses()
                    .that()
                    .resideInAPackage("${package}.adapter..")
                    .should()
                    .dependOnClassesThat()
                    .resideInAPackage("${package}.infrastructure.dataobject..")
                    .because("DO 属于基础设施持久化对象，不能泄漏到 adapter。");

    /**
     * client 层不允许出现基础设施实现细节。
     */
    @ArchTest
    static final ArchRule client_should_not_depend_on_infrastructure_details =
            noClasses()
                    .that()
                    .resideInAPackage("${package}.client..")
                    .should()
                    .dependOnClassesThat()
                    .resideInAnyPackage(
                            "${package}.infrastructure..",
                            "${package}.adapter..",
                            "org.mybatis..",
                            "com.baomidou.mybatisplus..",
                            "org.springframework.data.redis..",
                            "cn.dev33.satoken.."
                    )
                    .because("client 是对外契约包，不应该依赖实现细节。");

    /**
     * app 层不允许出现 HTTP / gRPC / MQ 接入实现。
     */
    @ArchTest
    static final ArchRule app_should_not_contain_adapter_implementation =
            noClasses()
                    .that()
                    .resideInAPackage("${package}.app..")
                    .should()
                    .dependOnClassesThat()
                    .resideInAnyPackage(
                            "org.springframework.web.bind.annotation..",
                            "io.grpc..",
                            "net.devh.boot.grpc.server.service.."
                    )
                    .because("app 层负责用例编排，不应该包含 HTTP、gRPC 等接入实现。");

    /**
     * start 层不允许依赖 Mapper。
     *
     * 启动层可以配置 MapperScan，但不应该直接调用 Mapper。
     */
    @ArchTest
    static final ArchRule start_should_not_access_mapper_directly =
            noClasses()
                    .that()
                    .resideInAPackage("${package}")
                    .should()
                    .dependOnClassesThat()
                    .resideInAPackage("${package}.infrastructure.mapper..")
                    .because("start 层只做启动装配，不应该直接访问 Mapper。");
}