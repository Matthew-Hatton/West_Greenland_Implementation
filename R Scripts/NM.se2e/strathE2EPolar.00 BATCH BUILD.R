## Run batches of R scripts to build StrathE2EPolar West Greenland model
rm(list = ls()) #reset

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

  #### Batch process scripts ####
  # Get full list of scripts
  all_scripts <- list.files("./R Scripts/NM.se2e/", full.names = TRUE)
  
  # Skip first two only if there are at least three
  if (length(all_scripts) >= 3) {
    scripts <- all_scripts[3:(length(all_scripts)-1)]
    
    for (script in scripts) {
      paste0("Running script:", script, "\n")
      tryCatch({
        MiMeMo.tools::execute(script)
      }, error = function(e) {
        paste0("Error in script:", script, "\n")
        print(e)
      })
    }
  } else {
    paste0("Not enough scripts to batch process (need at least 3).\n")
  }