# robyn visualizations
sol_ID |>
  filter(!is.na(cluster)) |>
  hchart(
    "scatter", 
    hcaes(x = nrmse, y = decomp.rssd, group = cluster),
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
    labels = list(format = "{value}")
  )


