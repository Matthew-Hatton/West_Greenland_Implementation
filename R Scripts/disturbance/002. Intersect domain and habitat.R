## script which intersects each point within the domain with the sediment map provided by Yesson
## Takes quite a while to execute

rm(list = ls()) # reset

library(MiMeMo.tools) # everything we need
library(raster)

source("./R Scripts/regionFileWG.R")
domain <- readRDS("./Objects/domain/domainWG.rds") # domain

# Depth per pixel
GEBCO <- raster("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/Figures and Data/RAW/GEBCO/GEBCO_2020.nc")

crop <- as(extent(-61,-45,59,72.5),"SpatialPolygons") #defined as (xmin,xmax,ymin,ymax) <- (W,E,S,N)
crs(crop) <- crs(GEBCO)

GEBCO <- crop(GEBCO, crop)

Depths <- GEBCO

depth_df <- as.data.frame(Depths, xy = TRUE) %>% 
  mutate(shore = case_when(
    Elevation.relative.to.sea.level >= -20 ~ "in",
    Elevation.relative.to.sea.level < -20 ~ "off",
  )) %>% 
  st_as_sf(coords = c("x","y"),crs = 4326) %>% 
  st_transform(crs = crs)# from domain script

# Read in sediment map
habitat <- st_read(dsn = "./Objects/physical/GreenlandHabitatClasses.kml") %>% 
  st_transform(crs = crs)#reads in habitat map and converts from kml to shape file. Changes crs

# Intersect
intersection <- st_intersection(depth_df,habitat)

saveRDS(intersection,"./Objects/physical/habitat_depth intersection.RDS")
