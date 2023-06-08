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
  tags$style(
    type = "text/css",
    paste0(
      "body{background-image: linear-gradient(to right top,", bg_color, ", ", cool_winter_theme$light_gray, ", ", bg_color,", ", bg_color, ");}
      .transparentBackgroundColorMixin(@alpha,@color) {
        background-color: rgba(red(@color), green(@color), blue(@color), @alpha);
        }" 
    )
  ),
  # Main Panel features start 
  mainPanel(
    width = 12,
    fluidRow(
      #style="padding-bottom:10px; padding-top:10px;",
      column(6, titlePanel("Marketing Performance")),
      column(3, titlePanel("Summary")),
      column(3)
      ),
    fluidRow(
      column(6, 
        highchartOutput(outputId = "first_plot")),
      column(3, 
      fluidRow(h2(textOutput(outputId = "total_spend")), p("spend")),
      fluidRow(h2(textOutput(outputId = "conversions")), p("sales")),
      fluidRow(h2(textOutput(outputId = "roas")), p("ROAS (not)")),
      fluidRow(
        column(
          width = 6,
          dateInput(
            inputId = "start_date",
            label = "start date",
            value = start_date)
          ),
        column(
          width = 6,
          dateInput(
            inputId = "end_date",
            label = "end date",
            value = end_date))
        ),
      fluidRow(materialSwitch(inputId = "first_plot_toggle", label = "trend vs. summary"))
      )),
    fluidRow(
      column(4, titlePanel("Media Mix Modeling")),
      column(4, actionLink(
        inputId = "info_modal",
        label = "learn more about robyn",
        icon("circle-info"),
        style = glue::glue(
          ".transparentBackgroundColorMixin:(1,#FFFFFF)", #cool_winter_theme$light_gray,
          "; color:", fg_color)
      )),
      column(
        width = 4, 
        materialSwitch(inputId = "toggle_roi_vs_contribution", label = "contribution vs. roas")
      ),
    ),
    fluidRow(
      column(4, highchartOutput(outputId = "pareto_frontier")),
      column(4, highchartOutput(outputId = "actual_vs_predicted")),
      column(4, highchartOutput(outputId = "second_toggle_plot"))
    )
  )
)





# Define Server ####
server <- function(input, output, session) {
  
  easeOutBounce  <- JS("function (pos) {
    if ((pos) < (1 / 2.75)) {
      return (7.5625 * pos * pos);
    }
    if (pos < (2 / 2.75)) {
      return (7.5625 * (pos -= (1.5 / 2.75)) * pos + 0.75);
    }
    if (pos < (2.5 / 2.75)) {
      return (7.5625 * (pos -= (2.25 / 2.75)) * pos + 0.9375);
    }
    return (7.5625 * (pos -= (2.625 / 2.75)) * pos + 0.984375);
    }")
  
  legendMouseOverFunction <- JS("function(event) {Shiny.onInputChange('legendmouseOver', this.name);}")
  
  start_date <- reactive(input$start_date)
  end_date <- reactive(input$end_date)
  
  example_data <- reactive({spend_data_filtered |>
    filter(
    date >= start_date(),
    date <= end_date()
    )})
  
  # define chart functions
  
  plot_spend_summary <- reactive({
    example_data() |>
      filter(name != "sales") |>
      group_by(name) |>
      summarise(spend = sum(value)) |>
      arrange(desc(spend)) |>
      hchart(
        "bar",
        hcaes(x = reorder(as.factor(name), desc(spend)), y = spend), 
        color = cool_winter_theme$baby_blue,
        animation = list(
          duration = 3000,
          easing = easeOutBounce
        )) |>
      hc_title(
        text = "media spend trend",
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
      filter(name != "sales") |>
      hchart("line", hcaes(x = date, y = value, group = name)) |>
      hc_colors(c(
        cool_winter_theme$off_white, cool_winter_theme$pastel_orange, 
        cool_winter_theme$dark_gray, cool_winter_theme$forest_green,
        cool_winter_theme$mid_gray, cool_winter_theme$light_blue,
        cool_winter_theme$baby_blue)) |>
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
    model_scatter_data |> 
      filter(!is.na(cluster)) |>
      mutate(top_model = if_else(solID == "2_237_5", cool_winter_theme$pastel_orange, cool_winter_theme$deep_blue)) |>
      hchart(
        "scatter",
        hcaes(x = nrmse, y = decomp.rssd, group = solID, color = top_model),
        style = list(fontFamily = "Quicksand"),
        #color = list(cool_winter_theme$baby_blue, cool_winter_theme$dark_gray),
        tooltip = list(pointFormat = "model: {point.solID} <br> nrsme: {point.nrmse} <br> {point.decomp.rssd}")
      ) |>
      #hc_colors(c(cool_winter_theme$baby_blue, cool_winter_theme$dark_gray)) |>
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
  
  values <- reactiveValues(default = 0)
  
  observeEvent(input$legendmouseOver,{
    values$default <- input$legendmouseOver
  })
  
  selected_model =  eventReactive(input$legendmouseOver, {
    input$legendmouseOver
  })
  
  output$total_spend <- renderText(
    example_data() |>
      filter(name != "sales") |>
      summarise(value = sum(value)) |>
      mutate(spend_formatted = scales::dollar_format()(value)) |>
      pull(spend_formatted)
  )
  
  output$conversions <- renderText(
    example_data() |>
      filter(name == "sales") |>
      summarise(value = sum(value)) |>
      mutate(spend_formatted = scales::comma_format()(value)) |>
      pull(spend_formatted)
  )
  
  output$roas <- renderText({
    
    total_spend <- example_data() |>
        filter(name != "sales") |>
        summarise(value = sum(value)) |>
        pull(value)
    
    conversions <- example_data() |>
        filter(name == "sales") |>
        summarise(value = sum(value)) |>
        pull(value)
    
    roas <- scales::dollar_format()(total_spend/conversions)
    return(roas)
  })
  
  
  actual_vs_predicted_plot <- reactive({
    
    model = if(values$default == 0){
      "2_237_5"
    }
    else{
      selected_model()
    }
    
    performance_string <- paste0("OutputCollect$allPareto$plotDataCollect$`",model,"`$plot5data$xDecompVecPlotMelted")
    
    performance <- eval(parse_expr(performance_string))
    
    OutputCollect$allPareto$xDecompAgg$train_size[1]
    
    train_size <- round(OutputCollect$allPareto$xDecompAgg$train_size[1],4)
    days <- sort(unique(performance$ds))
    ndays <- length(days)
    train_cut <- round(ndays * train_size)
    val_cut <- train_cut + round(ndays * (1 - train_size)/2)
    
    train_date <- min(performance$ds)+train_cut
    val_date <- min(performance$ds)+val_cut
    
    
    actual_vs_predicted <- performance |>
      hchart(
        "line", 
        hcaes(x = ds, y = value, group = variable),
        animation = list(
          duration = 2000
        )) |>
      hc_colors(c(cool_winter_theme$baby_blue, cool_winter_theme$dark_gray)) |>
      hc_title(
        text = "Actual vs. predicted sales",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_yAxis(
        title = list(text = "sales"),
        labels = list(format = "{value}")
      ) |>
      hc_xAxis(
        type = 'datetime',
        plotLines = list(
          list(
            label = list(text = "test"),
            color = "#CCCCCC",
            width = 4,
            value = datetime_to_timestamp(train_date)
          ),
          list(
            label = list(text = "validation"),
            color = "#CCCCCC",
            width = 4,
            value = datetime_to_timestamp(val_date)
          )
        )
      )
  })
  
  output$actual_vs_predicted <- renderHighchart({actual_vs_predicted_plot()})
  
  effect_contribution <- reactive({
    selected_model = if(values$default == 0){
      "2_237_5"
    }
    else{
      selected_model()
    }
    
    model_data |>
      filter(
        solID == selected_model,
        !is.na(effect_share)
      ) |>
      arrange(desc(xDecompPercRF)) |>
      hchart(
        "bar",
        hcaes(x = as.factor(rn), y = xDecompPercRF),
        color = cool_winter_theme$mid_gray,
        style = list(fontFamily = "Quicksand"),
        animation = list(
          duration = 3000,
          easing = easeOutBounce
        )
      ) |>
      hc_title(
        text = "Channel contribution to sales",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_plotOptions(
        animation = list(
          duration = 2
        )
      ) |>
      hc_yAxis(min = 0) |>
      hc_yAxis(
        labels = list(format = "{value}")
      ) |>
      hc_xAxis(title = list(text = ""))
    }
    )
  
  return_on_adspend <- reactive({
    selected_model = if(values$default == 0){
      "2_237_5"
    }
    else{
      selected_model()
    }
    
    model_data |>
      filter(
        solID == selected_model,
        !is.na(roi_total)
      ) |>
      arrange(desc(roi_total)) |>
      hchart(
        "bar",
        hcaes(x = as.factor(rn), y = roi_total),
        color = cool_winter_theme$forest_green,
        style = list(fontFamily = "Quicksand")#,
        # animation = list(
        #   duration = 3000,
        #   easing = easeOutBounce
        # )
      ) |>
      hc_title(
        text = "Return on Ad Spend",
        margin = 20,
        align = "left",
        style = list(useHTML = TRUE)
      ) |>
      hc_plotOptions(
        animation = list(
          duration = 2
        )
      ) |>
      hc_yAxis(min = 0) |>
      hc_yAxis(
        labels = list(format = "{value}")
      ) |>
      hc_xAxis(title = list(text = ""))
  }
  )
  
  output$second_toggle_plot <- renderHighchart({
    if
    (!input$toggle_roi_vs_contribution)
      return_on_adspend()
    else
      effect_contribution()
  })
  
  observeEvent(input$info_modal, {
    showModal(modalDialog(
      title = "Media Mix Modeling",
      "Robyn is an open source model originally developed by Facebook that uses ridge regression and evolutionary multi-objective optimization to estimate co-effecients for ad-stock decay and diminishing return curves"
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


