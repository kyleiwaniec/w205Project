library(shiny)
library(ggplot2)

fluidPage(
  includeCSS("www/styles.css"),
  #tags$div(class="divclass",tags$h2("Following to Followers Ratio 2")),
  tabsetPanel(
    tabPanel('Honeywell data', tags$div(class="divclass",tags$h2("Following to Followers Ratio"), plotOutput('plot'))),
    tabPanel('two', plotOutput("s3plot"))
  )
  
  #tags$div(class="divclass",plotOutput('plot')),
  
  
  
  #mainPanel(
    #plotOutput('plot')
  #)
)

