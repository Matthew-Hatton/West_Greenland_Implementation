## Change Model Setup file to be in line with the new West Greenland files. ##

rm(list = ls()) # Reset
library(tidyverse)

model_setup <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/MODEL_SETUP.csv") # Load in template

## vector template of names to change
vec <- model_setup$Filename

vec_WG <- gsub("BS","WG",vec)

model_setup$Filename <- vec_WG

write.csv(model_setup, file = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/MODEL_SETUP.csv",
          row.names = F)
 ## Will go in and change the Descriptions in Excel, just much cleaner