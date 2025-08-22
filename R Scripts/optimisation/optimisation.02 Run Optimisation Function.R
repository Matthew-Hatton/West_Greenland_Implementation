rm(list = ls()) # reset

library(StrathE2EPolar)

# check models exist
e2ep_ls() # all there

# model1 <- e2ep_read("Barents_Sea","2011-2019")
model <- e2ep_read("West_Greenland.test","2011-2019")

opt_eco <- e2ep_optimize_eco(model,nyears = 50,n_iter = 1000,quiet = T,start_temperature = 1,cooling = 1)
saveRDS(opt_eco,"./Objects/Optimisation/WG.1000iterTest.RDS")
# opt_fish <- e2ep_optimize_hr(model = model,nyears = 40,n_iter = 50)

new_pref <- opt_eco[["new_parameter_data"]][["new_preference_matrix"]]
new_uptake_mort <- opt_eco[["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
new_microbiology <- opt_eco[["new_parameter_data"]][["new_microbiology_parameters"]]

write.csv(new_pref,"C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_preference_matrix_new.csv")
write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_microbiology_others_new.csv")
