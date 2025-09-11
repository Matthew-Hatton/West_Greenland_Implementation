## Run batches of R scripts to build StrathE2EPolar West Greenland model
rm(list = ls()) #reset

library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")

#### Batch process scripts ####
# len <- length(list.files("./R Scripts/NM.se2e/",full.names = T))
# scripts <- list.files("./R Scripts/NM.se2e/",full.names = T)[3:len] %>% # all except first (this one)
#   map(MiMeMo.tools::execute) # Run the scripts

# Get full list of scripts
all_scripts <- list.files("./R Scripts/NM.se2e/", full.names = TRUE)

# Skip first two only if there are at least three
if (length(all_scripts) >= 3) {
  scripts <- all_scripts[3:length(all_scripts)]
  
  for (script in scripts) {
    cat("Running script:", script, "\n")
    tryCatch({
      MiMeMo.tools::execute(script)
    }, error = function(e) {
      cat("❌ Error in script:", script, "\n")
      print(e)
    })
  }
} else {
  cat("Not enough scripts to batch process (need at least 3).\n")
}
