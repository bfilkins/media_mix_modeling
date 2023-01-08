# Load Data and initial cleaning
# 
# install.packages("arrow")
# 
# scaler <- function(x){
#   x*7
# }
# 
# data_clean <- data_raw |>
#   mutate_if(is.numeric,scaler) |>
#   mutate(
#     youtube_spend = YOUTUBE_RT_SPEND +YOUTUBE_PROSP_SPEND,
#     facebook_spend = FACEBOOK_RT_SPEND+FACEBOOK_PROSP_SPEND,
#     google_display_spend = GDN_RT_SPEND + GDN_PROSP_SPEND,
#     search_spend = Brand_Paid_Search_Spend + NonBrand_Paid_Search_Spend, 
#     partner_spend = Partner_Spend + Affiliate_Spend, 
#     tv_spend = Short_Form_TV_Spend + CTV_Spend,
#     programmatic_spend = Programmatic_Spend,
#     report_date = date + 30) |>
#   select(
#     report_date,conversions, youtube_spend, facebook_spend, google_display_spend,
#     search_spend, partner_spend, tv_spend, programmatic_spend) %>%
#   head(500)
# 
# arrow::write_parquet(data_clean,"anonymous_data.parquet")
spend_data <- arrow::read_parquet("anonymous_data.parquet")
