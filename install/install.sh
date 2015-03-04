# Zabbix install and post config

ZABBIX_PWD="${ZABBIX_PWD:-zabbix}"

mkdir -p /etc/zabbix/web
mkdir /root/zab-web
cd /root/zab-web
yum install -y yum-utils
yumdownloader zabbix-web zabbix-server-pgsql

cd / 
rpm2cpio /root/zab-web/zabbix-web-2.4.*.rpm | cpio -idmv
rpm2cpio /root/zab-web/zabbix-server-pgsql*.rpm | cpio -idmv
rm -rf /root/zab-web

ln -s /usr/share/zabbix /usr/share/nginx/html/zabbix
ln -s /usr/share/fonts/dejavu/DejaVuSans.ttf /usr/share/zabbix/fonts/graphfont.ttf


mkdir -p /etc/runit /etc/service /etc/service/nginx /etc/service/php-fpm /etc/service/postgresql /etc/service/zabbix_server /etc/service/zabbix_agentd

cd /install/runit
rpm -ivh runit-2.1.1-6.el6.x86_64.rpm
cp 1 2 3 /etc/runit/
cp -p nginx-run /etc/service/nginx/run
cp -p php-fpm-run /etc/service/php-fpm/run
cp -p zabbix_server-run /etc/service/zabbix_server/run
cp -p zabbix_agentd-run /etc/service/zabbix_agentd/run
cp -p zabbix_server_fg zabbix_agentd_fg /usr/bin/
cp -p postgresql-run /etc/service/postgresql/run

cd /install
sed -i "s/XXXXXXXX/$ZABBIX_PWD/" zabbix.conf.php
sed -i "s/# DBPassword=/DBPassword=$ZABBIX_PWD/" /etc/zabbix/zabbix_server.conf
cp -p www.conf /etc/php-fpm.d/www.conf
cp -p zabbix.conf /etc/nginx/conf.d/zabbix.conf
cp -p zabbix.conf.php /etc/zabbix/web
chown -R nginx:nginx /etc/zabbix/web


sed -i 's#if \[ x"$PGDATA" = x \]#export PGDATA=/var/lib/pgsql/9.4/data/\nif \[ x"$PGDATA" = x \]#' /usr/pgsql-9.4/bin/postgresql94-setup
/usr/pgsql-9.4/bin/postgresql94-setup initdb
echo "daemon off;" >> /etc/nginx/nginx.conf
echo "local all all trust" > /var/lib/pgsql/9.4/data/pg_hba.conf
echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/9.4/data/pg_hba.conf
echo "host all all ::1/128 md5" >> /var/lib/pgsql/9.4/data/pg_hba.conf
chown postgres:postgres /var/lib/pgsql/9.4/data/pg_hba.conf 
chmod 600 /var/lib/pgsql/9.4/data/pg_hba.conf 


mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.ori

su - postgres -c "/usr/pgsql-9.4/bin/pg_ctl start -D /var/lib/pgsql/9.4/data/ -s -w -t 300"
su postgres -c "psql < create_zabbix.sql"


sed 's|post_max_size = 8M|post_max_size = 16M|' -i /etc/php.ini
sed 's|max_execution_time = 30|max_execution_time = 300|' -i /etc/php.ini
sed 's|max_execution_time = 30|max_execution_time = 300|' -i /etc/php.ini
sed 's|max_input_time = 60|max_input_time = 300|' -i /etc/php.ini
sed 's|;date.timezone =|date.timezone = UTC|' -i /etc/php.ini

psql -d zabbix -U zabbix < /usr/share/doc/zabbix-server-pgsql-2.4.4/create/schema.sql
psql -d zabbix -U zabbix < /usr/share/doc/zabbix-server-pgsql-2.4.4/create/images.sql
psql -d zabbix -U zabbix < /usr/share/doc/zabbix-server-pgsql-2.4.4/create/data.sql


