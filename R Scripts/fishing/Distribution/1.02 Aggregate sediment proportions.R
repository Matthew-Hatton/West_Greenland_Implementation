rm(list = ls()) #reset

library(rnaturalearth)
library(ggplot2)
library(sf)
library(furrr)
library(tidyverse)
plan(multisession)
sf_use_s2(FALSE) # turn off spherical geometry
source("./R Scripts/regionFileWG.R")

Domain <- readRDS("./Objects/domain/domainWG.rds") %>% 
  st_transform(crs = 4326)#load domain sizes

Domain$Shore <- c("Inshore","Offshore") #adds inshore offshore column

years <- seq(2013,2019) #years -1
all_data <- read.csv("./Objects/fishing/Distribution/2012_GFW_sediment_intersection.csv")#read in start file
#read in rest
for (year in years) {
  new_data <- read.csv(paste0("./Objects/fishing/Distribution/",year,"_GFW_sediment_intersection.csv"))
  all_data <- rbind(all_data,new_data)
  rm(new_data)
}

write.csv(all_data,"./Objects/fishing/Distribution/Sediment Distribution.csv")
