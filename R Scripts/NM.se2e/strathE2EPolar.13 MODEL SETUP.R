## Change Model Setup file to be in line with the new West Greenland files. ##
rm(list = ls())
library(tidyverse)
source("./R Scripts/regionFileWG.R")

start <- c(2011,seq(2020,2090,10))
end <- seq(2019,2099,10)
init <- read.csv(paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/param/initial_values_WG_2011-2019.csv"),
                 header = F)

for (i in 1:length(start)) {
  tmp_setup <- read.csv(paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/MODEL_SETUP.csv")) # Load in template
  tmp_setup$Filename <- str_replace(tmp_setup$Filename,
                                    pattern = "\\d{4}-\\d{4}",
                                    replacement = paste0(start[i], "-", end[i]))
  write.csv(tmp_setup,file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",start[i],"-",end[i],"/MODEL_SETUP.csv"),
            row.names = F)
  ## initial values
  write.table(init,paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/",start[i],"-",end[i],"/Param/initial_values_WG_",start[i],"-",end[i],".csv"),
            row.names = F,col.names = F,sep = ",")
  
  }

