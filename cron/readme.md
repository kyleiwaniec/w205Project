##CRON is awesome

To schedule some stuff, write a cron job in cron-file.txt   

Then run:   
`crontab cron-file.txt`   

This will start the deamon. Everytime you run this command, the crontab will be replaced by the new data in the cron-file.txt
   
Put everything on one line   
Make sure to hit "return" so the file ends with a new line. 

To setup the cron Daemon that will schedule the project every day at noon UTC run:
`crontab simple_sched_cron.txt`
Make sure that 
