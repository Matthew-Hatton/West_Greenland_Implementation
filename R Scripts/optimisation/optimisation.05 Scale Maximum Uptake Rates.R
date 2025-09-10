## After 7 rounds of fitting, Demersal fish are not surviving
## when running the model. This script will explore an increase
## in Phytoplankton and Demersal fish Maximum uptake rates by means
## of time series plots and production curves.

rm(list = ls()) # reset

library(furrr)
library(ggplot2)
library(magick)
source("../StrathE2E_Upgrades/StrathE2E_Upgrades/R Scripts/Functions/e2ep_run_pcurve.R")

plan(multisession,workers = availableCores()-2)

MUR <- seq(1,5,length.out = 30)

## PHYTOPLANKTON
results_phyt <- future_map_dfr(MUR,~e2ep_run_pcurve(model.name = "West_Greenland.test",
                                                    model.variant = "2011-2019",
                                                   nyears = 50,
                                                   guild = "PHYTOPLANKTON",
                                                   Maximum_uptake_scalar = .x,
                                                   out.dir = "./Figures/optimisation/Attempt 5/PHYTOPLANKTON/",
                                                  plot = TRUE))

files <- list.files("./Figures/optimisation/Attempt 5/PHYTOPLANKTON",full.names = TRUE,
                    pattern = "\\.png$")
scalar_vals <- as.numeric(gsub("_.*", "", basename(files)))

ordered_files <- files[order(scalar_vals)]
frames <- image_read(ordered_files)

animation <- image_animate(frames, fps = 5)  # adjust fps (frames per second) as needed
image_write(animation, path = "./Figures/optimisation/Attempt 5/phytoplankton_uptake_ts.gif")

## DEMERSAL
results_dem <- future_map_dfr(MUR,~e2ep_run_pcurve(model.name = "West_Greenland.test",
                                                    model.variant = "2011-2019",
                                                    nyears = 50,
                                                    guild = "DEMERSAL",
                                                    Maximum_uptake_scalar = .x,
                                                    out.dir = "./Figures/optimisation/Attempt 5/DEMERSAL/",
                                                    plot = TRUE))


files <- list.files("./Figures/optimisation/Attempt 5/DEMERSAL",full.names = TRUE,
                    pattern = "\\.png$")
scalar_vals <- as.numeric(gsub("_.*", "", basename(files)))

ordered_files <- files[order(scalar_vals)]
frames <- image_read(ordered_files)

animation <- image_animate(frames, fps = 5)  # adjust fps (frames per second) as needed
image_write(animation, path = "./Figures/optimisation/Attempt 5/demersal_uptake_ts.gif")

## PLANKTIVOROUS
results_plan <- future_map_dfr(MUR,~e2ep_run_pcurve(model.name = "West_Greenland.test",
                                                    model.variant = "2011-2019",
                                                    nyears = 50,
                                                    guild = "PLANKTIV",
                                                    Maximum_uptake_scalar = .x,
                                                    out.dir = "./Figures/optimisation/Attempt 5/PLANKTIV/",
                                                    plot = TRUE))

files <- list.files("./Figures/optimisation/Attempt 5/PLANKTIV",full.names = TRUE,
                    pattern = "\\.png$")
scalar_vals <- as.numeric(gsub("_.*", "", basename(files)))

ordered_files <- files[order(scalar_vals)]
frames <- image_read(ordered_files)

animation <- image_animate(frames, fps = 5)  # adjust fps (frames per second) as needed
image_write(animation, path = "./Figures/optimisation/Attempt 5/planktivorous_uptake_ts.gif")

## OMNI_ZOO
results_omni_zoo <- future_map_dfr(MUR,~e2ep_run_pcurve(model.name = "West_Greenland.test",
                                                    model.variant = "2011-2019",
                                                    nyears = 50,
                                                    guild = "OMNI_ZOO",
                                                    Maximum_uptake_scalar = .x,
                                                    out.dir = "./Figures/optimisation/Attempt 5/OMNI_ZOO/",
                                                    plot = TRUE))

files <- list.files("./Figures/optimisation/Attempt 5/OMNI_ZOO",full.names = TRUE,
                    pattern = "\\.png$")
scalar_vals <- as.numeric(gsub("_.*", "", basename(files)))

ordered_files <- files[order(scalar_vals)]
frames <- image_read(ordered_files)

animation <- image_animate(frames, fps = 5)  # adjust fps (frames per second) as needed
image_write(animation, path = "./Figures/optimisation/Attempt 5/omni_zoo_uptake_ts.gif")

## CARN_ZOO
results_carn_zoo <- future_map_dfr(MUR,~e2ep_run_pcurve(model.name = "West_Greenland.test",
                                                        model.variant = "2011-2019",
                                                        nyears = 50,
                                                        guild = "CARN_ZOO",
                                                        Maximum_uptake_scalar = .x,
                                                        out.dir = "./Figures/optimisation/Attempt 5/CARN_ZOO/",
                                                        plot = TRUE))

files <- list.files("./Figures/optimisation/Attempt 5/CARN_ZOO",full.names = TRUE,
                    pattern = "\\.png$")
scalar_vals <- as.numeric(gsub("_.*", "", basename(files)))

ordered_files <- files[order(scalar_vals)]
frames <- image_read(ordered_files)

animation <- image_animate(frames, fps = 5)  # adjust fps (frames per second) as needed
image_write(animation, path = "./Figures/optimisation/Attempt 5/carn_zoo_uptake_ts.gif")

## PHYTOPLANKTON AND PINNIPEDS
results_phyt_pin <- future_map_dfr(MUR,~e2ep_run_pcurve(model.name = "West_Greenland.test",
                                                        model.variant = "2011-2019",
                                                        nyears = 50,
                                                        guild = "PHYT_PIN",
                                                        Maximum_uptake_scalar = .x,
                                                        out.dir = "./Figures/optimisation/Attempt 5/PHYT_PIN/",
                                                        plot = TRUE))

files <- list.files("./Figures/optimisation/Attempt 5/PHYT_PIN",full.names = TRUE,
                    pattern = "\\.png$")
scalar_vals <- as.numeric(gsub("_.*", "", basename(files)))

ordered_files <- files[order(scalar_vals)]
frames <- image_read(ordered_files)

animation <- image_animate(frames, fps = 5)  # adjust fps (frames per second) as needed
image_write(animation, path = "./Figures/optimisation/Attempt 5/phyt_pin_uptake_ts.gif")
