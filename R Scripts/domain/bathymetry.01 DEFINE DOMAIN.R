rm(list=ls())                                                   

Packages <- c("tidyverse", "sf", "stars", "rnaturalearth", "raster")        # List handy packages
lapply(Packages, library, character.only = TRUE)                            # Load packages

source("@_Region file.R")                                       # Define project region 

world <- ne_countries(scale = "medium", returnclass = "sf") %>%             # Get a world map
  st_transform(crs = crs)                                                   # Assign polar projection
setwd("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way")
GEBCO <- raster("Figures and Data\\RAW\\GEBCO\\GEBCO_2020.nc")
GFW <- raster("Figures and Data\\RAW\\GFW\\distance-from-shore.tif")

crop <- as(extent(-61,-45,59,72.5),"SpatialPolygons") #defined as (xmin,xmax,ymin,ymax) <- (W,E,S,N)
crs(crop) <- crs(GEBCO)

GEBCO <- crop(GEBCO, crop)
GFW <- crop(GFW, crop)

#### Polygons based on depth ####

Depths <- GEBCO
Depths[GEBCO >= 0 | GEBCO < - 600] <- NA

Depths[Depths < -20] <- -600
Depths[Depths >= -20] <- -20

Depths <- st_as_stars(Depths) %>% 
  st_as_sf(merge = TRUE) %>% 
  st_make_valid() %>% 
  group_by(Elevation.relative.to.sea.level) %>% 
  summarise(Depth = abs(mean(Elevation.relative.to.sea.level))) %>% 
  st_make_valid()

ggplot(Depths) +
  geom_sf(aes(fill = Depth), alpha = 0.2) + 
  theme_minimal() 

#### Polygons based on distance ####

Distance <- GFW
Distance[GFW == 0 | GFW > 20] <- NA  # Distance appears to be in KM not m as stated on the website.

Distance[is.finite(Distance)] <- 20  # Distance appears to be in KM not m as stated on the website.

Distance <- st_as_stars(Distance) %>% 
  st_as_sf(merge = TRUE) %>% 
  st_make_valid() %>% 
  group_by(distance.from.shore) %>% 
  summarise(Distance = (mean(distance.from.shore))) %>% 
  st_make_valid()

ggplot() +
  geom_sf(data = Distance, fill = "red") + 
  geom_sf(data = Depths, aes(fill = Depth), alpha = 0.2) +
  theme_minimal() 

#### Expand inshore and cut offshore ####

ggplot(data = filter(Depths,Depth == 20)) + geom_sf() #lots of little bit just around the shore - FIX

meld <- st_union(Distance, filter(Depths, Depth == 20)) %>% 
  st_make_valid()

ggplot(data = meld,aes(fill = distance.from.shore)) + geom_sf()

sf_use_s2(F)

offshore <- filter(Depths, Depth == 600) %>% 
  st_cast("POLYGON") %>% 
  mutate(area = as.numeric(st_area(.))) %>%
  slice_max(order_by = area) #this is the problematic one

ggplot(data = offshore,aes(fill = Depth)) + geom_sf()

shrunk <- bind_rows(meld, offshore) %>%
  st_make_valid() %>% 
  st_difference()

ggplot(shrunk) +
  geom_sf(aes(fill = as.character(Depth)), alpha = 0.5)

#### Cut to region mask ####

clipped <- st_intersection(shrunk, st_transform(Region_mask, st_crs(shrunk))) #clip needs to be closer

ggplot(clipped) +
  geom_sf(aes(fill = as.character(Depth)), alpha = 0.5)

ggplot(Region_mask) +
  geom_sf()
#### Format to domains object ####
Domains <- transmute(clipped, 
                     Shore = ifelse(Depth == d_from_shore, "Inshore", "Offshore"),
                     area = as.numeric(st_area(shrunk)),
                     Elevation = exactextractr::exact_extract(GEBCO, shrunk, "mean")) %>% 
  st_transform(crs = 4326) #keep in 4326 for now to define pocket

guesses <- data.frame(lon = c(-51.5,-53,-51.5,-53),
                      lat = c(68.9,68.9,69.6,69.2)) #these seem about right

ggplot() +
  geom_sf(data = Domains,aes(fill = Shore),alpha = 0.5) +
  geom_point(data = guesses,aes(x = lon,y = lat))
# ggsave("newdomainold.tiff",
#        dpi = 1200,
#        bg = "white") #save out

### !!!! MANUALLY ADDING POINTS IN SO THAT WE FILL IN DISKO BAY !!!! ###
sf_use_s2(FALSE)
disko_pocket <- st_polygon(list(rbind(
  c(-51.5, 68.9),   # Start: Bottom right
  c(-53, 68.9),     # Bottom left
  c(-53, 69.2),     # Top left
  c(-51.5, 69.6),   # Top right
  c(-51.5, 68.9)    # Closing the loop (same as start)
))) %>% 
  st_sfc(crs = 4326)

ggplot() +
  geom_sf(data = Domains) +
  geom_sf(data = disko_pocket)

new_inshore <- st_sf(Shore = "Inshore", area = st_area(disko_pocket), Elevation = NA, geometry = disko_pocket) %>% 
  st_make_valid()
# Filter inshore region
inshore_domain <- Domains %>% filter(Shore == "Inshore") %>% 
  st_make_valid()

# Merge the new pocket with the existing inshore domain
updated_inshore <- st_union(inshore_domain, new_inshore) %>% subset(select = c(Shore,area,Elevation))

ggplot() + geom_sf(data = updated_inshore,aes(fill = Shore))

# If you want to replace the inshore polygon in your Domains object:
# Domains[1, ] <- updated_inshore
offshore_zone <- Domains %>% filter(Shore == "Offshore")

# Subtract the disko_pocket polygon from the offshore zone
updated_offshore <- st_difference(offshore_zone$geometry, disko_pocket)

updated_offshore <- st_sf(Shore = "Offshore", area = st_area(updated_offshore), Elevation = NA, geometry = updated_offshore) %>% 
  st_make_valid()
# Domains <- Domains %>%
#   filter(Shore != "Offshore") %>%
#   bind_rows(st_sf(Shore = "Offshore", area = NA, Elevation = NA, geometry = updated_offshore))

Domains <- rbind(updated_inshore,updated_offshore)

ggplot() +
  geom_sf(data = Domains,aes(fill = Shore))

Domains_offshore <- Domains %>% filter(Shore == "Offshore") %>% st_cast("POLYGON") %>% 
  mutate(area = as.numeric(st_area(.))) %>% 
  filter(area == max(area))

ggplot() +
  geom_sf(data = Domains,aes(fill = Shore))

inshore <- Domains %>% filter(Shore == "Inshore")

Domains <- bind_rows(inshore,Domains_offshore)
ggplot() +
  geom_sf(data = Domains,aes(fill = Shore))

# Domains elevation goes amiss, we can manually add back in
Domains$Elevation[2] <- -266.0670
setwd("~/PhD/24-25/NEMO-ERSEM") # Reset to project directory
saveRDS(Domains, "Objects/Domains.rds") #saves out domain FINISHED

#plot(GEBCO)
