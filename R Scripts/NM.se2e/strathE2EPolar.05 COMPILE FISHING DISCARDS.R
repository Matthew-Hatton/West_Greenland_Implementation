#### Setup ####

rm(list=ls())                                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

# File is already created elsewhere so just copy it into the correct directory

disc <- read.csv("./Objects/fishing/Discards/fishing_discards_WG_2011-2019.csv")

write.csv(disc, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_discards_WG_2011-2019.csv"),
          row.names = F)
