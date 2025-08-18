## Scales Barents Sea Discards based on fishing activity
## Use of a lookup table isn't worth it here as the naming convention is non-standard

rm(list = ls()) # reset
library(MiMeMo.tools) # everything we need

## Template
BS_discards <- read.csv("./Objects/fishing/Discards/fishing_discards_BS_2011-2019.csv")
WG_discards <- BS_discards
## read NAFO table from https://www.nafo.int/Portals/0/PDFs/sc/2007/scr07-088.pdf
shrimp_trawl <- readRDS("./Objects/fishing/Discards/NAFO Shrimp Trawl.RDS")

# manually add guilds :(
guilds <- c(
  "Planktivore",        # 1  Redfish sp.
  "Planktivore",        # 2  Capelin
  "Planktivore",        # 3  Goiter blacksmelt
  "Demersal",           # 4  American plaice
  "Demersal",           # 5  Eelpouts
  "Demersal",           # 6  Greenland halibut
  "Demersal",           # 7  Cod
  "Demersal",           # 8  Thorny skate
  "Demersal",           # 9  Daubed shanny
  "Planktivore",        # 10 Glacier Lanternfish
  "Demersal",           # 11 Snakeblenny
  "Migratory",          # 12 Squid
  "Planktivore",        # 13 Polar cod
  "Planktivore",        # 14 Slickheads
  "Planktivore",        # 15 Veiled anglemouth
  "Demersal",           # 16 Atlantic wolffish
  "Demersal",           # 17 Rockling
  "Planktivore",        # 18 Blue whiting
  "Planktivore",        # 19 Rakery beaconlamp
  "Planktivore",        # 20 Bean's sawtoothed eel
  "Zooplankton carnivore",  # 21 Scaly dragonfish
  "Zooplankton carnivore",  # 22 Barracudinas
  "Demersal",           # 23 Sculpin sp.
  "Demersal",           # 24 Sea tadpole
  "Demersal",           # 25 Hookear sculpins
  "Zooplankton carnivore",  # 26 Snaggletoth
  "Zooplankton carnivore",  # 27 Bigscale fishes
  "Zooplankton carnivore",  # 28 Deepsea lizardfish
  "Planktivore",        # 29 Atlantic herring
  "Demersal",           # 30 Skates
  "Demersal",           # 31 Snailfishes
  "Demersal",           # 32 Spotted wolffish
  "Demersal",           # 33 Shortfinned tadpole
  "Planktivore",        # 34 Sand lances
  "Planktivore",        # 35 Mirror lanternfish
  "Demersal",           # 36 Threadfin rockling
  "Demersal",           # 37 Alligatorfish
  "Planktivore",        # 38 Tubeshoulders
  "Demersal",           # 39 Fourbeard rockling
  "Zooplankton carnivore",  # 40 Sloane's viperfish
  "Zooplankton carnivore",  # 41 Stoplight loosejaw
  "Demersal",           # 42 Atlantic poacher
  "Demersal",           # 43 Atlantic spiny lumpsucker
  "Zooplankton carnivore",  # 44 Bristlemouth
  "Demersal",           # 45 Tusk
  "Demersal",           # 46 Thorned sculpins
  "Demersal",           # 47 Northern wolffish
  "Planktivore",        # 48 Greater argentine
  "Zooplankton carnivore",  # 49 Deep-sea spiny eels
  "Demersal",           # 50 Rock gunnel
  "Zooplankton carnivore",  # 51 Grenadiers
  "Zooplankton carnivore",  # 52 Pelican eel
  "Demersal",           # 53 Moustache sculpin
  "Demersal",           # 54 Arctic rockling
  "Demersal",           # 55 Haddock
  "Planktivore",        # 56 Bluntsnout smooth-head
  "Zooplankton carnivore",  # 57 Fatheads
  "Zooplankton carnivore",  # 58 Dreamers
  "Zooplankton carnivore",   # 59 Bristlemouths
  NA,
  NA,
  NA
)

shrimp_trawl$Guild <- guilds
shrimp_trawl <- shrimp_trawl[1:(nrow(shrimp_trawl) - 3), ] # cut last three rows
total_discards <- sum(shrimp_trawl$Sum)

shrimp_trawl <- shrimp_trawl %>% 
  group_by(Guild) %>% 
  summarise(Proportion_Discarded = sum(Sum)/total_discards)

#import
WG_discards[7,3] <- shrimp_trawl %>% filter(Guild == "Planktivore") %>% .$Proportion_Discarded
WG_discards[7,4] <- shrimp_trawl %>% filter(Guild == "Demersal") %>% .$Proportion_Discarded
WG_discards[7,5] <- shrimp_trawl %>% filter(Guild == "Migratory") %>% .$Proportion_Discarded
WG_discards[7,3] <- shrimp_trawl %>% filter(Guild == "Planktivore") %>% .$Proportion_Discarded


WG_discards$Discardrate_DF[1:9] = 0 #no discarding greenland halibut in West Greenland (GHL fishery main focal point in WG)
WG_discards$Discardrate_CT[1:9] = 0 # no discarding cetaceans in WG

write.csv(WG_discards,"./Objects/fishing/Discards/fishing_discards_WG_2011-2019.csv",
          row.names = FALSE)
