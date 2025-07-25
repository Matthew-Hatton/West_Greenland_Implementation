## Overwrite example driving data (boundaries and physics)

#### Setup ####

rm(list=ls())                                                               # Wipe the brain

library(MiMeMo.tools)

Force <- "GFDL"
ssp <- "ssp370" #Define the forcing and ssp we use for this parametrisation

Physics_template <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") # Read in example Physical drivers

#### Last minute data manipulation ####

My_scale <- readRDS("./Objects/Domains.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = c(T, T),
         D = c(F, T)) %>% 
  gather(key = "slab_layer", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = c(Elevation[1], -60, Elevation[3] + 60)) %>% 
  mutate(Volume = area * abs(Elevation)) %>% 
  dplyr::select(Shore, slab_layer, Volume)

My_light <- readRDS("./Objects/light.rds") %>% 
  filter(Forcing == Force & SSP == ssp) %>%               # Limit to reference period and variable
  group_by(Month,SSP,Forcing) %>%                                                       # Average across months
  summarise(Measured = mean(Light, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month)                                                            # Order to match template

# My_AirTemp <- readRDS("./Objects/Air temp and light.rds") %>% 
#   filter(between(Year, 2011, 2019), grepl("Air", Type)) %>%                 # Limit to reference period and variable
#   group_by(Month, Shore) %>%                                                # Average across months
#   summarise(Measured = mean(Measured, na.rm = T)) %>% 
#   ungroup() %>% 
#   arrange(Month)                                                            # Order to match template

My_H_Flows <- readRDS("./Objects/H-Flows.rds") %>% 
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(across(-c(Year, Flow))) %>%                                      # Group over everything except year and variable of interest
  summarise(Flow = mean(Flow, na.rm = T)) %>%                               # Average flows by month over years
  ungroup() %>% 
  left_join(My_scale) %>%                                                   # Attach compartment volumes
  mutate(Flow = Flow/Volume) %>%                                            # Scale flows by compartment volume
  mutate(Flow = abs(Flow * 86400)) %>%                                      # Multiply for total daily from per second, and correct sign for "out" flows
  arrange(Month) %>%                                                             # Order by month to match template
  filter(SSP == "ssp126" & Forcing == "CNRM")
  
My_V_Flows <- readRDS("./Objects/vertical diffusivity.rds") %>%
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Month) %>% 
  summarise(V_diff = mean(Vertical_diffusivity, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

My_volumes <- readRDS("./Objects/TS.rds") %>% 
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Compartment, Month) %>%                                          # By compartment and month
  summarise(across(c(NO3_avg,NH4_avg,Diatoms_avg,Other_phytoplankton_avg,Detritus_avg,Temperature_avg), mean, na.rm = T)) %>%         # Average across years for multiple columns
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

# My_SPM <- readRDS("./Objects/Suspended particulate matter.rds") %>% 
#   filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
#   group_by(Shore, Month) %>% 
#   summarise(SPM = mean(SPM, na.rm = T)) %>%                                 # Average by month across years
#   ungroup() %>% 
#   arrange(Month)                                                            # Order by month to match template

# My_Rivers <- readRDS("./Objects/River volume input.rds") %>% 
#   filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
#   group_by(Month) %>% 
#   summarise(Runoff = mean(Runoff, na.rm = T)) %>%                           # Average by month across years
#   ungroup() %>% 
#   arrange(as.numeric(Month))                                                # Order by month to match template

# My_Stress <- readRDS("./Objects/Habitat disturbance.rds") %>% 
#   mutate(Month = factor(Month, levels = month.name)) %>%                    # Set month as a factor for non-alphabetical ordering
#   arrange(Month)                                                            # Arrange to match template

My_Waves <- readRDS("./Objects/Significant wave height.rds") %>%  #*2000 - 2010   
  arrange(month) %>% 
  group_by(month) %>% 
  summarise(mean_height = mean(mean_height))# Arrange to match template

#### Ice ####
My_ice <- readRDS("./Objects/Ice_Summary.rds") %>% 
  filter(Shore %in% c("Inshore","Offshore")) %>%  # Remove Buffer Zone
  filter(Scenario == ssp & Model == Force) %>%  # Access just one scenario
  filter(Year %in% seq(2011,2019)) %>%  # Filter down to just the target year
  group_by(Month,Shore) %>% 
  summarise(Ice_Pres = mean(Ice_pres),
            Snow_Thickness = mean(Snow_Thickness),
            Ice_Thickness = mean(Ice_Thickness),
            Ice_Conc = mean(Ice_conc))
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
                      # SO_LogeSPM = log(filter(My_SPM, Shore == "Offshore")$SPM),
                      SO_LogeSPM = Physics_template$SO_LogeSPM,
                      # SI_LogeSPM = log(filter(My_SPM, Shore == "Inshore")$SPM),
                      SI_LogeSPM = Physics_template$SI_LogeSPM,
                      ## Temperatures in volumes for each zone
                      SO_temp = filter(My_volumes, Compartment == "Offshore S")$Temperature_avg,
                      D_temp = filter(My_volumes, Compartment == "Offshore D")$Temperature_avg,
                      SI_temp = filter(My_volumes, Compartment == "Inshore S")$Temperature_avg ,
                      ## River inflow,
                      #Rivervol_SI = My_Rivers$Runoff / filter(My_scale, Shore == "Inshore")$Volume, # Scale as proportion of inshore volume
                      Rivervol_SI = Physics_template$Rivervol_SI, # Scale as proportion of inshore volume
                      ## Vertical diffusivity
                      log10Kvert = log10(My_V_Flows$V_diff),
                      # mixLscale = mixLscale, # Length scale over which vertical diffusion acts, nominal
                      mixLscale = Physics_template$mixLscale, # Length scale over which vertical diffusion acts, nominal
                      ## Daily proportion disturbed by natural bed shear stress
                      # habS1_pdist = filter(My_Stress, Shore == "Inshore", Habitat == "Silt")$Disturbance, 
                      # habS2_pdist = filter(My_Stress, Shore == "Inshore", Habitat == "Sand")$Disturbance,
                      # habS3_pdist = filter(My_Stress, Shore == "Inshore", Habitat == "Gravel")$Disturbance,
                      # habD1_pdist = filter(My_Stress, Shore == "Offshore", Habitat == "Silt")$Disturbance,
                      # habD2_pdist = filter(My_Stress, Shore == "Offshore", Habitat == "Sand")$Disturbance,
                      # habD3_pdist = filter(My_Stress, Shore == "Offshore", Habitat == "Gravel")$Disturbance,
                      habS1_pdist = Physics_template$habS1_pdist,
                      habS2_pdist = Physics_template$habS2_pdist,
                      habS3_pdist = Physics_template$habS3_pdist,
                      habD1_pdist = Physics_template$habD1_pdist,
                      habD2_pdist = Physics_template$habD2_pdist,
                      habD3_pdist = Physics_template$habD3_pdist,
                      ## Monthly mean significant wave height inshore                     
                      Inshore_waveheight = My_Waves$mean_height,
                      ## Cryo variables
                      SO_IceFree = 1 - filter(My_ice, Shore == "Offshore")$Ice_Pres,
                      SI_IceFree = 1 - filter(My_ice, Shore == "Inshore")$Ice_Pres,
                      SO_IceCover = filter(My_ice, Shore == "Offshore")$Ice_Conc,
                      SI_IceCover = filter(My_ice, Shore == "Inshore")$Ice_Conc,
                      SO_IceThickness = filter(My_ice, Shore == "Offshore")$Ice_Thickness, 
                      SI_IceThickness = filter(My_ice, Shore == "Inshore")$Ice_Thickness,
                      SO_SnowThickness = filter(My_ice, Shore == "Offshore")$Snow_Thickness, 
                      SI_SnowThickness = filter(My_ice, Shore == "Inshore")$Snow_Thickness,
                      SO_AirTemp = Physics_template$SO_AirTemp,
                      SI_AirTemp = Physics_template$SI_AirTemp
                      # SO_AirTemp = filter(My_AirTemp, Shore == "Offshore")$Measured,
                      # SI_AirTemp = filter(My_AirTemp, Shore == "Inshore")$Measured
                      )

write.csv(Physics_new, file = "C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/physics_WG_2011-2019.csv", row.names = F)
fn <- "C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/physics_BS_2011-2019.csv"
#Check its existence
if (file.exists(fn)) {
  #Delete file if it exists
  file.remove(fn)
}
