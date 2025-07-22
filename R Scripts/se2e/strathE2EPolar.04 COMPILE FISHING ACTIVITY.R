## Overwrite example fishing activity data - This is just moving of a file

#### Setup ####

rm(list=ls())                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/fishing/functions/fishing functions.R")

fishing_activity_path <- read.csv("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/Most Recent/Good to go/fishing_activity_WG_2011-2019.csv")

# Write it to the destination

write.csv(fishing_activity_path,"C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_activity_WG_2011-2019.csv",
          row.names = FALSE)
