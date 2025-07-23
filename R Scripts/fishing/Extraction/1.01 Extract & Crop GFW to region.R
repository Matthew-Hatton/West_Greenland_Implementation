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

source("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/Global Fishing Watch/R Scripts/Functions/RoughCrop.R") #loads crop function

#specify year - 2012 is GFW min
year <- seq(2012,2019)

for (i in year){
  message(paste(i,"...\n"))
  files <- list.files(path = paste0("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/Global Fishing Watch/RAW/Daily/",i,"/fleet-daily-csvs-100-v2-",i),
                      full.names = TRUE) #list all year files
  all_files <- future_map(files,read.csv,
                          .progress = F) #read in all files from that year
  
  all_files <- lapply(all_files,crop,maxlat = 72.5,minlat = 59,maxlon = -45,minlon = -61) #crops down those files
  
  all_data <- do.call(rbind.data.frame,all_files) #merges to one dataframe
  write.csv(all_data,paste0("./Objects/fishing/GlobalFishingWatch/WestGreenland//GFW_",i,".csv"),row.names = FALSE)
}
