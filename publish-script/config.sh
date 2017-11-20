#!/bin/bash
#script name ：congfig.sh
#note: 定义各个参数

#定义颜色
RED='\e[1;31m'        #红色
GREEN='\e[1;32m'      #绿色
YELLOW='\e[1;33m'     #黄色
BULE='\e[1;34m'       #蓝色
PUPPY='\e[1;35m'      #紫色
WHITE='\e[1;37m'      #白色
SKY_BULE='\e[1;36m'   #天蓝色
CLEAR='\e[0m'         #结束符

## 定义项目部署目录
ROOT_PATH=/data/project
RUN_USER='testuser'

## 定义项目字典
#字典dic使用方法
#打印所有key值  echo ${!dic[*]}
#打印所有value  echo ${dic[*]}

PROJECT=(
'project-test1'
'project-test2'

);

#所有主机列表字典
declare -A SERVER_DICTS
SERVER_DICTS=(
['test1']="192.168.0.100"
['test2']="192.168.0.101"

);

#定义各个程序列表
#project-test测试目录，变量名为程序名大写
PROJECT_TEST=(
${SERVER_DICTS['test1']}
${SERVER_DICTS['test2']}
);
