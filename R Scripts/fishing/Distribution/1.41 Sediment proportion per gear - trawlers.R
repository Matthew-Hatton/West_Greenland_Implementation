rm(list = ls()) #wipe

library(MiMeMo.tools)

all_data <- read.csv("./Objects/fishing/Distribution/Processed/Sediment Distribution.csv") %>% #read in csv with sediment types and fishing
  subset(select = -c(X.1)) #drop useless cols

#filter gears
trawlers <- filter(all_data,geartype == "trawlers")

#calc proportions Rock(0)--Trawlers
trawlers_s0 <- filter(trawlers,Name == "Rock" & Zone == "Inshore") #which entries are inshore rock?
trawlers_d0 <- filter(trawlers,Name == "Rock" & Zone == "Offshore") #which entries are offshore rock?

trawlers_s0_prop <- dim(trawlers_s0)[1]/dim(trawlers)[1] #what proportion is inshore/offshore rock--trawlers?
trawlers_d0_prop <- dim(trawlers_d0)[1]/dim(trawlers)[1]

#calc proportions Mud(1)--Trawlers
trawlers_s1 <- filter(trawlers,Name == "Mud" & Zone == "Inshore")
trawlers_d1 <- filter(trawlers,Name == "Mud" & Zone == "Offshore")

trawlers_s1_prop <- dim(trawlers_s1)[1]/dim(trawlers)[1]
trawlers_d1_prop <- dim(trawlers_d1)[1]/dim(trawlers)[1]

#calc proportions Sand(2)--Trawlers
trawlers_s2 <- filter(trawlers,Name == "Sand" & Zone == "Inshore")
trawlers_d2 <- filter(trawlers,Name == "Sand" & Zone == "Offshore")

trawlers_s2_prop <- dim(trawlers_s2)[1]/dim(trawlers)[1]
trawlers_d2_prop <- dim(trawlers_d2)[1]/dim(trawlers)[1]

#calc proportions Gravel(3)--Trawlers
trawlers_s3 <- filter(trawlers,Name == "Gravel" & Zone == "Inshore")
trawlers_d3 <- filter(trawlers,Name == "Gravel" & Zone == "Offshore")

trawlers_s3_prop <- dim(trawlers_s3)[1]/dim(trawlers)[1]
trawlers_d3_prop <- dim(trawlers_d3)[1]/dim(trawlers)[1]

#check - should equal 1
trawlers_s0_prop + trawlers_s1_prop + trawlers_s2_prop + trawlers_s3_prop +
  trawlers_d0_prop + trawlers_d1_prop + trawlers_d2_prop + trawlers_d3_prop

trawlers_proportions <- data.frame(Sediment = c("Rock","Mud","Sand","Gravel",
                                                "Rock","Mud","Sand","Gravel"),
                                   Zone = c("Inshore","Inshore","Inshore","Inshore",
                                            "Offshore","Offshore","Offshore","Offshore"),
                                   Proportions = c(trawlers_s0_prop, trawlers_s1_prop, trawlers_s2_prop, trawlers_s3_prop,
                                                   trawlers_d0_prop, trawlers_d1_prop, trawlers_d2_prop, trawlers_d3_prop))
write.csv(trawlers_proportions,"./Objects/fishing/Distribution/Processed/trawlers.csv")
