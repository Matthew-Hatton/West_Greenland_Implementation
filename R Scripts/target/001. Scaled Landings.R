## Script which will take the RAW landings from the Barents Sea implementation, scale them, 
## and sum them to calculate (along with subsistence data) the landings required for the target data.

rm(list = ls())

library(MiMeMo.tools)

## Landings for all of BS - need to scale as a ratio of activities
landings_raw <- readRDS("./Objects/fishing/Landings Catch Discards/BS_landings.RDS")
landings <- landings_raw * 1e6 / 360 # Convert landings to g/m2/day

### Rearrange
desired_row_order <- c(
  "Pelagic","Trawls","Seines","Gillnets","Longlines_and_Jigging",
  "Shrimp trawl", "Pots","Dredging","Harpoons", "Rifles", "Kelp harvesting",
  "Recreational"
) 

desired_col_order <- c(
  "Planktivore",
  "Demersal",                   # Combined column
  "Migratory",
  "Benthos filter/deposit feeder",
  "Benthos carnivore/scavenge feeder",
  "Zooplankton carnivore",
  "Birds",
  "Pinnipeds",
  "Cetacean",
  "Macrophyte"
)

landings_agg <- landings %>%
  as.data.frame() %>%
  mutate(Demersal = `Demersal (non quota)` + `Demersal (quota limited)`) %>%
  select(-`Demersal (non quota)`, -`Demersal (quota limited)`, -`Zooplankton omnivorous`) %>%
  .[desired_row_order, desired_col_order] %>% 
  .[!(row.names(.) %in% c("Recreational")),]

### Scale
#Table of nitrogen per unit wet weight - from Table 18 of SE2E North Sea implementation
mMNpergWW <- c(PF = 2.038, DF = 1.340, MF = 2.314, FDB = 0.503,
               CSB = 1.006, CZ = 1.258, BD = 2.518, SL = 2.518, 
               CT = 2.518, KP = 2.070)

WG_activity <- read.csv("./Objects/fishing/Activity/fishing_activity_WG_2011-2019.csv") %>% 
  filter(!Gear_name %in% "Subsistence") %>% 
  .$Activity_.s.m2.d.

BS_activity <- read.csv("./Objects/fishing/Activity/fishing_activity_BS_2011-2019.csv") %>% 
  filter(!Gear_name %in% "Recreational") %>% 
  .$Activity_.s.m2.d.

## Ratio of activities
activity <- WG_activity/BS_activity
activity[is.nan(activity)] <- 0

for (i in seq(1,nrow(landings_agg))) {
  landings_agg[i,] <- landings_agg[i,] * activity[i]
}

landings_agg_N <- (colSums(landings_agg)) * 360 * mMNpergWW ## sum of landings for each guild in BS

target_landings <- data.frame(Guild = desired_col_order,
                              Landings = landings_agg_N)
row.names(target_landings) <- NULL

### Add in Subsistence landings
local_data <- readRDS("./Objects/fishing/Local Data/Local data.RDS") # loads local landings

target_landings$Landings[target_landings$Guild == "Demersal"] <- 
  target_landings$Landings[target_landings$Guild == "Demersal"] + local_data


### Save out
saveRDS(target_landings,"./Objects/fishing/Target/Landings_by_guild.RDS")
