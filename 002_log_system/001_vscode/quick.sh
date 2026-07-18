#!/bin/bash
# ./build.sh debug clean ; ./build.sh  debug  2>&1 | tee ./zzz_build.log
./build.sh release clean ; ./build.sh  release  2>&1 | tee ./zzz_build.log
# ./build.sh  release install 2>&1 | tee ./zzz_build.log
# cmd 启动app 可以 app.exe > app.log
# 全量编译脚本