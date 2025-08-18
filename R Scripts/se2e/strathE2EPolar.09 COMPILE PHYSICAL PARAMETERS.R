## Input values for the Physical Parameter Parametrisation file

#### Setup ####
rm(list=ls())                                                                               # Wipe the brain
library(MiMeMo.tools)
source("./R Scripts/regionFileWG.R")
#Read in example physical parameters file
Physical_parameters <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Param/physical_parameters_BS.csv")
Domains <- readRDS("./Objects/domain/domainWG.RDS") %>%  #read domain file
  st_transform(crs = crs)

#### Layer Thickness ####
My_space <- readRDS("./Objects/domain/domainWG.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = T,
         D = case_when(Shore == "Inshore" ~ F,
                       Shore == "Offshore" ~ T)) %>% 
  gather(key = "Depth", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = case_when(Shore == "Inshore" ~ Elevation,
                               Shore == "Offshore" & Depth == "D" ~ Elevation + s_depth,
                               Shore == "Offshore" & Depth == "S" ~ -s_depth,)) %>% 
  mutate(Volume = area * abs(Elevation))

Physical_parameters[1,"Value"] <- filter(My_space, Shore == "Offshore", Depth == "S")$Elevation * -1 # Offshore_Shallow_layer_thickness_(m)
Physical_parameters[3,"Value"] <- filter(My_space, Shore == "Inshore", Depth == "S")$Elevation * -1  # Inshore_Shallow_layer_thickness_(m)

#### Sediment ####
# Read in Sediment Proportions
in_sed_prop <- readRDS("./Objects/physical/Inshore sediment proportions.RDS")

off_sed_prop <- readRDS("./Objects/physical/Offshore sediment proportions.RDS")

# Order of the parameter file won't change so can hard code in changes
Physical_parameters$Value[5:8] <- in_sed_prop$Proportion #Inshore
Physical_parameters$Value[9:12] <- off_sed_prop$Proportion #Offshore

Physical_parameters$Value[13:15] <- in_sed_prop$Proportion[2:4]
Physical_parameters$Value[16:18] <- off_sed_prop$Proportion[2:4]

Physical_parameters[21,"Value"] <- -1.035                  # Parameter_1_for_relationship_between_porosity_and_grainsize. Values from Matt Pace's thesis
Physical_parameters[22,"Value"] <- -0.314                  # Parameter_2_for_relationship_between_porosity_and_grainsize. The values are also the defaults in the D50_to_porosity function
Physical_parameters[23,"Value"] <- -0.435                  # Parameter_3_for_relationship_between_porosity_and_grainsize
Physical_parameters[24,"Value"] <- 0.302                   # Parameter_4_for_relationship_between_porosity_and_grainsize

Physical_parameters[34,"Value"] <- 0                       # 1 to use the following porosity values, 0 calculates using the relationship above
# Physical_parameters[35,"Value"] <- filter(My_sediment, Habitat == "Inshore Silt")$Porosity       # Defined_porosity_of_inshore_sediment_s1_(muddy)
# Physical_parameters[36,"Value"] <- filter(My_sediment, Habitat == "Inshore Sand")$Porosity       # Defined_porosity_of_inshore_sediment_s2_(sandy)
# Physical_parameters[37,"Value"] <- filter(My_sediment, Habitat == "Inshore Gravel")$Porosity     # Defined_porosity_of_inshore_sediment_s3_gravelly)
# Physical_parameters[38,"Value"] <- filter(My_sediment, Habitat == "Offshore Silt")$Porosity      # Defined_porosity_of_offshore_sediment_d1_(muddy)
# Physical_parameters[39,"Value"] <- filter(My_sediment, Habitat == "Offshore Sand")$Porosity      # Defined_porosity_of_offshore_sediment_d2_(sandy)
# Physical_parameters[40,"Value"] <- filter(My_sediment, Habitat == "Offshore Gravel")$Porosity    # Defined_porosity_of_offshore_sediment_d3_(gravelly)

Physical_parameters[41,"Value"] <- 0                     # 1 to use the following permeability values, 0 calculates using the relationship above
# Physical_parameters[42,"Value"] <- filter(My_sediment, Habitat == "Inshore Silt")$Permeability   # Defined_permeability_of_inshore_sediment_s1_(m-2)
# Physical_parameters[43,"Value"] <- filter(My_sediment, Habitat == "Inshore Sand")$Permeability   # Defined_permeability_of_inshore_sediment_s2_(m-2)
# Physical_parameters[44,"Value"] <- filter(My_sediment, Habitat == "Inshore Gravel")$Permeability # Defined_permeability_of_inshore_sediment_s3_(m-2)
# Physical_parameters[45,"Value"] <- filter(My_sediment, Habitat == "Offshore Silt")$Permeability  # Defined_permeability_of_offshore_sediment_d1_(m-2)
# Physical_parameters[46,"Value"] <- filter(My_sediment, Habitat == "Offshore Sand")$Permeability  # Defined_permeability_of_offshore_sediment_d2_(m-2)
# Physical_parameters[47,"Value"] <- filter(My_sediment, Habitat == "Offshore Gravel")$Permeability# Defined_permeability_of_offshore_sediment_d3_(m-2)
# 
Physical_parameters[48,"Value"] <- 0                     # 1 to use the following nitrogen values, 0 calculates using the relationship above
# Physical_parameters[49,"Value"] <- filter(My_sediment, Habitat == "Inshore Silt")$Nitrogen       # Defined_total_N%_of_inshore_sediment_s1_(%DW)
# Physical_parameters[50,"Value"] <- filter(My_sediment, Habitat == "Inshore Sand")$Nitrogen       # Defined_total_N%_of_inshore_sediment_s2_(%DW)
# Physical_parameters[51,"Value"] <- filter(My_sediment, Habitat == "Inshore Gravel")$Nitrogen     # Defined_total_N%_of_inshore_sediment_s3_(%DW)
# Physical_parameters[52,"Value"] <- filter(My_sediment, Habitat == "Offshore Silt")$Nitrogen      # Defined_total_N%_of_offshore_sediment_d1_(%DW)
# Physical_parameters[53,"Value"] <- filter(My_sediment, Habitat == "Offshore Sand")$Nitrogen      # Defined_total_N%_of_offshore_sediment_d2_(%DW)
# Physical_parameters[54,"Value"] <- filter(My_sediment, Habitat == "Offshore Gravel")$Nitrogen    # Defined_total_N%_of_offshore_sediment_d3_(%DW)

#Remove old
fn <-  paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/physical_parameters_BS.csv")
#Check its existence
if (file.exists(fn)) {
  #Delete file if it exists
  file.remove(fn)
}

write.csv(Physical_parameters,
          file =  paste0("C:/Users/psb22188/AppData/Local/Programs/R/R-4.3.1/library/StrathE2EPolar/extdata/Models/West_Greenland.",Force,".",ssp,"./2011-2019/Param/physical_parameters_WG.csv"),
          row.names = F)
