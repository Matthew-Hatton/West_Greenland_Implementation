## Overwrite example fishing activity data - This is just moving of a file

#### Setup ####

rm(list=ls())                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

fishing_activity_path <- read.csv("./Objects/fishing/Activity/fishing_activity_WG_2011-2019.csv")

# Write it to the destination
write.csv(fishing_activity_path,paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",start_year,"-",end_year,"/Param/fishing_activity_WG_",start_year,"-",end_year,".csv"),
          row.names = FALSE)
