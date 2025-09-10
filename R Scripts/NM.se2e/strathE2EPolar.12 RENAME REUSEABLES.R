## Various files stay the same between models, but the names of the files don't. Let's change them here.

#### Setup ####

rm(list=ls())                                                                               # Wipe the brain
message("Renaming Reusables")
library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")
#This will throw a warning and FALSE if the file doesn't exist (because it's already been renamed)

## Fishing Fleet
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_fleet_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Param/fishing_fleet_WG_2011-2019.csv"))

## Fishing Processing
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Param/fishing_processing_BS.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_processing_WG.csv"))

## Fixed Consumers
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Param/fixed_consumers_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Param/fixed_consumers_WG_2011-2019.csv"))

## Target
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Target/region_harvest_r_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Target/region_harvest_r_WG_2011-2019.csv"))
file.rename(from = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Target/zonal_harvest_r_BS_2011-2019.csv"),
            to = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/Target/zonal_harvest_r_WG_2011-2019.csv"))

