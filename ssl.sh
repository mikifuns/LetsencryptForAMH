#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required:  CentOS, Debian, Ubuntu                      #
#   Description: One click Get Let’s Encrypt For Your AMH WebSite #
#   Author: Miki.Technology <mikifuns@mikifuns.com>               #
#   Thanks: @mikifuns <https://twitter.com/mikifuns>              #
#   Intro: https://mikifuns.com                                   #
#==================================================================

clear
# 提示信息
echo
echo "#############################################################"
echo "# One click Get Let’s Encrypt For Your AMH WebSite          #"
echo "# Support: http://mikifuns.com  QQ:2306285095(Break Time)  #"
echo "# Author: Miki.Technology <mikifuns@mikifuns.com>           #"
echo "# Thanks: @mikifuns <https://twitter.com/mikifuns>          #"
echo "# Thank You! Let’s Encrypt <https://letsencrypt.org/>       #"
echo "# You Need Have AMH panel First!<https://amh.sh/>           #"
echo "# ======================!WARNING!========================== #"
echo "#             It's ONLY Support For AMH 5.3!                #"
echo -e "\033[47;31m#  AND!GO AMH panel to create A SSL for This Domian FIRST!  # \033[0m"
echo -e "\033[47;31m# The SSL NAME MUST!same as Domain Logo NAME! Please Check! # \033[0m"
echo "#             And Don't Forget To Apply Your SSL !          #"
echo -e "\033[47;31m# 如果正常显示简体中文,您可以到下面的地址下载简体中文版程序 # \033[0m"
echo -e "\033[47;31m# https://github.com/mikifuns/LetsencryptForAMH 选择sslCN.sh# \033[0m"
echo "#############################################################"
echo

# 确保运行于root权限
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root USER!" 1>&2
	   echo "For More Information,please visit:http://www.mikifuns.com or QQ:2306285095(Only Break time)"
       exit 1
    fi
}

# 检察系统
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=CentOS
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
    else
        echo "Not supported OS, Please reinstall OS and retry!"
		echo "For More Information,please visit:http://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
    fi
}


# 安装设定
function pre_install(){
    # 环境名称
    echo "Please input Site Environmental name(You can get it from panel):"
    read -p "(For Example: /home/wwwroot/<Environmental name>/domain/<Domain logo>/web):" webename
    [ -z "$webename" ] && webename="example"
    echo
    echo "---------------------------"
    echo "Environmental name = $webename"
    echo "---------------------------"
    echo
	# 标识域名
    echo "Please input Domain logo(You can get it from panel):"
    read -p "(For Example: /home/wwwroot/<Environmental name>/domain/<Domain logo>/web):" webdlogo
    [ -z "$webdlogo" ] && webdlogo="example"
    echo
    echo "---------------------------"
    echo "Domain logo = $webdlogo"
    echo "---------------------------"
    echo
	# 证书名称
    echo "Please input SSL name(You can get it from panel):"
    read -p "(For Example: example):" sslname
    [ -z "$sslname" ] && sslname="example"
    echo
    echo "---------------------------"
    echo "SSL name = $sslname"
    echo "---------------------------"
    echo
    # 网站域名
    while true
    do
    echo -e "Please input The Domain You need install(like >DNS:example.com,DNS:www.example.com<)"
	echo -e "Please Make Sure YOU DON'T Forget "DNS:" ! IT's Very Important!:"
    read -p "(If more than 1 domain,please use<,>to Separated.):" webdomain
    [ -z "$webdomain" ] && webdomain="DNS:example.com,DNS:www.example.com"
         echo
            echo "---------------------------"
            echo "Domain = $webdomain"
            echo "---------------------------"
            echo
            break
    done
	get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
   echo -e "\033[47;31m Please Check!If everythings OK,Press any key to start...or Press Ctrl+C to cancel \033[0m"
   char=`get_char`
   # 检查ssl证书目录是否存在
    if [ -e /home/wwwroot/${webename}/etc/${sslname}-ssl ]; then
		echo "=====================SSL file is READY!===================="
	else
        echo
		echo -e "\033[47;31m SSL file IS NOT READY!Please GO AMH panel to create A SSL for This Domian! \033[0m"
        echo "For More Information,please visit:http://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
	fi
    
    # 获取证书获取程序
    if [ "$OS" == 'CentOS' ];then
        mkdir -p /root/${webename}/${webdlogo}
		cd /root/${webename}/${webdlogo}
		wget https://raw.githubusercontent.com/xdtianyu/scripts/master/lets-encrypt/letsencrypt.sh    
		
		else
		mkdir -p /root/${webename}/${webdlogo}
		cd /root/${webename}/${webdlogo}
        wget https://raw.githubusercontent.com/xdtianyu/scripts/master/lets-encrypt/letsencrypt.sh   
		
    fi
}



# 配置证书设定
function config_ssl(){
    if [ ! -d /root/${webename}/${webdlogo} ];then
        mkdir -p /root/${webename}/${webdlogo}
        echo "========Dir Can't Found.Just Create.========"
    fi
    cat > /root/${webename}/${webdlogo}/letsencrypt.conf<<-EOF

# only modify the values, key files will be generated automaticly.
ACCOUNT_KEY="letsencrypt-account.key"
DOMAIN_KEY="${sslname}.key"
DOMAIN_DIR="/home/wwwroot/${webename}/domain/${webdlogo}/web"
DOMAINS="${webdomain}"
#ECC=TRUE
#LIGHTTPD=TRUE
EOF
echo "==========Conf file IS READY!=========="
}

# 安装证书 
function install_ssl(){
    # 检查证书配置文件是否存在
    if [ -s /root/${webename}/${webdlogo}/letsencrypt.conf ]; then
        echo "==============Conf IS READY!=============="
        cd /root/${webename}/${webdlogo}
        # 给予证书获取程序所有权 并运行
        chmod +x letsencrypt.sh
        ./letsencrypt.sh letsencrypt.conf
        echo "==============SSL File GET Finish=============."
		#删除残缺证书
		rm -rf ${sslname}.crt
		#重命名完整证书到正确名称
		mv ${sslname}.chained.crt ${sslname}.crt
		echo "=================SSL File Is Ready!================="
		#停止apache
		amh apache stop
		echo "==============Apache Is STOP NOW!================"
		#复制证书到SSL文件夹
		mv -f /root/${webename}/${webdlogo}/${sslname}.crt /home/wwwroot/${webename}/etc/${sslname}-ssl
		mv -f /root/${webename}/${webdlogo}/${sslname}.key /home/wwwroot/${webename}/etc/${sslname}-ssl
		echo "==============File Copy Over================="
		#启动apache
		amh apache reload
	        echo "==============Apache Is Work NOW!================="
	        
	        
    else
        echo
        echo "Not Ready!Please Restart SH Again!(conf LOST)"
		echo "For More Information,please visit:http://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
    fi
    }
    
    

# 设定计划任务
function install_corn(){
#安装计划任务程序
    if [ "$OS" == 'CentOS' ];then
        yum -y install vixie-cron crontabs
		chkconfig crond on
		service crond start
		else
		apt-get -y install cron
		/etc/init.d/cron restart	
    fi
    #创建计划任务所需运行的程序
cat > /root/${webename}/${webdlogo}/${sslname}.sh<<-EOF

#!/bin/sh
cd /root/${webename}/${webdlogo}
        chmod +x letsencrypt.sh
        ./letsencrypt.sh letsencrypt.conf
		rm -rf ${sslname}.crt
		mv ${sslname}.chained.crt ${sslname}.crt
		amh apache stop
		mv -f /root/${webename}/${webdlogo}/${sslname}.crt /home/wwwroot/${webename}/etc/${sslname}-ssl
		mv -f /root/${webename}/${webdlogo}/${sslname}.key /home/wwwroot/${webename}/etc/${sslname}-ssl
		amh apache restart	     
EOF
       
   	    echo "==============crontab is READY!================="
	   #复制程序到每月运行文件夹
	    mv ${sslname}.sh /etc/cron.monthly
		echo "==============Copy Cron Over!================="
}

# 完成
function finish(){
    cd $cur_dir
    clear
    echo
    echo "Congratulations, Let’s Encrypt SSL For Domain "${webdomain}" is completed!"
    echo -e "Your web file is in: /home/wwwroot/"${webename}"/domain/"${webdlogo}"/web  Named:"${sslname}" ."
    echo 
    echo "Welcome to visit:http://Mikifuns.com"
    echo "Enjoy it!"
    echo
    exit 1
}

# 安装步骤
function install_sslsetp(){
    checkos
    rootness
    pre_install
    config_ssl
    install_ssl
    install_corn
    finish
}


# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_sslsetp
    ;;
install)
    install_sslsetp
    ;;
*)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install|install}"
	echo "For More Information,please visit:http://www.mikifuns.com or QQ:2306285095(Only Break time)"
    ;;
esac
