# Title: app.R script for marketing dashboard example
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

# Adhoc analysis and media mix modeling
# source("src/analysis.R")
# source("src/in_progress/media_mix_modeling.R")

# Define UI for app ####

ui = fluidPage(
  useShinyjs(),
  theme = my_theme,
  # Main Panel features start 
  mainPanel(
    width = 12,
    fluidRow(
      style="padding-bottom:20px; padding-top:20px;",
      column(3, titlePanel("Marketing Performance")),
      column(3),
      column(3, titlePanel("Media Mix Modeling")),
      column(3, actionLink(
        inputId = "info_modal",
        label = "learn more about robyn",
        icon("circle-info"),
        style = glue::glue("background-color:", bg_color, "; color:", fg_color)
      ))),
    fluidRow(
      column(4, highchartOutput(outputId = "first_plot")),
      column(2, h2(textOutput(outputId = "total_spend")), p("spend"),
             h2(textOutput(outputId = "conversions")), p("sales"),
             h2(textOutput(outputId = "roas")), p("ROAS")),
      column(3, highchartOutput(outputId = "pareto_frontier")),
      column(3, highchartOutput(outputId = "effect_contribution"))
    ),
    fluidRow(
      column(
        width = 2, 
        materialSwitch(inputId = "first_plot_toggle", label = "trend vs. summary")
      ),
      column(width = 1,
             dateInput(inputId = "start_date",
                       label = "start date",
                       value = date("2021-1-1"))),
      column(width = 1,
             dateInput(inputId = "end_date",
                       label = "end date",
                       value = date("2021-8-1"))),
      column(2)
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
      filter(name != "conversions") |>
      group_by(name) |>
      summarise(spend = sum(value)) |>
      arrange(desc(spend)) |>
      hchart("bar", hcaes(x = reorder(as.factor(name), desc(spend)), y = spend), color = green_purple_theme$`sgbus-green`) |>
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
      filter(name != "conversions") |>
      hchart("line", hcaes(x = report_date, y = value, group = name)) |>
      hc_colors(c(
        green_purple_theme$`sgbus-green`, green_purple_theme$avocado, green_purple_theme$`dark-purple`,
        green_purple_theme$gray1, green_purple_theme$yellow, green_purple_theme$blue, green_purple_theme$gray2)) |>
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
    (!input$first_plot_toggle)
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
        color = green_purple_theme$`dark-purple` ,
        style = list(fontFamily = "Quicksand"),
        tooltip = list(pointFormat = "model: {point.solID} <br> nrsme: {point.nrmse} <br> {point.decomp.rssd}")
      ) |>
      hc_plotOptions(series = list(events = list(mouseOver = legendMouseOverFunction))) |>
      hc_title(
        text = "Multi-objective model performance",
        margin = 20,
        align = "center",
        style = list(useHTML = TRUE)
      ) |>
      hc_subtitle(
        text = "7 pareto frontiers",
        margin = 20,
        align = "center",
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
  
  output$total_spend <- renderText(
    example_data() |>
      filter(name != "conversions") |>
      summarise(value = sum(value)) |>
      mutate(spend_formatted = scales::dollar_format()(value)) |>
      pull(spend_formatted)
  )
  
  output$conversions <- renderText(
    example_data() |>
      filter(name == "conversions") |>
      summarise(value = sum(value)) |>
      mutate(spend_formatted = scales::comma_format()(value)) |>
      pull(spend_formatted)
  )
  
  output$roas <- renderText({
    
    total_spend <- example_data() |>
        filter(name != "conversions") |>
        summarise(value = sum(value)) |>
        pull(value)
    
    conversions <- example_data() |>
        filter(name == "conversions") |>
        summarise(value = sum(value)) |>
        pull(value)
    
    roas <- total_spend/conversions
    return(roas)
  })
  
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
        hcaes(x = rn, y = xDecompAgg),
        color = green_purple_theme$avocado,
        style = list(fontFamily = "Quicksand")
      ) |>
      hc_title(
        text = "Channel contribution to sales",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_yAxis(
        #title = list(text = ""),
        #limits = c(0,100000),
        # plotBands = list(
        #   list(
        #     from = 200000,
        #     to = 600000,
        #     color = "rgba(100, 0, 0, 0.1)",
        #     label = list(text = "This is a plotBand")
        #   )
        # ),
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



