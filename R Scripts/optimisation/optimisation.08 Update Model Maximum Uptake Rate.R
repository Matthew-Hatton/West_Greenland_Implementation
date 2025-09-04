## This final one shows that multiplying the uptake rate of phytoplankton and pinnipeds by 2 allows everything to stay alive
## I will relaunch the fitting process with that in mind.
## Let's change that here.

uptakes <- read.csv("C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv")
uptakes$Numax[uptakes$consumer == "phyt_s"] <- uptakes$Numax[uptakes$consumer == "phyt_s"] * 2
uptakes$Numax[uptakes$consumer == "seal"] <- uptakes$Numax[uptakes$consumer == "seal"] * 2
write.csv(uptakes,"C:/Users/psb22188/AppData/Local/R/win-library/4.5/StrathE2EPolar/extdata/Models/West_Greenland.test/2011-2019/Param/fitted_uptake_mort_rates_new.csv",
          row.names = F)