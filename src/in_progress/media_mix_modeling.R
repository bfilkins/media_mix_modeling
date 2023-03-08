 
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
  window_start = start_date,
  window_end = end_date,
  adstock = "geometric"
)

# Define parameter search ranges for inputs ####
# use recommended ranges for geometric adstock decay
alpha_list_values <- c(.5, 3)
gamma_list_values <- c(.3, 1)
theta_list_values <- c(0, 0.3)
shapes_list_values <- c(0.5, 2)
scales_list_values <- c(0, .5)

# Create hyper parameter list for all variables
# parameters for alternate adstock commented 
hyperparameters <- list()

for (i in 1:length(variables)){
  hyperparameters[paste0(variables[i],"_alphas")] = list(alpha_list_values)
  hyperparameters[paste0(variables[i],"_gammas")] = list(gamma_list_values)
  hyperparameters[paste0(variables[i],"_thetas")] = list(theta_list_values)
  #hyperparameters[paste0(variables[i],"_shapes")] = list(shapes_list_values)
  #hyperparameters[paste0(variables[i],"_scales")] = list(scales_list_values)
  }

hyperparameters["train_size"] = c(0.5)

# Add hyper parameters to input list
InputCollect <- robyn_inputs(InputCollect = input_initialize, hyperparameters = hyperparameters)

# # Step 3: Build initial model ####
# 
# # Run all trials and iterations.
OutputModels <- robyn_run(
  InputCollect = InputCollect, # feed in all model specification
  cores = NULL, # NULL defaults to max available - 1
  iterations = 1000, # 2000 recommended for the dummy dataset with no calibration
  trials = 5, # 5 recommended for the dummy dataset
  ts_validation = TRUE, # 3-way-split time series for NRMSE validation.
  add_penalty_factor = FALSE, # Experimental feature. Use with caution.
) # is there a minumum for iterations or trials? YES the next function will fail when it tries to cluster UGGGHHHH
# # no I still don't understand this!!!

# just load this to trouble shoot below
# saved_run <- write_rds(OutputModels, "output_models.rds")
# OutputModels <- read_rds("output_models.rds")


robyn_object <- getwd()
# Calculate Pareto optimality, cluster and export results and plots ####
OutputCollect <- robyn_outputs(
  InputCollect = InputCollect, 
  OutputModels = OutputModels, 
  pareto_fronts = 7,
  #csv_out = "all", # "pareto" or "all"
  #plot_folder = robyn_object,
  clusters = TRUE, # Set to TRUE to cluster similar models by ROAS. See ?robyn_clusters
  plot_pareto = FALSE # Set to FALSE to deactivate plotting and saving model one-pagers, 
)

pareto_frontier_model_data <- OutputCollect$xDecompAgg

#write_rds(pareto_frontier_model_data, "pareto_frontier_model_data.rds")
