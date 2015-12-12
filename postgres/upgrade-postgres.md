
Upgrade Postgresql 8.4 to 9.4 in Centos

yum install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm
yum install postgresql94-server postgresql94-contrib
service postgresql-9.4 initdb
chkconfig postgresql-9.4 on

sudo -u postgres pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/pgsql.log start

psql -U postgres
pg_dumpall > dump.sql
\q

sudo -u postgres pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/pgsql.log stop
service postgresql-9.4 start

su - postgres
psql < dump.sql

vi /var/lib/pgsql/9.4/data/postgresql.conf

 1. listen_addresses = '*'
 2. port = 5432


yum remove postgresql
ln -s /usr/pgsql-9.4/bin/psql /usr/bin/psql



-------------------------
 1. yum install PG9.4
 2. wget http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm
 3. yum install pgdg-redhat94-9.4-1.noarch.rpm
 4. yum install postgresql94-server
 5. service postgresql-9.4 initdb
 6. chkconfig postgresql-9.4 on
Backup Data

 7. su - postgres

 8. pg_dumpall > dump.sql
Restore Data

 9. service postgresql stop

 10. service postgresql-9.4 start

 11. su - postgres

 12. psql < dump.sql
Config Network Access

vi /var/lib/pgsql/9.4/data/postgresql.conf

 1. listen_addresses = '*'
 2. port = 5432
/var/lib/pgsql/9.4/data/pg_hba.conf

# "local" is for Unix domain socket connections only
local   all         all                               ident
# IPv4 local connections:
host    all         all         127.0.0.1/32          ident
host    all         all         130.51.79.0/24        md5
host    all         all         10.210.29.0/24        md5
# IPv6 local connections:
host    all         all         ::1/128               ident
Remove PG8.4

 1. yum remove postgresql
 2. ln -s /usr/pgsql-9.4/bin/psql /usr/local/bin/psql