#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package};

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 应用启动入口。
 *
 * 说明：
 * 1. start 模块只负责启动和装配。
 * 2. 不要在启动类中编写业务逻辑。
 * 3. MapperScan 默认扫描 infrastructure 模块下的 mapper 包。
 */
@SpringBootApplication(scanBasePackages = "${package}")
@MapperScan("${package}.infrastructure.mapper")
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}