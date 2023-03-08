
# define data functions

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

