rm(list = ls()) # reset

library(StrathE2EPolar)
# check models exist
e2ep_ls() # all there

# model1 <- e2ep_read("Barents_Sea","2011-2019")
model <- e2ep_read("West_Greenland.test","2011-2019")
# model <- e2ep_read("West_Greenland.CNRM.ssp126","2011-2019")
res <- e2ep_run(model = model,nyears = 50)
start <- e2ep_extract_start(model,res)
# input new start
init_con <- e2ep_extract_start(model = model,results = res,
                               csv.output = F)
model[["data"]][["initial.state"]][1:nrow(init_con)] <- e2ep_extract_start(model = model,results = res,
                                                                           csv.output = F)[,1]

opt_eco <- e2ep_optimize_eco(model,nyears = 3,n_iter = 5,start_temperature = 0.01,quiet = T)
# opt_fish <- e2ep_optimize_hr(model = model,nyears = 40,n_iter = 50)


# Assuming your model results are in 'res'
opt <- res[["final.year.outputs"]][["opt_results"]]

# Keep only the targets flagged for use
opt_used <- subset(opt, Use1_0 == 1)

# Calculate each chi^2 (should match the "Chi" column)
opt_used$chi_calc <- ((opt_used$Model_data - opt_used$Annual_measure) /
                        opt_used$SD_of_measure)^2

# Total Chi^2
chi_total <- sum(opt_used$chi_calc, na.rm = TRUE)

# Log-likelihood (up to an additive constant)
logL <- -0.5 * chi_total

chi_total
logL
exp(logL)

## flag large mismatch
opt <- res[["final.year.outputs"]][["opt_results"]]

# Keep only the targets flagged for use
opt_used <- subset(opt, Use1_0 == 1)

# Compute ratio: Model / Observed
opt_used$ratio <- opt_used$Model_data / opt_used$Annual_measure

# Flag extreme ratios (10x larger or smaller than observation)
extreme_targets <- subset(opt_used, abs(ratio) > 10 | abs(ratio) < 0.1)

# Sort by absolute ratio descending
extreme_targets <- extreme_targets[order(-abs(extreme_targets$ratio)), ]

# Print key info
extreme_targets[, c("Name", "Description", "Units", "Annual_measure", "Model_data", "ratio", "Chi")]


opt_used$ratio <- opt_used$Model_data / opt_used$Annual_measure
opt_used[order(-opt_used$ratio), c("Name", "Model_data", "Annual_measure", "Units", "ratio")]





















# 
# library(StrathE2E2)
# model_NS <- e2e_read("North_Sea",
#                      "2003-2013")
# # add 3 degC to upper layer offshore temperatures:
# model_NS$data$physics.drivers$so_temp <- model_NS$data$physics.drivers$so_temp+3
# # add 3 degC to inshore temperatures:
# model_NS$data$physics.drivers$si_temp <- model_NS$data$physics.drivers$si_temp+3
# # add 3 degC to lower layer offshore temperatures:
# model_NS$data$physics.drivers$d_temp  <- model_NS$data$physics.drivers$d_temp+3
# opt_eco_NS <- e2e_optimize_eco(model_NS,nyears = 3,n_iter = 10)
