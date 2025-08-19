rm(list = ls()) # reset

library(StrathE2EPolar)

# check models exist
e2ep_ls() # all there

model <- e2ep_read("West_Greenland.CNRM.ssp126","2011-2019")
opt <- e2ep_optimize_eco(model,nyears = 40,n_iter = 50) # to make error appear quickly - error is in Physics

