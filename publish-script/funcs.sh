#!/bin/bash
#script name ：funcs.sh
#note: common funciton
DIR="$( cd "$( dirname "$0"  )" && pwd  )" 
source $DIR/config.sh
dstpath=/tmp/shell #临时目录

#判断两个文件MD5值是否相同
function chkmd5(){
    srcMD5=`md5sum $1 |awk '{print $1}'`
    dstMD5=`md5sum $2 |awk '{print $1}'`
    [ "$srcMD5" = "$dstMD5" ] && echo true
}


#需求为高亮回显所在执行的服务器ip:hostname
#getDictKey函数，遍历key，根据value值返回key值。
function printDictKey(){
    ip=$1
    for key in $(echo ${!SERVER_DICTS[*]})
    do
        if [ "${SERVER_DICTS[$key]}" == "$ip" ];then
            echo -e "$PUPPY $key : ${SERVER_DICTS[$key]} $CLEAR"
        fi
    done 

}


#判断本地脚本是否存在，否则生成
function generate_script()
{
    project=$1
    [ -d $dstpath ] || mkdir -p $dstpath
    if [ "$project" == "ALL" ]; then
        echo "开始生成所有程序启停脚本"
        for project in ${PROJECT[*]}
        do
            cp $DIR/run_project_template.tpl  $dstpath/run_$project.sh
            sed -i "s#project-template#$project#g"  $dstpath/run_$project.sh
			chmod +x $dstpath/run_$project.sh
            [ $? == 0 ] && echo "完成$project脚本生成！"
        done
        echo "完成所有程序启停脚本的生成,路径为:$dstpath"
    else
        cp $DIR/project-template.tpl  $dstpath/run_$project.sh
        sed -i "s#project-template#$project#g"  $dstpath/run_$project.sh
        chmod +x $dstpath/run_$project.sh
        [ $? == 0 ] && echo "完成$project脚本生成！路径为:$dstpath/run_$project.sh"
    fi
}

#上传函数upload(),参数1为ip，参数2位程序项目名,参数3为源文件,参数4为用户
function upload(){
    ip=$1
    PROJECT_NAME=$2
    srcfile=$3
    user=$4
    #参数
    _date=$(date +%Y%m%d%H%M)
    tmpfile=/tmp/$PROJECT_NAME.jar
    dstfile=$ROOT_PATH/$PROJECT_NAME/$PROJECT_NAME.jar

    #echo " start --->> upload $srcfile to $ip "
    scp -P22 $srcfile $user@$ip:$tmpfile
    # publish
    ssh -p22 $user@$ip " 
        [ -d $ROOT_PATH/$PROJECT_NAME/_bak ] || mkdir -p $ROOT_PATH/$PROJECT_NAME/_bak/;
        [ -d $ROOT_PATH/$PROJECT_NAME/log ] || mkdir -p $ROOT_PATH/$PROJECT_NAME/log/;
        if [ -f $dstfile ]; then
            cp $dstfile $ROOT_PATH/$PROJECT_NAME/_bak/$PROJECT_NAME.jar_$_date;
            #增加默认备份文件名，利于回滚操作
            cp $dstfile $ROOT_PATH/$PROJECT_NAME/_bak/$PROJECT_NAME.jar_bak; 
            mv $tmpfile $dstfile;
        else
            mv $tmpfile $dstfile;
        fi
    "
    #echo "upload $srcfile to $ip <<-----done  "
}

#执行重启脚本，参数1位ip，参数2为程序项目名，参数3位用户名
function restart(){
    ip=$1
    PROJECT_NAME=$2
    user=$3
    PROJECT_SHELL='run_'$PROJECT_NAME'.sh'
    [ -f $dstpath/$PROJECT_SHELL ] || generate_script $PROJECT_NAME
    PROJECT_SHELL_FUL=$ROOT_PATH/$PROJECT_NAME/$PROJECT_SHELL
    scp -P22 $dstpath/$PROJECT_SHELL  $user@$ip:$PROJECT_SHELL_FUL 
    ssh -p22 $user@$ip "
        if [ -f $PROJECT_SHELL_FUL ]; then
            chmod +x $PROJECT_SHELL_FUL ;
            /bin/bash $PROJECT_SHELL_FUL restart ;
        else
            echo "$PROJECT_SHELL_FUL 脚本不存在" ;
        fi
    "

}

#执行脚本，参数1位ip，参数2为程序项目名，参数3位用户名
function stop_func(){
    ip=$1
    PROJECT_NAME=$2
    user=$3
    PROJECT_SHELL='run_'$PROJECT_NAME'.sh'
    [ -f $dstpath/$PROJECT_SHELL ] || generate_script $PROJECT_NAME
    PROJECT_SHELL_FUL=$ROOT_PATH/$PROJECT_NAME/$PROJECT_SHELL
    scp -P22 $dstpath/$PROJECT_SHELL  $user@$ip:$PROJECT_SHELL_FUL 
    ssh -p22 $user@$ip "
        if [ -f $PROJECT_SHELL_FUL ]; then
            /bin/bash $PROJECT_SHELL_FUL stop ;
        else
            echo "$PROJECT_SHELL_FUL 脚本不存在" ;
        fi
    "

}


#区别upload，本函数uploadFile为上传文件，参数1为ip,参数2为用户名，参数3为上传的文件，参数4为目标文件
function uploadFile(){
    ip=$1
    user=$2
    srcfile=$3
    dstfile=$4
    #参数
    _date=$(date +%Y%m%d%H%M)
    filename=`echo ${srcfile##*/}` ##获取文件名
    tmpfile=/tmp/$filename
    #echo " start --->> upload $srcfile to $ip "
    printDictKey $ip
    scp -P22 $srcfile $user@$ip:$tmpfile
    #发布
    ssh -p22 $user@$ip " 
        if [ -f $dstfile ]; then
            cp $dstfile $dstfile.$_date 
            #增加默认备份文件名，利于回滚操作
            cp $dstfile $dstfile'_bak'; 
            mv $tmpfile $dstfile;
        else
            mv $tmpfile $dstfile;
        fi
    "
    #echo "upload $srcfile to $ip <<-----done  "
}

