#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.infrastructure.gateway;

import ${package}.domain.gateway.ExampleGateway;
import ${package}.domain.model.Example;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExampleGatewayImpl implements ExampleGateway {
    public final static String EXAMPLE = "ExampleConfig";
    
    @Override
    public Example getById(Long id) {
        return new Example();
    }
}