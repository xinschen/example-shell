#!/bin/bash
#统一生成程序启动脚本
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
source $DIR/config.sh
source $DIR/funcs.sh



function usage(){
    echo ""
    echo "USAGE: $0 -p project_xxx_xxx "
    echo """
    参数解析:
        -h 指向程序名(project_xxx_xxx),如需重新生成所有程序脚本，参数则为ALL
    """ 
    exit 1
}


if [ $# -ne 2 ];then
    usage
fi
  
while getopts :p: name
do
    case $name in
    p)
        project=$OPTARG
    ;;
    *)
        usage
    ;;
      esac
done

if [ $project ] ;then
    echo "${PROJECT[*]}" | grep -w "$project"> /dev/null 2>&1
    if [ $? == 0 ]; then
        generate_script $project
    elif [ "$project" == "ALL" ]; then
        generate_script 'ALL'
    else
        usage
    fi
else
    usage
fi