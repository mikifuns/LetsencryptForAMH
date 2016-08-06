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
echo "#          一键给你的AMH网站获得Let’s Encrypt证书!          #"
echo "#   支持: http://mikifuns.com  QQ:2306285095(仅限休息时间)  #"
echo "# 项目组: Miki.Technology <mikifuns@mikifuns.com>           #"
echo "#   感谢: @mikifuns <https://twitter.com/mikifuns>          #"
echo "# 自豪的使用了! Let’s Encrypt <https://letsencrypt.org/>证书#"
echo "# 注意:安装前您需要有一个AMH面板<https://amh.sh/>           #"
echo "# ========================!警告!============================#"
echo "#                      仅支持AMH5.3!                        #"
echo -e "\033[47;31m#  请在运行前到AMH面板给您的网站创建一个证书!使用amssl模块) # \033[0m"
echo -e "\033[47;31m#           SSL名称是您所设置的名称!请注意核对检查!         # \033[0m"
echo "#            最后别忘了去amssl中应用您的ssl证书 !           #"
echo "#############################################################"
echo -e "\033[47;31m* If You Can't Read Chinese,Please Download English Version. \033[0m"
echo -e "\033[47;31m*https://github.com/mikifuns/LetsencryptForAMH choose ssl.sh or sslEN.sh \033[0m"
echo -e "\033[47;31m*And You Can Try to change your Xshell Set up:UTF-8. \033[0m"
echo

# 确保运行于root权限
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "错误!请以Root身份运行程序!" 1>&2
	   echo "获得更多信息,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
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
        echo "系统不支持!请更换系统再试!"
		echo "获得更多信息,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
        exit 1
    fi
}


# 安装设定
function pre_install(){
    # 环境名称
    echo "请输入您的网站所在的#环境名称#(可在控制面板查看):"
    read -p "(例如: /home/wwwroot/<环境名称>/domain/<标识域名>/web):" webename
    [ -z "$webename" ] && webename="example"
    echo
    echo "---------------------------"
    echo "环境名称 = $webename"
    echo "---------------------------"
    echo
	# 标识域名
    echo "请输入您的网站所在的#标识域名#(可在控制面板查看):"
    read -p "(例如: /home/wwwroot/<环境名称>/domain/<标识域名>/web):" webdlogo
    [ -z "$webdlogo" ] && webdlogo="example"
    echo
    echo "---------------------------"
    echo "标识域名 = $webdlogo"
    echo "---------------------------"
    echo
	# 证书名称
    echo "请输入您需要设置的#SSl证书的名称#(可在控制面板查看):"
    read -p "(例如: example):" sslname
    [ -z "$sslname" ] && sslname="example"
    echo
    echo "---------------------------"
    echo "SSL证书名 = $sslname"
    echo "---------------------------"
    echo
    # 网站域名
    while true
    do
    echo -e "请输入您需要绑定的域名(请以这种格式输入 >DNS:example.com,DNS:www.example.com<)"
	echo -e "请确保您没有忘记 "DNS:" ! 这很重要!:"
    read -p "(如有超过一个域名需要绑定,请用英文","分隔.):" webdomain
    [ -z "$webdomain" ] && webdomain="DNS:example.com,DNS:www.example.com"
         echo
            echo "---------------------------"
            echo "域名 = $webdomain"
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
   echo -e "\033[47;31m 请检查.如果全部正确,请按任意键继续...或按Ctrl+C来取消安装. \033[0m"
   char=`get_char`
   # 检查ssl证书目录是否存在
    if [ -e /home/wwwroot/${webename}/etc/${sslname}-ssl ]; then
		echo "=====================SSL 文件准备完毕===================="
	else
        echo
		echo -e "\033[47;31m SSL 文件尚未准备完毕!请您先到面板中创建证书! \033[0m"
       echo "获得更多信息,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
	   exit 1
	fi
    
    # 获取证书获取程序
    if [ "$OS" == 'CentOS' ];then
     yum -y install python-argparse
        mkdir -p /root/${webename}/${webdlogo}
		cd /root/${webename}/${webdlogo}
		wget https://raw.githubusercontent.com/mikifuns/LetsencryptForAMH/master/letsencryptcn.sh
		
		else
		mkdir -p /root/${webename}/${webdlogo}
		cd /root/${webename}/${webdlogo}
        wget https://raw.githubusercontent.com/mikifuns/LetsencryptForAMH/master/letsencryptcn.sh
		
    fi
}



# 配置证书设定
function config_ssl(){
    if [ ! -d /root/${webename}/${webdlogo} ];then
        mkdir -p /root/${webename}/${webdlogo}
        echo "========文件夹不存在.正在创建.========"
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
echo "==========设置文件准备完毕!=========="
}

# 安装证书 
function install_ssl(){
    # 检查证书配置文件是否存在
    if [ -s /root/${webename}/${webdlogo}/letsencrypt.conf ]; then
        echo "==============设置文件准备完毕!=============="
        cd /root/${webename}/${webdlogo}
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
        # 给予证书获取程序所有权 并运行
        chmod +x letsencryptcn.sh
        ./letsencryptcn.sh letsencrypt.conf
        echo "==============SSL文件获取完毕=============."
		#删除残缺证书
		rm -rf ${sslname}.crt
		#重命名完整证书到正确名称
		mv ${sslname}.chained.crt ${sslname}.crt
		echo "=================SSL文件重命名完毕!================="
		#停止apache
		amh apache stop
		echo "==============Apache已经停止!================"
		#复制证书到SSL文件夹
		mv -f /root/${webename}/${webdlogo}/${sslname}.crt /home/wwwroot/${webename}/etc/${sslname}-ssl
		mv -f /root/${webename}/${webdlogo}/${sslname}.key /home/wwwroot/${webename}/etc/${sslname}-ssl
		echo "==============文件复制完毕================="
		#启动apache
		amh apache reload
	        echo "==============Apache已经启动!================="
	     
    else
        echo
        echo -e "没准备完毕.请尝试重新启动程序. \a "
        echo "获得技术支持,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
        exit 1
    fi
    }
    
    

# 完成
function finish(){
    cd $cur_dir
    clear
    echo
    echo "祝贺!您针对网站 "${webdomain}" 所创建的SSL已经完毕!"
    echo -e "您的网站位置在: /home/wwwroot/"${webename}"/domain/"${webdlogo}"/web  证书名称为::"${sslname}" \a."
    echo "证书文件等准备文件存放在:/root/"${webename}"/"${webdlogo}"/ 您可以删除它或导出它."
    echo -e "\033[47;31m您选择的是手动配置计划任务版本,所以您需要手动添加计划任务! \033[0m"
	echo -e "\033[47;31m请您在Shell中输入"crontab -e" \033[0m"
	echo -e "\033[47;31m然后按Ins键,选择新一行输入 0 0 1 * * /root/"${webename}"/"${webdlogo}"/"${sslname}".sh \033[0m"
    echo -e "\033[47;31m然后按Esc键,输入":wq"来保存.这样就结束了 \033[0m"
	echo -e "\033[47;31m如有问题请联系我: QQ:2306285095(仅限休息时间) \033[0m"
	echo "欢迎访问我的博客:http://Mikifuns.com"
    echo "尽情享受吧~!"
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
    echo  "获得更多信息,请访问http://mikifuns.com 或QQ:2306285095(仅限休息时间)"
    ;;
esac
