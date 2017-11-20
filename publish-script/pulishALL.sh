#!/bin/bash
#加载脚本
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
source $DIR/config.sh
source $DIR/funcs.sh


function usage() 
{
    echo "${PROJECT[*]}" | grep -w "$1"> /dev/null 2>&1
    if [ $? == 0 ];then
        main $1 $2
    else
        echo "$1不在定义数组列表里，请确认";
        exit 1
    fi

}

function main()
{
    project=$1
    srcfile=$2
    if [ ! -f $srcfile ];then
        echo "$srcfile不存在,退出脚本！！"
        exit 1
    fi
	
    #转换为应提取主机列表数组,先截取提取最后一个字符，转换大小，再拼接名字
    #LAST=`echo ${project##*-}|tr '[a-z]' '[A-Z]'`
    #PROJECT_NAME="SERVERS_$LAST"
	
	#转换为应提取主机列表数组，直接大写转换
    PROJECT_NAME=`echo $project|sed 's/-/_/g'|tr '[a-z]' '[A-Z]'`
    DEPLOY_SERVERS=$(eval echo \${$PROJECT_NAME[*]})
    echo -e "$BULE -----> 开始更新$PROJECT_NAME项目 `date` <------ $CLEAR"
    for ip in ${DEPLOY_SERVERS[*]}
    do
        printDictKey $ip
        #先停-执行函数stop_func，参数1位ip，参数2为程序项目名，参数3位用户名
        stop_func $ip $project $RUN_USER
        #上传函数upload(),参数1为ip，参数2位程序项目名,参数3为源文件,参数4为用户
        upload $ip $project $srcfile $RUN_USER
        #执行重启函数restart，参数1位ip，参数2为程序项目名，参数3位用户名
        restart $ip $project $RUN_USER
        sleep 2
        #增加判断启动状态，若失败，怎么退出循环
        status=`ssh $RUN_USER@$ip "ps -ef|grep -v grep|grep $project -c"`
        if [ $status -eq 0 ]; then
            echo "$ip --> $project,程序启动失败，退出本次发布,请及时排查"
            echo -e "$BULE -----> 更新$PROJECT_NAME项目:失败 `date` <------ $CLEAR"
            exit 1
        fi
        #预防启停太快导致服务不可用
        #sleep 8
    done
    echo -e "$BULE -----> 完成更新$PROJECT_NAME项目 `date` <------ $CLEAR"
}



#简单测试上传
if [ $# -eq 2 ]; then 
    #echo ${PROJECT[*]}
    #第一个参数为项目名(project-xxxx-xx),第二个参数为源文件
    #增加发布项目名和程序名简单校验，避免出现手工发包出错
    echo $2|grep $1
    if [ $? == 1 ];then
        echo "项目名$1和文件名$2不符";
        exit 1;
    fi
    usage $1 $2
else
    echo "$0 xxxx-xxx-xx   xxxx-xxx-xx.jar"
    exit 1; 
fi 

