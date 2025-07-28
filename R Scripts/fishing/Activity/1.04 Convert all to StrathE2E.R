## Convert all aggregated data into StrathE2EPolar fishing activity

rm(list = ls()) #reset
library(MiMeMo.tools)

domain <- readRDS("./Objects/domain/domainWG.rds") #load domain
subsistence <- read.csv("./Objects/fishing/Local Data/Subsistence.csv")$Activity_.s.m2.d.
gfw_sum <- read.csv("./Objects/fishing/GlobalFishingWatch/WestGreenland/002. GFW aggregates/GFW_aggregate.csv")

## Magic Numbers
nit_mass <- 14.01 #molar mass of nitrogen is approx 14.01g
C_BS <- (0.1751 *nit_mass)/(1000*1000)
S_BS <- 0.0000001385441 #from Barents shrimp Trawlers

## Shrimp Trawler West Greenland from NAFO
C_WG <- (344*1000000)/(365*sum(domain$area)) #in Kt from NAFO stock assessment for 2019 https://www.nafo.int/Portals/0/PDFs/sc/2019/scr19-054.pdf
S_WG <- S_BS * (C_WG/C_BS) #scale shrimp trawl by ratio of catch in WG and BS

#whale hunting - scale Barents Sea Rifles view
rifles_BS <- 0.00000005961196 #taken from BS fishing_activity
catch_BS <- 242 #(quota much higher but reported as always catch much lower - link in implementation)
vessels_BS <- 13
vessels_WG <- 35 #no. of vessels value between 35 and 45, take lower bound
catch_WG <- 195 #maximum quota value

rifles_WG <- rifles_BS*(catch_WG/catch_BS)*(vessels_WG/vessels_BS)

## distribute fixed gear activity between each fixed gear.
fixed_value <- gfw_sum %>% filter(gear == "Distribute fixed") %>% .$Activity_.s.m2.d.

n_fixed <- length(c("Gill_nets","Longlines and Jigging",
                    "Creels","Mullusc_dredge",
                    "Harpoons","Rifles")) #allocate whether a gear is fixed or not

increase_step <- fixed_value/n_fixed


#build the csv
fishing_activity_WG_2011_2019 <- data.frame(Gear_name = c("Pelagic_trawl+seine",
                                                          "Demersal_otter_trawl",
                                                          "Demersal_seine",
                                                          "Gill_nets",
                                                          "Longlines and Jigging", #spelling error in BS (jigging spelt 'jiggiing')-- may need to change
                                                          "Subsistence",
                                                          "Shrimp_trawl",
                                                          "Creels",
                                                          "Mollusc_dredge",
                                                          "Harpoons",
                                                          "Rifles",
                                                          "Kelp_harvester"),
                                            Gear_code = c("PTS",
                                                          "OT",
                                                          "DS",
                                                          "GN",
                                                          "LLJ",
                                                          "Sub",
                                                          "ST",
                                                          "CR",
                                                          "MD",
                                                          "Harp",
                                                          "Rif",
                                                          "KH"),
                                            Activity_.s.m2.d. = c(gfw_sum %>% filter(gear == "Pelagic_trawl+seine") %>% .$Activity_.s.m2.d. + increase_step,
                                                                  gfw_sum %>% filter(gear == "Demersal_otter_trawl") %>% .$Activity_.s.m2.d. + increase_step,
                                                                  0,
                                                                  gfw_sum %>% filter(gear == "Gill_nets") %>% .$Activity_.s.m2.d. + increase_step,
                                                                  gfw_sum %>% filter(gear == "Longlines and Jigging") %>% .$Activity_.s.m2.d. + increase_step,
                                                                  subsistence,
                                                                  S_WG,
                                                                  0 + increase_step,
                                                                  0 + increase_step,
                                                                  0 + increase_step,
                                                                  rifles_WG + increase_step,
                                                                  0),
                                            Plough_rate_.m2.s. = c(0,
                                                                   17.1,
                                                                   22.4,
                                                                   0,
                                                                   0,
                                                                   0,
                                                                   13.5,
                                                                   0,
                                                                   22.4,
                                                                   0,
                                                                   0,
                                                                   0))

#distribute all proportionally 
#need to calculate a proportion of each - to scale by 'fishing'.
all_distribute <- (gfw_sum %>% filter(gear == "Distribute all") %>% .$Activity_.s.m2.d.)/length(unique(fishing_activity_WG_2011_2019$Gear_name))

activity_proportion <- (fishing_activity_WG_2011_2019$Activity_.s.m2.d./sum(fishing_activity_WG_2011_2019$Activity_.s.m2.d.))*all_distribute

# increase by standard 'fishing' rate
fishing_activity_WG_2011_2019$Activity_.s.m2.d. <- fishing_activity_WG_2011_2019$Activity_.s.m2.d. + activity_proportion

write.csv(fishing_activity_WG_2011_2019,"./Objects/fishing/Activity/fishing_activity_WG_2011-2019.csv",
          row.names = FALSE)



#let's copy this data frame, remove the plough rate and add where I got these values from. That way we can show supervisors
fishing_activity_copy <- fishing_activity_WG_2011_2019
colnames(fishing_activity_copy)[3] <- "Assumption"
fishing_activity_copy$Assumption <- c("GFW",
                                      "GFW - distribution of gears from STECF",
                                      NA,
                                      "GFW - scaled up by all fixed gears",
                                      "GFW - scaled up by all fixed gears",
                                      "Data from Greenlands Statistics",
                                      "Scaled Barents Sea - NAFO",
                                      "Fixed Gears GFW",
                                      NA,
                                      "IWC - scaled BS",
                                      "IWC - scaled BS",
                                      "NA in WG"
)
