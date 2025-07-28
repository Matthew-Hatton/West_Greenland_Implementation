## Run batches of R scripts. Handy if you want scripts to run after another finishes while you're away from the machine
rm(list = ls()) #reset

library(tidyverse)
library(MiMeMo.tools)
library(tictoc)

#### Batch process scripts ####

scripts <- c(                                           # List scripts in the order you want to run them
  # "./R scripts/fishing/Distribution/1.10 Intersect domain with habitat map.R",
  # "./R scripts/fishing/Distribution/1.20 Intersect GFW with sediment types.R",
  # "./R scripts/fishing/Distribution/1.30 Aggregate sediment proportions.R",
  "./R scripts/fishing/Distribution/1.41 Sediment proportion per gear - trawlers.R",
  "./R scripts/fishing/Distribution/1.42 Sediment proportion per gear - set_longlines.R",
  "./R scripts/fishing/Distribution/1.43 Sediment proportion per gear - unclassified.R",
  "./R scripts/fishing/Distribution/1.44 Sediment proportion per gear - other_purse_seines.R",
  "./R scripts/fishing/Distribution/1.45 Sediment proportion per gear - fixed_gear.R",
  "./R scripts/fishing/Distribution/1.46 Sediment proportion per gear - set_gillnets.R",
  # "./R scripts/fishing/Distribution/1.50 Calculate Sediment Proportion.R",
  NULL
) %>% 
  map(MiMeMo.tools::execute)                                                           # Run the scripts

# "./R scripts/fishing/Distribution/1.10 Intersect domain with habitat map.R",# #### Plot run times ####

# timings <- tictoc::tic.log(format = F) %>%                                             # Get the log of timings
#   lapply(function(x) data.frame("Script" = x$msg, Minutes = (x$toc - x$tic)/60)) %>%   # Get a dataframe of scripts and runtimes in minutes
#   bind_rows() %>%                                                                      # Get a single dataframe
#   separate(Script, into = c(NA, "Script"), sep = "/R scripts/") %>%
#   separate(Script, into = c("Type", NA, NA), sep = "[.]", remove = F) %>%
#   mutate(Script = factor(Script, levels = Script[order(rownames(.), decreasing = T)])) # Order the scripts
# saveRDS(timings, "../Recovery Time Manuscript/Objects/Batch Run time.rds")