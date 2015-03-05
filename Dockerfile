FROM centos:7
MAINTAINER Philippe Suzzoni <psuzzoni@gmail.com>
ENV REFRESHED_AT 2015-03-04

# Repositories
RUN yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install -y http://repo.zabbix.com/zabbix/2.4/rhel/7/x86_64/zabbix-release-2.4-1.el7.noarch.rpm
RUN yum install -y http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm

RUN yum install -y nginx php-fpm php-pgsql php-common php-cli php-pear php-gd php-mbstring php-bcmath php-pdo php-process php-xml php-pecl-memcache php-mysqlnd dejavu-sans-fonts zabbix-server zabbix-agent postgresql94-server

ADD install /install
RUN /install/install.sh

EXPOSE 80 10051

CMD runit
