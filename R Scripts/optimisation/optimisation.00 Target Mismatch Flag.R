## Script to flag large mismatch in target and model data.
## Nice to run before running optimisation code
rm(list = ls()) #reset
library(MiMeMo.tools)

# read and run model
model <- e2ep_read("West_Greenland.test",
                   "2011-2019")
results <- e2ep_run(model = model,nyears = 50)

opt <- results[["final.year.outputs"]][["opt_results"]]

# keep only the targets flagged for use
opt_used <- subset(opt, Use1_0 == 1)

# compute ratio: Model / Observed
opt_used$ratio <- opt_used$Model_data / opt_used$Annual_measure

# flag extreme ratios
extreme_targets <- subset(opt_used, abs(ratio) > 10 | abs(ratio) < 0.1)

# sort
extreme_targets <- extreme_targets[order(-abs(extreme_targets$ratio)), ]

# print
extreme_targets[, c("Name", "Description", "Units", "Annual_measure", "Model_data", "ratio", "Chi")]