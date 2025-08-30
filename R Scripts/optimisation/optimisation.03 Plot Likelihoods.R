# rm(list = ls())
library(MiMeMo.tools)

opt_eco <- readRDS("./Objects/Optimisation/WG.1000iterV3_no_fishing_parallel.RDS")

likelihoods <- data.frame(Accepted = numeric(),
                          Model = character(),
                          Iteration = numeric(),
                          Marker = character())
for (i in 1:30) {
  tmp <- data.frame(Accepted = opt_eco[[i]][["parameter_accepted_history"]][["annual_obj"]],
                    Model = i,
                    Iteration = seq(1,1000),
                    Marker = "Initial")
  likelihoods <- rbind(likelihoods,tmp)
}

plt <- ggplot() +
  geom_line(data = likelihoods,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
  # ggrepel::geom_label_repel(data = subset(likelihoods, Iteration == 1000), 
                            # aes(x = Iteration, y = Accepted, label = Model),max.overlaps = 100) +
  NULL
ggsave(plot = plt,"./Figures/Optimisation/Attempt 4/Trajectories.png")

## Model 18 is the one that seems to be leading somewhere, so let's write those parameter files
# new_pref <- opt_eco[[18]][["new_parameter_data"]][["new_preference_matrix"]]
# new_uptake_mort <- opt_eco[[18]][["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
# new_microbiology <- opt_eco[[18]][["new_parameter_data"]][["new_microbiology_parameters"]]
# 
# write.csv(new_pref,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_preference_matrix_new.csv")
# write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
# write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_microbiology_others_new.csv")

## Add Model 18 in
l_18s <- readRDS("./Objects/Optimisation/WG.1000ADDITIONALiter.RDS")
likelihoods_18s <- data.frame(Accepted = numeric(),
                          Model = character(),
                          Iteration = numeric(),
                          Marker = character())
for (i in 1:30) {
  tmp <- data.frame(Accepted = l_18s[[i]][["parameter_accepted_history"]][["annual_obj"]],
                    Model = i,
                    Iteration =  1000 + seq(1,500),
                    Marker = "Onward")
  likelihoods_18s <- rbind(likelihoods_18s,tmp)
}

lks_2 <- rbind(likelihoods %>% filter(Model == 18),likelihoods_18s)
plt2 <- ggplot() +
  geom_line(data = lks_2,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
  # ggrepel::geom_label_repel(data = subset(likelihoods, Iteration == 1000), 
  # aes(x = Iteration, y = Accepted, label = Model),max.overlaps = 100) +
  labs(color = "") +
  geom_vline(xintercept = 1000,linewidth = 0.1,linetype = "dashed") +
  NULL
ggsave(plot = plt2,"./Figures/Optimisation/Attempt 4/TrajectoriesV2.png")

##lets look at model 22:
# new_pref <- l_18s[[22]][["new_parameter_data"]][["new_preference_matrix"]]
# new_uptake_mort <- l_18s[[22]][["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
# new_microbiology <- l_18s[[22]][["new_parameter_data"]][["new_microbiology_parameters"]]
# # 
# write.csv(new_pref,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_preference_matrix_new.csv")
# write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
# write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_microbiology_others_new.csv")

## Add Model 22 in
l_V3 <- readRDS("./Objects/Optimisation/WG.500ADDITIONALV2iter.RDS")
likelihoods_22s <- data.frame(Accepted = numeric(),
                          Model = character(),
                          Iteration = numeric(),
                          Marker = character())
for (i in 1:30) {
  tmp <- data.frame(Accepted = l_V3[[i]][["parameter_accepted_history"]][["annual_obj"]],
                    Model = i,
                    Iteration =  1500 + seq(1,500),
                    Marker = "Third")
  likelihoods_22s <- rbind(likelihoods_22s,tmp)
}

lks_prev <- rbind(likelihoods,likelihoods_18s)

plt2 <- ggplot() +
  geom_line(data = lks_prev,
            aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
  geom_line(data = likelihoods_22s,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
  labs(color = "") +
  geom_vline(xintercept = 1000,linewidth = 0.2,linetype = "dashed") +
  geom_vline(xintercept = 1500,linewidth = 0.2,linetype = "dashed") +
  NULL
ggsave(plot = plt2,"./Figures/Optimisation/Attempt 4/TrajectoriesV3ALL.png")

message(paste0("The highest likelihood was in Model: ", (likelihoods_22s %>% filter(Iteration == 2000) %>% arrange(-Accepted))$Model[1]))

# # ##lets look at model 28:
# new_pref <- l_V3[[28]][["new_parameter_data"]][["new_preference_matrix"]]
# new_uptake_mort <- l_V3[[28]][["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
# new_microbiology <- l_V3[[28]][["new_parameter_data"]][["new_microbiology_parameters"]]
# #
# write.csv(new_pref,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_preference_matrix_new.csv")
# write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
# write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_microbiology_others_new.csv")

## Add Model 28 in
l_V4 <- readRDS("./Objects/Optimisation/WG.500ADDITIONALV4iter.RDS")
likelihoods_28s <- data.frame(Accepted = numeric(),
                              Model = character(),
                              Iteration = numeric(),
                              Marker = character())
for (i in 1:30) {
  tmp <- data.frame(Accepted = l_V4[[i]][["parameter_accepted_history"]][["annual_obj"]],
                    Model = i,
                    Iteration =  2000 + seq(1,500),
                    Marker = "Fourth")
  likelihoods_28s <- rbind(likelihoods_28s,tmp)
}

lks_prev <- rbind(likelihoods,likelihoods_18s,likelihoods_22s)

plt3 <- ggplot() +
  geom_line(data = lks_prev,
            aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
  geom_line(data = likelihoods_28s,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
  labs(color = "") +
  geom_vline(xintercept = 1000,linewidth = 0.2,linetype = "dashed") +
  geom_vline(xintercept = 1500,linewidth = 0.2,linetype = "dashed") +
  geom_vline(xintercept = 1500,linewidth = 0.2,linetype = "dashed") +
  NULL
ggsave(plot = plt3,"./Figures/Optimisation/Attempt 4/TrajectoriesV4ALL.png")

message(paste0("The highest likelihood was in Model: ", (likelihoods_28s %>% filter(Iteration == 2500) %>% arrange(-Accepted))$Model[1]))

# ##lets look at model 22 (for the second time):
new_pref <- l_V4[[22]][["new_parameter_data"]][["new_preference_matrix"]]
new_uptake_mort <- l_V4[[22]][["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
new_microbiology <- l_V4[[22]][["new_parameter_data"]][["new_microbiology_parameters"]]
#
write.csv(new_pref,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_preference_matrix_new.csv")
write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_microbiology_others_new.csv")
