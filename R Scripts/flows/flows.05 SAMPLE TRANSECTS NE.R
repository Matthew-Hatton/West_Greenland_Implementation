# readRDS("./Objects/NE_Days/.")    # Marker so network script can see where the data is coming from

#### Set up ####

rm(list=ls())                                                               # Wipe the brain
Packages <- c("tidyverse", "nemoRsem", "data.table", "furrr")                         # List packages
lapply(Packages, library, character.only = TRUE)                                # Load packages
source("./regionFile.R")                                       # Define project region 
plan(multisession,workers = availableCores() - 2)                                                          # Choose the method to parallelise by with furrr

Transects <- readRDS("./Objects/chemistry/Boundary_transects.rds")                    # Import transects to sample at

look <- list.files("./Objects/NEMO RAW/NE_Days/", full.names = T) %>% 
  .[1] %>%
  readRDS()

#### Summarise along transects ####
NE_boundary_summary_V2 <- function (saved, transects, vars = c("NO3", "NH4", "Detritus"))
{
  ## -- Test -- ##
  # transects = Transects
  # vars = c("NO3", "NH4", "Detritus", "Diatoms", "Other_phytoplankton")
  # saved = list.files("./Objects/NEMO RAW/NE_Days/", full.names = T)[1]
  # 
  
  
  Data <- readRDS(saved) %>% dplyr::select(-c(Shore, weights))
  data.table::setDT(Data, key = c("x", "y", "slab_layer"))
  transects_dt <- unique(
    data.table::as.data.table(transects),
    by = c("x", "y", "slab_layer")
  )
  
  join <- Data[transects_dt, allow.cartesian = TRUE] %>% dplyr::mutate(Flow = ifelse(current ==
                                                                                "Zonal", Zonal, Meridional)) %>% dplyr::mutate(Flow = ifelse(Flip ==
                                                                                                                                               T, -1 * Flow, Flow)) %>% dplyr::mutate(Flow = Flow *
                                                                                                                                                                                        weights, Direction = ifelse(Flow > 0, "In", "Out"))
  water <- join[, .(Flow = sum(Flow, na.rm = T)), by = c("Shore",
                                                         "slab_layer", "Direction", "Neighbour", "Month", "Year",
                                                         "Forcing", "SSP")] %>% tidyr::drop_na()
  boundary <- join[perimeter == T & Direction == "In", lapply(.SD,
                                                              weighted.mean, w = Flow, na.rm = T), by = c("Shore",
                                                                                                          "slab_layer", "Neighbour", "Month", "Year", "Forcing",
                                                                                                          "SSP"), .SDcols = vars] %>% tidyr::drop_na() %>% dplyr::mutate(Date = as.Date(paste(15,
                                                                                                                                                                                              Month, Year, sep = "/"), format = "%d/%m/%Y"), Compartment = paste(Shore,
                                                                                                                                                                                                                                                                 slab_layer)) %>% tidyr::pivot_longer(eval(vars), names_to = "Variable",
                                                                                                                                                                                                                                                                                                      values_to = "Measured")
  result <- list(Flows = water, Boundarys = boundary)
  return(result)
}

Summary <- list.files("./Objects/NEMO RAW/NE_Days/", full.names = T) %>%              # Get the names of all data files
  future_map(NE_boundary_summary_V2, transects = Transects, 
             vars = c("NO3", "NH4", "Detritus", "Diatoms", "Other_phytoplankton"), .progress = T) # Sample NE output along domain boundary

#### Save water exchanges between compartments ####

Flows <- map(Summary, `[[`, 1) %>%                                          # Subset the summary results
  data.table::rbindlist() %>% 
  saveRDS("./Objects/physics/H-Flows.rds")                                          

#### Save boundary conditions ####

Boundary <- map(Summary, `[[`, 2) %>%                                       # Subset the summary results
  data.table::rbindlist()
saveRDS(Boundary, "./Objects/chemistry/Boundary measurements.rds")