rm(list = ls()) #reset
library(rnaturalearth)
library(ggplot2)
library(sf)
library(progressr)
source("./R Scripts/regionFileWG.R")

handlers("cli")
handlers(global = T)

intersection <- function(years){
  inshore_sed <- readRDS("./Objects/physical/INSHORE_polygon.RDS") #load habitat map (intersected with domain)
  offshore_sed <- readRDS("./Objects/physical/OFFSHORE_polygon.RDS")
  
  Domain <- readRDS("./Objects/domain/domainWG.rds") #load domain polygon
  Domain$Shore <- c("Inshore","Offshore") #adds inshore offshore column
  
  p <- progressor(along = years)
  # Loop over each year
  for (i in 1:length(years)) {
    year <- years[i]
    
    # Read in GFW data for the current year
    all_data <- read.csv(paste0("./Objects/fishing/GlobalFishingWatch/WestGreenland/001. rough crop/GFW_", year, ".csv")) %>% 
      st_as_sf(coords = c("cell_ll_lon", "cell_ll_lat"))
    
    st_crs(all_data) <- st_crs(Domain) # Set CRS of read-in data
    
    # Intersect with inshore sediment map
    inshore_fishing <- st_intersection(inshore_sed, all_data) %>% 
      subset(select = -c(date))
    
    inshore_fishing$Zone <- "Inshore"
    
    # Intersect with offshore sediment map
    offshore_fishing <- st_intersection(offshore_sed, all_data) %>% 
      subset(select = -c(date))
    
    offshore_fishing$Zone <- "Offshore"
    
    # Plot fishing by sediment type in the different fishing zones
    p1 <- ggplot() +
      geom_sf(data = Domain, aes(fill = Shore), alpha = 0.3) +
      geom_sf(data = offshore_fishing, aes(color = Name), size = 0.1) +
      geom_sf(data = inshore_fishing, aes(color = Name), size = 0.1) +
      scale_color_manual(values = c("Rock" = "#5B7C99",
                                    "Gravel" = "#7D7D7D",
                                    "Sand" = "#E2C085",
                                    "Mud" = "#8B4513")) +
      labs(color = "Sediment Type") +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      guides(colour = guide_legend(override.aes = list(size = 2))) +
      ggtitle(paste0(year, " fishing distribution"))
    
    # Save the plot
    ggsave(plot = p1,paste0("./Figures/physical/", year, " fishing distribution.png"), 
           width = 33.867, height = 19.05, units = "cm", bg = 'white')
    
    # Combine inshore and offshore fishing data for export
    fishing_sediment <- rbind(inshore_fishing, offshore_fishing)
    
    # Extract coordinates for export
    fishing_sediment_coords <- st_coordinates(fishing_sediment) 
    fishing_sediment_export <- cbind(fishing_sediment, fishing_sediment_coords) %>% 
      st_drop_geometry() # Drop geometry for saving
    
    # Save the export CSV
    write.csv(fishing_sediment_export, 
              paste0("./Objects/physical/", year, "_GFW_sediment_intersection.csv"), 
              row.names = FALSE)
    

  }
  # Update progress bar
  p()
}

years <- seq(2012,2019)
run <- intersection(years)
