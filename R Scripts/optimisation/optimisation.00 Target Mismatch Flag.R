## Script to flag large mismatch in target and model data.
## Nice to run before running optimisation code
rm(list = ls()) #reset
library(MiMeMo.tools)

# read and run model
model <- e2ep_read("West_Greenland.test",
                   "2011-2019")
results <- e2ep_run(model = model,nyears = 50)

ex <- e2ep_validate_target(model,results)
