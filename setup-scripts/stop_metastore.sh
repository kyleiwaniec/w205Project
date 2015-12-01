#! /bin/bash

ps aux|grep org.apache.hadoop.hive.metastore.HiveMetaStore|awk '{print $2}'|xargs kill -9
