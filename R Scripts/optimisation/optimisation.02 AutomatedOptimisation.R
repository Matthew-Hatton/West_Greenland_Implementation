rm(list = ls()) # reset

library(StrathE2EPolar)
library(furrr)
library(purrr)
library(future)
library(tictoc)
library(tidyverse)

future:::ClusterRegistry("stop") # make sure all additional clusters are closed

tic()
## Initialise ##
n_runs <- availableCores() - 2
n_iter <- 300
rounds <- seq(1,2)
n_years <- 40
## ########## ##


plan(multisession,workers = n_runs)

parallel_optimise <- function(n_iter,n_years){
  model <- e2ep_read("West_Greenland","2011-2019")
  opt_eco <- e2ep_optimize_eco(model,nyears = n_years,n_iter = n_iter,quiet = T,start_temperature = 1,cooling = 1)
  return(opt_eco)
}

likelihoods <- list()

message(paste0("ETC: ",round((n_iter * n_years * length(rounds))/1800,digits = 1), " Hours.\n",round((n_iter * n_years * length(rounds))/(1800*24),digits = 1)," Days.")) ## 2.17s per optimisation year per iteration

for (round in rounds) {
  # debug
  # round = 2
  message(paste0("Round: ",round))
  opt_eco <- future_map(1:n_runs, ~ parallel_optimise(n_iter,n_years),.progress = F, .options = furrr_options(seed = TRUE)) # run parallel optimise
  saveRDS(opt_eco,paste0("./Objects/Optimisation/NM/AutoOptimise/WG.NM.round.",round,".RDS")) # save it out (incase we need it again)
  
  ## initialise data storage
  likelihood <- data.frame(Accepted = numeric(),
                            Model = character(),
                            Iteration = numeric(),
                            Round = character())
  
  for (i in 1:n_runs) { # build up current likelihoods df
    tmp <- data.frame(Accepted = opt_eco[[i]][["parameter_accepted_history"]][["annual_obj"]],
                      Model = i,
                      Iteration = seq(1,round*n_iter),
                      Round = round)
    likelihood <- rbind(likelihood,tmp)
  }
  
  likelihoods <- append(likelihoods,list(likelihood))
  
  if (round != 1) { #store the previous results
    lks_prev <- likelihoods[round] %>% 
      as.data.frame()
    plt <- ggplot() +
      geom_line(data = lks_prev,
                aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
      geom_line(data = likelihood,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
      NULL
    ggsave(plot = plt,paste0("./Figures/optimisation/NM/Trajectories.Round.",round,".png"),width = 1920,height = 1080,units = "px")
  } else{
    plt <- ggplot() +
      geom_line(data = likelihood,aes(x = Iteration,y = Accepted,group = Model),linewidth = 0.1) +
      NULL
    ggsave(plot = plt,paste0("./Figures/optimisation/NM/Trajectories.Round.",round,".png"),width = 1920,height = 1080,units = "px")
  }
  
  

  largest <- likelihood %>% filter(Iteration == (round * n_iter)) %>% arrange(-Accepted) %>% slice(1) %>% .$Model
  
  ## Save the new values
  new_pref <- opt_eco[[largest]][["new_parameter_data"]][["new_preference_matrix"]]
  new_uptake_mort <- opt_eco[[largest]][["new_parameter_data"]][["new_uptake_mort_rate_parameters"]]
  new_microbiology <- opt_eco[[28]][["new_parameter_data"]][["new_microbiology_parameters"]]

  write.csv(new_pref,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_preference_matrix_new.csv")
  write.csv(new_uptake_mort,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
  write.csv(new_microbiology,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_microbiology_others_new.csv")
  
}

future:::ClusterRegistry("stop") # make sure all additional clusters are closed
toc()

