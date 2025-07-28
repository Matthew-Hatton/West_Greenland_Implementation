## WEST GREENLAND ONLY - Subsistence fishing data provided by Martin Reinhardt Nielsen and Greenland Statistics ##

rm(list = ls()) #reset
library(MiMeMo.tools)

## LOAD
load("./Objects/fishing/Local Data/matty_2019.Rdata") # monthly fishing data - kg of demersal caught and no. of fishers in municipality/district
domain <- readRDS("./Objects/domain/domainWG.rds") #load domain

#Avaannata and Sermersooq isn't within my domain, so cut it out
nielsen_data <- matty_2019 %>% 
  filter(Municipality != "Avaannata") %>% 
  filter(Municipality != "Sermersooq") %>% 
  group_by(Municipality) %>% #don't need seasonal
  summarise(tot_kg_demersal = sum(Kg_demersal),
            tot_fishers = sum(Fishers))

rec_bs_bio <- 0.3233/365 #from the barents sea model. given in mMN/m2/y so needs conversion
nit_mass <- 14.01 #molar mass of nitrogen is approx 14.01g
rec_bs_bio <- (rec_bs_bio*nit_mass)/(1000*1000) #gives biomass per meter squared for barents sea per day (of recreational fishing)
rec_bs_act <- 0.000007423365 #recreational fishing activity from BS model

## now get demersal kg per meter squared from local data
kg_dem_local <- sum(nielsen_data$tot_kg_demersal/365)/sum(domain$area)

#now for the scaling
R_WG <- rec_bs_act*(kg_dem_local/rec_bs_bio)
R_WG #this should be our value for recreational fishing in West Greenland

subsistence <- data.frame(Gear_name = "Subsistence",
                          Gear_code = "Sub",
                          Activity_.s.m2.d. = R_WG,
                          Plough_rate_.m2.s. = 0) # for now...

write.csv(subsistence,"./Objects/fishing/Local Data/Subsistence.csv",
          row.names = FALSE)

