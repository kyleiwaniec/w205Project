# We're not doing this. this is just reference
####Upgrade Postgresql 8.4 to 9.4 in Centos####
```
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

```

Backup Data
```
 su - postgres
 pg_dumpall > dump.sql
```
Restore Data
```
service postgresql stop
service postgresql-9.4 start
su - postgres
psql < dump.sql
```

Config Network Access
```
/var/lib/pgsql/9.4/data/pg_hba.conf

# "local" is for Unix domain socket connections only
local   all         all                               ident
# IPv4 local connections:
host    all         all         127.0.0.1/32          ident
host    all         all         130.51.79.0/24        md5
host    all         all         10.210.29.0/24        md5
# IPv6 local connections:
host    all         all         ::1/128               ident
```
Remove PG8.4 -- Uhhh not sure about this:
```
yum remove postgresql
ln -s /usr/pgsql-9.4/bin/psql /usr/local/bin/psql
 ```
