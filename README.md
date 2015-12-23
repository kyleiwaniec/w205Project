#Please see the wiki for full project details and documentation

### ~~A running instance: http://52.7.131.84:10000/dashboard/~~   

##QUICK SETUP INSTRUCTIONS##

###With a brand new instance and volume: ###
follow these steps in order:   

use this AMI:   
__w205Project_V2.0__

create a new __m3.large__ instance with security group containing:

```
Ports	Protocol	Source	tableau
4040	tcp	0.0.0.0/0	✔
50070	tcp	0.0.0.0/0	✔
8080	tcp	0.0.0.0/0	✔
22		tcp	0.0.0.0/0	✔
10000	tcp	0.0.0.0/0	✔
8020	tcp	0.0.0.0/0	✔
8088	tcp	0.0.0.0/0	✔
```
Attach a __100GB Volume__ in the same region   
ssh into your instance   

```
ssh -i "xxx.pem" root@ec2-xx-x-xxx-xx.compute-1.amazonaws.com
fdisk -l
wget https://s3-us-west-2.amazonaws.com/w205twitterproject/provision.sh
. provision.sh <DEVICE PATH> # run once - this may take several mintes...
```

then run your personal git-keys script, or however you want to authorize git.   
here is a template, if you know what yer keys are: `git-keys-template.sh`
```
vi git-keys.sh # copypasta from the template
. git-keys.sh
cd /data
git clone git@github.com:kyleiwaniec/w205Project.git
```
pull the repo, then run:  
```
cd /data/w205Project
. provision/bootstrap.sh # this may take several minutes...
```

You will be prompted to add your Twitter keys and AWS keys in the bootstrap script.

Run the scheduler:
```
crontab cron/simple_sched_cron.txt
```

Watch it here: `tail -f /data/cronlog.log`   


***

GO TO YOUR INSTANCE's DASHBOARD:   
http://ec2-xx-x-xxx-xx.compute-1.amazonaws.com:10000/dashboard/   
***

INSTALL PLUGIN:   
Drag and drop the chromeExtension.crx file into your chrome browser, and follow the prompts.
