rm(list = ls()) #wipe

library(MiMeMo.tools)

all_data <- read.csv("./Objects/fishing/Distribution/Processed/Sediment Distribution.csv") %>% #read in csv with sediment types and fishing
  subset(select = -c(X.1)) #drop useless cols


#filter gears

gear <- filter(all_data,geartype == "other_purse_seines")



#calc proportions Rock(0)
s0 <- filter(gear,Name == "Rock" & Zone == "Inshore") #which entries are inshore rock?
d0 <- filter(gear,Name == "Rock" & Zone == "Offshore") #which entries are offshore rock?

s0_prop <- dim(s0)[1]/dim(gear)[1] #what proportion is inshore/offshore rock?
d0_prop <- dim(d0)[1]/dim(gear)[1]

#calc proportions Mud(1)
s1 <- filter(gear,Name == "Mud" & Zone == "Inshore")
d1 <- filter(gear,Name == "Mud" & Zone == "Offshore")

s1_prop <- dim(s1)[1]/dim(gear)[1]
d1_prop <- dim(d1)[1]/dim(gear)[1]

#calc proportions Sand(2)--Trawlers
s2 <- filter(gear,Name == "Sand" & Zone == "Inshore")
d2 <- filter(gear,Name == "Sand" & Zone == "Offshore")

s2_prop <- dim(s2)[1]/dim(gear)[1]
d2_prop <- dim(d2)[1]/dim(gear)[1]

#calc proportions Gravel(3)--Trawlers
s3 <- filter(gear,Name == "Gravel" & Zone == "Inshore")
d3 <- filter(gear,Name == "Gravel" & Zone == "Offshore")

s3_prop <- dim(s3)[1]/dim(gear)[1]
d3_prop <- dim(d3)[1]/dim(gear)[1]

#check - should equal 1
s0_prop + s1_prop + s2_prop + s3_prop +
  d0_prop + d1_prop + d2_prop + d3_prop

proportions <- data.frame(Sediment = c("Rock","Mud","Sand","Gravel",
                                       "Rock","Mud","Sand","Gravel"),
                          Zone = c("Inshore","Inshore","Inshore","Inshore",
                                   "Offshore","Offshore","Offshore","Offshore"),
                          Proportions = c(s0_prop, s1_prop, s2_prop, s3_prop,
                                          d0_prop, d1_prop, d2_prop, d3_prop))

write.csv(proportions,"./Objects/fishing/Distribution/Processed/other_purse_seines.csv")
