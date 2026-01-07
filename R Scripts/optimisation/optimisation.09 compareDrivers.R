rm(list = ls()) # reset

library(tidyverse)
library(MiMeMo.tools)

# Cleaning
field <- read.delim("./Objects/Validation/Light/ShortWave.txt", header = TRUE) %>% 
  filter(SRI..W.m2. >= 0) %>% 
  mutate(Year = year(Date),
         Month = month(Date),
         Day = day(Date)) %>%
  filter(Year %in% c(2011:2019)) %>% 
  subset(select = -c(Date,Quality.Flag)) %>% 
  group_by(Month) %>% 
  summarise(SLight = shortwave_to_einstein(mean(SRI..W.m2.))) %>% 
  mutate(Source = "Field")

NEMO_WG <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/physics_WG_2011-2019.csv") %>% 
  subset(select = c(Month,SLight)) %>% 
  mutate(Source = "WG NEMO")

NEMO_BS <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") %>% 
  subset(select = c(Month,SLight)) %>% 
  mutate(Source = "BS NEMO")

WG_Light <- rbind(field,NEMO_WG,NEMO_BS)

ggplot() +
  geom_line(data = WG_Light,aes(x = Month,y = SLight,color = Source),alpha = 0.7,linewidth = 2) +
  theme_minimal() +
  labs(x = "Month",y = "Light (Einsteins)",color = "",caption = "Field data averaged from Nuuk and Disko Bay. Provided by Greenland Ecosystem Monitoring.") +
  theme(legend.position = "top") +
  scale_x_continuous(labels = c(1:12),breaks = c(1:12)) +
  NULL
ggsave("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/24-25/West_Greenland_Implementation/Figures/optimisation/NM/Test Runs/LightDrivers.png",height = 3000,width = 5000,unit = "px")


NEMO_WG_AIR <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/physics_WG_2011-2019.csv") %>% 
  subset(select = c(Month,SI_AirTemp)) %>% 
  mutate(Source = "WG NEMO")

NEMO_BS_AIR <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") %>% 
  subset(select = c(Month,SI_AirTemp)) %>% 
  mutate(Source = "BS NEMO")

field_airtemp <- read.delim("./Objects/Validation/Air Temperature/air temperature.txt",header = T) %>% 
  mutate(Year = year(Date),
         Month = month(Date),
         Day = day(Date)) %>% 
  filter(air_temperature_2m >= 0 & Year > 2011 & Year < 2019) %>% 
  subset(select = c(Year,Month,Day,Time,air_temperature_2m)) %>% 
  group_by(Month) %>% 
  summarise(SI_AirTemp = mean(air_temperature_2m)) %>% 
  mutate(Source = "Field")

airtemp <- rbind(NEMO_WG_AIR,NEMO_BS_AIR,field_airtemp)

ggplot() +
  geom_line(data = airtemp,aes(x = Month,y = SI_AirTemp,color = Source),alpha = 0.7,linewidth = 2) +
  theme_minimal() +
  labs(x = "Month",y = "Air Temperature (Degrees C)",color = "",caption = "Field data averaged from Nuuk and Disko Bay. Provided by Greenland Ecosystem Monitoring.") +
  theme(legend.position = "top") +
  scale_x_continuous(labels = c(1:12),breaks = c(1:12)) +
  NULL
ggsave("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/24-25/West_Greenland_Implementation/Figures/optimisation/NM/Test Runs/AirTempDrivers.png",
       height = 3000,width = 5000,unit = "px")
