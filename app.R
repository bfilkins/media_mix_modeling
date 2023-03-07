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
source("src/analysis.R")

# Define chart functions


# Define UI for app ####

ui = fluidPage(
  useShinyjs(),
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
                     value = date("2022-1-3"))),
    column(width = 1,icon("circle-info", "fa-3x")),
    column(width = 1, materialSwitch(inputId = "first_plot_toggle", label = "trend vs. summary"))
  ),
  fluidRow(
      column(6, highchartOutput(outputId = "first_plot")),
      column(6) 
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

  # rv <- reactiveValues()
  # 
  # observe({
  #   x <- input$first_plot_toggle
  #   # condition tested
  #   if (x == TRUE) rv$first_plot_toggle <- plot_spend_trends
  #   else rv$first_plot_toggle <- plot_spend_summary
  # })
  #source("src/server.R", local = TRUE)$value
  #source("src/fakeserver.R", local = TRUE)$value
  #value <- reactive({input$first_plot_toggle})
  # first_plot <- reactive({
  #   #value = input$first_plot_toggle
  #   print(input$first_plot_toggle)
  #   chart = ifelse(input$first_plot_toggle == TRUE, plot_spend_trends, plot_spend_summary)
  #   return(chart)})
  output$first_plot <- renderHighchart({
    
    if (input$first_plot_toggle)
      plot_spend_trends
    else
      plot_spend_summary})
    
   # renderHighchart(plot_spend_trends)})
  #output$first_plot <- renderHighchart(plot_spend_trends)
  #output$plot_spend_summary <- renderHighchart(plot_spend_summary)
  output$effect_contribution <- renderHighchart(effect_contribution)
  output$pareto_frontier <- renderHighchart(pareto_scatter)
  
  observeEvent(input$show, {
    showModal(modalDialog(
      title = "Important message",
      "This is an important message!"
      ))
    })
  
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



