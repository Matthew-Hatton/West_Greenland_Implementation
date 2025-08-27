## Does parallel processing slow down StrathE2E runs?

rm(list = ls())

library(tictoc)
library(StrathE2EPolar)
library(furrr)
library(future)
future:::ClusterRegistry("stop") # make sure all additional clusters are closed

n_runs <- availableCores()
plan(multisession,workers = n_runs,gc = T)
model_path <- "C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test"

my_func <- function(){
  model <- e2ep_read("West_Greenland.test",
                     "2011-2019")
  res_parallel <- e2ep_run(model = model, nyears = 20)
  return(res_parallel)
}

time1 <- system.time({
  res_parallel <- future_map(n_runs, ~my_func())
})

time2 <- system.time({
  model <- e2ep_read("West_Greenland.test",
                     "2011-2019")
  res_singular <- e2ep_run(model = model,nyears = 20)
})

print(time1) # parallel
print(time2) # singular

future:::ClusterRegistry("stop") # make sure all additional clusters are closed