#A script which will crop daily resolved global fishing watch data to a domain for use in the parametrisation of StrathE2EPolar.

rm(list=ls()) #reset
library(tidyverse)
library(furrr)
library(sf)
library(dplyr)
library(progressr)
plan(multisession,workers = availableCores()-1)
sf_use_s2(FALSE) #turn off spherical geometry
handlers(global = T)
progressr::handlers("cli") # progress bars are nice

model <- "BarentsSea"
#specify years - 2012 is GFW min
year <- seq(2012,2019)

source("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/Global Fishing Watch/R Scripts/Functions/RoughCrop.R") #loads crop function
if (model == "WestGreenland") {
  message("Loaded West Greenland model")
  source("./Objects/regionFileWG.R")
} else if(model == "BarentsSea"){
  message("Loaded Barents Sea model")
  source("./Objects/regionFileBS.R")
} else{
  message("Please enter valid model.\nOptions:\nWestGreenland\nBarentsSea")
}

for (i in year){
  message(paste(i,"...\n"))
  files <- list.files(path = paste0("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/Global Fishing Watch/RAW/Daily/",i,"/fleet-daily-csvs-100-v2-",i),
                      full.names = TRUE) #list all year files
  all_files <- future_map(files,read.csv,
                          .progress = F) #read in all files from that year
  
  all_files <- lapply(all_files,crop,maxlat = maxlat,minlat = minlat,maxlon = maxlon,minlon = minlon) #crops down those files to rough study domain
  
  all_data <- do.call(rbind.data.frame,all_files) #merges to one dataframe
  write.csv(all_data,paste0("./Objects/fishing/GlobalFishingWatch/",model,"/001. rough crop/GFW_",i,".csv"),row.names = FALSE)
}
