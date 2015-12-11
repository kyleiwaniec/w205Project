
library(shiny)
library(ggplot2)
library(RPostgreSQL)
library(pryr)
library(stargazer)

#install.packages("RAmazonS3", repos = "http://www.omegahat.org/R")
#library(rmongodb)

# require("httr")
# require("RCurl")
# require("stringr")


load_data <- function(){
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="twitter",host="localhost",port=5432,user="postgres",password="pass")
  #data <- dbReadTable(con, "twitters")
  #data <- dbGetQuery(con, "SELECT * FROM twitters")
  data <- dbGetQuery(con, "SELECT * FROM twitters ORDER BY RANDOM() LIMIT 100000" )



# SELECT * FROM twitters
#                             WHERE index IN (
#                               SELECT round(random() * 21e6)::integer as index
#                               FROM generate_series(1, 110000)
#                               GROUP BY index 
#                             )
#                             LIMIT 100000


# ^^ GROUP BY index --> Discard duplicates

# some fancy wierdness
# SELECT * FROM  
#       (SELECT DISTINCT 1 + trunc(random() * (
#               SELECT reltuples::bigint AS estimate
#               FROM   pg_class
#               WHERE  oid = 'public.twitters'::regclass
#             )
#         )::integer AS index 
#         FROM generate_series(1, 11000) g) r 
#         JOIN  twitters USING (index) LIMIT  10000;

# count(*) the number of rows: meh...

# "WITH params AS (
#     SELECT count(*) AS ct             
#      , min(index)  AS min_id
#      , max(index)  AS max_id
#      , max(index) - min(index) AS id_span
#     FROM   twitters
#     )
#     SELECT *
#     FROM  (
#         SELECT p.min_id + trunc(random() * p.id_span)::integer AS index
#         FROM   params p
#               ,generate_series(1, 110000) g 
#         GROUP  BY 1                       
#         ) r
#     JOIN   twitters USING (index)
#     LIMIT  100000;"



# approximate the number of rows manually: meh...

# SELECT * FROM  
#     ( SELECT DISTINCT 1 + trunc(random() * 5100000)::integer AS index 
#       FROM generate_series(1, 251000) g) r 
#       JOIN  twitters USING (index) LIMIT  250000;


# SELECT * FROM twitters TABLESAMPLE BERNOULLI (10); --Using BERNOULLI sampling method fails

# SELECT * FROM twitters ORDER BY RANDOM() LIMIT 10000 --Booooring....




  dbDisconnect(con)
  #data = na.omit(data)
  data$is_polluter = ifelse(data$is_polluter > 0.85, 1,  0)
  return(data)
}


function(input, output) {
  
  twitters <- load_data()



  # twitters
  # [1] "index"            "user_id"          "tweet_id"         "tweet"           
  # [5] "num_words"        "created_ts"       "user_created_ts"  "tweet_created_ts"
  # [9] "screen_name"      "name"             "num_following"    "num_followers"   
  # [13] "num_tweets"      "retweeted"        "retweet_count"    "num_urls"        
  # [17] "num_mentions"    "num_hashtags"      "user_profile_url" "tweeted_urls"    
  # [21] "is_polluter" 
    
  
  #############################################################################################
  # HONEYPOT
  #############################################################################################

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

  #############################################################################################
  # SHINY-TWEETS(TM)
  #############################################################################################

  

  polluters_ps = subset(twitters, is_polluter == 1)
  legit_ps = subset(twitters, is_polluter == 0)

  fitPolluters = lm(num_following ~ num_followers, data=polluters_ps) 
  fitLegit = lm(num_following ~ num_followers, data=legit_ps)



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

  output$N_leg <- renderPrint({
    cat("N = ", nrow(legit_ps)[1])
  })

  output$N_poll <- renderPrint({
    cat("N = ", nrow(polluters_ps)[1])
  })
  
  ##############
  # num_words
  ##############

  max_words = max(max(polluters_ps$num_words), max(legit_ps$num_words))
  
  output$words_poll <- renderPlot({
     hist(polluters_ps$num_words, col="gold2", border="white",main = paste("Content Polluters"), breaks=30, xlim=c(0,max_words))
         axis(1,col="gray100")
         axis(2,col="gray100")
  })
  output$words_leg <- renderPlot({
    hist(legit_ps$num_words, col="darkolivegreen3", border="white", main=paste("Legitimate Users"),breaks=30, xlim=c(0,max_words))
    axis(1,col="gray100")
    axis(2,col="gray100")
  })
  output$summary_poll <- renderPrint({
    print(summary(polluters_ps$num_words) )
  })
  output$summary_leg <- renderPrint({
    print( summary(legit_ps$num_words) )
  })

  output$words_boxplot <- renderPlot({
    boxplot(twitters$num_words ~ twitters$is_polluter, 
      ylim=c(0,max_words),
      xlab="Legitmate Users Vs Polluters",
      )
  })
  output$summary_words_model <- renderPrint({
    mod_words = glm(is_polluter ~ num_words, 
          data=twitters,
          family="binomial"
          )
    stargazer(mod_words, type = "html")
  })

  ##############
  # num_tweets
  ##############
  # max of the 3rd quartile
  max_tweets = max(summary(polluters_ps$num_tweets)[5], summary(legit_ps$num_tweets)[5])

  output$tweets_poll <- renderPlot({
     hist(polluters_ps$num_tweets, col="gold2", border="white",main = paste("Content Polluters"), breaks=600, xlim=c(0,max_tweets))
     axis(1,col="gray100")
     axis(2,col="gray100")
  })
  output$tweets_leg <- renderPlot({
    hist(legit_ps$num_tweets, col="darkolivegreen3", border="white", main=paste("Legitimate Users"),breaks=600, xlim=c(0,max_tweets))
    axis(1,col="gray100")
    axis(2,col="gray100")
  })
  
  output$summary_Tpoll <- renderPrint({
    print(summary(polluters_ps$num_tweets))
  })
  output$summary_Tleg <- renderPrint({
    print( summary(legit_ps$num_tweets))
  })

  output$tweets_boxplot <- renderPlot({
    boxplot(twitters$num_tweets ~ twitters$is_polluter, 
      ylim=c(0,(summary(polluters_ps$num_tweets)[5])*2),
      xlab="Legitmate Users Vs Polluters",
      )
  })
  output$summary_tweets_model <- renderPrint({
    mod_tweets = glm(is_polluter ~ num_tweets, 
          data=twitters,
          family="binomial"
          )
    stargazer(mod_tweets, type = "html")
  })

  ##############
  # num_mentions
  ##############

  #max_mentions = max(max(polluters_ps$num_mentions), max(legit_ps$num_mentions))

  output$mentions_p <- renderPlot({
     hist(polluters_ps$num_mentions, col="gold2", border="white",main = paste("Content Polluters"), breaks=30)
     axis(1,col="gray100")
     axis(2,col="gray100")
  })
  output$mentions_l <- renderPlot({
    hist(legit_ps$num_mentions, col="darkolivegreen3", border="white", main=paste("Legitimate Users"),breaks=30,)
    axis(1,col="gray100")
    axis(2,col="gray100")
  })
  output$summary_mentions_p <- renderPrint({
    print(summary(polluters_ps$num_mentions))
  })
  output$summary_mentions_l <- renderPrint({
    print( summary(legit_ps$num_mentions))
  })

  ##############
  # num_hashtags
  ##############

  max_hashtags = max(max(polluters_ps$num_hashtags), max(legit_ps$num_hashtags))

  output$hashtags_p <- renderPlot({
     hist(polluters_ps$num_hashtags, col="gold2", border="white",main = paste("Content Polluters"), breaks=30, xlim=c(0,max_hashtags))
     axis(1,col="gray100")
     axis(2,col="gray100")
  })
  output$hashtags_l <- renderPlot({
    hist(legit_ps$num_hashtags, col="darkolivegreen3", border="white", main=paste("Legitimate Users"),breaks=30, xlim=c(0,max_hashtags))
    axis(1,col="gray100")
    axis(2,col="gray100")
  })
  output$summary_hashtags_p <- renderPrint({
    print(summary(polluters_ps$num_hashtags))
  })
  output$summary_hashtags_l <- renderPrint({
    print( summary(legit_ps$num_hashtags))
  })
  



}
