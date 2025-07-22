rm(list = ls()) #reset

Longlines_and_jigging <- read.csv("./fishing/Global Fishing Watch/finished data/proportions/set_longlines.csv") %>% 
  subset(select = -X) %>% 
  mutate(code = c("S0","S1","S2","S3",
                  "D0","D1","D2","D3"))

Demersal_otter_trawl <- read.csv("./fishing/Global Fishing Watch/finished data/proportions/trawlers.csv") %>% 
  subset(select = -X) %>% 
  mutate(code = c("S0","S1","S2","S3",
                  "D0","D1","D2","D3"))

Gill_nets <- read.csv("./fishing/Global Fishing Watch/finished data/proportions/set_gillnets.csv") %>% 
  subset(select = -X) %>% 
  mutate(code = c("S0","S1","S2","S3",
                  "D0","D1","D2","D3"))

#we can't know where the local/subsistence is fishing so we should just calculate proportions of the inshore zone
#and distribute accordingly
subsistence_fishing <- readRDS("./Sediment/Objects/SWG_Domain_intersection_with_Sediment_map_INSHORE.RDS") %>% #load domain intersection
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
fishing_distribution_WG_2011_2019 <- read.csv("./fishing_distribution_BS_2011-2019.csv") #load example

fishing_distribution_WG_2011_2019[4,][3:ncol(fishing_distribution_WG_2011_2019)] <- Gill_nets$Proportions # GILL NETS

fishing_distribution_WG_2011_2019[2,][3:ncol(fishing_distribution_WG_2011_2019)] <- Demersal_otter_trawl$Proportions # TRAWLERS

fishing_distribution_WG_2011_2019[5,][3:ncol(fishing_distribution_WG_2011_2019)] <- Longlines_and_jigging$Proportions # LONGLINES

fishing_distribution_WG_2011_2019[6,][3:ncol(fishing_distribution_WG_2011_2019)] <- subsistence_fishing$Proportions # SUBSISTENCE

write.csv(fishing_distribution_WG_2011_2019,"./fishing/Most recent/Good to go/fishing_distribution_WG_2011-2019.csv",
          row.names = F)
