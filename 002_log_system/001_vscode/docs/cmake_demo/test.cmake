cmake_minimum_required(VERSION 3.10)
message(STATUS "CMake version: ${CMAKE_VERSION}")


message(STATUS "当前脚本所在的文件夹: ${CMAKE_CURRENT_SOURCE_DIR}")
# 
set(CMAKE_MODULE_PATH  ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_MODULE_PATH})
set(CMAKE_MODULE_PATH    ${CMAKE_MODULE_PATH} 青冥幽风)
message(STATUS "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")

include(tools)
include(gg.txt)
# include("gg.txt")
include("凉凉.cmake")
my_getchar()



# include("tools") # include(tools)
# # include(gg)
# include(gg.txt)
# include("凉凉.cmake")




message(STATUS "脚本退出~~")

