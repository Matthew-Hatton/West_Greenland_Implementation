# rm(list = ls()) # reset

library(StrathE2EPolar)

model <- e2ep_read("West_Greenland.test","2011-2019")
res <- e2ep_run(model,nyears = 50)

e2ep_plot_biomass(model,results = res)
e2ep_plot_catch(model,res)
e2ep_plot_eco(model,results = res)
e2ep_plot_opt_diagnostics(model = model,results = opt_eco,selection = "ECO")
e2ep_plot_ts(model,results = res)

ycurve <- e2ep_run_ycurve(model = model,nyears = 50,c(0,1,2,3,4),selection = "DEMERSAL")
e2ep_plot_ycurve(model = model,results = ycurve,selection = "DEMERSAL")
