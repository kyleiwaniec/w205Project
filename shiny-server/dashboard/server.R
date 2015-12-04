
library(shiny)
library(ggplot2)
library(RPostgreSQL)
#install.packages("RAmazonS3", repos = "http://www.omegahat.org/R")
#library(rmongodb)

require("httr")
require("RCurl")
require("stringr")

library('scatterplot3d')

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="twitter",host="localhost",port=5432,user="postgres",password="pass")
twitters <- dbReadTable(con, "twitters")
dbDisconnect(con)

twitters = na.omit(twitters)

function(input, output) {
  
  loadData <- function() {

  }
  
  # twitters
  # [1] "index"            "user_id"          "tweet_id"         "tweet"           
  # [5] "num_words"        "created_ts"       "user_created_ts"  "tweet_created_ts"
  # [9] "screen_name"      "name"             "num_following"    "num_followers"   
  # [13] "num_tweets"       "retweeted"        "retweet_count"    "num_urls"        
  # [17] "num_mentions"     "num_hastags"      "user_profile_url" "tweeted_urls"    
  # [21] "isPolluter" 
    
    
  legitimate_users = read.delim("legitimate_users.txt", header=FALSE)
  legitimate_users = na.omit(legitimate_users)
  
  content_polluters = read.delim("content_polluters.txt", header=FALSE)
  content_polluters = na.omit(content_polluters)
  
  legitimate_users$isLegit = rep(1,nrow(legitimate_users))
  content_polluters$isLegit = rep(0,nrow(content_polluters))

  colNames = c("UserID","CreatedAt","CollectedAt","NumerOfFollowings",
                "NumberOfFollowers","NumberOfTweets","LengthOfScreenName",
                "LengthOfDescriptionInUserProfile", "isLegit")

  names(legitimate_users) = colNames
  names(content_polluters) = colNames

  all_users = rbind(legitimate_users,content_polluters)
  
  fit_polluters = lm(NumberOfFollowers~NumerOfFollowings, data = content_polluters)
  fit_legit = lm(NumberOfFollowers~NumerOfFollowings, data = legitimate_users)
  

  fitPolluters = lm(num_following[isPolluter > 0.8] ~ num_followers[isPolluter > 0.8], data=twitters) 
  fitLegit = lm(num_following[isPolluter <= 0.8] ~ num_followers[isPolluter <= 0.8], data=twitters)

  polluters_ps = subset(twitters, isPolluter > 0.95)
  legit_ps = subset(twitters, isPolluter <= 0.95)


  output$postgresData <- renderPlot({
    ggplot() +
      geom_point(data = polluters_ps, aes(log(num_followers), log(num_following)), colour = "gold2", shape=1) +
      geom_abline(slope=as.numeric(fitPolluters$coefficients[2]), colour='gold2') + 
      geom_point(data = legit_ps, aes(log(num_followers), log(num_following)), colour="darkolivegreen3",shape=1) +
      geom_abline(slope=as.numeric(fitLegit$coefficients[2]), colour="darkolivegreen3") +
      #scale_x_continuous(limits = c(0, 200000)) +
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


  
  ##############
  # num_words
  ##############

  maxx = max(max(polluters_ps$num_words), max(legit_ps$num_words))
  
  output$words_poll <- renderPlot({
     hist(polluters_ps$num_words, col="gold2", border="white",main = paste("Content Polluters"), breaks=30, xlim=c(0,maxx))
         axis(1,col="gray100")
         axis(2,col="gray100")
  })
  output$words_leg <- renderPlot({
    hist(legit_ps$num_words, col="darkolivegreen3", border="white", main=paste("Legitimate Users"),breaks=30, xlim=c(0,maxx))
    axis(1,col="gray100")
    axis(2,col="gray100")
  })
  output$texts <- renderPrint({
         print( head(twitters$num_words) )
  })
  output$summary_poll <- renderPrint({
    print(summary(polluters_ps$num_words) )
  })
  output$summary_leg <- renderPrint({
    print( summary(legit_ps$num_words) )
  })


  ##############
  # num_tweets
  ##############

  maxxt = max(max(log(polluters_ps$num_tweets)), max(log(legit_ps$num_tweets)))

  output$tweets_poll <- renderPlot({
     hist(log(polluters_ps$num_tweets), col="gold2", border="white",main = paste("Content Polluters"), breaks=30, xlim=c(0,maxxt))
     axis(1,col="gray100")
     axis(2,col="gray100")
  })
  output$tweets_leg <- renderPlot({
    hist(log(legit_ps$num_tweets), col="darkolivegreen3", border="white", main=paste("Legitimate Users"),breaks=30, xlim=c(0,maxxt))
    axis(1,col="gray100")
    axis(2,col="gray100")
  })
  output$summary_Tpoll <- renderPrint({
    print(summary(polluters_ps$num_tweets))
  })
  output$summary_Tleg <- renderPrint({
    print( summary(legit_ps$num_tweets))
  })




  output$plot <- renderPlot({
      ggplot() +

      geom_point(data = content_polluters, aes(log(NumberOfFollowers), log(NumerOfFollowings)), colour = "gold2", shape=1) +
      geom_abline(slope=as.numeric(fit_polluters$coefficients[2]), colour='gold2') + 
      geom_point(data = legitimate_users, aes(log(NumberOfFollowers), log(NumerOfFollowings)), colour = "darkolivegreen3", shape=1) +
      geom_abline(slope=as.numeric(fit_legit$coefficients[2]), colour='darkolivegreen3') +      
      #scale_x_continuous(limits = c(0, 200000)) +
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


  output$aliens <- renderPlot({
    temp <- seq(-pi, 0, length = 50)
    x <- c(rep(1, 50) %*% t(cos(temp)))
    y <- c(cos(temp) %*% t(sin(temp)))
    z <- 10 * c(sin(temp) %*% t(sin(temp)))
    color <- rep("green", length(x))
    temp <- seq(-10, 10, 0.01)
    x <- c(x, cos(temp))
    y <- c(y, sin(temp))

    z <- c(z, temp)
    color <- c(color, rep("maroon1", length(temp)))
    scatterplot3d(x, y, z, color, pch=20, zlim=c(-2, 10),
    main="Hello, do you like my hat?", grid=FALSE, axis=FALSE,box=FALSE)
  }) 
}
