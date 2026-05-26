#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.infrastructure.repository;

import lombok.RequiredArgsConstructor;
import ${package}.domain.repository.ExampleRepository;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class ExampleRepositoryImpl implements ExampleRepository {

    @Override
    public Example getById(Long id) {
        return new Example();
    }
}