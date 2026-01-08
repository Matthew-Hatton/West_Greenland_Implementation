## Change Model Setup file to be in line with the new East Greenland files. ##

rm(list = ls()) # Reset
library(tidyverse)
source("./regionFile.R")

# read in current one
model_setup <- read.csv(paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",
                               start_year,"-",end_year,"-",forcing,"-SSP",ssp,"/MODEL_SETUP.csv")) # Load in template

# Physics
model_setup$Filename[2] <- paste0("physics_WG_",start_year,"-",end_year,"-",forcing,"-SSP",ssp,".csv")
model_setup$Comments[2] <- paste0("West Greenland ",start_year,"-",end_year, " Physics data from NEMO-ERSEM.")
# Chemistry
model_setup$Filename[3] <- paste0("chemistry_WG_",start_year,"-",end_year,"-",forcing,"-SSP",ssp,".csv")
model_setup$Comments[3] <- paste0("West Greenland ",start_year,"-",end_year, " Chemistry data from NEMO-ERSEM.")

write.csv(model_setup, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",
                                     start_year,"-",end_year,"-",forcing,"-SSP",ssp,"/MODEL_SETUP.csv"),
          row.names = F)