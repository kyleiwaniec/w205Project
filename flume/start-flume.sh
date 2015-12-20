#! /bin/bash

flume-ng agent --conf /data/w205Project/flume/conf/ -f /data/w205Project/flume/conf/flume.conf -Dflume.root.logger=DEBUG,console -n TwitterAgent

echo $$ > /data/script.pid