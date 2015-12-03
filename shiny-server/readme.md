### Run install-shiny.sh, OR, follow these instructions: ###

Install R

```
sudo yum install epel-release
sudo yum install R
```

Install shiny-server:

```
wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.1.759-rh5-x86_64.rpm
sudo yum install --nogpgcheck shiny-server-1.4.1.759-rh5-x86_64.rpm
```

administration guide   
http://rstudio.github.io/shiny-server/latest/

set the port to 10000, since this is already open in the security group I'm using.
Otherwise leave as is, and create a new security group with port 3838 open
```
vi /etc/shiny-server/shiny-server.conf
sudo restart shiny-server
```

copy the dashboard app to the server dir:

```

mkdir /srv/shiny-server/dashboard
cp -r /data/w205Project/shiny-server/dashboard/* /srv/shiny-server/dashboard/
sudo restart shiny-server
```

Start R, and install packages:
```
install.packages('shiny', repos='http://cran.rstudio.com/',dependencies = TRUE)
install.packages('ggplot2',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)
install.packages('RPostgreSQL',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)
```
