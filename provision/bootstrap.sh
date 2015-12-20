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

# start servers
echo "starting hadoop.."
. /root/start-hadoop.sh
. /data/start_postgres.sh
. /data/start_metastore.sh



#####################################
# SHINY (already installed)
#####################################

# STR=$'Does your AMI have shiny? [yes/n]: '
# echo "$STR"
# read answer

# if [[ "$answer" != "yes" ]]; then
# 	. /data/w205Project/shiny-server/install-shiny.sh
# fi

# Extra libraries not on the AMI:

sudo su - \
  -c "R -e \"install.packages('pryr',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)\""
sudo su - \
  -c "R -e \"install.packages('devtools',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)\""
sudo su - \
  -c "R -e \"install.packages('stargazer',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)\""

# copy the dashboard files:
cp -r /data/w205Project/shiny-server/dashboard/* /srv/shiny-server/dashboard/

#####################################
# POSTGRES
#####################################

# write setup script for twitter table
# cat > /data/make_twitter_postgres.sql <<EOF
# CREATE DATABASE TWITTER;
# \c twitter
# \i /data/w205Project/postgres/twitter.sql
# \d+ twitters
# \q
# EOF

#run the twitter creation sql
sudo -u postgres psql -f /data/w205Project/postgres/twitter.sql

#####################################
# HIVE
#####################################
# make sure the hive metastore is set
cp /data/hadoop/hive/conf/hive-site.xml /etc/hive/conf.dist/hive-site.xml


#####################################
# SPARK
#####################################

sudo cp -r /data/w205Project/provision/hive-site.xml /data/spark15/conf/hive-site.xml


#####################################
# PYTHON
#####################################

source ~/ENV27/bin/activate
# install any additonal python modules
pip install 'requests[security]' #for urllib3
pip install -r /data/w205Project/provision/requirements.txt


#####################################
# AWS KEYS
#####################################

# add S3 keys to environment:

function AWSKEYID {
	STR=$'Please enter your AWS ACCESS KEY ID: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "export S3_ACCESS_KEY=$answer" >> ~/.passwords 
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
		echo "export S3_SECRET_ACCESS_KEY=$answer" >> ~/.passwords
	else
		STR=$'AWS SECRET ACCESS KEY can\'t be empty: \n'
		echo "$STR"
		AWSSECRETKEY	
	fi
}

AWSKEYID
AWSSECRETKEY

source ~/.passwords


#####################################
# TWITTER KEYS
#####################################

# add twitter keys to environment:

function consumerKey {
	STR=$'Please enter your Twitter consumerKey: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.consumerKey = $answer" >> /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'consumerKey can\'t be empty: \n'
		echo "$STR"
		consumerKey	
	fi
}
function consumerSecret {
	STR=$'Please enter your Twitter consumerSecret: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.consumerSecret = $answer" >> /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'consumerSecret can\'t be empty: \n'
		echo "$STR"
		consumerSecret	
	fi
}
function accessToken {
	STR=$'Please enter your Twitter accessToken: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.accessToken = $answer" >> /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'accessToken can\'t be empty: \n'
		echo "$STR"
		accessToken	
	fi
}
function accessTokenSecret {
	STR=$'Please enter your Twitter accessTokenSecret: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.accessTokenSecret = $answer" >> /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'accessTokenSecret can\'t be empty: \n'
		echo "$STR"
		accessTokenSecret	
	fi
}

consumerKey
consumerSecret
accessToken
accessTokenSecret