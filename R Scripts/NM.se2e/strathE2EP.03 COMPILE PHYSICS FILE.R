## Overwrite example driving data (physics)

#### Setup ####

rm(list=ls()) # reset

library(MiMeMo.tools)

Physics_template <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") # Read in example Physical drivers

#### Last minute data manipulation ####

My_scale <- readRDS("./Objects/domain/domainWG.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = c(T, T),
         D = c(F, T)) %>% 
  gather(key = "slab_layer", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = c(Elevation[1], -40, Elevation[3] + 40)) %>% # 40 is deep layer 
  mutate(Volume = area * abs(Elevation)) %>% 
  dplyr::select(Shore, slab_layer, Volume)

My_H_Flows <- readRDS("./Objects/flows/NM/H-Flows.rds") %>% 
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(across(-c(Year, Flow))) %>%                                      # Group over everything except year and variable of interest
  summarise(Flow = mean(Flow, na.rm = T)) %>%                               # Average flows by month over years
  ungroup() %>% 
  left_join(My_scale) %>%                                                   # Attach compartment volumes
  mutate(Flow = Flow/Volume) %>%                                            # Scale flows by compartment volume
  mutate(Flow = abs(Flow * 86400)) %>%                                      # Multiply for total daily from per second, and correct sign for "out" flows
  arrange(Month)                                                            # Order by month to match template

My_V_Flows <- readRDS("./Objects/physics/NM/vertical diffusivity.rds") %>%
  mutate(Year = Year + 2000) %>%  # Years set to 0 fix
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Month) %>% 
  summarise(V_diff = mean(Vertical_diffusivity, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

My_volumes <- readRDS("./Objects/physics/NM/NM.TS.rds") %>% 
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Compartment, Month) %>%                                          # By compartment and month
  summarise(across(Salinity_avg:Ice_conc_avg, mean, na.rm = T)) %>%         # Average across years for multiple columns
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

My_SPM <- readRDS("./Objects/physics/Suspended particulate matter.rds") %>% 
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Shore, Month) %>% 
  summarise(SPM = mean(SPM, na.rm = T)) %>%                                 # Average by month across years
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

My_stress <- readRDS("./Objects/physics/My_Stress.RDS")

My_Waves <- readRDS("./Objects/physics/Significant wave height.rds") %>%  #*2000 - 2010   
  arrange(month) %>% 
  group_by(month) %>% 
  summarise(mean_height = mean(mean_height))# Arrange to match template  

## ?? ##

## just use NE for now ##
My_Rivers <- readRDS("./Objects/rivers/NE/NE River input.rds") %>%
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  mutate(Month = as.integer(format(.$Date, "%m"))) %>% # convert to month
  group_by(Month) %>%
  summarise(Runoff = mean(Runoff, na.rm = T)) %>%                           # Average by month across years
  ungroup() %>%
  arrange(as.numeric(Month))                                                # Order by month to match template

My_light <- readRDS("./Objects/physics/NE/light.rds") %>% 
  # filter(Forcing == "CNRM" & SSP == "ssp126") %>%               # Limit to reference period and variable
  group_by(Month) %>% # For now, just average across forcings and SSPs                                                       # Average across months
  summarise(Measured = mean(Light, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month)                                                             # Order to match template

# My_AirTemp <- readRDS("./Objects/Air temp and light.rds") %>% 
#   filter(between(Year, 2011, 2019), grepl("Air", Type)) %>%                 # Limit to reference period and variable
#   group_by(Month, Shore) %>%                                                # Average across months
#   summarise(Measured = mean(Measured, na.rm = T)) %>% 
#   ungroup() %>% 
#   arrange(Month)

## ?? ##

#### Create new file ####

Physics_new <- mutate(Physics_template, SLight = My_light$Measured,
                      ## Flows, should be proportions of volume per day
                      SO_OceanIN = filter(My_H_Flows, slab_layer == "S", Shore == "Offshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      D_OceanIN = filter(My_H_Flows, slab_layer == "D", Shore == "Offshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      SI_OceanIN = filter(My_H_Flows, slab_layer == "S", Shore == "Inshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      SI_OceanOUT = filter(My_H_Flows, slab_layer == "S", Shore == "Inshore", Neighbour == "Ocean", Direction == "Out")$Flow,
                      SO_SI_flow = filter(My_H_Flows, slab_layer == "S", Shore == "Offshore", Neighbour == "Inshore", Direction == "Out")$Flow,
                      Upwelling = 0, # Nominal value   
                      ## log e transformed suspended particulate matter concentration in zones
                      SO_LogeSPM = log(filter(My_SPM, Shore == "Offshore")$SPM),  
                      SI_LogeSPM = log(filter(My_SPM, Shore == "Inshore")$SPM),
                      ## Temperatures in volumes for each zone
                      SO_temp = filter(My_volumes, Compartment == "Offshore S")$Temperature_avg,
                      D_temp = filter(My_volumes, Compartment == "Offshore D")$Temperature_avg,
                      SI_temp = filter(My_volumes, Compartment == "Inshore S")$Temperature_avg ,
                      ## River inflow,
                      Rivervol_SI = My_Rivers$Runoff / filter(My_scale, Shore == "Inshore")$Volume, # Scale as proportion of inshore volume
                      ## Vertical diffusivity
                      log10Kvert = log10(My_V_Flows$V_diff),
                      mixLscale = mixLscale, # Length scale over which vertical diffusion acts, nominal
                      ## Daily proportion disturbed by natural bed shear stress
                      habS1_pdist = My_stress$habS1_pdist,
                      habS2_pdist = My_stress$habS2_pdist,
                      habS3_pdist = My_stress$habS3_pdist,
                      habD1_pdist = My_stress$habD1_pdist,
                      habD2_pdist = My_stress$habD2_pdist,
                      habD3_pdist = My_stress$habD3_pdist,
                      ## Monthly mean significant wave height inshore                     
                      Inshore_waveheight = My_Waves$mean_height,
                      ## Cryo variables
                      SO_IceFree = 1 - filter(My_volumes, Compartment == "Offshore S")$Ice_pres,
                      SI_IceFree = 1 - filter(My_volumes, Compartment == "Inshore S")$Ice_pres,
                      SO_IceCover = filter(My_volumes, Compartment == "Offshore S")$Ice_conc_avg,
                      SI_IceCover = filter(My_volumes, Compartment == "Inshore S")$Ice_conc_avg,
                      SO_IceThickness = filter(My_volumes, Compartment == "Offshore S")$Ice_Thickness_avg, 
                      SI_IceThickness = filter(My_volumes, Compartment == "Inshore S")$Ice_Thickness_avg,
                      SO_SnowThickness = filter(My_volumes, Compartment == "Offshore S")$Snow_Thickness_avg, 
                      SI_SnowThickness = filter(My_volumes, Compartment == "Inshore S")$Snow_Thickness_avg,
                      # SO_AirTemp = filter(My_AirTemp, Shore == "Offshore")$Measured,
                      # SI_AirTemp = filter(My_AirTemp, Shore == "Inshore")$Measured
                      )

write.csv(Physics_new, file = paste0("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/physics_WG_2011-2019.csv"), row.names = F)