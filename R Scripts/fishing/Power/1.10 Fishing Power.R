## Lift fishing powers from Barents Sea model and calculate power for Subsistence fishing

rm(list = ls()) # reset

library(MiMeMo.tools)
source("./R Scripts/fishing/Functions/kg_to_mmNm2.R")
domain <- readRDS("./Objects/domain/domainWG.RDS")
WG_activity <- read.csv("./Objects/fishing/Activity/fishing_activity_WG_2011-2019.csv") %>% 
  filter(Gear_name == "Subsistence") %>% .$Activity_.s.m2.d.

# template
BS_power <- read.csv("./Objects/fishing/Power/fishing_power_BS_2011-2019.csv")

### Calculate Subsistence power (Catch/Activity)
load("./Objects/fishing/Local Data/matty_2019.Rdata") # monthly fishing data - kg of demersal caught and no. of fishers in municipality/district

nielsen_data <- matty_2019 %>% 
  filter(!Municipality %in% c("Avaannata","Sermersooq")) %>% #Avaannata and Sermersooq isn't within my domain, so cut it out
  group_by(Municipality) %>% #don't need seasonal
  summarise(tot_kg_demersal = sum(Kg_demersal),
            tot_fishers = sum(Fishers))
rm(matty_2019)

## kg per meter squared from local data
kg_dem_local <- sum(nielsen_data$tot_kg_demersal/365)/sum(domain$area) 

## convert to mmN/m2
catch <- kg_to_mmNm2(kg_dem_local,"Demersal")

## calculate subsistence power - just for Demersal fish
sub_power <- catch/WG_activity

## Replace Recreational with Subsistence
WG_power <- BS_power %>%
  mutate(
    Gear_name = case_when(
      Gear_name == "Recreational" ~ "Subsistence",
      TRUE ~ Gear_name
    ),
    Gear_code = case_when(
      Gear_code == "Rec" ~ "Sub",
      TRUE ~ Gear_code
    )
  )

WG_power[6,4] <- sub_power ## replace subsistence for Demersal fish

write.csv(WG_power,"./Objects/fishing/Power/fishing_power_WG_2011-2019.csv")

