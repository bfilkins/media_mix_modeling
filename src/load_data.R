# Load Data 

#arrow::write_parquet(spend_data,"anonymous_data.parquet")
spend_data <- arrow::read_parquet("anonymous_data.parquet")
