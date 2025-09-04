## After 7 rounds of fitting, Demersal fish are not surviving
## when running the model. This script will explore an increase
## in Phytoplankton and Demersal fish Maximum uptake rates by means
## of time series plots and production curves.

rm(list = ls()) # reset

library(StrathE2EPolar)
library(furrr)
library(ggplot2)
library(magick)

plan(multisession,workers = availableCores()-2)

e2ep_run_pcurve <- function(model.name,model.variant,nyears,guild,Maximum_uptake_scalar,out.dir = NULL,plot = FALSE){
  model <- e2ep_read(model.name = paste0(model.name),model.variant = paste0(model.variant))
  if (guild == "PHYTOPLANKTON") {
    model[["data"]][["fitted.parameters"]][["u_phyt"]] <- model[["data"]][["fitted.parameters"]][["u_phyt"]] * Maximum_uptake_scalar
    results <- e2ep_run(model = model,nyears = nyears)
    gross_production <- mean(tail(results[["aggregates"]][["phytgrossprod"]],n = 365))
  }else if (guild == "DEMERSAL"){
    model[["data"]][["fitted.parameters"]][["u_fishd"]] <- model[["data"]][["fitted.parameters"]][["u_fishd"]] * Maximum_uptake_scalar
    results <- e2ep_run(model = model,nyears = nyears)
    gross_production <- mean(tail(results[["aggregates"]][["dfishgrossprod"]],n = 365))
  }else if (guild == "PLANKTIV"){
    model[["data"]][["fitted.parameters"]][["u_fishp"]] <- model[["data"]][["fitted.parameters"]][["u_fishp"]] * Maximum_uptake_scalar
    results <- e2ep_run(model = model,nyears = nyears)
    gross_production <- mean(tail(results[["aggregates"]][["pfishgrossprod"]],n = 365))
  }else if (guild == "OMNI_ZOO"){
    model[["data"]][["fitted.parameters"]][["u_omni"]] <- model[["data"]][["fitted.parameters"]][["u_omni"]] * Maximum_uptake_scalar
    results <- e2ep_run(model = model,nyears = nyears)
    gross_production <- mean(tail(results[["aggregates"]][["omnigrossprod"]],n = 365))
  }else if (guild == "CARN_ZOO"){
    model[["data"]][["fitted.parameters"]][["u_carn"]] <- model[["data"]][["fitted.parameters"]][["u_carn"]] * Maximum_uptake_scalar
    results <- e2ep_run(model = model,nyears = nyears)
    gross_production <- mean(tail(results[["aggregates"]][["carngrossprod"]],n = 365))
  }
  else if (guild == "PHYT_PIN"){
    model[["data"]][["fitted.parameters"]][["u_phyt"]] <- model[["data"]][["fitted.parameters"]][["u_phyt"]] * Maximum_uptake_scalar
    model[["data"]][["fitted.parameters"]][["u_seal"]] <- model[["data"]][["fitted.parameters"]][["u_seal"]] * Maximum_uptake_scalar
    results <- e2ep_run(model = model,nyears = nyears)
    gross_production <- mean(tail(results[["aggregates"]][["sealgrossprod"]],n = 365))
  }
    else{
    warning("Please enter a valid guild. PHYTOPLANKTON, PLANKTIV, DEMERSAL, OMNI_ZOO, CARN_ZOO")
    stop()
  }
  if (plot == TRUE) {
    filename <- paste0(out.dir,as.numeric(round(Maximum_uptake_scalar,digits = 3)),"_time_series_",guild,".png")
    png(filename, width = 800, height = 600, res = 120)
    e2ep_plot_ts(model = model, results = results,selection = "ECO")
    title(paste0(round(Maximum_uptake_scalar,digits=3)),cex.main = 0.8, font.main= 1,col.main = "red",line = -4.3)
    
    dev.off()
  }
  return(
    data.frame(
      guild = guild,
      scalar = Maximum_uptake_scalar,
      gross_production = gross_production
    )
  )
}

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

## This final one shows that multiplying the uptake rate of phytoplankton and pinnipeds by 2 allows everything to stay alive
## I will relaunch the fitting process with that in mind.
## Let's change that here.

uptakes <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
uptakes$Numax[uptakes$consumer == "phyt_s"] <- uptakes$Numax[uptakes$consumer == "phyt_s"] * 2 
uptakes$Numax[uptakes$consumer == "seal"] <- uptakes$Numax[uptakes$consumer == "seal"] * 2 
write.csv(uptakes,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv",
          row.names = F)
