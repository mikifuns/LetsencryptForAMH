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
echo
echo "#############################################################"
echo "# One click Get Let’s Encrypt For Your AMH WebSite          #"
echo "# Support: https://mikifuns.com  QQ:2306285095(Break Time)  #"
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
echo "#############################################################"
echo

# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root USER!" 1>&2
	   echo "For More Information,please visit:https://www.mikifuns.com or QQ:2306285095(Only Break time)"
       exit 1
    fi
}

# Check OS
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=CentOS
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
    else
        echo "Not supported OS, Please reinstall OS and retry!"
		echo "For More Information,please visit:https://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
    fi
}


# Pre-installation settings
function pre_install(){
    # Set Environmental name
    echo "Please input Site Environmental name(You can get it from panel):"
    read -p "(For Example: /home/wwwroot/<Environmental name>/domain/<Domain logo>/web):" webename
    [ -z "$webename" ] && webename="example"
    echo
    echo "---------------------------"
    echo "Environmental name = $webename"
    echo "---------------------------"
    echo
	# Set Domain logo
    echo "Please input Domain logo(You can get it from panel):"
    read -p "(For Example: /home/wwwroot/<Environmental name>/domain/<Domain logo>/web):" webdlogo
    [ -z "$webdlogo" ] && webdlogo="example"
    echo
    echo "---------------------------"
    echo "Domain logo = $webdlogo"
    echo "---------------------------"
    echo
	# Set SSl NAME
    echo "Please input SSL name(You can get it from panel):"
    read -p "(For Example: example):" sslname
    [ -z "$sslname" ] && sslname="example"
    echo
    echo "---------------------------"
    echo "SSL name = $sslname"
    echo "---------------------------"
    echo
    # Set WEbsite Domain
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
   #check SSL is ready?
    if [ -f /home/wwwroot/${webename}/etc/${sslname}-ssl/${sslname}.crt ]; then
		echo "SSL file crt is READY!"
	else
        echo
		echo -e "\033[47;31m SSL file <CRT> IS NOT READY!Please GO AMH panel to create A SSL for This Domian! \033[0m"
        echo "For More Information,please visit:https://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
	fi
	if [ -f /home/wwwroot/${webename}/etc/${sslname}-ssl/${sslname}.key ]; then
		echo "SSL file key is READY!"
	else
        echo
		echo -e "\033[47;31m SSL file <KEY> IS NOT READY!Please GO AMH panel to create A SSL for This Domian! \033[0m"
        echo "For More Information,please visit:https://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
	fi
    
    #Install necessary dependencies
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



# Config ssl
function config_ssl(){
    if [ ! -d /root/${webename}/${webdlogo} ];then
        mkdir -p /root/${webename}/${webdlogo}
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
}

# Install 
function install_ssl(){
    # Install shadowsocks-go
    if [ -s /root/${webename}/${webdlogo}/letsencrypt.conf ]; then
        echo "Every Thing IS READY!"
		cd /root/${webename}/${webdlogo}
        chmod +x letsencrypt.sh
        ./letsencrypt.sh letsencrypt.conf
		rm -rf ${sslname}.crt
		mv ${sslname}.chained.crt ${sslname}.crt
		mv -f /root/${webename}/${webdlogo}/${sslname}.crt /home/wwwroot/${webename}/etc/${sslname}-ssl
		mv -f /root/${webename}/${webdlogo}/${sslname}.key /home/wwwroot/${webename}/etc/${sslname}-ssl
		amh apache restart
    else
        echo
        echo "Not Ready!Please Restart SH Again!(conf LOST)"
		echo "For More Information,please visit:https://www.mikifuns.com or QQ:2306285095(Only Break time)"
        exit 1
    fi
    cd $cur_dir
    clear
    echo
    echo "Congratulations, Let’s Encrypt SSL For Domain "${webdomain}" is completed!"
    echo -e "Your web file is in: /home/wwwroot/"${webename}"/domain/"${webdlogo}"/web  Named:"${sslname}" ."
    echo 
    echo "Welcome to visit:https://Mikifuns.com"
    echo "Enjoy it!"
    echo
    exit 1
}

# Install SSL
function install_sslsetp(){
    checkos
    rootness
    pre_install
    config_ssl
	install_ssl
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
    echo "Usage: `basename $0` {install|uninstall}"
	echo "For More Information,please visit:https://www.mikifuns.com or QQ:2306285095(Only Break time)"
    ;;
esac
