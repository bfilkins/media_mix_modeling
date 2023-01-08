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

ui = grid_page(
  useShinyjs(),
  tags$style(".grid_card_text {border-color: transparent;}"),
  theme = my_theme,
  layout = c(
    ".     header  .",
    "sidebar   trend   bar"
  ),
  row_sizes = c(
    "70px",
    "1fr"
  ),
  col_sizes = c(
    "250px", 
    "1fr",
    "1fr"
  ),
  gap_size = "2rem",
  # Define sidebar items
  div(id = "sidebar_div",
  grid_card(
    area = "sidebar",
    item_alignment = "top",
    collapsible = TRUE,
    title = "Settings",
    item_gap = "12px",
    imageOutput("filter", height = 50),
    selectizeInput(
      inputId = "selected_tiers",
      label = "Select Tiers",
      multiple = TRUE,
      choices = c("tier1", "tier2","tier3")
    ),
    dateInput(inputId = "navigation_start_range",
              label = "Range Start",
              value = date("2022-1-1")),
    dateInput(inputId = "navigation_end_range",
              label = "Range End",
              value = date("2022-1-3"))
    )),
  grid_card_text(
    area = "header",
    content = "media mix modeling",
    alignment = "center",
    has_border = FALSE,
    is_title = FALSE
  ),
  grid_card(
      "trend",
      highchartOutput(outputId = "spend_trend"),
      has_border = FALSE
  ),
  grid_card(
    "bar",
    highchartOutput(outputId = "spend_summary"),
    has_border = FALSE
  )
)




# Define Server
server <- function(input, output, session) {

  #source("src/server.R", local = TRUE)$value
  #source("src/fakeserver.R", local = TRUE)$value

  output$spend_trend <- renderHighchart(plot_spend_trends)
  output$spend_summary <- renderHighchart(plot_spend_summary)
  
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



