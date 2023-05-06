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



plot_spend_summary <- spend_data_filtered |>
    filter(name != "conversions") |>
    group_by(name) |>
    summarise(spend = sum(value)) |>
    arrange(desc(spend)) |>
    hchart(
      "bar", 
      hcaes(x = reorder(as.factor(name), desc(spend)), y = spend), 
      color = green_purple_theme$`sgbus-green`,
      animation = list(
        duration = 3000,
        easing = easeOutBounce
      )) |>
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

plot_spend_summary
  