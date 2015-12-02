library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),
 
  tabsetPanel(
    tabPanel('Honeypot data', tags$div(class="divclass",tags$h2("Following to Followers Ratio"), plotOutput('plot'))),
    tabPanel('Postgres', plotOutput("postgresData")),
    tabPanel('Cube', 
      tags$h4(textOutput('texts')),
      tags$div(class="col-sm-6",plotOutput('cube_p')),
      tags$div(class="col-sm-6",plotOutput('cube_l')),
      tags$div(class="col-sm-6",textOutput('summary_poll')),
      tags$div(class="col-sm-6",verbatimTextOutput('summary_leg'))
   ),
   tabPanel('Aliens', plotOutput("aliens"))


)

 
  #tags$div(class="divclass",printOutput('texts')),
  
  
  
  #mainPanel(
    #plotOutput('plot')
  #)
)

