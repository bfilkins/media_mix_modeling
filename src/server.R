main_trend <- reactive(
nupath_data %>%
  filter(report_date>= date("2022-9-1")) %>%
  group_by(report_date) %>%
  summarise(funds = sum(`Amount Included In Thermometer`)) %>%
  arrange(report_date) %>%
  mutate(
    report_week = floor_date(report_date,"week"), 
    cumulative = cumsum(funds),
    total = sum(funds)
    ) %>%
  group_by(report_week) %>%
  mutate(weekly_contribution = sum(funds)) %>%
  ungroup() %>%
  mutate(
    daily_weighted = weekly_contribution/total/7,
    pacing = cumsum(daily_weighted)) %>%
  hchart(
    input$series_type,
    hcaes(x = report_date, y = !!input$y_measure),
    color = "#9A231D",
    )
)

output$main_trend <- renderHighchart(main_trend())

output$pacing <- renderPlot(pacing)