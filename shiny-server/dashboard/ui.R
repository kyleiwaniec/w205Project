library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),
  
  tabsetPanel(
    tabPanel('Honeypot data', tags$div(class="divclass",tags$h4("Following to Followers Ratio"), plotOutput('plot'))),
    tabPanel('Following/Followers', plotOutput("postgresData")),
    tabPanel('Word counts', 
#      tags$h4(textOutput('texts')),
      tags$div(class="col-sm-6",plotOutput('words_poll')),
      tags$div(class="col-sm-6",plotOutput('words_leg'))
      #tags$div(class="col-sm-6",textOutput('summary_poll')),
      #tags$div(class="col-sm-6",verbatimTextOutput('summary_leg'))
   ),
   tabPanel('My hat', plotOutput("aliens"))


)

 
  #tags$div(class="divclass",printOutput('texts')),
  
  
  
  #mainPanel(
    #plotOutput('plot')
  #)
)

