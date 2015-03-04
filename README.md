# docker-zabbix-aio-centos7
Simple Zabbix docker package on top of Centos7 
Including frontend (nginx), zabbix server, zabbix agentd and postgresql

Database is created at build time internally 
Only http port and zabbix server port are exposed

Run command :

docker run -d -p 80:80 -p 10050:10050 psuzzoni/docker-zabbix-aio-centos7


