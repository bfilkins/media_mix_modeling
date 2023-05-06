# box plot for model's output

dat <- grr |>
  group_by(rn) |>
  mutate(agg_prec = sum(xDecompPercRF)) |>
  ungroup() |>
  arrange(desc(agg_prec)) |>
  data_to_boxplot(
    variable = xDecompPercRF,
    group_var = rn
)


highchart() %>%
  hc_xAxis(type = "category") %>%
  hc_add_series_list(dat)





plot <- dat |>
  hcboxplot(x = as.numeric(grr$xDecompPercRF), var = NULL, rn = NULL, outliers = TRUE)
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
plot
