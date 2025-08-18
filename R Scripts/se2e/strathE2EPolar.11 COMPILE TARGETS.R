rm(list = ls()) # reset
message("Compiling Targets")

library(MiMeMo.tools) # everything we need

source("./R Scripts/regionFileWG.R")

# read template
targets <- read.csv("./Objects/target/annual_observed_WG_2011-2019.csv")

fishing <- readRDS("./Objects/fishing/Target/Landings_by_guild.RDS")

## LONG WAY, BUT SAFER ##
library(dplyr)

targets <- targets %>%
  mutate(
    Annual_measure = case_when(
      Name == "Obs_Pland_livewt" ~ fishing %>% filter(Guild == "Planktivore") %>% pull(Landings),
      Name == "Obs_Dland_livewt" ~ fishing %>% filter(Guild == "Demersal") %>% pull(Landings),
      Name == "Obs_Mland_livewt" ~ fishing %>% filter(Guild == "Migratory") %>% pull(Landings),
      Name == "Obs_Bsland_livewt" ~ fishing %>% filter(Guild == "Benthos filter/deposit feeder") %>% pull(Landings),
      Name == "Obs_Bcland_livewt" ~ fishing %>% filter(Guild == "Benthos carnivore/scavenge feeder") %>% pull(Landings),
      Name == "Obs_Zcland_livewt" ~ fishing %>% filter(Guild == "Zooplankton carnivore") %>% pull(Landings),
      Name == "Obs_Slland_livewt" ~ fishing %>% filter(Guild == "Pinnipeds") %>% pull(Landings),
      Name == "Obs_Ctland_livewt" ~ fishing %>% filter(Guild == "Cetacean") %>% pull(Landings),
      TRUE ~ Annual_measure
    )
  )

write.csv(targets, file = paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Target/annual_observed_WG_2011-2019.csv"),
          row.names = F)