#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.domain.repository;

import ${package}.domain.model.Example;

public interface ExampleRepository {
    Example getById(Long id);
}