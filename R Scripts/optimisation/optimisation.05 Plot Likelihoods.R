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
l_18s <- readRDS("./Objects/Optimisation/WG.test.RDS")
likelihoods_18s <- data.frame(Accepted = numeric(),
                          Model = character(),
                          Iteration = numeric(),
                          Marker = character())
for (i in 1:30) {
  tmp <- data.frame(Accepted = l_18s[[i]][["parameter_accepted_history"]][["annual_obj"]],
                    Model = i,
                    Iteration =  1000 + seq(1,3),
                    Marker = "Onward")
  likelihoods_18s <- rbind(likelihoods_18s,tmp)
}

lks <- rbind(likelihoods %>% filter(Model == 18),likelihoods_18s)
plt2 <- ggplot() +
  geom_line(data = lks,aes(x = Iteration,y = Accepted,color = as.character(Marker)),linewidth = 0.1) +
  # ggrepel::geom_label_repel(data = subset(likelihoods, Iteration == 1000), 
  # aes(x = Iteration, y = Accepted, label = Model),max.overlaps = 100) +
  labs(color = "") +
  NULL
ggsave(plot = plt2,"./Figures/Optimisation/Attempt 4/TrajectoriesV2.png")
