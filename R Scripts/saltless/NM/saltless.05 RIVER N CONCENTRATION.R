rm(list = ls()) # reset

set.seed(710)
library(tidyverse)
library(raster)

source("./R Scripts/regionFileWG.R")

water_quality <- read.csv("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/24-25/Recovery Time Manuscript/Objects/Shared Data/Rivers/ArcticGRO Water Quality Data.csv")[-c(1:7),]   # get water quality data and clean

names(water_quality) <- water_quality[1,]

wq <- water_quality[-c(1,2),]

names(wq) <- make.unique(names(wq))

wq <- wq %>%
  filter(Date != "" & NO3 != "") %>% 
  subset(select = c(Discharge,NO3,NH4,Date)) %>% 
  mutate(month = month(Date)) %>% 
  arrange(month)

# CONVERT AND CLEAN
wq$NO3 <- as.numeric(wq$NO3)
wq$NH4 <- as.numeric(wq$NH4)
wq <- wq[!is.na(wq$NO3),]
wq <- wq[!is.na(wq$NH4),]
wq$Discharge <- as.numeric(wq$Discharge)
wq$Discharge_scaled <- (wq$Discharge)/1000 #convert from litres to cubic meters

## BUILD

model.NO3 <- nls(NO3 ~ a * (1 - b)^Discharge_scaled,#fitting exponential decay function
                 data = wq,
                 start = list(a = 150, b = 0.0001))#provide estimates of start parameters, then model tries to converge

model.NH4 <- nls(NH4 ~ a * (1 - b)^Discharge_scaled,
                 data = wq,
                 start = list(a = 150, b = 0.0001))


summary(model.NO3)
summary(model.NH4)
# a and b statistically significant in  both cases

## Load Mankoff Data
# test
year <- 2011

tst <- nc_open(paste0("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/24-25/Recovery Time Manuscript/Objects/Shared Data/Rivers/Mankoff/discharge/MAR_",year,".nc"))

discharge <- ncvar_get(tst, "discharge") # it's the whole of Greenland - will have to crop

lon <- ncvar_get(tst, "lon")
lat <- ncvar_get(tst, "lat")

dates <- seq(as.Date("2010-01-01"), as.Date("2010-12-31"), by = "day")

month_index <- month(dates)

monthly_discharge <- sapply(1:12, function(m) {
  rows_in_month <- which(month_index == m)
  # Average discharge for each column (point) over the days in the month
  colMeans(discharge[rows_in_month, , drop = FALSE], na.rm = TRUE)
})  # Result: [N x 12] matrix

monthly <- data.frame(
  lon = lon,
  lat = lat,
  monthly_discharge
)

names(monthly)[3:14] <- paste0("dis_", seq(1,12))

all_discharge <- monthly %>%
  pivot_longer(
    cols = starts_with("dis_"),         # all discharge columns
    names_to = "month",                 # new column for month names
    names_prefix = "dis_",              # remove "dis_" from month names
    values_to = "discharge"             # new column for values
  ) %>% 
  mutate(Year = year)

## crop
all_discharge_cropped <- all_discharge %>% 
  filter(lon < maxlon & lon > minlon & lat < maxlat & lat > minlat) %>%  # just on country boundaries, so can be rough
  group_by(month) %>% 
  summarise(discharge = mean(discharge,na.rm = T)*10e1)

monthly_predict <- all_discharge_cropped %>%
  ungroup() %>%
  mutate(
    month = as.numeric(month),
    Discharge_scaled = discharge,
    NO3 = predict(model.NO3, newdata = data.frame(Discharge_scaled = discharge))/10,
    NH4 = predict(model.NH4, newdata = data.frame(Discharge_scaled = discharge))
  ) %>% 
  arrange(month)


ggplot() +
  geom_line(data = monthly_predict,aes(x = month,y = NO3))


### not working. For now just use the NE values...
