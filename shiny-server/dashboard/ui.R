library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),
  #tags$div(class="divclass",tags$h2("Following to Followers Ratio 2")),
  tabsetPanel(
    tabPanel('Honeypot data', tags$div(class="divclass",tags$h2("Following to Followers Ratio"), plotOutput('plot'))),
    tabPanel('Postgres', plotOutput("postgresData"))
  )
  
  #tags$div(class="divclass",plotOutput('plot')),
  
  
  
  #mainPanel(
    #plotOutput('plot')
  #)
)

