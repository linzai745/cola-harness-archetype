#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.app.service;

import ${package}.app.api.ExampleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ExampleServiceImpl implements ExampleService {
    
    @Override
    public void doSomething() {
        
    }
}
