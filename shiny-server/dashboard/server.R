
library(shiny)
library(ggplot2)
library(RPostgreSQL)
#install.packages("RAmazonS3", repos = "http://www.omegahat.org/R")
#library(rmongodb)

require("httr")
require("RCurl")
require("stringr")

#library(RAmazonS3)

#library(RJSONIO)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="twitter",host="localhost",port=5432,user="postgres",password="pass")
twitters <- dbReadTable(con, "twitters")
dbDisconnect(con)



function(input, output) {
  


  
  loadData <- function() {
   
    
   #raw <- getFile("w205twitterproject", "legitimate_users.txt", auth = NA)
   #d = read.delim(text = raw, stringsAsFactors = FALSE)
   d = read.delim("http://s3-us-west-2.amazonaws.com/w205twitterproject/legitimate_users.txt")
   return(d)
  
  }
  
  
  
  
  
  
  
  #legitimate_users <- read.delim("legitimate_users.txt", header=FALSE)
  
  legitimate_users <- loadData()
  
  legitimate_users = na.omit(legitimate_users)
  
  content_polluters <- read.delim("content_polluters.txt", header=FALSE)
  content_polluters = na.omit(content_polluters)
  
  legitimate_users$isLegit = rep(1,nrow(legitimate_users))
  
  content_polluters$isLegit = rep(0,nrow(content_polluters))
  colNames <- c("UserID","CreatedAt","CollectedAt","NumerOfFollowings",
                "NumberOfFollowers","NumberOfTweets","LengthOfScreenName",
                "LengthOfDescriptionInUserProfile", "isLegit")
  names(legitimate_users) = colNames
  names(content_polluters) = colNames
  all_users = rbind(legitimate_users,content_polluters)
  
  fit_polluters = lm(NumberOfFollowers~NumerOfFollowings, data = content_polluters)
  fit_legit = lm(NumberOfFollowers~NumerOfFollowings, data = legitimate_users)
  
  output$s3plot <- renderPlot({
    #View(loadData())
  })
  
  output$plot <- renderPlot({
    
   
    ggplot() +
      geom_point(data = content_polluters, aes(NumberOfFollowers, NumerOfFollowings), colour = "red", shape=1) +
      geom_abline(slope=as.numeric(fit_polluters$coefficients[2]), colour='red') + 
      geom_point(data = legitimate_users, aes(NumberOfFollowers, NumerOfFollowings), shape=1) +
      geom_abline(slope=as.numeric(fit_legit$coefficients[2])) +
      scale_x_continuous(limits = c(0, 200000)) +
      theme(
       # axis.text = element_text(size = 14),
       # legend.key = element_rect(fill = "navy"),
       # legend.background = element_rect(fill = "white"),
       # legend.position = c(0.14, 0.80),
       # panel.grid.major = element_line(colour = "grey40"),
       # panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white")
      )
    
    
    
    
  }, height=700)
  
}