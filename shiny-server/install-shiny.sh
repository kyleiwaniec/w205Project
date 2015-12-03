#! /bin/bash

sudo yum install epel-release
sudo yum install R
sudo su - \
  -c "R -e \"install.packages('ggplot2',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)\""
sudo su - \
  -c "R -e \"install.packages('RPostgreSQL',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)\""
sudo su - \
  -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""


sudo su - \
  -c "R -e \"install.packages('scatterplot3d',repos='http://cran.cnr.berkeley.edu',dependencies = TRUE)\""


# wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.1.759-rh5-x86_64.rpm
sudo yum install --nogpgcheck /data/shiny-server/shiny-server-1.4.1.759-rh5-x86_64.rpm

#administration guide   
#http://rstudio.github.io/shiny-server/latest/

#set the port to 10000, since this is already open in the security group I'm using.
#Otherwise leave as is, and create a new security group with port 3838 open
#vi /etc/shiny-server/shiny-server.conf
sudo rm /etc/shiny-server/shiny-server.conf
sudo cat > /etc/shiny-server/shiny-server.conf <<EOF
# Instruct Shiny Server to run applications as the user "shiny"
run_as shiny;

# Define a server that listens on port 3838
server {
  listen 10000;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /srv/shiny-server;

    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
}
EOF


mkdir /srv/shiny-server/dashboard
cp -r /data/w205Project/shiny-server/dashboard/* /srv/shiny-server/dashboard/
sudo restart shiny-server