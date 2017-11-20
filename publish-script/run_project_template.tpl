#!/bin/bash
#. /etc/profile

#-------start  需要设置项  -------#
count=30  #设置判断次数
interval=2 #sleep 秒数
export JAVA_HOME=/usr/local/jdk
export PROJECT_HOME=/data/project
export PROJECT_NAME=project-template
export JAR_NAME=project-template.jar
#export PORT=portjs
export JVM_OPTS=" -Xms512M -Xmx512M  "

#-------end  需要设置项  -------#

# 启动
start() {
    echo "Ready to start $JAR_NAME"
    nohup $JAVA_HOME/bin/java  $JVM_OPTS  -jar $PROJECT_HOME/$PROJECT_NAME/$JAR_NAME  > /dev/null &

}

# 停止
stop() {
    #30秒判断程序是否停止
    for ((i=0;i<$count;i++))
    do
        pid=`ps -ef | grep java |grep "$JAR_NAME" | egrep -v 'grep|\.log|vim|view' |awk '{print $2}'`
        if [ $pid ];then
            echo "$JAR_NAME is running ,the pid is $pid,and now stop ! "
            kill $pid
        else
            echo "$JAR_NAME has stopped !"
			break #退出for循环
        fi
        sleep $interval
    done
}

# 判断状态
status() {
    pid=`ps -ef | grep java |grep "$JAR_NAME" | egrep -v 'grep|\.log|vim|view' |awk '{print $2}'`
    if [ $pid ];then
        echo "$JAR_NAME is running and pid is $pid !"
    else
        echo "$JAR_NAME has stopped !"
    fi
}

case "$1" in
    start)
        start
        status
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        sleep 1
        status
        ;;
    logs)
        #sudo tail -100f /home/${RUNUSER}/nohup.out
        tail -100f $PROJECT_HOME/$PROJECT_NAME/log/xxxxxx.log 
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        ;;
esac

exit 0
#exit $RETVAL
