## Change Model Setup file to be in line with the new West Greenland files. ##

rm(list = ls()) # Reset
library(tidyverse)
source("./R Scripts/regionFileWG.R")

model_setup <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/MODEL_SETUP.csv") # Load in template

## use fit from NE.CNRM.ssp126
model_setup$Filename[8] <- "fitted_preference_matrix_new.csv"
model_setup$Filename[9] <- "fitted_uptake_mort_rates_new.csv"
model_setup$Filename[10] <- "fitted_microbiology_others_new.csv"

## vector template of names to change
vec <- model_setup$Filename

vec_WG <- gsub("BS","WG",vec)

model_setup$Filename <- vec_WG

write.csv(model_setup, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/MODEL_SETUP.csv"),
          row.names = F)