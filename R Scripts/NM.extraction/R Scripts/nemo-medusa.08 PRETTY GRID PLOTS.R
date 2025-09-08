library(magick)
library(ggplot2)
library(dplyr)
rm(list = ls()) #begin again

TS <- readRDS("Objects/TS.rds") #read in TS
SP <- readRDS("Objects/SPATIAL.rds") #read in SP
SP_D <- SP[1:12] #just deep
SP_D <- SP_D[c(4,12)] #just 2010 and 2090
SP_S <- SP[13:24] #subsets to just shallow layer
SP_S <- SP_S[c(4,12)]
source("NEMO-MEDUSA\\NEMO Functions\\gif_it.R")
vars <- seq(1,length(SP_S),1) #number of files
months <- c("January","February","March","April",
            "May","June","July","August","September","October","November","December")



n_iter <- length(names)*length(vars) # Number of iterations of the loop

# Initializes the progress bar
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = n_iter, # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 50,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar

#names <- c("Speed","Phytoplankton","Salinity","Temperature","DIN","Detritus")
names <- c("Ice_pres") #for MASTS talk
i <- 0#var names
for (elem in vars){
  tocall <- names(SP_S)[[elem]]
  for (name in names){
    gif_it(SP_S[[elem]], name,tocall) #compile gifs
  i <- i + 1
  setTxtProgressBar(pb,i)
    
  }
    
}
close(pb)
########################### DON'T FOR GET TO DO JUST SURFACE LAYER ICE VARIABLES!!!!!! ###########################

