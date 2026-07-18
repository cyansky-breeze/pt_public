#!/bin/bash

# 检查传递的参数是否存在
# 参数 $1 是待检查的文件路径
FILE="${1}"

function print_message() 
{
    local message="$1"
    local status="$2"

    if [[ "$status" == "ok" ]]; then
        echo -e "\e[32m$message\e[0m"  # 打印绿色
    elif [[ "$status" == "error" ]]; then
        echo -e "\e[31m$message\e[0m"  # 打印红色
    else
        echo "无效状态"
    fi
}

function log_ok() 
{
    print_message "$*" "ok"  # 使用 "$*" 传递所有参数
}

function log_error() 
{
    print_message "$*" "error"  # 使用 "$*" 传递所有参数
}

# 测试调用
# log_ok "成功" "200"
# log_error "错误" "500"
# exit
# 检查文件是否存在并获取最后修改时间
if [ -f "$FILE" ]; then
    # 获取当前时间戳
    CURRENT_TIME=$(date +%s)
    # 获取文件最后修改时间戳
    FILE_MOD_TIME=$(stat -c %Y "$FILE")
    
    # 计算时间差
    TIME_DIFF=$((CURRENT_TIME - FILE_MOD_TIME))
    if [ $TIME_DIFF -lt 10 ]; then
        # 如果时间差小于10秒，返回0表示检查通过
        log_ok "File $FILE 已经更新.Pass~"
        exit 0
    else
        # 如果时间差大于等于10秒，输出提示信息并返回1表示检查失败,但是只做警告
        log_error "文件 $FILE has 没有修改过.Warning"
        exit 250 #即时止损
    fi
else
    # 如果文件不存在，输出错误信息并返回250
    log_error "文件 $FILE 不存在."
    exit 250
fi