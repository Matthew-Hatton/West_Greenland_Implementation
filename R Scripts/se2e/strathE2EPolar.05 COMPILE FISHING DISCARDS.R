## Overwrite example fishing discards data

#### Setup ####

rm(list=ls())                                                                               # Wipe the brain

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

domains <- readRDS("./Objects/domain/domainWG.rds") %>%                                             # Load SF polygons of the MiMeMo model domains
  st_transform(crs = 4326)

                                                                                            # Read in example activity template
discards_template <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Param/fishing_discards_BS_2011-2019.csv")

BS_discards <- data.frame(
  PLANKTIVOROUS = c(0.002940862, 0.000117639, 0, 0, 0, 0.125586035, 1.29661e-05, 0.422012971, 0.379740296, 0.056057846, 0, 0),
  DEMERSAL = c(0.111955218, 0.53772272, 0.004905382, 0.544527877, 0, 0.47386451, 0.027499596, 0.970253908, 0.684241519, 0.008395374, 0.47689113, 0),
  MIGRATORY = c(0.052261365, 0.008721464, 0, 0.670642427, 0, 0.769790851, 0.231375133, 0.365643786, 0.439291664, 0.000584674, 0, 0),
  BENTH_FD = c(0, 0.000409807, 0, 0.013789586, 0, 0.021689801, 0.000488107, 0, 0, 0, 0.005634317, 0),
  BENTH_CS = c(0, 0.172539844, 2.20768e-05, 0.149863968, 0, 0.312558954, 0.49755816, 0.576040185, 0.06020828, 1.77197e-06, 0, 0),
  ZOO_CARN = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  BIRDS = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  PINNIPEDS = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  CETACEANS = c(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
  MACROPHYTES = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
)

BS_discards$DEMERSAL <- 0                                                                   # Demersal discards banned

landings <- data.frame(
  PLANKTIVOROUS = c(349609.761, 358201.8196, 1.713424511, 1.159933629, 0, 1338.310959, 172.8939334, 151.8290908, 5.809130803, 0.73954042, 31.93334073, 0),
  DEMERSAL = c(237.2490461, 571.0016293, 11.42784419, 58238.5794, 25.17682339, 121323.2873, 9176.992184, 268.8695873, 12004.87937, 65.84756175, 10.76285707, 0),
  MIGRATORY = c(185310.9876, 13462.09336, 1037.514481, 50.99165509, 15.71248546, 3911.584154, 28.46007309, 13.76215871, 132.6221401, 79.92412067, 1.968655769, 0),
  BENTH_FD = c(0, 0.900912731, 0.02, 2.930921997, 0, 7.165526687, 1.700909753, 0.029090909, 0.96182116, 8.353653903, 4314.172526, 0),
  BENTH_CS = c(1.04825454, 485.3469732, 7.666147702, 687.1933123, 0.047361136, 1874.581095, 49.64174464, 27123.70919, 16706.21997, 7276.790564, 3.271545488, 0),
  ZOO_CARN = c(0, 0, 0, 0, 0, 0, 0, 0, 1.22e-05, 0, 0, 0),
  BIRDS = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  PINNIPEDS = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  CETACEANS = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 67),
  MACROPHYTES = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
)                                                                                           # Values in tonnes, averaged over years from ICES
                                                                                            # Fix CETACEAN DISCARDS (was returning NaN for an unknown reason)

discards_template[, 3:ncol(discards_template)] <- BS_discards

discards_template$Discardrate_CT <- 0                                                       # Cannot discard cetaceans in WG (reference)

discards_template$Gear_name[discards_template$Gear_name == "Recreational"] <- "Subsistence" #change recreational to subsistence
discards_template$Gear_code[discards_template$Gear_code == "Rec"] <- "Sub"                  #and the code

write.csv(discards_template, file = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/fishing_discards_WG_2011-2019.csv"),
          row.names = F)

