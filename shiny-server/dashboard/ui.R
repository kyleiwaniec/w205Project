library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),


    navlistPanel(
      well = FALSE,
      widths = c(3, 9),
      tabPanel('Project home',tags$div(class="home", img(src = "img/home-bg.jpg"))), 

      tabPanel('Honeypot', ""),
      tabPanel('Following/Followers',
        tags$div(class="divclass",
          tags$h4("Following to Followers Ratio"), 
          plotOutput('plot')
          )
        ),
      tabPanel('Word counts',""),
      tabPanel('Recent Activity', ""),
      tabPanel('Following/Followers', plotOutput("postgresData")),
      tabPanel('Word counts',
        tags$div(class="col-sm-12",div$h4('Word counts'),actionButton("action", label = "Refresh")),
        tags$div(class="col-sm-6",plotOutput('words_poll')),
        tags$div(class="col-sm-6",plotOutput('words_leg')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_poll')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_leg')),
        tags$div(class="col-sm-6",plotOutput('words_boxplot')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_words_model'))         
    ),
    tabPanel('Tweet counts',
        tags$div(class="col-sm-6",plotOutput('tweets_poll')),
        tags$div(class="col-sm-6",plotOutput('tweets_leg')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_Tpoll')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_Tleg')),
        tags$div(class="col-sm-6",plotOutput('tweets_boxplot')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_tweets_model'))       
    ),
    tabPanel('Mention counts',
        tags$div(class="col-sm-6",plotOutput('mentions_p')),
        tags$div(class="col-sm-6",plotOutput('mentions_l')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_mentions_p')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_mentions_l'))      
    ),
    tabPanel('Hashtag counts',
        tags$div(class="col-sm-6",plotOutput('hashtags_p')),
        tags$div(class="col-sm-6",plotOutput('hashtags_l')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_hashtags_p')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_hashtags_l'))      
    )
  )


)
