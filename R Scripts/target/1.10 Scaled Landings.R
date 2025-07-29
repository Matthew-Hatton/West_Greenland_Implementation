## Script which will take the RAW landings from the Barents Sea implementation, scale them, and sum them to calculate (along with subsistence data)
## the landings required for the target data.

rm(list = ls())

library(MiMeMo.tools)

## Landings for all of BS - need to scale as a ratio of activities
BS_landings <- t(readRDS("./Objects/fishing/Landings Catch Discards/BS_landings.RDS"))
### Scale



### Sum per fleet



### Add in Subsistence landings



### Save out