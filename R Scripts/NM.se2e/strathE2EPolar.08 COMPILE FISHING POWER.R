## Aggregate fishing powers using the fishing functions - This file needs to change to have West Greenland files.

#### Setup ####
rm(list=ls())                                                                               # Wipe the brain
library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

power_template <- read.csv("./Objects/fishing/Power/fishing_power_WG_2011-2019.csv") %>% 
  subset(select = -c(X)) # fix saving mistake

write.csv(power_template, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",start_year,"-",end_year,"/Param/fishing_power_WG_",start_year,"-",end_year,".csv"),
          row.names = F)