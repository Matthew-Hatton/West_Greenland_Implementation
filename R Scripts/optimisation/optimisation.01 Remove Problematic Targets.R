rm(list = ls()) # reset

library(StrathE2EPolar)
source("../StrathE2E_Upgrades/StrathE2E_upgrades/R Scripts/Functions/e2ep_validate_targets.R")
# check models exist
e2ep_ls() # all there

# model1 <- e2ep_read("Barents_Sea","2011-2019")
model <- e2ep_read("West_Greenland.test","2011-2019")
results <- e2ep_run(model,nyears = 50)

ex <- e2ep_validate_targets(model,results) # identify then manually remove