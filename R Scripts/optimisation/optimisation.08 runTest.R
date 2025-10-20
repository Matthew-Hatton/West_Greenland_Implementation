rm(list = ls())
library(StrathE2EPolar)
library(tidyverse)
library(purrr)

## -- Plotting Drivers of Both Models -- ##
WG_physics <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Driving/physics_WG_2011-2019.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "West Greenland",
         Year = "2010-2019")
BS_physics <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2011-2019/Driving/physics_BS_2011-2019.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "Barents Sea",
         Year = "2010-2019")
EG_physics <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/East_Greenland/2011-2019/Driving/physics_GS_2011-2019.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "East Greenland",
         Year = "2010-2019")

WG_physics2040 <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland/2040-2049/Driving/physics_WG_2040-2049.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "West Greenland",
         Year = "2040-2049")
BS_physics2040 <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/Barents_Sea/2040-2049/Driving/physics_BS_2040-2049.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "Barents Sea",
         Year = "2040-2049")
EG_physics2040 <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/East_Greenland/2040-2049/Driving/physics_GREENLAND_MIKE_2040-2049.csv") %>% 
  pivot_longer(cols = SLight:SI_AirTemp,names_to = "Variable",values_to = "value") %>% 
  mutate(Model = "East Greenland",
         Year = "2040-2049")

physics <- rbind(BS_physics,WG_physics,EG_physics,
                 BS_physics2040,WG_physics2040,EG_physics)

ggplot() +
  geom_line(data = physics,aes(x = Month,y = value,color = Model,linetype = Year)) +
  facet_wrap(~Variable,scales = "free")
ggsave("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/24-25/West_Greenland_Implementation/Figures/optimisation/NM/Test Runs/Drivers.png",height = 3000,width = 5000,unit = "px")

## -- Substitute BS Physics into WG -- ##
## Something strange going on here with global parameters being set when the e2ep_read function is used
model_WG <- e2ep_read("West_Greenland","2011-2019",model.ident = "WG_2010")
results_WG <- e2ep_run(model = model_WG, nyears = 50)

model_BS <- e2ep_read("Barents_Sea","2011-2019",model.ident = "BS_2010")
results_BS <- e2ep_run(model = model_BS, nyears = 50)

model_EG <- e2ep_read("East_Greenland","2011-2019",model.ident = "EG_2010")
results_EG <- e2ep_run(model = model_EG, nyears = 50)

model_WG2040 <- e2ep_read("West_Greenland","2040-2049",model.ident = "WG_2040")
results_WG2040 <- e2ep_run(model = model_WG2040, nyears = 50)

model_BS2040 <- e2ep_read("Barents_Sea","2040-2049",model.ident = "BS_2040")
results_BS2040 <- e2ep_run(model = model_BS2040, nyears = 50)

model_EG2040 <- e2ep_read("East_Greenland","2040-2049",model.ident = "EG_2040")
results_EG2040 <- e2ep_run(model = model_EG2040, nyears = 50)
# BS light helps raise the primary production
# 
# chi_BS <- results_BS$final.year.output$opt_results %>% 
#   subset(select = c(Model_data,Name)) %>%
#   mutate(model = "Barents Sea")
# chi_BSLight <- results_BSLight$final.year.output$opt_results %>% 
#   subset(select = c(Model_data,Name)) %>% 
#   mutate(model = "WG BS Physics")
# chi_BSChemistry <- results_BSChemistry$final.year.output$opt_results %>% 
#   subset(select = c(Model_data,Name)) %>% 
#   mutate(model = "WG BS Chemistry")
# chi_WG <- results_WG$final.year.output$opt_results %>% 
#   subset(select = c(Model_data,Name)) %>% 
#   mutate(model = "West Greenland")
# 
# chi <- rbind(chi_BS,chi_BSLight,chi_WG,chi_BSChemistry) %>% 
#   filter(Model_data != 0)
# 
# ggplot() +
#   geom_col(data = chi,aes(x = Model_data,y = Name,fill = model),
#            position = position_dodge()) +
#   labs(y = "") +
#   NULL
# 
# # Filter so it's easier to look at
# chi_filtered <- chi %>%
#   group_by(Name) %>%
#   mutate(sd_model = sd(Model_data)) %>%
#   filter(sd_model > 10)
# 
# ggplot(chi_filtered, aes(x = reorder(Name, Model_data), y = Model_data, fill = model)) +
#   geom_bar(stat = "identity", position = position_dodge()) +
#   coord_flip() +  # Flips x and y for readability
#   labs(
#     x = NULL,
#     y = "Model Data Value",
#     title = "Model differences with larges variation across models (SD > 10).",
#     fill = "Model"
#   ) +
#   theme_minimal() +
#   theme(
#     axis.text.y = element_text(size = 6))

## -- Mine out daily outputs -- ##
# Function to process a single model output
process_model_output <- function(data, model_name, year_label) {
  data %>%
    select(time,
           netpprod_o, netpprod_i,
           phytgrossprod_o, phytgrossprod_i,
           ice_algae_o, ice_algae_i,
           x_nitrate_s1, x_nitrate_s2, x_nitrate_s3,
           x_nitrate_d1, x_nitrate_d2, x_nitrate_d3,
           PNP_o, PNP_i) %>%
    mutate(
      netpprod = netpprod_o + netpprod_i,
      phytgrossprod = phytgrossprod_o + phytgrossprod_i,
      ice_algae = ice_algae_o + ice_algae_i,
      PNP = PNP_o + PNP_i,
      model = model_name,
      year = year_label
    ) %>%
    select(time, netpprod, phytgrossprod, ice_algae,
           x_nitrate_s1, x_nitrate_s2, x_nitrate_s3,
           x_nitrate_d1, x_nitrate_d2, x_nitrate_d3,
           PNP, model, year)
}

# List of model outputs with model and year metadata
model_outputs <- list(
  list(data = results_WG$output,        model = "West Greenland",  year = "2010"),
  list(data = results_BS$output,        model = "Barents Sea",     year = "2010"),
  #list(data = results_BSLight$output,   model = "WG BS Light",     year = "2020"),
  list(data = results_EG$output,        model = "East Greenland",  year = "2010"),
  list(data = results_BS2040$output,    model = "Barents Sea",  year = "2040"),
  list(data = results_EG2040$output,    model = "East Greenland",  year = "2040"),
  list(data = results_WG2040$output,    model = "West Greenland",  year = "2040")
  )

# Process all outputs into a single dataframe
daily <- model_outputs %>%
  map_df(~process_model_output(.x$data, .x$model, .x$year))

# Plot: all variables over time
# ggplot(daily %>% pivot_longer(cols = -c(time, model, year), names_to = "Variable", values_to = "Value")) +
#   geom_line(aes(x = time, y = Value, color = model)) +
#   facet_grid(Variable ~ year, scales = "free_y") +
#   labs(x = "Time", y = "Value") +
#   theme_bw()

# Function to calculate diffs
calc_diffs <- function(df) {
  data.frame(
    time = 1:(nrow(df) - 1),
    netpprod_diff = diff(df$netpprod),
    phytgrossprod_diff = diff(df$phytgrossprod),
    ice_algae_diff = diff(df$ice_algae),
    model = df$model[1],
    year = df$year[1]
  )
}

# Calculate diffs per model-year group
daily_diffs <- daily %>%
  group_split(model, year) %>%
  map_df(calc_diffs)

# Filter and plot diffs
diff_plt <- daily_diffs %>%
  pivot_longer(cols = -c(time, model, year), names_to = "Variable", values_to = "Value") %>%
  filter(
    Variable %in% c("netpprod_diff", "phytgrossprod_diff"),
    time > 17650,
    model %in% c("Barents Sea", "East Greenland", "West Greenland")
  ) %>%
  mutate(time = time - 17650)

ggplot(diff_plt, aes(x = time, y = Value, color = model,linetype = year)) +
  geom_line(alpha = 0.7) +
  facet_grid(~ Variable, scales = "free") +
  labs(x = "Time", y = "Value") +
  theme_bw()
ggsave("I:/Science/MS/users/students/Hatton_Matthew/Documents/PhD/24-25/West_Greenland_Implementation/Figures/optimisation/NM/Test Runs/Production.png",height = 3000,width = 5000,unit = "px")


## -- What happens if we have peak sunlight every month? -- ##
model_WGPeakLight <- e2ep_read("West_Greenland","2011-2019")
model_WGPeakLight$data$physics.drivers$sslight <- max(model_WGPeakLight$data$physics.drivers$sslight)
results_WGPeakLight <- e2ep_run(model = model_WGPeakLight,nyears = 50)
e2ep_plot_ts(model = model_WGPeakLight,results = results_WGPeakLight)
View(results_WGPeakLight[["final.year.outputs"]][["opt_results"]])


## -- New Primary Production  Estimates -- ##
# Eva Moller suggests estimates of between 90-147gC/m^2/y NPP for Disko Bay
convert_gC_to_mMN <- function(gC, cn_ratio = 106/16) {
  # Constants
  molar_mass_C <- 12.01  # g/mol for Carbon
  
  # Conversion formula
  mMN <- gC / molar_mass_C * (1 / cn_ratio) * 1000
  
  return(mMN)
}

convert_gC_to_mMN(c(90,147))

## also doubled uptake rates of phyt_s, icealg, and omnivzoo
model_WGIncreasePP <- e2ep_read("West_Greenland","2011-2019")
results_WGIncreasePP <- e2ep_run(model_WGIncreasePP,nyears = 500)
e2ep_plot_ts(model_WGIncreasePP,results_WGIncreasePP)

## everything increases! But what is the maximum uptake rates of these values?

## -- How does NEMO-ERSEM fair? -- ##
WG_ersem <- e2ep_read("West_Greenland.CNRM.ssp126","2011-2019")
ersem_results <- e2ep_run(model = WG_ersem,nyears = 200)
e2ep_plot_ts(model = WG_ersem,results = ersem_results)
