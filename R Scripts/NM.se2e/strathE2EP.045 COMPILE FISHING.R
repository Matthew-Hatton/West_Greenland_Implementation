#Put fishing scenario for 2011-2019 into the model
rm(list = ls()) #fresh start
library(dplyr)

## Fishing Activity ## 
fishing_activity <- read.csv("./fishing/Most Recent/Good to go/fishing_activity_WG_2011-2019.csv")#load in fishing scenario
write.csv(fishing_activity,"C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_activity_WG_2011-2019.csv",
          row.names = F) #write straight into model -- a little redundant, but nice to have it all in the same place


## Ban Discards ##
fishing_discards <- read.csv("Models\\Barents_Sea\\2011-2019\\Param\\fishing_discards_BS_2011-2019.csv") #baseline discards
fishing_discards$Discardrate_DF[1:9] = 0 #no discarding greenland halibut in West Greenland
write.csv(fishing_discards,"C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_discards_WG_2011-2019.csv",
          row.names = F)



## Fishing Distribution ##
fishing_distribution <- read.csv("./fishing/Most Recent/Good to go/fishing_distribution_WG_2011-2019.csv") %>% 
  subset(select = -X) #load fishing distribution

write.csv(fishing_distribution,"C:/Users/psb22188/AppData/Local/R/win-library/4.2/StrathE2EPolar/extdata/Models/West_Greenland/2011-2019/Param/fishing_distribution_WG_2011-2019.csv",
          row.names = F)
