#### Setup ####

rm(list=ls())                                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

# File is already created elsewhere so just copy it into the correct directory

dist <- read.csv("./Objects/fishing/Distribution/fishing_distribution_WG_2011-2019.csv") %>% 
  subset(select = -c(X)) # clean saving mistake

dist$Gear_name[dist$Gear_name == "Recreational"] <- "Subsistence" #change recreational to subsistence
dist$Gear_code[dist$Gear_code == "Rec"] <- "Sub"                  #and the code
write.csv(dist, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",start_year,"-",end_year,"/Param/fishing_distribution_WG_",start_year,"-",end_year,".csv"),
          row.names = F)
