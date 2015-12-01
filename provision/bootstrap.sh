#! /bin/bash


# make pretty prompt for github
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
PS1="\[\e[32m\]\$(parse_git_branch)\[\e[m\]\u@\h:\W \$ \[\e[m\]"
export PS1


#####################################
# START SERVICES
#####################################

# make sure the hive metastore is set
cp /data/hadoop/hive/conf/hive-site.xml /etc/hive/conf.dist/hive-site.xml

# start servers
echo "starting servers"
. /root/start-hadoop.sh
. /data/start_postgres.sh
. /data/start_metastore.sh



#####################################
# SHINY
#####################################

# mkdir /srv/shiny-server/dashboard
cp -r /data/w205Project/shiny-server/dashboard/* /srv/shiny-server/dashboard/
sudo start shiny-server


#####################################
# POSTGRES
#####################################

# write setup script for twitter table
cat > /data/make_twitter_postgres.sql <<EOF
CREATE DATABASE TWITTER
\c twitter
\i /data/w205Project/postgres/twitter.sql
\q
EOF

#run the twitter creation sql
sudo -u postgres psql -f /data/make_twitter_postgres.sql

#####################################
# SPARK
#####################################

mv spark15 /data
ln -s /data/spark15 $HOME/spark15
cp /data/hadoop/hive/conf/hive-site.xml /data/spark15/conf


#####################################
# PYTHON
#####################################


# already activated in the bash profile
# source ENV27/bin/activate
# install any additonal python modules
pip install -r requirements.txt


#####################################
# AWS KEYS
#####################################

# add S3 keys to environment:

function AWSKEYID {
	STR=$'Please enter your AWS ACCESS KEY ID: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		export S3_ACCESS_KEY="$answer"
	else
		STR=$'AWS ACCESS KEY ID can\'t be empty: \n'
		echo "$STR"
		AWSKEYID	
	fi
}
function AWSSECRETKEY {
	STR=$'Please enter your AWS SECRET ACCESS KEY: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		export S3_SECRET_ACCESS_KEY="$answer"
	else
		STR=$'AWS SECRET ACCESS KEY can\'t be empty: \n'
		echo "$STR"
		AWSSECRETKEY	
	fi
}

AWSKEYID
AWSSECRETKEY