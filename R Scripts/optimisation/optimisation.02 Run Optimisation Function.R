# rm(list = ls()) # reset

library(StrathE2EPolar)
library(furrr)
library(purrr)
library(future)
future:::ClusterRegistry("stop") # make sure all additional clusters are closed

n_runs <- availableCores() - 2
plan(multisession,workers = n_runs)

parallel_optimise <- function(){
  model <- e2ep_read("West_Greenland.test","2011-2019")
  opt_eco <- e2ep_optimize_eco(model,nyears = 50,n_iter = 3,quiet = F,start_temperature = 1,cooling = 1)
  return(opt_eco)
}

opt_eco <- future_map(1:n_runs, ~ parallel_optimise(),.progress = T)
# saveRDS(opt_eco,"./Objects/Optimisation/WG.1000iterV3_no_fishing_parallel.RDS")
saveRDS(opt_eco,"./Objects/Optimisation/WG.1000ADDITIONALiter.RDS")

future:::ClusterRegistry("stop") # make sure all additional clusters are closed