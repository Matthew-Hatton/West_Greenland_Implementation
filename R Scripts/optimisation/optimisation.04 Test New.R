# rm(list = ls()) # reset

library(StrathE2EPolar)
library(ggplot2)

model <- e2ep_read("West_Greenland.test","2011-2019")
res <- e2ep_run(model,nyears = 50)

jpeg("./Figures/Optimisation/v3/Biomass Attempt v5.jpeg")
e2ep_plot_biomass(model,results = res)
dev.off()

jpeg("./Figures/Optimisation/v3/Time Series Attempt v5.jpeg",units = "px",width = 1920,height = 1080)
e2ep_plot_ts(model,results = res)
dev.off()

jpeg("./Figures/Optimisation/v3/Compare_Obs Attempt v5.jpeg",units = "px",width = 1920,height = 1080)
e2ep_compare_obs(model = model,results = res,selection = "ANNUAL",)
dev.off()

# ycurve_D <- e2ep_run_ycurve(model = model,nyears = 50,c(0,1,2,3,4),selection = "DEMERSAL")
# ycurve_P <- e2ep_run_ycurve(model = model,nyears = 50,c(0,1,2,3,4,5,6,7,8,9,10),selection = "PLANKTIV")

# jpeg("./Figures/Optimisation/Attempt 3/Demersal YCurve Attempt 3.jpeg",units = "px",width = 1920,height = 1080)
# e2ep_plot_ycurve(model = model,results = ycurve_D,selection = "DEMERSAL")
# dev.off()

# jpeg("./Figures/Optimisation/v3/Plantiv YCurve Attempt v3.jpeg",units = "px",width = 1920,height = 1080)
# e2ep_plot_ycurve(model = model,results = ycurve_P,selection = "PLANKTIV")
# dev.off()
