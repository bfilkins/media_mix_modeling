# plot actual vs. precicted
model <- "2_237_5"

performance_string <- paste0("OutputCollect$allPareto$plotDataCollect$`",model,"`$plot5data$xDecompVecPlotMelted")

performance <- eval(parse_expr(performance_string))

OutputCollect$allPareto$xDecompAgg$train_size[1]

OutputCollect$allPareto$plotDataCollect$`5_215_3`$plot5data$xDecompVecPlotMelted

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
      duration = 6000,
      easing = easeOutBounce
    )) |>
  hc_colors(c(
    green_purple_theme$`sgbus-green`, green_purple_theme$avocado, green_purple_theme$`dark-purple`,
    green_purple_theme$gray1, green_purple_theme$yellow, green_purple_theme$blue, green_purple_theme$gray2)) |>
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

actual_vs_predicted

