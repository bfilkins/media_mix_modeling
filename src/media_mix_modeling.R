
# load join, clean data ####


start_date <- min(spend_data$report_date)
end_date <- max(spend_data$report_date)

# create variable array for model input object initialization and parameter range lists
variables <- colnames(
  spend_data %>%
    select(3:ncol(spend_data)))

# Define initial inputs ####

input_initialize <- robyn_inputs(
  dt_input = spend_data,
  dt_holidays = dt_prophet_holidays,
  date_var = "report_date",
  dep_var = "conversions",
  dep_var_type = "conversion",
  prophet_vars = c("trend", "season", "holiday"),
  prophet_country = "US",
  paid_media_spends = variables,
  #paid_media_vars = variables,
  window_start = start_date,
  window_end = end_date,
  adstock = "weibull_pdf"
)

# Define parameter search ranges for inputs ####
# currently reflects default/recommended ranges for weibull pdf
alpha_list_values <- c(.5, 3)
gamma_list_values <- c(.3, 1)
theta_list_values <- c(0, .3)
shapes_list_values <- c(0.5, 2)
scales_list_values <- c(0, .5)

# Create hyper parameter list for all variables
hyperparameters <- list()

for (i in 1:length(variables)){
  hyperparameters[paste0(variables[i],"_alphas")] = list(alpha_list_values)
  hyperparameters[paste0(variables[i],"_gammas")] = list(gamma_list_values)
  hyperparameters[paste0(variables[i],"_shapes")] = list(shapes_list_values)
  hyperparameters[paste0(variables[i],"_scales")] = list(scales_list_values)}

hyperparameters["train_size"] = .6

# Add hyper parameters to input list
InputCollect <- robyn_inputs(InputCollect = input_initialize, hyperparameters = hyperparameters)

# Step 3: Build initial model ####

# Run all trials and iterations.
OutputModels <- robyn_run(
  InputCollect = InputCollect,
  iterations = 200,
  trials = 3,
  ts_validation = TRUE,
  outputs = FALSE
)

# Calculate Pareto optimality, cluster and export results and plots ####
OutputCollect <- robyn_outputs(
  InputCollect = InputCollect,
  OutputModels = OutputModels,
  pareto_fronts = 3,
  #csv_out = "pareto", # "pareto" or "all"
  clusters = FALSE # Set to TRUE to cluster similar models by ROAS.
  #plot_pareto = TRUE, # Set to FALSE to deactivate plotting and saving model one-pagers
  #plot_folder = getwd() # path for plots export
)


sol_ID <- OutputCollect$xDecompAgg %>%
  group_by(solID,nrmse,decomp.rssd) %>%
  summarise()

model_plot <- sol_ID %>%
  ggplot(aes(x= nrmse, y = decomp.rssd, label = solID)) +
  geom_point()

plotly::ggplotly(model_plot)
