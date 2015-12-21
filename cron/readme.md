##CRON ~~is awesome~~ is the evil spawn of satan

Remember to put everything on one line    
Make sure to hit "return" so the file ends with a new line.   

Make sure that `simple_sched.sh` is executable:   
`chmod +x simple_sched.sh`   

To setup the cron Daemon that will schedule the project every day at noon UTC run:   
`crontab simple_sched_cron.txt`   

Everytime you run this command, the crontab will be replaced by the new data in the simple_sched_cron.txt

