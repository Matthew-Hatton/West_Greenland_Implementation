#### EVENT TIMINGS ####
## Lots of values pulled from literature and will be referred to in the Implementation document ##

rm(list = ls()) # reset
library(MiMeMo.tools) #everything I will need
library(units)

domain <- readRDS("./Objects/domain/domainWG.RDS")

# Read in example event timings
BS_events <- read.csv("./Objects/events/example_BS.csv")

BS_events$Value[BS_events$Description == "Planktivorous_fish_spawning_start_day"] <- 0 # from doi:10.1006/jmsc.2002.123
BS_events$Value[BS_events$Description == "Planktivorous_fish_spawning_duration_(days)"] <- 90 # from doi:10.1006/jmsc.2002.123
BS_events$Value[BS_events$Description == "Planktivorous_fish_recruitment_start_day"] <- 200 # from doi:10.1006/jmsc.2002.123
BS_events$Value[BS_events$Description == "Planktivorous_fish_recruitment_duration_(days)"] <- 150 # from doi:10.1006/jmsc.2002.123

BS_events$Value[BS_events$Description == "Demersal_fish_spawning_start_day"] <- 0 # Boje, J. (2004) “Sexual maturity and spawning of Greenland halibut , R . hippoglossoides , in West Greenlad waters.”
BS_events$Value[BS_events$Description == "Demersal_fish_spawning_duration_(days)"] <- 60 # Boje, J. (2004) “Sexual maturity and spawning of Greenland halibut , R . hippoglossoides , in West Greenlad waters.”
BS_events$Value[BS_events$Description == "Demersal_fish_recruitment_start_day"] <- 152 # Boje, J. (2004) “Sexual maturity and spawning of Greenland halibut , R . hippoglossoides , in West Greenlad waters.”3
BS_events$Value[BS_events$Description == "Demersal_fish_recruitment_duration_(days)"] <- 150 # Boje, J. (2004) “Sexual maturity and spawning of Greenland halibut , R . hippoglossoides , in West Greenlad waters.”

BS_events$Value[BS_events$Description == "Model_domain_sea_surface_area_(km2)"] <- set_units(sum(st_area(domain)),km^2)

BS_events$Value[BS_events$Description == "Migratory_fish_immigration_start_day"] <- 225 #from https://visitgreenland.com/articles/fish/
BS_events$Value[BS_events$Description == "Migratory_fish_immigration_end_day_(must_be_later_than_start_day_even_if_migration_disabled)"] <- 334


###/// Bird Imigration/Emigration - values are backwards here due to patterns in West Greenland \\\###
## From: Mosbech, Anders & Gilchrist, H. & Merkel, Flemming & Sonne, Christian & Flagstad, Annette & Nyegaard, Helene. (2006). Year-round movements of Northern Common Eiders Somateria mollissima borealis breeding in Arctic Canada and West Greenland followed by satellite telemetry. Ardea. 94. 

BS_events$Value[BS_events$Description == "Bird_spring_immigration_start_day"] <- 292
BS_events$Value[BS_events$Description == "Bird_spring_immigration_end_day_(must_be_later_than_start_day_even_if_migration_disabled)"] <- 307
BS_events$Value[BS_events$Description == "Bird_autumn_emigration_start_day"] <- 122
BS_events$Value[BS_events$Description == "Bird_autumn_emigration_end_day_(must_be_later_than_start_day_even_if_migration_disabled)"] <- 149 

BS_events$Value[BS_events$Description == "Cetacean_winter_migration_switch_(0=off_1=on)"] <- 0 #https://visitgreenland.com/articles/whales/
BS_events$Value[BS_events$Description == "Cetacean_propn_of_peak_popn_in_model_domain_which_remains_and_does_not_emigrate_(must_be>0)"] <- 0.2 #https://visitgreenland.com/articles/whales/
BS_events$Value[BS_events$Description == "Cetacean_spring_immigration_start_day"] <- 110 #https://visitgreenland.com/articles/whales/
BS_events$Value[BS_events$Description == "Cetacean_spring_immigration_end_day_(must_be_later_than_start_day_even_if_migration_disabled)"] <- 165 #https://visitgreenland.com/articles/whales/
BS_events$Value[BS_events$Description == "Cetacean_autumn_emigration_start_day"] <- 274 #https://visitgreenland.com/articles/whales/
BS_events$Value[BS_events$Description == "Cetacean_autumn_emigration_end_day_(must_be_later_than_start_day_even_if_migration_disabled)"] <- 335 #https://visitgreenland.com/articles/whales/

write.csv(BS_events,"./Objects/events/event_timing_WG_2011-2019.csv",
          row.names = FALSE)
