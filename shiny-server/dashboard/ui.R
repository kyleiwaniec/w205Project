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
      tabPanel('Word counts',""),
      tabPanel('Recent Activity', ""),
       tabPanel('Following/Followers', plotOutput("postgresData")),
       tabPanel('Word counts',
  #      tags$h4(textOutput('texts')),
        tags$div(class="col-sm-6",plotOutput('words_poll')),
        tags$div(class="col-sm-6",plotOutput('words_leg')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_poll')),
        tags$div(class="col-sm-6",verbatimTextOutput('summary_leg'))      
#tabPanel('My hat', plotOutput("aliens"))
)
    )


)
