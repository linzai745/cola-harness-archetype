#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.domain.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 命名规则：动词 + 业务对象 + DomainService
 * 领域能力要保证职责单一性，其中只包含一个方法，此方法以动词命名。
 * 参数只是领域对象或者基础数据类型
 * 常见的动词：
 *  能返回结果的：check / calculate / determine / match / estimate
 *  会改变状态的：reserve / deduct / apply / use / confirm / cancel / complete
 *  失败就阻断的：validate / ensure
 *  生成对象的：create / build / generate
 * 方法返回：聚合根、实体、值对象，值对象不一定是要绑定到实体里面的才是值对象。
 */
@Service
@RequiredArgsConstructor
public class DoExampleDomainService {
    
    public void apply() {
        System.out.println("Do Example Domain Service");
    }
}