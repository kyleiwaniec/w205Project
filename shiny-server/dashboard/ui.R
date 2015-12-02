library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),
  #tags$div(class="divclass",tags$h2("Following to Followers Ratio 2")),
  tabsetPanel(
    tabPanel('Honeypot data', tags$div(class="divclass",tags$h2("Following to Followers Ratio"), plotOutput('plot'))),
    tabPanel('Postgres', plotOutput("postgresData")),
    tabPanel('Cube', 
      tags$h4(printOutput('texts')),
      tags$div(class="col-sm-6",plotOutput('cube_p')),
      tags$div(class="col-sm-6",plotOutput('cube_l'))  
    ),
    tabPanel('Aliens', plotOutput("aliens"))
  )
  
  #tags$div(class="divclass",plotOutput('plot')),
  
  
  
  #mainPanel(
    #plotOutput('plot')
  #)
)

