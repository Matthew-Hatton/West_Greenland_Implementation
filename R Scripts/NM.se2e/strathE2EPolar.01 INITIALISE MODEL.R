## Initialise model

library(ggplot2)
# source("./R Scripts/regionFileWG.R")

R.utils::copyDirectory("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/Barents_Sea",              # Copy example model 
                       stringr::str_glue("./StrathE2EPolar_Implementation/West_Greenland/2011-2019/"))    # Into new implementation

dir.create("./StrathE2EPolar_Implementation/NM/Results")   
