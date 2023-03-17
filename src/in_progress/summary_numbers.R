# Big ass numbers
#Total Spend, Total Sales, Spend/ Sales

total_spend <- spend_data |>
  summarise(spend = sum(
    youtube_spend+facebook_spend+
    google_display_spend+search_spend+
    partner_spend +tv_spend +programmatic_spend
    )) |>
  mutate(spend_formatted = scales::dollar_format()(spend)) |>
  pull(spend_formatted)
