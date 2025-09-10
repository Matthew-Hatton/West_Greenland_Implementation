## Automate the downloading of N atmospheric depostion data from EMEP server

library(tidyverse)
library(rvest)

download <- function(file) {
  
  download <- download.file(url = paste0(source, file), destfile = paste("./Objects/Shared Data/EMEP Atmosphere/", file))
  
}                                                # Create path, download, and specify destination file name

source <- "https://thredds.met.no/thredds/fileServer/data/EMEP/2018_Reporting/" # Where are the files stored?

read_html("https://thredds.met.no/thredds/catalog/data/EMEP/2018_Reporting/catalog.html") %>% # Import the file catalog
  html_nodes("a") %>%                                                           # Extract links
  html_attr("href") %>%                      
  .[which(grepl("month", .), )] %>%                                             # Limit to monthly files
  str_remove(., fixed("catalog.html?dataset=EMEP/2018_Reporting/")) %>%         # Extract file names from links
  map(download)                                                                 # Download all the files, don't parallelise, we don't want to overload the website!