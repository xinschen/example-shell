#!/bin/sh
#author:xinschen@foxmail.com
USER='test'
SERVER_IP=(192.168.2.1 192.168.2.2 192.168.2.3 192.168.2.4 )
#check rsa 
if [ -e id_rsa.pub ];then 
        echo 'id_rsa.pub is exited,keep running'
else
        echo "id_rsa.pub is not exited"
        exit
fi 

#创建用户
function userauth(){
        for ip in ${SERVER_IP[*]}
        do
                echo  $ip
                scp -P32200 id_rsa.pub $ip:/tmp/id_rsa.pub
                ssh -p32200 $ip "
                id $USER;
                [ \$? != 0 ] && sudo useradd $USER || echo \"$USER用户已存在\";
                sudo su - $USER -c \"
                mkdir -p /home/$USER/.ssh;
                cat /tmp/id_rsa.pub >/home/$USER/.ssh/authorized_keys;
                chmod 600 /home/$USER/.ssh/authorized_keys;
                chmod 700  /home/$USER/.ssh;
                 \"; 
                
                "
                echo "add $USER done"
                [ -e /tmp/id_rsa.pub ] && rm  -rf /tmp/id_rsa.pub 
                echo "-------------------userauth $ip done--------------------"
        done
}
#do add sudo privileges
function addsudo(){
        for ip in ${SERVER_IP[*]}
        do
                echo  $ip
                ssh -p32200 $ip " sudo  usermod -G wheel $USER"
                echo "add $USER sudo privileges done"

        done
}
#main fuction
userauth
addsudo