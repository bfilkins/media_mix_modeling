
selected_measures <- c("youtube_spend")

spend_data_filtered <- spend_data |>
  pivot_longer(cols = 2:9) |>
  filter(
    name != "conversions",
    name != "tv_spend",
    report_date <= date("2022-1-10")
    )

plot_spend_trends <- spend_data_filtered |>
  hchart("line", hcaes(x = report_date, y = value, group = name)) |>
  hc_title(
     text = "eCommerce company media spend trend",
     margin = 20,
     align = "left",
     style = list(useHTML = TRUE)
   ) |>
   hc_yAxis(
     title = list(text = "spend $"),
     labels = list(format = "{value}")
   )

plot_spend_summary <- spend_data_filtered |>
  group_by(name) |>
  summarise(spend = sum(value)) |>
  arrange(desc(spend)) |>
  hchart("bar", hcaes(x = reorder(as.factor(name), desc(spend)), y = spend)) |>
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


