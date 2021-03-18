#!/usr/bin/env bash

DBHOST=localhost
DBNAME=dbname
DBUSER=root
DBPASSWD=root

apt-get update
apt-get install vim curl build-essential python-software-properties git

debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

# install mysql and admin interface

apt-get -y install mysql-server phpmyadmin

mysql -u$DBUSER -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -u$DBUSER -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'%' identified by '$DBPASSWD'"

cd /vagrant

# update mysql conf file to allow remote access to the db

sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

sudo service mysql restart

# setup phpmyadmin

apt-get -y install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mysql php-gettext

sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

rm -rf /var/www/html
ln -fs /vagrant/public /var/www/html
sudo ln -s /usr/share/phpmyadmin /var/www/phpmyadmin

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

service apache2 restart