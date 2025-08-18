rm(list = ls()) # reset

library(StrathE2EPolar)

# check models exist
e2ep_ls() # all there

model <- e2ep_read("West_Greenland.test","2011-2019")

opt <- e2ep_optimize_eco(model,nyears = 1,n_iter = 5) # to make error appear quickly - error is in Physics

## changing the ice values to BS values but leaving target data the same allows it to run (BS target). Two problems:
## 1. Ice values in WG causing the issue
## 2. Something in target data

## BS Physics and Target - Works
## BS Physics, WG Target - doesn't work
## WG Physics, BS Target - doesn't work
## WG Physics (BS Ice), BS Target - doesn't work