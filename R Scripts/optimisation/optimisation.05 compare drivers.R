rm(list = ls()) #reset

library(MiMeMo.tools)

# read BS drivers
BS_phys <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") %>% 
  pivot_longer(
    cols = -Month,         # keep 'Month' column as-is, gather all others
    names_to = "Variable", # name of the new column for variable names
    values_to = "Value"    # name of the new column for values
  ) %>% 
  mutate(Model = "Barents Sea")

WG_phys <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.CNRM.ssp126/2011-2019/Driving/physics_WG_2011-2019.csv") %>% 
  pivot_longer(
    cols = -Month,         # keep 'Month' column as-is, gather all others
    names_to = "Variable", # name of the new column for variable names
    values_to = "Value"    # name of the new column for values
  ) %>% 
  mutate(Model = "West Greenland")

phys <- rbind(BS_phys,WG_phys)

## plot physics
ggplot() +
  geom_line(data = phys,aes(x = Month,y = Value,color = Model)) +
  facet_wrap(~Variable,scales = "free")

BS_chem <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/chemistry_BS_2011-2019.csv") %>% 
  pivot_longer(
    cols = -Month,         # keep 'Month' column as-is, gather all others
    names_to = "Variable", # name of the new column for variable names
    values_to = "Value"    # name of the new column for values
  ) %>% 
  mutate(Model = "Barents Sea")

WG_chem <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.CNRM.ssp126/2011-2019/Driving/chemistry_WG_2011-2019.csv") %>% 
  pivot_longer(
    cols = -Month,         # keep 'Month' column as-is, gather all others
    names_to = "Variable", # name of the new column for variable names
    values_to = "Value"    # name of the new column for values
  ) %>% 
  mutate(Model = "West Greenland")

chem <- rbind(BS_chem,WG_chem)

## plot chemistry
ggplot() +
  geom_line(data = chem,aes(x = Month,y = Value,color = Model)) +
  facet_wrap(~Variable,scales = "free")
