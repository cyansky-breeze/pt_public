

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

