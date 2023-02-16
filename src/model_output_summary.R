# consolidate all model output data I dont know if these functions should be nested or not?
# this was f'ing stupid for me to make!!!
structure_robyn_data <- function(OutputModels) {
  pull_parameters <- function(x){
    OutputModels %>%
      pluck(x,1,1)
    }
  
  pull_output <- function(x){
    OutputModels %>%
      pluck(x,1,4)
    }
  
  structured_data <- tibble(iteration = c(1:OutputModels$trials)) %>%
    mutate(
      model_parameters = map(iteration, pull_parameters),
      model_output = map(iteration, pull_parameters)
      )
  return(structured_data)
  }


pareto_data <- OutputCollect$allPareto$xDecompAgg
