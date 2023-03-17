# Load Data 

# arrow::write_parquet(spend_data,"anonymous_data.parquet")
spend_data <- arrow::read_parquet("example_data.parquet") |>
  filter(report_date <= date("2022-1-10"))


# pivot and filter 
spend_data_filtered <- spend_data |>
  pivot_longer(cols = 2:9)

# Models 
model_data <- readRDS("pareto_frontier_model_data.rds") 

model_scatter_data <- model_data |>
  filter(robynPareto < 3) |>
  group_by(solID,nrmse,decomp.rssd, cluster, robynPareto) |>
  summarise()


