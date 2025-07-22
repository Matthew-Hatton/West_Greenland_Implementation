#A script which will crop daily resolved global fishing watch data to a domain for use in the parametrisation of StrathE2EPolar.

rm(list=ls()) #reset
library(tidyverse)
library(furrr)
library(sf)
library(dplyr)
plan(multisession)
sf_use_s2(FALSE) #turn off spherical geometry

source("./fishing/Global Fishing Watch/R Scripts/Functions/RoughCrop.R") #loads crop function

#specify year - 2012 is GFW min
year <- seq(2012,2019)


for (i in year){
  files <- list.files(path = paste0("./fishing/Global Fishing Watch/RAW/Daily/",i,"/fleet-daily-csvs-100-v2-",i),
                      full.names = TRUE) #list all year files
  all_files <- future_map(files,read.csv,
                          .progress = TRUE) #read in all files from that year
  
  all_files <- lapply(all_files,crop) #crops down those files
  
  all_data <- do.call(rbind.data.frame,all_files) #merges to one dataframe
  write.csv(all_data,paste0("./fishing/Global Fishing Watch/finished data/",i,"/GFW_",i,".csv"),row.names = FALSE)
}
