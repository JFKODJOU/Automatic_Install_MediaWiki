#!/bin/bash

#########################################################################################
########################### Configuration Script of Mediawiki ###########################
#########################################################################################


#---- Test of SuperUser connection ---#
 
ROOT_UID=0   # Root identification $UID 0.

######################
############ If the user is root, execute all the installation (server and mediawiki)

if [ "$UID" -eq "$ROOT_UID" ]  
then

  echo "!--------------------------------------------!"
  echo "!----------Start-up Installation.------------!"
  echo "!--------------------------------------------!"

#########################################################################################
## -------------------------------------------------------------------------------------#
# ------------------------------------ Prerequisite ------------------------------------#
 
  echo "###### Installation of “LAMP “ stack (server) ######"
 
  ### Step 1: Intallation of Apache#
  yum -y install httpd
 
  ### Step 2: Installation of MySQL - Mariadb#
  yum -y install mariadb-server mariadb
 
  ### Step 3: Installation of PHP#
  yum -y install php php-mysql
  yum -y upgrade php*
 
  ### Extensions of PHP#
  yum -y install php-xml php-intl php-gd texlive php-mysqli
 
  ### Installation of xcache
  yum -y install epel-release
  yum -y install php-xcache xcache-admin
 
  ### Installation of APC (Alternative PHP Cache)
  yum -y install php-pear php-devel httpd-devel pcre-devel gcc make
  yum -y install php-pecl-apc
 
  # Git configuration
  yum -y install git
  yum -y groupinstall "Development Tools"
  yum -y install zlib-devel perl-ExtUtils-MakeMaker asciidoc xmlto openssl-devel
 
 # Start server to complete the installation#
  systemctl start httpd.service
  systemctl start mariadb
  systemctl enable httpd.service
  systemctl enable mariadb.service
 
  # MariaDB configuration for MediaWiki#
  #mysql_secure_installation
 
  echo "###### Server Installation End  ######"
 
 
#########################################################################################
## -------------------------------------------------------------------------------------#
# ----------------------------- Downloading of mediawiki -------------------------------#
 
  echo "###### Installation of Mediawiki ######"
 
  #Download MediaWiki#
  curl -OL https://releases.wikimedia.org/mediawiki/1.23/mediawiki-1.23.15.tar.gz
 
  # Create folder "mediawiki" if it not exist
  if [ ! -d "/var/www/html/mediawiki" ]; then mkdir -p /var/www/html/mediawiki; fi

  # Move the file download
  # Unzip the package#
  mv -f mediawiki-* mediawiki.tar.gz
  tar xvzf mediawiki.tar.gz --strip-components=1 -C /var/www/html/mediawiki
 
  chown -R apache:apache /var/www/html/mediawiki
  chmod -R 755 /var/www/html/mediawiki
 
  #restarting server#
  systemctl restart httpd.service

  echo "###### Mediawiki Installation End ######"


#########################################################################################
## -------------------------------------------------------------------------------------#
# ----------------------------- Configuration of Database ------------------------------#
 
  echo "###### Configuration of DataBase ######"

  #Connection to the MySQL DataBase
  echo "**********************************"
  echo "**** Press enter to continuous ****"
     # some variables
    DB_USER=jojo_user
    DB_PASS=pass
    DB_NAME=jojo
    
# creation of database and configuration of a user  
mysql -u root -p << EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
grant ALL PRIVILEGES on $DB_NAME.* to '$DB_USER'@'localhost' ;
FLUSH PRIVILEGES;
EOF

  echo "###### End of Configuration of DB ######"


#########################################################################################
## -------------------------------------------------------------------------------------#
# -------------------------------- Setting of MediaWiki --------------------------------#
echo""
echo "!--------------------------------------------------------------------------------!"
echo "Now, we will configure mediawiki in the browser"
echo""
echo "Follow steps bellow:"
echo "Copie and paste this adresse in your browser '\e[1mhttp://$(hostname -i)/mediawiki\e[0m'"
echo "Select a language and click Continue"

echo""
echo "If you have this phrase (in green): "
echo -e "\e[1m\e[32mThe environment has been checked. You can install MediaWiki.\e[0m"
echo -e "Click Continue"

echo""
echo -e "\e[1mConnection to the database\e[0m"
echo -e "DataBase Name = \e[1m$DB_NAME\e[0m"
echo -e "User Name DataBase = \e[1m$DB_USER\e[0m"
echo -e "User Password = \e[1m$DB_PASS\e[0m"
echo "Click Continue"

echo""
echo "Click Continue"

echo""
echo -e "\e[1mInstallation of wikimedia\e[0m"
echo "Fill information of your wiki, and click Continue"

echo "Click Continue"

echo -e "Download file \e[1mLocalSettings.php\e[0m"

# A stop to end configuration of wiki in the browser
read -p "Press [Enter] key to start backup..."

echo -e "\e[1mDon't forget to be in root mode (sudo)\e[0m"

echo -e "Copy the file LocalSettings.php in the \e[1m/var/www/html/mediawiki/\e[0m"
echo ""

echo "Exécute this line: \e[1mchmod 644 /var/www/html/mediawiki/LocalSettings.php\e[0m"

echo ""
echo "And Restart your serveur"
echo -e "\e[1msystemctl restart httpd.service\e[0m"
 
######################
############ If the user isn't the root, exit directly
else
  echo -e "\e[31m\e[5m!! You must be a superuser (root) to run this script !!\e[0m"
fi

# exit the script
exit 0




