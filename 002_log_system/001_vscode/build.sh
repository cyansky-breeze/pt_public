#!/bin/bash
# set -x
# 统一规定脚本中的dir变量都不要加/
root_dir=$(pwd)
build_type=$1       # debug 或者 release
action=$2           # clean 或者 空【空就是构建】
# install_base_dir=${root_dir}/out
sys_env_dir=${root_dir}/sys_env/${build_type}
bin_base_dir=${sys_env_dir}/bin
build_base_dir=${root_dir}/build
program_name="app.exe"
start=$(date +%s) #获取起始执行时间
# 当前PC核数
declare -i cpu_core_count=8


if [[ -z "${bin_base_dir}" || -z "${build_base_dir}" ]]; then
    echo "Error: dir must be provided."
    exit 250
fi


# 探测系统

case "$OSTYPE" in
    linux-gnu*)
        echo "当前运行在Linux系统"
        cmake_generator='"Unix Makefiles"'
        cmake_arch_define=""
        ;;
    msys* | mingw* | cygwin*)
        echo "当前运行在Windows系统"
        cmake_generator='"Visual Studio 17 2022"'
        cmake_arch_define="-T host=x64 -A x64"
        ;;
    *)
        echo "错误：不支持的操作系统类型: $OSTYPE" >&2
        exit 1
        ;;
esac

# export_cmake_opts 可以在外面export所需的cmake 额外选项

command_hook()
{
    echo -e "\n==> $*"
    # shift
    eval $*
}

# ===================================
# 动作们 ： 清理、编译、安装
# ===================================

# ----------------------
# 1.清理
# ----------------------
if [ "${action}"x == "clean"x ]; then
    # 写这种命令要小心，注意要有前置判断~
    # ps: 有个safe-rm的东西大家可以去了解下
    echo "执行清理动作~~~"
    command_hook rm -rf "${bin_base_dir}/${program_name}"
    command_hook rm -rf "${build_base_dir}/${build_type}"
    exit 0
fi

# ----------------------
# 2. 编译
# ----------------------

function cmake_build_func() 
{
    local bit_count=$1
    local build_type=$2

    if [ "${bit_count}"x == "64"x ]; then
        # 这里可以添加相应的逻辑
        echo "支持64位系统"
    else
        echo "仅支持64 [$*]别乱来"
        exit 88
    fi

    # local install_dir=${install_base_dir}/${build_type}
    local build_dir=${build_base_dir}/${build_type}
    echo "Build ${bit_count}bit ${build_type} in ${OSTYPE} entering......"

    # 将 release 调整为 RelWithDebInfo 其可调试
    local build_type_lower=$(tr '[:upper:]' '[:lower:]' <<< "${build_type}")
    case $build_type_lower in
        debug)   cmake_build_type=Debug ;;
        release) cmake_build_type=RelWithDebInfo ;;
        *)       echo "Error: 无效的 build_type '$build_type'，应为 debug 或 release" >&2; exit 1 ;;
    esac

    # 执行 配置构建工程的命令
    command_hook cmake \
        -S ${root_dir} \
        -G ${cmake_generator} \
        ${cmake_arch_define} \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
        -DCMAKE_BUILD_TYPE:STRING=${cmake_build_type} \
        ${export_cmake_opts} \
        -B ${build_dir}
    # 调用工程的命令
    inc_build_cmd="cmake --build ${build_dir} \
                         --config ${cmake_build_type} \
                         --parallel  ${cpu_core_count} \
                         --"
    #  -- 后面没有跟任何参数，它实际上没有效果
    # 这是一个良好的实践习惯，为后续添加构建工具选项预留位置
    # 调用工程
    command_hook ${inc_build_cmd}
    # 生成增量编译脚本
    echo "#!/bin/bash" >./my_incremental_build.sh
    echo "${inc_build_cmd} 2>&1 | tee ./zzz_build.log" >>./my_incremental_build.sh
    chmod a+x ./my_incremental_build.sh

    echo "Build ${bit_count}bit ${build_type} in ${OSTYPE} leaving......"

    return
}


if [ "${action}"x == ""x ]; then
    # 注意  release 内部使用的是 RelWithDebInfo
    # cmake_build_func 64 release
    # cmake_build_func 64 debug
    cmake_build_func 64 ${build_type}
fi




# 执行代码后时间点
end=$(date +%s) 
runtime=$(expr $end - $start) 
echo "本次执行耗时: ${runtime}秒"
# set +x