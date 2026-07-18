cmake_minimum_required(VERSION 3.10)
message(STATUS "CMake version: ${CMAKE_VERSION}")
# cmake -P 
# bash zsh ...
message(STATUS "当前的 shell : $ENV{SHELL}")

# execute_process(
#     COMMAND cmd /c "echo 你好，中国..."
#     # ENCODING ANSI
# )
# cmake 《===》 cmd
# execute_process(
#     COMMAND bash -c "echo 你好，中国..."
#     ENCODING  UTF-8
# )
# cmake 《===》 process

# bash ===>  cmake 
# ansi gbk
if("$ENV{SHELL}" MATCHES "bash")
    message(STATUS "处于 bash 里面，使用bash")
    execute_process(
        COMMAND bash -c "echo 你好，中国..."
        ENCODING UTF-8
    )
else()
    if(WIN32)
        message(STATUS "处于 WIN32 ，使用 cmd ")
        execute_process(
            COMMAND cmd /c "echo 你好，中国..."
            # ENCODING UTF-8
        )
    endif()
endif()   

    
