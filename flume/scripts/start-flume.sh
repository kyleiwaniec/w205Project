#! /bin/bash

flume-ng agent --conf /data/flume/conf/ -f /data/flume/conf/flume.conf -Dflume.root.logger=DEBUG,console -n TwitterAgent

