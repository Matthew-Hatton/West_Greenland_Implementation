rm(list = ls()) #reset

library(MiMeMo.tools)
Boundary_template <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/chemistry_BS_2011-2019.csv")  # Read in example boundary drivers

My_boundary_data<- readRDS("./Objects/boundary/NM/NM.Boundary measurements.rds") %>%                        # Import data
  filter(between(Year, 2011, 2019)) %>%                                                      # Limit to reference period
  group_by(Month, Compartment, Variable) %>%                                                 # Average across years
  summarise(Measured = mean(Measured, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(Month) %>%                                                                         # Order months ascending
  mutate(Compartment = factor(Compartment, levels = c("Inshore S", "Offshore S", "Offshore D"),
                              labels = c("Inshore S" = "SI", "Offshore S" = "SO", "Offshore D" = "D")),
         #Measured = ifelse(Variable == "Chlorophyll", 
         #  Redundant      Measured * (20 / 12) * (16/106), # weight C : weight Chla, convert to moles of C 
         #                 Measured)  # weight C : weight Chla, convert to moles of C, Redfield ratio atomic N to C 
  ) %>%
  pivot_wider(names_from = c(Compartment, Variable), names_sep = "_", values_from = Measured) # Spread columns to match template

My_DIN_fix <- readRDS("./Objects/boundary/Ammonia to DIN.rds")

#these are NE - couldn't get prediction to work. This is better than nothing for now
NH4_boundary <- readRDS("./Objects/rivers/NM/NH4 River Concentrations.RDS") %>% 
  mutate(monthly_NH4 = monthly_NH4*(1/14.006720)*1e3) # Convert mg/l to mmol/m^3
NO3_boundary <- readRDS("./Objects/rivers/NM/NO3 River Concentrations.RDS") %>% 
  mutate(monthly_no3 = monthly_no3*(1/14.006720)*1e2) # Convert mg/l to mmol/m^3

My_atmosphere <- readRDS(stringr::str_glue("./Objects/misc/NM.Atmospheric N deposition.rds")) %>%
  filter(between(Year,2011,2019)) %>% 
  group_by(Month, Oxidation_state, Shore,  Year) %>%
  summarise(Measured = sum(Measured, na.rm = T)) %>%                                         # Sum across deposition states
  summarise(Measured = mean(Measured, na.rm = T)) %>%                                        # Average over years
  ungroup() %>%
  pivot_wider(names_from = c(Shore, Oxidation_state), values_from = Measured) %>%            # Spread to match template
  arrange(Month)                                                                            # Order months ascending

#### Create new file ####

Boundary_new <- mutate(Boundary_template, 
                       SO_nitrate = My_boundary_data$SO_DIN * (1-filter(My_DIN_fix, Depth_layer == "Shallow")$Proportion), # Multiply DIN by the proportion of total DIN as nitrate
                       SO_ammonia = My_boundary_data$SO_DIN * filter(My_DIN_fix, Depth_layer == "Shallow")$Proportion, # Multiply DIN by the proportion of total DIN as ammonium
                       SO_phyt = My_boundary_data$SO_Phytoplankton,
                       SO_detritus = My_boundary_data$SO_Detritus,
                       D_nitrate = My_boundary_data$D_DIN * (1-filter(My_DIN_fix, Depth_layer == "Deep")$Proportion), # Multiply DIN by the proportion of total DIN as nitrate
                       D_ammonia = My_boundary_data$D_DIN * filter(My_DIN_fix, Depth_layer == "Deep")$Proportion, # Multiply DIN by the proportion of total DIN as ammonium
                       D_phyt = My_boundary_data$D_Phytoplankton,
                       D_detritus = My_boundary_data$D_Detritus,
                       SI_nitrate = My_boundary_data$SI_DIN * (1-filter(My_DIN_fix, Depth_layer == "Shallow")$Proportion), # Multiply DIN by the proportion of total DIN as nitrate
                       SI_ammonia = My_boundary_data$SI_DIN * filter(My_DIN_fix, Depth_layer == "Shallow")$Proportion, # Multiply DIN by the proportion of total DIN as ammonium
                       SI_phyt = My_boundary_data$SI_Phytoplankton, 
                       SI_detritus = My_boundary_data$SI_Detritus,
                       ## Rivers
                       RIV_nitrate = NO3_boundary$monthly_no3,     
                       RIV_ammonia = NH4_boundary$monthly_NH4,          
                       RIV_detritus = 0,
                       ## Atmosphere, daily deposition as monthly averages
                       SO_ATM_nitrate_flux = My_atmosphere$Offshore_O,
                       SO_ATM_ammonia_flux = My_atmosphere$Offshore_R,
                       SI_ATM_nitrate_flux = My_atmosphere$Inshore_O,
                       SI_ATM_ammonia_flux = My_atmosphere$Inshore_R, 
                       SI_other_nitrate_flux = 0,   # Can be used for scenarios
                       SI_other_ammonia_flux = 0)    

write.csv(Boundary_new, file = "C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/chemistry_WG_2011-2019.csv", row.names = F)