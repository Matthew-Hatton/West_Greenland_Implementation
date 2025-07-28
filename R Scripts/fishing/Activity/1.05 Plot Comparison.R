## Script to compare between Barents Sea activity and West Greenland activity to show the change

rm(list = ls()) # reset

library(MiMeMo.tools) # everything we need

## Read in West Greenland
wg_activity <- read.csv("./Objects/fishing/Activity/fishing_activity_WG_2011-2019.csv") %>% 
  mutate(Region = "West Greenland")

## Read in Barents Sea (from model)
bs_activity <- read.csv("./Objects/fishing/Activity/fishing_activity_BS_2011-2019.csv") %>% 
  mutate(Region = "Barents Sea")

activity <- rbind(wg_activity,bs_activity)

## very basic plot which show similarities and differences
ggplot() +
  geom_point(data = activity,aes(x = Gear_name,y = Activity_.s.m2.d.,color = Region))
