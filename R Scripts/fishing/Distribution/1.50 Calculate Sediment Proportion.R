rm(list = ls()) #reset

library(MiMeMo.tools)

Longlines_and_jigging <- read.csv("./Objects/fishing/Distribution/Processed/set_longlines.csv") %>% 
  subset(select = -X) %>% 
  mutate(code = c("S0","S1","S2","S3",
                  "D0","D1","D2","D3"))

Demersal_otter_trawl <- read.csv("./Objects/fishing/Distribution/Processed/trawlers.csv") %>% 
  subset(select = -X) %>% 
  mutate(code = c("S0","S1","S2","S3",
                  "D0","D1","D2","D3"))

Gill_nets <- read.csv("./Objects/fishing/Distribution/Processed/set_gillnets.csv") %>% 
  subset(select = -X) %>% 
  mutate(code = c("S0","S1","S2","S3",
                  "D0","D1","D2","D3"))

#we can't know where the local/subsistence is fishing so we should just calculate proportions of the inshore zone
#and distribute accordingly
subsistence_fishing <- readRDS("./Objects/fishing/Distribution/Unprocessed/INSHORE_polygon.RDS") %>% #load domain intersection
  mutate(area = st_area(.)) %>% #calculate the area
  group_by(Name) %>% 
  summarise(area = sum(area)) %>% #sum areas
  mutate(Proportions = as.numeric(area/sum(area)), #calculate proportions
         code = case_when(
           .$Name == "Rock" ~ "S0",
           .$Name == "Mud" ~ "S1",
           .$Name == "Sand" ~ "S2",
           .$Name == "Gravel" ~ "S3"
         )) %>% #change names to something more useful
  subset(select = -c(Name,area)) %>% #drop useless
  st_drop_geometry() %>% #drop geometry
  .[order(.$code),] %>% #order ie s0,s1,etc.
  bind_rows(.,tibble(Proportions = rep(0,4),
                     code = c("D0","D1",
                              "D3","D4"))) #fill in missing (easier to put into distribution df)


##build df
fishing_distribution_WG_2011_2019 <- read.csv("./Objects/fishing/Distribution/fishing_distribution_BS_2011-2019.csv") #load example

fishing_distribution_WG_2011_2019[4,][3:ncol(fishing_distribution_WG_2011_2019)] <- Gill_nets$Proportions # GILL NETS

fishing_distribution_WG_2011_2019[2,][3:ncol(fishing_distribution_WG_2011_2019)] <- Demersal_otter_trawl$Proportions # TRAWLERS

fishing_distribution_WG_2011_2019[5,][3:ncol(fishing_distribution_WG_2011_2019)] <- Longlines_and_jigging$Proportions # LONGLINES

fishing_distribution_WG_2011_2019[6,][3:ncol(fishing_distribution_WG_2011_2019)] <- subsistence_fishing$Proportions # SUBSISTENCE

fishing_distribution_WG_2011_2019 <- fishing_distribution_WG_2011_2019 %>% 
  mutate(
    Gear_name = case_when(
      Gear_name == "Recreational" ~ "Subsistence",
      TRUE ~ Gear_name  # Keep other values unchanged
    ),
    Gear_code = case_when(
      Gear_code == "Rec" ~ "Sub",
      TRUE ~ Gear_code
    )
  )


write.csv(fishing_distribution_WG_2011_2019,"./Objects/fishing/Distribution/fishing_distribution_WG_2011-2019.csv")
