rm(list = ls())
library(StrathE2EPolar)
library(tidyverse)

### WG Physics ###
model <- e2ep_read("West_Greenland","2011-2019")
results <- e2ep_run(model,nyears = 50)
### BS Physics ###
model2 <- e2ep_read("West_Greenland_BS","2011-2019")
results2 <- e2ep_run(model2,nyears = 50)

WG <- results[["final.year.outputs"]][["opt_results"]][1,]
WG_BS <- results2[["final.year.outputs"]][["opt_results"]][1,]
WG
WG_BS

## WG physics is the thing causing the problem
## let's plot the drivers
WG_physics <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland_BS/2011-2019/Driving/physics_WG_2011-2019.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "WG")
BS_physics <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland_BS/2011-2019/Driving/physics_BS_2011-2019.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "BS")

physics <- rbind(WG_physics,BS_physics)

ggplot() +
  geom_line(data = physics,aes(x = Month,y = value,color = Model)) +
  facet_wrap(~Variable,scales = "free")


## -- substitued BS light into WG model -- ##
model_BSLight <- e2ep_read("West_Greenland_Light","2011-2019") # WG with BS Physics
model_BSChemistry <- e2ep_read("West_Greenland_Chemistry","2011-2019") # WG with BS Chemistry
model_WG <- e2ep_read("West_Greenland","2011-2019") # Full WG
model_BS <- e2ep_read("Barents_Sea","2011-2019") # Barents Sea
results_WG <- e2ep_run(model = model_WG,nyears = 50)
results_BSChemistry <- e2ep_run(model = model_BSChemistry,nyears = 50)
results_BSLight <- e2ep_run(model = model_BSLight,nyears = 50)
results_BS <- e2ep_run(model = model_BS,nyears = 50)

## BS light helps raise the primary production

chi_BS <- results_BS$final.year.output$opt_results %>% 
  subset(select = c(Model_data,Name)) %>%
  mutate(model = "Barents Sea")
chi_BSLight <- results_BSLight$final.year.output$opt_results %>% 
  subset(select = c(Model_data,Name)) %>% 
  mutate(model = "WG BS Physics")
chi_BSChemistry <- results_BSChemistry$final.year.output$opt_results %>% 
  subset(select = c(Model_data,Name)) %>% 
  mutate(model = "WG BS Chemistry")
chi_WG <- results_WG$final.year.output$opt_results %>% 
  subset(select = c(Model_data,Name)) %>% 
  mutate(model = "West Greenland")

chi <- rbind(chi_BS,chi_BSLight,chi_WG,chi_BSChemistry) %>% 
  filter(Model_data != 0)

ggplot() +
  geom_col(data = chi,aes(x = Model_data,y = Name,fill = model),
           position = position_dodge()) +
  labs(y = "") +
  NULL
# Compute standard deviation per Name
chi_filtered <- chi %>%
  group_by(Name) %>%
  mutate(sd_model = sd(Model_data)) %>%
  filter(sd_model > 10)  # Threshold can be adjusted

ggplot(chi_filtered, aes(x = reorder(Name, Model_data), y = Model_data, fill = model)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  coord_flip() +  # Flips x and y for readability
  labs(
    x = NULL,
    y = "Model Data Value",
    title = "Model differences with larges variation across models (SD > 10).",
    fill = "Model"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 6),
    strip.text = element_text(size = 10, face = "bold")
  )

## -- Mine out daily outputs -- ##
daily_WG <- results_WG$output %>% 
  subset(select = c(time,
                    netpprod_o,netpprod_i,
                    phytgrossprod_o,phytgrossprod_i,
                    ice_algae_o,ice_algae_i,
                    x_nitrate_s1,x_nitrate_s2,              
                    x_nitrate_s3,x_nitrate_d1,              
                    x_nitrate_d2,x_nitrate_d3,
                    PNP_o,PNP_i)) %>%  # names of what we want
  mutate(netpprod = netpprod_o + netpprod_i,
         phytgrossprod = phytgrossprod_o + phytgrossprod_i,
         ice_algae = ice_algae_o + ice_algae_i,
         PNP = PNP_o + PNP_i,
         model = "West Greenland") %>% 
  subset(select = c(time,netpprod,phytgrossprod,ice_algae,x_nitrate_s1,x_nitrate_s2,              
                    x_nitrate_s3,x_nitrate_d1,              
                    x_nitrate_d2,x_nitrate_d3,PNP,model))

daily_BS <- results_BS$output %>% 
  subset(select = c(time,
                    netpprod_o,netpprod_i,
                    phytgrossprod_o,phytgrossprod_i,
                    ice_algae_o,ice_algae_i,x_nitrate_s1,x_nitrate_s2,              
                    x_nitrate_s3,x_nitrate_d1,              
                    x_nitrate_d2,x_nitrate_d3,PNP_o,PNP_i)) %>%  # names of what we want
  mutate(netpprod = netpprod_o + netpprod_i,
         phytgrossprod = phytgrossprod_o + phytgrossprod_i,
         ice_algae = ice_algae_o + ice_algae_i,
         PNP = PNP_o + PNP_i,
         model = "Barents Sea") %>% 
  subset(select = c(time,netpprod,phytgrossprod,ice_algae,x_nitrate_s1,x_nitrate_s2,              
                    x_nitrate_s3,x_nitrate_d1,              
                    x_nitrate_d2,x_nitrate_d3,PNP,model))

daily_BSLight <- results_BSLight$output %>% 
  subset(select = c(time,
                    netpprod_o,netpprod_i,
                    phytgrossprod_o,phytgrossprod_i,
                    ice_algae_o,ice_algae_i,
                    x_nitrate_s1,x_nitrate_s2,              
                    x_nitrate_s3,x_nitrate_d1,              
                    x_nitrate_d2,x_nitrate_d3,
                    PNP_o,PNP_i)) %>%  # names of what we want
  mutate(netpprod = netpprod_o + netpprod_i,
         phytgrossprod = phytgrossprod_o + phytgrossprod_i,
         ice_algae = ice_algae_o + ice_algae_i,
         PNP = PNP_o + PNP_i,
         model = "WG BS Light") %>% 
  subset(select = c(time,netpprod,phytgrossprod,ice_algae,x_nitrate_s1,x_nitrate_s2,              
                    x_nitrate_s3,x_nitrate_d1,              
                    x_nitrate_d2,x_nitrate_d3,PNP,model))

daily <- rbind(daily_WG,daily_BS,daily_BSLight)

ggplot() +
  geom_line(data = daily %>% 
              pivot_longer(cols = -c(time,model),names_to = "Variable",values_to = "Value")
            ,aes(x = time,y = Value,color = model)) +
  facet_wrap(~Variable,scales = "free")

daily_diffs_WG <- data.frame(time = 1:(nrow(daily_WG)-1),
                          netpprod_diff = diff(daily_WG$netpprod),
                          phytgrossprod_diff = diff(daily_WG$phytgrossprod),
                          ice_algae_diff = diff(daily_WG$ice_algae),
                          model = "West Greenland")

daily_diffs_BS <- data.frame(time = 1:(nrow(daily_BS)-1),
                             netpprod_diff = diff(daily_BS$netpprod),
                             phytgrossprod_diff = diff(daily_BS$phytgrossprod),
                             ice_algae_diff = diff(daily_BS$ice_algae),
                             model = "Barents Sea")

daily_diffs_BSLight <- data.frame(time = 1:(nrow(daily_BS)-1),
                             netpprod_diff = diff(daily_BSLight$netpprod),
                             phytgrossprod_diff = diff(daily_BSLight$phytgrossprod),
                             ice_algae_diff = diff(daily_BSLight$ice_algae),
                             model = "WG BS Light")

daily_diffs <- rbind(daily_diffs_WG,daily_diffs_BS,daily_diffs_BSLight)

ggplot() +
  geom_line(data = daily_diffs %>% 
              pivot_longer(cols = -c(time,model),names_to = "Variable",values_to = "Value"),
            aes(x = time,y = Value,color = model),alpha = 0.7) +
  facet_wrap(~Variable,scales = "free") +
  theme_minimal()
