#!/bin/bash
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