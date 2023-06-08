# Load Data 

# arrow::write_parquet(spend_data,"anonymous_data.parquet")
spend_data <- arrow::read_parquet("model.parquet") |>
  mutate(sales = as.numeric(sales))
  #filter(report_date <= date("2022-1-10"))

start_date <- min(spend_data$date)
end_date <- max(spend_data$date)

# pivot and filter 
spend_data_filtered <- spend_data |>
  pivot_longer(cols = 2:7) |> # abstract this
  arrange(date)

# Models 
model_data <- readRDS("pareto_frontier_model_data.rds") 

model_scatter_data <- model_data |>
  filter(robynPareto < 3) |>
  group_by(solID,nrmse,decomp.rssd, cluster, robynPareto) |>
  summarise()


