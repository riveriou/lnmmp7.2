#!/bin/bash
# touch init.sh && chmod +x init.sh && vi init.sh

apt-get update
apt-get install -y curl wget vim dialog software-properties-common

add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install php7.2 php7.2-dev php7.2-fpm php7.2-xml php7.2-mysql php7.2-gd php7.2-mbstring php7.2-curl php7.2-zip mariadb-server nginx -y --allow-unauthenticated

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

#Download appropriate package for the OS version
#Choose only ONE of the following, corresponding to your OS version

#Ubuntu 20.04
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
apt-get update

ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-server
/opt/mssql/bin/mssql-conf set sqlagent.enabled true
# optional: for bcp and sqlcmd
ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
# optional: for unixODBC development headers
apt-get install -y unixodbc-dev

pecl install sqlsrv
pecl install pdo_sqlsrv

printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.2/mods-available/sqlsrv.ini
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini

phpenmod sqlsrv pdo_sqlsrv

org1="index index.html index.htm"
rep1="index index.html index.php index.htm"
org2="# pass PHP scripts to FastCGI server"
rep2="# pass PHP scripts to FastCGI server\n\tlocation ~ \\\.php$ {\n\t\tinclude snippets/fastcgi-php.conf;\n\t\tfastcgi_pass unix:/var/run/php/php7.2-fpm.sock;\n\t}"

sed -i.bak "s/$org1/$rep1/g" /etc/nginx/sites-available/default
sed -i "s?$org2?$rep2?g" /etc/nginx/sites-available/default



