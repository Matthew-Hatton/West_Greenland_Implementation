## Aggregate fishing powers using the fishing functions - This file needs to change to have West Greenland files.

#### Setup ####
rm(list=ls())                                                                               # Wipe the brain
library(MiMeMo.tools)
source("./Objects/@_Region file.R")
source("./R Scripts/fishing/functions/fishing functions.R")


domains <- readRDS("./Objects/Domains.rds") %>%                                             # Load SF polygons of the MiMeMo model domains
  st_transform(crs = 4326)

power_template <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Param/fishing_power_BS_2011-2019.csv")


activity_vector_WG <- activity(hours_vector,
                            area = sum(domains$area)) # hours_vector gives the hours spent using each gear -- Currently taken from BS model

powers <- relative_power(landings = landings_WG,
                         discards = discards_WG,
                         area = sum(domains$area),
                         activity_vector = activity_vector_WG)

## Higher trohpics in BS, so take from template.
powers$CETACEANS <- power_template$Power_CT
powers$BIRDS <- power_template$Power_BD
powers$PINNIPEDS <- power_template$Power_SL

power_template[,3:12] <- powers

write.csv(power_template, file = "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_power_WG_2011-2019.csv",
          row.names = F)

#Remove old
fn <- "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_power_BS_2011-2019.csv"
#Check its existence
if (file.exists(fn)) {
  #Delete file if it exists
  file.remove(fn)
}