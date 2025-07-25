
# readRDS("./Objects/Months/.")    # Marker so network script can see where the data is coming from

#### Set up ####

rm(list=ls())                                                               # Wipe the brain
library(MiMeMo.tools)
source("./Objects/@_Region file.R")                                       # Define project region 

domains <- readRDS("./Objects/Domains.rds")                                 # Load SF polygons of the MiMeMo model domains

Edges <- readRDS("./Objects/Split_boundary.rds") %>%                        # Load in segments of domain boundaries
  mutate(Segment = as.numeric(Segment))

#### Create a NEMO-ERSEM grid to intersect with transects ####

points <- readRDS("./Objects/NE_Days/NE.CNRM.hist.01.2010.rds") %>%             # Import an NM summary object
  filter(slab_layer == "S") %>%                                             # Limit to the shallow layer to avoid duplication (and it's bigger)
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%             # Set as sf object
  st_transform(crs = crs)

days <- ifelse(nrow(points)%%6 == 1, 5, 6)                                  # If the number of rows is not divisible into 6 then it is a 5 day february

points <- mutate(points, Day = rep(1:days, each = nrow(points)/days)*5) %>%       # Insert a column of days
  filter(Day == 5)

grid <- st_union(points) %>%                                                # Combine              
  st_voronoi() %>%                                                          # And create a voronoi tesselation
  st_collection_extract(type = "POLYGON") %>%                               # Expose the polygons
  sf::st_sf() %>%                                                           # Reinstate sf formatting
  st_join(points) %>%                                                       # Rejoin meta-data from points
  arrange(x, y)                                                             # Order the polygons to match the points

ggplot(grid) +                                                              # Check the polygons match correctly with points
  geom_sf(aes(fill = Meridional), size = 0.05, colour = NA) +
  geom_sf(data = Edges, colour = "orange") +
  theme_minimal() +
  labs(caption = "If the spatial pattern looks right, polygons and points are matched") +
  NULL

ggsave("./Figures/flows/check.04.1.png")

#### Characterise transects (weights, target current, nature of water exchanges) ####

labelled <- st_intersection(Edges %>% st_transform(crs), grid) %>% 
  mutate(split_length = as.numeric(st_length(.))) %>% 
  dplyr::select(x, y, slab_layer, Shore, split_length, Bathymetry) %>% 
  characterise_flows(domains %>% st_transform(crs),precision = 100000)
# %>% 
#   filter(Neighbour != "Offshore")                                           # In which direction? (in or out of box and with which neighbour)


ggplot() +
  geom_sf(data = labelled[[2]],color = "black") +
  geom_sf(data = labelled[[1]],color = "red") ##all squigly round fjords - we'll get rid of them anyways

labelled_test <- slice(labelled[[2]],(unique(labelled[[1]]$V3))*-1)

ggplot() +
  geom_sf(data = labelled_test)

labelled <- labelled_test %>% 
  characterise_flows(domains %>% st_transform(crs),precision = 100000)

ggplot(labelled) +                                                              # Check segments are labelled
  geom_sf(aes(colour = Shore)) +
  viridis::scale_colour_viridis(option = "viridis", na.value = "red", discrete = T) +
  labs(caption = "Check the transects are correctly labelled by zone") +
  theme_minimal()
ggsave("./Figures/flows/check.04.2.png")

shallow <- mutate(labelled,
                  thickness = ifelse(Bathymetry >= SDepth, SDepth, Bathymetry),
                  weights = thickness*split_length) %>% 
  st_drop_geometry() %>% 
  dplyr::select(-c(thickness, Bathymetry, split_length))

deep <- mutate(labelled, 
               slab_layer = "D",
               thickness = ifelse(Bathymetry > DDepth, (DDepth-SDepth), (Bathymetry-SDepth)),
               weights = thickness*split_length) %>% 
  st_drop_geometry() %>% 
  dplyr::select(-c(thickness, Bathymetry, split_length))

#### Mark transects for different summaries ####

water_exchanges <- bind_rows(filter(shallow, Shore == "Offshore" | Neighbour != "Offshore"), # Drop Inshore to Offshore transects(avoid double accounting with Offshore to inshore transects)
                        filter(deep, Shore == "Offshore" & Neighbour == "Ocean"))      # The deep layer of the model only has exchange between offshore and the sea (and a vertical component dealt with separately)

boundary_conditions <- bind_rows(filter(shallow, Neighbour == "Ocean"),                # Keep only transects on the domain perimeter
                        filter(deep, Shore == "Offshore" & Neighbour == "Ocean")) %>%  # The deep layer of the model only has exchange between offshore and the sea
  mutate(perimeter = T)

test <- anti_join(boundary_conditions, water_exchanges)                                # Check boundary transects are a subset of water_exchange transects          

Transects <- left_join(water_exchanges, boundary_conditions)                           # Attach column indicating rows to drop when sumarising the boundary

data.table::setDT(Transects, key = c("x", "y", "slab_layer"))                 # Convert to a data.table keyed spatially for quick summaries.

saveRDS(Transects, "./Objects/Boundary_transects.rds")
