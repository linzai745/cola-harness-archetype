#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import ${package}.infrastructure.dataobject.ExampleDO;

@Mapper
public interface ExampleMapper extends BaseMapper<ExampleDO> {
    
}