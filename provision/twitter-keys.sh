#! bin/bash

#####################################
# TWITTER KEYS
#####################################

# add twitter keys to environment:

function consumerKey {
	STR=$'Please enter your consumerKey: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.consumerKey = $answer" | cat - /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'consumerKey can\'t be empty: \n'
		echo "$STR"
		consumerKey	
	fi
}
function consumerSecret {
	STR=$'Please enter your consumerSecret: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.consumerSecret = $answer" | cat - /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'consumerSecret can\'t be empty: \n'
		echo "$STR"
		consumerSecret	
	fi
}
function accessToken {
	STR=$'Please enter your accessToken: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.accessToken = $answer" | cat - /data/w205Project/flume/conf/flume.conf 
	else
		STR=$'accessToken can\'t be empty: \n'
		echo "$STR"
		accessToken	
	fi
}
function accessTokenSecret {
	STR=$'Please enter your accessTokenSecret: '
	echo "$STR"
	read answer

	if [[ "$answer" != "" ]]; then
		echo "TwitterAgent.sources.Twitter.accessTokenSecret = $answer" | cat - /data/w205Project/flume/conf/flume.conf 
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