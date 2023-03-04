# Title: app.R script for nupath shiny app
# Author: Brendan Filkins
# Date: 2022-11-4
# Notes:

# rsconnect::setAccountInfo(name='greenstatedata', token='C5D549B8A327628C42A4462F020528AD', secret='WTfEIsRkYvXZnr5ZGT51mTuaBaw/2nyU2bqlqA84')
# rsconnect::deployApp()

# Load Libraries
source("src/libraries.R")

# Define themes
source("src/theme.R")

# Load data
source("src/load_data.R")

# Adhoc analysis
# Load data
source("src/analysis.R")

# Define UI for app ####

ui = fluidPage(
  useShinyjs(),
  tags$style(".grid_card_text {border-color: transparent;}"),
  theme = my_theme,
  titlePanel("This is f'in awesome"),
  # Main Panel features start 
  mainPanel(
    width = 12,
  fluidRow(
    column(4),
    column(width = 2,
           dateInput(inputId = "navigation_start_range",
                     label = "Range Start",
                     value = date("2022-1-1"))),
    column(width = 2, dateInput(inputId = "navigation_end_range",
                     label = "Range End",
                     value = date("2022-1-3"))
    )
  ),
  fluidRow(
      column(6, highchartOutput(outputId = "spend_trend")),
      column(6, highchartOutput(outputId = "plot_spend_summary"))
  ),
  titlePanel("Another f in title!!! Woo"),
  fluidRow(
    column(6, highchartOutput(outputId = "effect_contribution")),
    column(6, highchartOutput(outputId = "pareto_frontier"))
  )
)
)




# Define Server
server <- function(input, output, session) {

  #source("src/server.R", local = TRUE)$value
  #source("src/fakeserver.R", local = TRUE)$value

  output$spend_trend <- renderHighchart(plot_spend_trends)
  output$plot_spend_summary <- renderHighchart(plot_spend_summary)
  output$effect_contribution <- renderHighchart(effect_contribution)
  output$pareto_frontier <- renderHighchart(pareto_scatter)
  
  
  output$filter <- renderImage(
    list(
      src = "filter.png",
      height = "50",
      contentType = "image/png"),
    deleteFile=FALSE
  )
}

# Create Shiny app ----
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
shinyApp(ui = ui, server = server)



