#### Setup ####

rm(list=ls())

Packages <- c("MiMeMo.tools", "exactextractr", "raster", "lubridate")       # List packages
lapply(Packages, library, character.only = TRUE)                            # Load packages
source("./R Scripts/regionFileWG.R")

domains <- readRDS("./Objects/domain/domainWG.rds") %>%                             # Import inshore polygon
  st_transform(crs = 4326)

Reduced <- brick("./Objects/Shared data/ISIMIP Atmosphere/ndep_nhx_rcp85soc_monthly_2006_2099.nc4") # import reduced nitrogen deposition
Oxidised <- brick("./Objects/Shared data/ISIMIP Atmosphere/ndep_noy_rcp85soc_monthly_2006_2099.nc4")# import oxidised nitrogen deposition

extract_deposition <- function(raster_obj, domains, start_date = "2006-01-01") {
  names(raster_obj) <- as.character(seq.Date(as.Date(start_date), by = "month", length.out = nlayers(raster_obj)))
  
  exact_extract(raster_obj, domains, "mean") %>%
    mutate(Shore = domains$Shore) %>%
    pivot_longer(-Shore, names_to = "Date", values_to = "Measured") %>%
    mutate(Date = as.Date(gsub("mean\\.X", "", Date), format = "%Y.%m.%d"))
}

Deposition_Reduced <- extract_deposition(Reduced, domains) %>% 
  mutate(Month = month(Date),
         Year = year(Date),
         Measured = full_to_milli(Measured/14)/days_in_month(Date),
         Oxidation_state = "R")
Deposition_Oxidised <- extract_deposition(Oxidised, domains) %>% 
  mutate(Month = month(Date),
         Year = year(Date),
         Measured = full_to_milli(Measured/14)/days_in_month(Date),
         Oxidation_state = "O")

Deposition <- rbind(Deposition_Reduced,Deposition_Oxidised)
#### Plot ####

Deposition_lab <- mutate(Deposition, Oxidation_state = factor(Oxidation_state, levels = c("O", "R"),
                                                                  labels = c(expression("Oxidised Nitrogen (NO"["y"]*")"), expression("Reduced Nitrogen (NH"["x"]*")"))))



ggplot(data = filter(Deposition_lab, Year > 2000)) + 
  geom_line(aes(x = Date, y = Measured, colour = Shore), size = 0.15) +
  theme_minimal() +
  facet_grid(rows = vars(Oxidation_state), scales = "free_y", labeller = label_parsed) +
  labs(y = expression("mmols N m"^{-2}*"Day"^{-1}), caption = "ISIMIP Atmospheric Nitrogen deposition") +
  theme(legend.position = "top",
        strip.text = element_text(size = 6),
        axis.text.x = element_text(size = 6,angle = 45),
        axis.title.x = element_blank()) +
  NULL

ggsave("./Figures/saltless/NM.Atmospheric N Deposition.png", last_plot(), dpi = 500, width = 18, height = 10 , units = "cm", bg = "white")

#### Save ####
Deposition %>% 
  dplyr::select(Month, Oxidation_state, Shore,  Year, Measured) %>%  
  saveRDS("./Objects/NM.Atmospheric N deposition.rds")
