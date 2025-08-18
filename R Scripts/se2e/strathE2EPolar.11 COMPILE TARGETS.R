rm(list = ls()) # reset
library(MiMeMo.tools) # everything we need

source("./R Scripts/regionFileWG.R")

# read template
event_timings <- read.csv("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Target/annual_observed_BS_2011-2019.csv")

fishing <- readRDS("./Objects/fishing/Target/Landings_by_guild.RDS")
