
#### Set up ####

rm(list=ls())                                                               # Wipe the brain

packages <- c("MiMeMo.tools", "sf", "tictoc", "furrr")                      # List packages
lapply(packages, library, character.only = TRUE)                            # Load packages
source("./R scripts/regionFileWG.R")                                       # Define project region 
sf_use_s2(FALSE)

plan(multisession,workers = availableCores() - 2)                                                          # Choose the method to parallelise by with furrr

all_files <- list.files("./Objects/Shared Data/light/", recursive = TRUE, full.names = TRUE, pattern = ".nc") %>%
  as.data.frame() %>%
  rename(value = 1) %>%
  mutate(path_fixed = sub("^\\.\\/", "", value)) %>%  # remove leading './' if needed
  separate(path_fixed, into = c(NA, NA, NA, "Type", NA, NA), sep = "[/_]", remove = FALSE) %>%
  separate(value, into = c(NA, "Year", NA), sep = "_y", remove = FALSE) %>%
  mutate(Year = str_sub(Year, end = -4)) %>%
  rename(File = value) %>% 
  subset(select = -c(path_fixed))


examples <- group_by(all_files, Type) %>% slice(1) %>% ungroup()            # Get one example for each file type

Space <- Window(all_files[1,]$File, w = 0, e = 76, s = 65, n = 84)          # Get values to crop a netcdf file spatially at import. Both data types share a grid

domains <- readRDS("./Objects/domain/domainWG.rds") %>%                             # Load SF polygons of the MiMeMo model domains
  st_transform(crs = 4326)

domains_mask <- expand.grid(Longitude = Space$Lons, Latitude = Space$Lats) %>% # Get the data grid
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326, remove = F) %>%    # Convert to SF
  voronoi_grid(domains) %>%                                                    # Weight points within the model domain
  select(-c(Elevation, area, geometry))

ggplot() + geom_sf(data = domains_mask, aes(fill = Cell_area))

#### Extract Air temperature and light ####

Light_months <- data.frame(Time_step = seq(1,360, 1), Month = rep(1:12, each = 30))     # Add month, 30 days in a model with a 360 day year
Airtemp_months <- data.frame(Time_step = seq(1,1440, 1), Month = rep(1:12, each = 120)) # Add month, to 6 hour time steps for 30 days in a model with a 360 day year

tic()
Air <- future_pmap_dfr(all_files, get_air, .progress = TRUE) %>%                        # Data extraction with parameters stored rowise in dataframe, executed in par
  ungroup() %>%
  mutate(Date = as.Date(paste("15", Month, Year, sep = "/"), format = "%d/%m/%Y"),      # Get date column for plotting
         Measured = ifelse(Type == "T150", Measured - 273.15,                           # Convert Kelvin to celsius for Temp data
                           shortwave_to_einstein(Measured)),                            # Convert Watts to Einsteins for Light data.
         Type = factor(Type, levels = c("SWF", "T150"),                                 # Give units for variables when facetting
                       labels = c(SWF = expression("Light (Em"^{-2}*"d"^{-1}*" )"),
                                  T150 = expression("Air temperature ( "*degree*"C )"))),
         Shore = replace_na(Shore, "Combined"))                                         # Only temperature is grouped by shore, replace NA with combined label
toc()
foo <- Air %>% 
  filter(Type == "T150" & Measured < 300 & Measured > 200) %>% 
  mutate(Date = as.Date(paste("15", Month, Year, sep = "/"), format = "%d/%m/%Y"),
         Measured = Measured - 273.15) # Kelvin to celsius 
saveRDS(Air, "./Objects/physics/NM/NM.light.rds")

#### Plot ####

ggplot() +
  geom_line(data = foo %>% filter(Year == 2020),aes(x = Date,y = Measured,colour = Shore))


## light work air temperature is fucked
ggplot(data = Air) +
  geom_line(aes(x = Date, y = Measured, colour = Shore), size = 0.25) +
  theme_minimal() +
  facet_grid(rows = vars(Type), scales = "free_y", labeller = label_parsed) +
  labs(y = NULL, caption = "NEMO-MEDUSA driving data") +
  theme(legend.position = "top") +
  NULL
