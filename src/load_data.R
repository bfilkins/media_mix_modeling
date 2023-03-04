# Load Data 

# arrow::write_parquet(spend_data,"anonymous_data.parquet")
spend_data <- arrow::read_parquet("anonymous_data.parquet") |>
  filter(report_date <= date("2022-1-10"))


# pivot and filter 
spend_data_filtered <- spend_data |>
  pivot_longer(cols = 2:9) |>
  filter(
    name != "conversions",
    name != "tv_spend",
    report_date <= date("2022-1-10")
  )