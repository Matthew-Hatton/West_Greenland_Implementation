## Various files stay the same between models, but the names of the files don't. Let's change them here.

#### Setup ####

rm(list=ls())                                                                               # Wipe the brain

library(MiMeMo.tools)

#This will throw a warning and FALSE if the file doesn't exist (because it's already been renamed)

## Fishing Fleet
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_fleet_BS_2011-2019.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_fleet_WG_2011-2019.csv")

## Event Timing
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/event_timing_BS_2011-2019.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/event_timing_WG_2011-2019.csv")

## Fishing Processing
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_processing_BS.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_processing_WG.csv")

## Fitted microbiology others
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_microbiology_others_BS.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_microbiology_others_WG.csv")

## Fitted preference matrix
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_preference_matrix_BS.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_preference_matrix_WG.csv")

## Fitted uptake mortality rates
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_uptake_mort_rates_BS.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fitted_uptake_mort_rates_WG.csv")

## Fixed Consumers
file.rename(from = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fixed_consumers_BS_2011-2019.csv",
            to = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fixed_consumers_WG_2011-2019.csv")

## Target
file.rename(from = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Target/monthly_observed_BS_2011-2019.csv",
            to = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Target/monthly_observed_WG_2011-2019.csv")
file.rename(from = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Target/region_harvest_r_BS_2011-2019.csv",
            to = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Target/region_harvest_r_WG_2011-2019.csv")
file.rename(from = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Target/zonal_harvest_r_BS_2011-2019.csv",
            to = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Target/zonal_harvest_r_WG_2011-2019.csv")

