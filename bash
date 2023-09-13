#!/bin/bash

# 处理脚本参数
CONN_USERNAME= # -u 用户名
CONN_PASSWORD= # -p 密码
CONN_SHOW_DETAIL= # -v 是否显示详情
CONN_PORT= # -n 端口

while getopts ":u:p:n:v" opt_name # 通过循环，使用 getopts，按照指定参数列表进行解析，参数名存入 opt_name
do
    case "$opt_name" in # 根据参数名判断处理分支
        'u') # -u
            CONN_USERNAME="$OPTARG" # 从 $OPTARG 中获取参数值
            ;;
        'p') # -p
            CONN_PASSWORD="$OPTARG"
            ;;
        'v') # -v
            CONN_SHOW_DETAIL=true
            ;;
        'n') # -n
            CONN_PORT="$OPTARG"
            ;;
        ?) # 其它未指定名称参数
            echo "Unknown argument(s)."
            exit 2
            ;;
    esac
done

# 删除已解析的参数
shift $((OPTIND-1))

# 通过第一个无名称参数获取 主机
CONN_HOST="$1"

# 显示获取参数结果
echo 用户名      "$CONN_USERNAME"
echo 密码        "$CONN_PASSWORD"
echo 主机        "$CONN_HOST"
echo 端口        "$CONN_PORT"
echo 显示详情     "$CONN_SHOW_DETAIL"#!/bin/bash

# 处理脚本参数
CONN_USERNAME= # -u 用户名
CONN_PASSWORD= # -p 密码
CONN_SHOW_DETAIL= # -v 是否显示详情
CONN_PORT= # -n 端口

while getopts ":u:p:n:v" opt_name # 通过循环，使用 getopts，按照指定参数列表进行解析，参数名存入 opt_name
do
    case "$opt_name" in # 根据参数名判断处理分支
        'u') # -u
            CONN_USERNAME="$OPTARG" # 从 $OPTARG 中获取参数值
            ;;
        'p') # -p
            CONN_PASSWORD="$OPTARG"
            ;;
        'v') # -v
            CONN_SHOW_DETAIL=true
            ;;
        'n') # -n
            CONN_PORT="$OPTARG"
            ;;
        ?) # 其它未指定名称参数
            echo "Unknown argument(s)."
            exit 2
            ;;
    esac
done

# 删除已解析的参数
shift $((OPTIND-1))

# 通过第一个无名称参数获取 主机
CONN_HOST="$1"

# 显示获取参数结果
echo 用户名      "$CONN_USERNAME"
echo 密码        "$CONN_PASSWORD"
echo 主机        "$CONN_HOST"
echo 端口        "$CONN_PORT"
echo 显示详情     "$CONN_SHOW_DETAIL"