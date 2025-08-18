## Run batches of R scripts to build StrathE2EPolar West Greenland model
rm(list = ls()) #reset

library(tidyverse)
library(MiMeMo.tools)
library(tictoc)

source("./R Scripts/regionFileWG.R")

#### Batch process scripts ####
scripts <- list.files("./R Scripts/se2e/",full.names = T)[2:length(scripts)] %>% # all except first (this one)
  map(MiMeMo.tools::execute)                                                           # Run the scripts