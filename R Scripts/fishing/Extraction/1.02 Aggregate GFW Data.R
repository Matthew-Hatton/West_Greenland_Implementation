## Script to aggregate previously extracted GFW data into Inshore/Offshore.
## CODE NEEDS CLEANING ## 

rm(list=ls()) #reset
library(tidyverse)
library(furrr)
library(sf)
library(dplyr)
plan(multisession)
sf_use_s2(FALSE) #turn off spherical geometry

#specify year
years <- seq(2012,2019)
model <- "BarentsSea"

if(model == "BarentsSea"){
  Domain <- readRDS("./Objects/domain/domainWG.rds") #load domain
} else if(model == "BarentsSea"){
  Domain <- readRDS("./Objects/domain/domainBS.rds") #load domain sizes
} else{
  stop("\nPlease enter valid model.\nOptions:\nWestGreenland\nBarentsSea")
}
Domain$Shore <- c("Inshore","Offshore") #adds inshore offshore column

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
  
  write.csv(aggregate,paste0("./Objects/fishing/GlobalFishingWatch/",model,"/002. GFW aggregates/",year," total fishing hours per day per meter squared in the model domain.csv"),
                             row.names = FALSE)
}

