#### Setup ####

rm(list=ls())                                                                               # Wipe the brain

library(MiMeMo.tools)

# File is already created elsewhere so just copy it into the correct directory

dist <- read.csv("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/Most Recent/Good to go/fishing_distribution_WG_2011-2019.csv")

dist$Gear_name[dist$Gear_name == "Recreational"] <- "Subsistence" #change recreational to subsistence
dist$Gear_code[dist$Gear_code == "Rec"] <- "Sub"                  #and the code

write.csv(dist, file = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_distribution_WG_2011-2019.csv",
          row.names = F)
