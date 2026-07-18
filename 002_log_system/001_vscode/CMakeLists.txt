cmake_minimum_required(VERSION 3.22) # CMake install : https://cmake.org/download/
project(app LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# 内建变量CMAKE_MODULE_PATH加入我们自己的cmake脚本存放路径，支持引入我们的脚本
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
# 引入我们的工具
include(my_cmake_tools)
# set(test_str "opengl_core_3.3")
# start_with("${test_str}" "opengl" is_opengl)
# message("是否以 opengl 开头？ ${is_opengl}")  # 输出 TRUE
# include(CMakePrintHelpers)


# win平台 代码页指定  
add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

# 让 系统api 默认走 W 接口
if(WIN32)
    add_definitions(-D_UNICODE -DUNICODE)
endif()

# TOP_DIR 设置
set(TOP_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(CURRENT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
# 编译类型获取
set(BUILD_TYPE ${CMAKE_BUILD_TYPE})
string(TOLOWER "${BUILD_TYPE}"  BUILD_TYPE ) # 将 BUILD_TYPE 转换为 纯小写
# message(BUILD_TYPE="${BUILD_TYPE}")

# 本地依赖变量
start_with("${BUILD_TYPE}" "r" is_release)
if(is_release)
    set(SYSENV_DIR ${TOP_DIR}/sys_env/release)
else()
    set(SYSENV_DIR ${TOP_DIR}/sys_env/debug)
endif()
set(SYSENV_BIN_DIR ${SYSENV_DIR}/bin)

set(SYSENV_LIB_DIR ${SYSENV_DIR}/lib)
set(SYSENV_INC_DIR ${SYSENV_DIR}/include)
# 设置安装路径 目前不使用
set(CMAKE_INSTALL_PREFIX ${TOP_DIR}/out)

# 公共代码设置
set(COMMON_DIR ${TOP_DIR}/src/common)
file(GLOB  COMMON_SRCS CONFIGURE_DEPENDS ${COMMON_DIR}/*.cpp  ${COMMON_DIR}/*.c 
                                          ${COMMON_DIR}/*.hpp ${COMMON_DIR}/*.h)
message(COMMON_SRCS="${COMMON_SRCS}")

# 3rd代码设置
# set(THIRD_DIR ./3rd)
# file(GLOB  GLAD_SRCS CONFIGURE_DEPENDS  ${THIRD_DIR}/glad/src/glad.c)

# 测试项
# cmake的执行逻辑是分为 “配置工程” 和 “构建” 两个步骤
# 我的增量编译就是“构建”这个阶段
# file 命令加入 CONFIGURE_DEPENDS 这个就会在我们“构建”的时候，再次检查文件夹的文件们的变动
# 重新更新TEST_SRCS变量。
# 如果不加的话，TEST_SRCS是不会在“构建”时再次刷新的。那么当我们
# 增加源码文件，然后直接构建，他不会知道，更不会帮我们编译，如果增加的文件被用到，直接就出错了
# 必须再次配置，就不是增量编译的效果了。如果删除文件，也是一样的道理
# 所以如果想要增量编译，就要加上这个玩意。
# GLOB不抓取指定文件夹里的子文件夹
# 之前有个老版本的aux_source_directory就是这样被淘汰的
# 程序源码
set(APP_SRC_DIR ${TOP_DIR}/src)
file(GLOB_RECURSE APP_SRCS CONFIGURE_DEPENDS ${APP_SRC_DIR}/*.cpp ${APP_SRC_DIR}/*.c
                                             ${APP_SRC_DIR}/*.hpp ${APP_SRC_DIR}/*.h)
message(APP_SRCS="${APP_SRCS}")

set(SRCS ${APP_SRCS})


# 上面这个，这个只会在配置阶段运行一次，下面这个才能实现文件夹变动，增量编译 -I
set(SRC_DIR ${APP_SRC_DIR}  ${COMMON_DIR}   
            CACHE INTERNAL "动态更新的源码目录列表" FORCE)
message(SRC_DIR="${SRC_DIR}")




message("COMMON_SRCS = ${COMMON_SRCS}")
message("SRCS = ${SRCS}")


# 开始设定目标
set(TARGET_NAME ${PROJECT_NAME})


add_executable(${TARGET_NAME}  ${SRCS} ${COMMON_SRCS})

# 添加预编译头
# 多次使用的头文件使用pch技术加快编译速度，如果人家pch文件的肉被改了，还是一样的慢哦
# set(APP_PCHS ${APP_SRC_DIR}/qt_tools.hpp)
# 即使只是一个文件这个项目里，也能把编译时间从170s降到92s
# target_precompile_headers(${TARGET_NAME}
#     PRIVATE
#     $<$<COMPILE_LANGUAGE:CXX>:${APP_PCHS}>)


# 调试时的中间路径-这个是全局生效的
if(WIN32)
    set(CONFIGS "" Debug Release RelWithDebInfo MinSizeRel)
    foreach(conf IN LISTS CONFIGS)
        if(conf)
            string(TOUPPER _${conf} conf)    
        endif(conf)
        message(conf=${conf})
        # RUNTIME_ : .exe elf .dll
        # LIBRARY_ : .lib .so  .dylib
        # ARCHIVE_ :  .a .lib 归档
        # PDB_     :  .pdb
        set_target_properties(${TARGET_NAME}
                                PROPERTIES
                                RUNTIME_OUTPUT_DIRECTORY${conf} ${SYSENV_BIN_DIR}/
                                LIBRARY_OUTPUT_DIRECTORY${conf} ${SYSENV_LIB_DIR}/
                                ARCHIVE_OUTPUT_DIRECTORY${conf} ${SYSENV_LIB_DIR}/
                                PDB_OUTPUT_DIRECTORY${conf}     ${SYSENV_BIN_DIR}/
                            )
    endforeach()
    # 动态获取输出目录（避免硬编码配置）​​
    # 将调试的工作目录设为可执行文件的输出路径（如 Debug/Release 子目录），使用 ​​生成器表达式​​：
    set_target_properties(${TARGET_NAME} PROPERTIES 
                            VS_DEBUGGER_WORKING_DIRECTORY "$<TARGET_FILE_DIR:${TARGET_NAME}>")
    # ​​$<TARGET_FILE_DIR:target>​​：动态解析目标文件（.exe）的输出目录（如 build/Debug）。
    # ​​优势​​：无需手动指定 Debug/Release，适配多配置构建（如 VS 的配置管理器）。

else()
    set_target_properties(${TARGET_NAME} PROPERTIES
                        RUNTIME_OUTPUT_DIRECTORY ${SYSENV_BIN_DIR}
                        ARCHIVE_OUTPUT_DIRECTORY ${SYSENV_LIB_DIR}
                        LIBRARY_OUTPUT_DIRECTORY ${SYSENV_LIB_DIR}
                        ) 
    # 要想实现 windows下这个优先在 当前目录下 找依赖的动态库
    # 可以去设置下 rpath 就不需要改环境变量了（这里就不演示了）
endif(WIN32)



# 各种 -I -L -l
# 其中【-l库名】 在win中可以隐写进源文件，所以这块可以不用写 库名
# QT库依赖
# GLAD依赖
# 本地依赖
target_include_directories(${TARGET_NAME} PRIVATE ${SYSENV_INC_DIR}/)
target_link_directories(${TARGET_NAME} PRIVATE ${SYSENV_LIB_DIR}/)
# message("SYSENV_LIB_DIR = ${SYSENV_LIB_DIR}")
# 源码
target_include_directories(${TARGET_NAME} PRIVATE ${SRC_DIR})
# target_include_directories(${TARGET_NAME} PRIVATE ${COMMON_DIR})

# 整个目标的所有选项
get_target_property(INC_DIRS ${TARGET_NAME} INCLUDE_DIRECTORIES)
message(STATUS "【显式包含路径】${INC_DIRS}")
get_target_property(INTERFACE_INC ${TARGET_NAME} INTERFACE_INCLUDE_DIRECTORIES)
message(STATUS "【接口包含路径】${INTERFACE_INC}")

