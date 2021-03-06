library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),


    navlistPanel(
      well = FALSE,
      widths = c(3, 9),
      tabPanel('Project home',tags$div(class="home", img(src = "img/home-bg.jpg"))), 

      tabPanel('Honeypot', ""),
      tabPanel('Following/Followers',tags$div(class="divclass",tags$h4("Following to Followers Ratio"), plotOutput('plot'))),
      tabPanel('Recent Activity', ""),
      tabPanel('Following/Followers', plotOutput("postgresData")),
      tabPanel('Word counts',
        tags$h4(class="col-sm-12 text-center","Word count"),
        tags$hr(),
        tags$div(class="col-sm-6",
          tags$h4(class="text-center", textOutput('N_leg'), plotOutput('words_leg'))
          ),
        tags$div(class="col-sm-6",
          tags$h4(class="text-center", textOutput('N_poll'), plotOutput('words_poll'))
          ),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_leg')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_poll')),
        
        tags$div(class="col-sm-6",plotOutput('words_boxplot')),
        tags$div(class="col-sm-6",htmlOutput('summary_words_model', class = "stargazer-table"))         
    ),
    tabPanel('Tweet counts',
        tags$h4(class="col-sm-12 text-center","Tweet count"),
        tags$hr(),
        tags$div(class="col-sm-6",
          tags$h4(class="text-center", textOutput('N_leg2'), plotOutput('tweets_leg'))
          ),
        tags$div(class="col-sm-6",
          tags$h4(class="text-center", textOutput('N_poll2'), plotOutput('tweets_poll'))
          ),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_Tleg')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_Tpoll')),
        
        tags$div(class="col-sm-6",plotOutput('tweets_boxplot')),
        tags$div(class="col-sm-6",htmlOutput('summary_tweets_model', class = "stargazer-table"))       
    )
    # tabPanel('Daily Tweets',
    #     tags$div(class="col-sm-12",plotOutput('daily_tweets'))
          
    # )
    # tabPanel('Hashtag counts',
    #     tags$div(class="col-sm-6",plotOutput('hashtags_p')),
    #     tags$div(class="col-sm-6",plotOutput('hashtags_l')),
    #     tags$div(class="col-sm-6",verbatimTextOutput('summary_hashtags_p')),
    #     tags$div(class="col-sm-6",verbatimTextOutput('summary_hashtags_l'))      
    # )
  )


)
