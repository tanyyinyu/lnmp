#! /bin/bash
#mysql install
 yum install -y wget perl-5.16.3-294.el7_6.x86_64 perl-Data-Dumper libaio-devel numactl-devel
 useradd mysql
 mkdir -p /data/mysql && chown mysql:mysql /data/mysql
cd /usr/local/src
 wget -c https://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz
 tar zxf mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz
 rm -rf mysql-5.6.46-linux-glibc2.12-x86_64.tar.gz
 mv mysql-5.6.46-linux-glibc2.12-x86_64 /usr/local/mysql
cd /usr/local/mysql
 ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
 cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld && chkconfig --add mysqld
 sed -r '45,48s/(basedir=)(.*)/\1\/usr\/local\/mysql/' -i /etc/init.d/mysqld && sed -r '45,48s/(datadir=)(.*)/\1\/data\/mysql/' -i /etc/init.d/mysqld
 rm -f /etc/my.cnf && wget -O /etc/my.cnf.d/my.cnf https://configfile-tanytan.oss-cn-shenzhen.aliyuncs.com/my.cnf
 echo "export PATH=$PATH:/usr/local/mysql/bin/" >>/etc/bashrc && source /etc/bashrc

#php7.3 install
 yum install -y wget bzip2 gcc-plugin-devel.x86_64  libxml2-devel openssl-devel.x86_64  libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel epel-release  libmcrypt-devel make
cd /usr/local/src
 wget -c http://cn2.php.net/distributions/php-7.3.0.tar.bz2
 tar -jxvf php-7.3.0.tar.bz2
 mv php-7.3.0 php7.3
 rm -f php-7.3.0.tar.bz2
cd /usr/local/src/php7.3
 ./configure --prefix=/usr/local/php-fpm --with-config-file-path=/usr/local/php-fpm/etc --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --with-mysql --with-mysqli --with-pdo-mysql --with-mysql-sock=/tmp/mysql.sock --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-mcrypt --enable-soap --enable-gd-native-ttf --enable-ftp --enable-mbstring --enable-exif --with-pear --with-curl --with-openssl --disable-fileinfo
 make && make install
 cp /usr/local/src/php7.3/php.ini-production /usr/local/php-fpm/etc/php.ini && cp  /usr/local/src/php7.3/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
 chmod 755 /etc/init.d/php-fpm && chkconfig --add php-fpm
 useradd -s /sbin/nologin php-fpm
 mv /usr/local/php-fpm/etc/php-fpm.conf.default /usr/local/php-fpm/etc/php-fpm.conf && mv /usr/local/php-fpm/etc/php-fpm.d/www.conf.default /usr/local/php-fpm/etc/php-fpm.d/www.conf
cd /root
 rm -rf /usr/local/src/php7.3

###nginx install
 rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
 yum install -y openssl
 yum install -y nginx
#config
mkdir -p /data/wwwroot/test.com
cat >  /data/wwwroot/test.com/index.php <<EOF
<?php
    header( 'Content-Type: text/plain' );
    echo 'Host: ' . \$_SERVER['HTTP_HOST'] . "\n";
    echo 'Remote Address: ' . \$_SERVER['REMOTE_ADDR'] . "\n";
    echo 'X-Forwarded-For: ' . \$_SERVER['HTTP_X_FORWARDED_FOR'] . "\n";
    echo 'X-Forwarded-Proto: ' . \$_SERVER['HTTP_X_FORWARDED_PROTO'] . "\n";
    echo 'Server Address: ' . \$_SERVER['SERVER_ADDR'] . "\n";
    echo 'Server Port: ' . \$_SERVER['SERVER_PORT'] . "\n\n";
?>
EOF
cat >  /etc/nginx/conf.d/1.conf <<EOF
server {
    listen       80;
    server_name  www.test.com;
        root   /data/wwwroot/test.com;
        index  index.html index.htm index.php;
    location ~ \.php$ {
        root           /data/wwwroot/test.com;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /data/wwwroot/test.com\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF
#start
/etc/init.d/php-fpm start && /etc/init.d/mysqld start && systemctl start nginx
echo "curl -x127.0.0.1:80 www.test.com"
curl -x127.0.0.1:80 www.test.com
