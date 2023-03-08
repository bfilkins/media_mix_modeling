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
#source("src/analysis.R")
# Media mix modeling (output saved)

# Define UI for app ####

ui = fluidPage(
  useShinyjs(),
  theme = my_theme,
  titlePanel("Media Mix Modeling with Facebook's Robyn algorithm"),
  # Main Panel features start 
  mainPanel(
    width = 12,
  fluidRow(
    column(width = 2, materialSwitch(inputId = "first_plot_toggle", label = "trend vs. summary")),
    column(width = 2,
           dateInput(inputId = "start_date",
                     label = "Range Start",
                     value = date("2021-1-1"))),
    column(width = 2, 
           dateInput(inputId = "end_date",
                     label = "Range End",
                     value = date("2021-8-1"))),
    column(3),
    column(
      width = 3,
      actionButton(
        inputId = "info_modal", 
        label = "learn more about robyn", 
        icon("circle-info"),
        style = glue::glue("background-color:", bg_color, "; color:", fg_color)
        ))
  ),
  fluidRow(
      column(6, highchartOutput(outputId = "first_plot")),
      column(3),
      column(3, textOutput(outputId = "text_test"))
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
  
  start_date <- reactive(input$start_date)
  end_date <- reactive(input$end_date)
  
  example_data <- reactive({spend_data_filtered |>
    filter(
    report_date >= start_date(),
    report_date <= end_date()
    )})
  
  # define chart functions
  
  plot_spend_summary <- reactive({
    example_data() |>
      group_by(name) |>
      summarise(spend = sum(value)) |>
      arrange(desc(spend)) |>
      hchart("bar", hcaes(x = reorder(as.factor(name), desc(spend)), y = spend), color = beercolors$light_brown) |>
      hc_title(
        text = "eCommerce company media spend trend",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_yAxis(
        title = list(text = "spend $"),
        labels = list(format = "{value}")
      ) |>
      hc_xAxis(title = list(text = ""))
  })
  
  plot_spend_trends <- reactive({
    example_data() |>
      hchart("line", hcaes(x = report_date, y = value, group = name)) |>
      hc_colors(c(
        beercolors$darkblue, beercolors$light_brown, beercolors$fiddlehead_light_green,
        beercolors$light_blue, beercolors$bbco_blue, beercolors$zero_gravity_madonna_yellow)) |>
      hc_title(
        text = "eCommerce company media spend trend",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_yAxis(
        title = list(text = "spend ($)"),
        labels = list(format = "{value}")
      )})

  output$first_plot <- renderHighchart({
    if
    (input$first_plot_toggle)
     plot_spend_trends()
    else
      plot_spend_summary()
    })
  
  output$pareto_frontier <- renderHighchart({
    legendMouseOverFunction <- JS("function(event) {Shiny.onInputChange('legendmouseOver', this.name);}")
    model_scatter_data |> 
      filter(!is.na(cluster)) |>
      hchart(
        "scatter",
        hcaes(x = nrmse, y = decomp.rssd, group = solID),
        color = beercolors$fiddlehead_light_green,
        style = list(fontFamily = "Quicksand"),
        tooltip = list(pointFormat = "model: {point.solID} <br> nrsme: {point.nrmse} <br> {point.decomp.rssd}")
      ) |>
      hc_plotOptions(series = list(events = list(mouseOver = legendMouseOverFunction))) |>
      hc_title(
        text = "Optimal Model Clusters (7 Pareto frontiers for multi-objective optimization)",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_yAxis(#title = list(text = ""),
        labels = list(format = "{value}")
        ) |>
      hc_legend(enabled = FALSE)
    })
  
  selected_model = eventReactive(input$legendmouseOver, {
    input$legendmouseOver
  })
  
  #output$text_test <- renderText(selected_model())
  
  output$effect_contribution <- renderHighchart({
    selected_model = selected_model()
    model_data |>
      filter(
        solID == selected_model,
        #!is.na(effect_share)
      ) |>
      arrange(desc(xDecompAgg)) |>
      hchart(
        "bar",
        hcaes(x = reorder(as.factor(rn), xDecompAgg), y = xDecompAgg),
        style = list(fontFamily = "Quicksand")
      ) |>
      hc_title(
        text = "Marketing Mix Models: Calculate pareto fronts for multi-objective optimization",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_yAxis(
        #title = list(text = ""),
        #limits = c(0,100000),
        plotBands = list(
          list(
            from = 200000,
            to = 600000,
            color = "rgba(100, 0, 0, 0.1)",
            label = list(text = "This is a plotBand")
          )
        ),
        labels = list(format = "{value}")
      )}
    )
  
  
  observeEvent(input$info_modal, {
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



