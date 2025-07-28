## Script to aggregate previously extracted GFW data into Inshore/Offshore.

rm(list=ls()) #reset
library(tidyverse)
library(furrr)
library(sf)
library(dplyr)
plan(multisession,workers = availableCores()-1)
sf_use_s2(FALSE) #turn off spherical geometry

#specify year
years <- seq(2012,2019)
model <- "WestGreenland"

if(model == "WestGreenland"){
  message("Loaded West Greenland")
  Domain <- readRDS("./Objects/domain/domainWG.rds") #load domain
} else if(model == "BarentsSea"){
  message("Loaded Barents Sea")
  Domain <- readRDS("./Objects/domain/domainBS.rds") %>% #load domain
    st_transform(crs = 4326) # Barents Sea in 3035
} else{
  stop("\nPlease enter valid model.\nOptions:\nWestGreenland\nBarentsSea")
}
Domain$Shore <- c("Inshore","Offshore") #adds inshore offshore column if not already present

## initialise
master <- data.frame(geartype = character(0),domain = character(0),total_fishing_hours = numeric(0))

for (year in years) {

  message(paste0(year,"...\n"))
  all_data <- read.csv(paste0("./Objects/fishing/GlobalFishingWatch/",model,"/001. rough crop/GFW_",year,".csv")) #read in data
  
  ### Aggregation ###
  data_sf <- st_as_sf(all_data,coords = c("cell_ll_lon","cell_ll_lat")) #convert to sf
  st_crs(data_sf) <- st_crs(Domain) #match crs
  data_sf$Inshore <- st_intersects(data_sf$geometry, Domain$geometry[[1]]) #check if in inshore
  data_sf$Offshore <- st_intersects(data_sf$geometry, Domain$geometry[[2]]) #check if in offshore
  
  #reset funky list 0s
  data_sf$Inshore[sapply(data_sf$Inshore, length) == 0] <- 0
  data_sf$Offshore[sapply(data_sf$Offshore,length) == 0] <- 0
  data_sf$domain <- NA #initialise domain checker
  #checks which zone
  data_sf <- data_sf %>%
    mutate(
      Inshore = as.numeric(Inshore),
      Offshore = as.numeric(Offshore),
      domain = case_when(
        Inshore == 1 ~ "Inshore",
        Offshore == 1 ~ "Offshore",
        TRUE ~ "Outside"
      )
    )
  data_sf <- data_sf[!data_sf$domain == "Outside",] #remove outside domain values
  
  aggregate <- data_sf %>%
    group_by(geartype,domain) %>%
    summarise(total_fishing_hours = sum(fishing_hours)/365) #aggregates data (per day)
  
  #aggregate_wholedomain <- aggregate #make copy (for plot)
  
  #split
  aggregate_in <- aggregate[aggregate$domain == "Inshore",] #filters to Inshore zone
  aggregate_in$total_fishing_hours <- (aggregate_in$total_fishing_hours/Domain$area[1])*3600 #divides by total area of Inshore zone and mult by seconds in hour
  
  aggregate_off <- aggregate[aggregate$domain == "Offshore",] #filters to Offshore zone
  aggregate_off$total_fishing_hours <- (aggregate_off$total_fishing_hours/Domain$area[2])*3600 #divides by total area of Offshore zone and mult by seconds in hour
  
  aggregate <- rbind(aggregate_in,aggregate_off) #bind back together
  
  #the next line requires a restart for some odd reason
  aggregate <- aggregate %>% st_drop_geometry() #drop geometry column for write
  
  master <- rbind(master,aggregate)
}

### Aggregate into closer approximations ###
# filter individual gears + sum
fishing <- filter(master,master$geartype == "fishing")
fishing_total <- sum(fishing$total_fishing_hours)/8 #/8 because 8 years (2012-2019)

set_longlines <- filter(master,master$geartype == "set_longlines")
set_longlines_total <- sum(set_longlines$total_fishing_hours)/8

trawlers <- filter(master,master$geartype == "trawlers")
trawlers_total <- sum(trawlers$total_fishing_hours)/8

other_purse_seines <- filter(master,master$geartype == "other_purse_seines")
other_purse_seines_total <- sum(other_purse_seines$total_fishing_hours)/8

fixed_gear <- filter(master,master$geartype == "fixed_gear")
fixed_gear_total <- sum(fixed_gear$total_fishing_hours)/8

set_gillnets <- filter(master,master$geartype == "set_gillnets")
set_gillnets_total <- sum(set_gillnets$total_fishing_hours)/8

fishing_activity <- data.frame(gear = c("fishing","set_longlines","trawlers","other_purse_seines","fixed_gear","set_gillnets"),
                               Activity_.s.m2.d. = c(fishing_total,set_longlines_total,trawlers_total,other_purse_seines_total,
                                                     fixed_gear_total,set_gillnets_total))

fishing_activity$gear <- case_when(  # convert to StrathE2E guilds
  fishing_activity$gear == "drifting_longlines" ~ "Longlines and Jigging",
  fishing_activity$gear == "fishing" ~ "Distribute all",
  fishing_activity$gear == "fixed_gear" ~ "Distribute fixed",
  fishing_activity$gear == "other_purse_seines" ~ "Pelagic_trawl+seine",
  fishing_activity$gear == "set_gillnets" ~ "Gill_nets",
  fishing_activity$gear == "set_longlines" ~ "Longlines and Jigging",
  fishing_activity$gear == "trawlers" ~ "Demersal_otter_trawl"
)

write.csv(fishing_activity,paste0("./Objects/fishing/GlobalFishingWatch/",model,"/002. GFW aggregates/GFW_aggregate.csv"),
          row.names = FALSE)
