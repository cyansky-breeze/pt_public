# 定义全局变量集合存储内置变量名
get_cmake_property(_BUILTIN_VARS VARIABLES)
# 只要include了这个脚本，就立马将所有变量收集起来, 
# 放到_BUILTIN_VARS，作为内建变量的



# 自定义宏：my_find_package
# 功能：find_package 的装饰器(或者叫调试钩子)
#       抓取find_package时，多出来的变量，方便调试
# 调用示例：查找 OpenCV 并打印新增变量
# my_find_package(OpenCV REQUIRED)
# 若需排除某些临时变量（如 _ALL_VARS_BEFORE），可添加过滤规则：
# list(FILTER setC EXCLUDE REGEX "^_")
macro(my_find_package package_name)
    # 获取执行前的非内置变量
    get_cmake_property(_ALL_VARS_BEFORE VARIABLES)
    list(REMOVE_ITEM _ALL_VARS_BEFORE ${_BUILTIN_VARS})
    set(setA "${_ALL_VARS_BEFORE}")

    # 执行原始 find_package
    find_package(${package_name} ${ARGN})

    # 获取执行后的非内置变量
    get_cmake_property(_ALL_VARS_AFTER VARIABLES)
    list(REMOVE_ITEM _ALL_VARS_AFTER ${_BUILTIN_VARS})
    set(setB "${_ALL_VARS_AFTER}")

    # 计算新增变量集合 setC
    list(REMOVE_ITEM setB ${setA})
    set(setC "${setB}")
    # 去掉CMAKE_开头的，这些正常都是cmake自己家的变量，正常人不会去动她们家的
    list(FILTER setC EXCLUDE REGEX "^CMAKE_")
    # 打印新增变量
    message(STATUS "================= 新增变量集合 =================")
    foreach(var ${setC})
        message(STATUS "${var} = ${${var}}")
    endforeach()
    message(STATUS "================= 新增变量集合 (长官！汇报结束~)=")

endmacro()


# 定义打印函数my_export
# 功能和shell中的export、bat中的set 类似
# 如果你要是想知道某个变量的设置全过程
# 可以用 variable_watch 监控变量的访问
function(my_export)
    # 获取当前所有变量
    get_cmake_property(_ALL_VARS VARIABLES)
    message("================= my_export =================")
    message("========= 内置变量 =========")
    foreach(var ${_ALL_VARS})
        list(FIND _BUILTIN_VARS ${var} _IS_BUILTIN)
        # 判断条件：变量名以 CMAKE_ 开头，或存在于预加载的内置变量集合中
        if(var MATCHES "^CMAKE_" OR _IS_BUILTIN GREATER -1)
            message("    [内置] ${var} = ${${var}}")
        endif()
    endforeach()


    # 打印自定义变量（排除 CMAKE_ 前缀和预加载变量）
    message("\n========= 自定义变量 =========")
    foreach(var ${_ALL_VARS})
        list(FIND _BUILTIN_VARS ${var} _IS_BUILTIN)
        if(_IS_BUILTIN EQUAL -1 AND NOT var MATCHES "^CMAKE_")
            message("    [自定义] ${var} = ${${var}}")
        endif()
    endforeach()
    message("================= my_export (长官！汇报结束~)=")
endfunction()



function(start_with input_str prefix output_var)
    string(REGEX MATCH "^${prefix}" matched "${input_str}")
    if(matched)
        set(${output_var} TRUE PARENT_SCOPE)
    else()
        set(${output_var} FALSE PARENT_SCOPE)
    endif()
endfunction()
# set(test_str "opengl_core_3.3")
# start_with("${test_str}" "opengl" is_opengl)
# message("是否以 opengl 开头？ ${is_opengl}")  # 输出 TRUE


function(my_getchar)
    if("$ENV{SHELL}" MATCHES "bash")
        message(STATUS "处于 bash 里面，执行 read 阻塞住进程")
        # message(STATUS "等一个回车中......")
        execute_process(
            COMMAND bash -c " read -p '等一个回车中...' < /dev/tty"
            ENCODING UTF-8
        )
        message(STATUS "read 阻塞结束")
        return()
    endif()   
    if(WIN32)
        message(STATUS "处于 cmd 里面，执行 pause 阻塞住进程")
        message(STATUS "等一个回车中......")
        execute_process(
            COMMAND cmd /c pause
        )
        message(STATUS "pause 阻塞结束")
        return()
    endif()
endfunction()