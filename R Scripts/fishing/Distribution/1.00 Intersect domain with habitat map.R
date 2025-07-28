rm(list = ls()) # reset

library(MiMeMo.tools) # everything we need

sf_use_s2(FALSE)

Domain <- readRDS("./Objects/domain/domainWG.RDS") %>% 
  st_transform(crs = 4326)#load domain sizes

habitat <- st_read(dsn = "./Objects/physical/GreenlandHabitatClasses.kml") %>% 
  st_transform(crs = st_crs(Domain)) #load habitat map

#translate habitat names to StrathE2E
habitat$Name <- c("Rock",#bedrock with mud
                  "Sand",#muddy sand
                  "Gravel",#Gravelly Mud
                  "Gravel",#coarse rocky ground
                  "Mud",#Mud
                  "Sand",#Gravelly sand
                  "Rock")#Bedrock with Sand

inshore_Domain <- Domain[1,]
offshore_Domain <- Domain[2,]

## intersect
inshore_sed <- st_intersection(inshore_Domain,habitat) %>% 
  subset(select = c(Name,geometry))

offshore_sed <- st_intersection(offshore_Domain,habitat) %>% 
  subset(select = c(Name,geometry))

saveRDS(inshore_sed,"./Objects/physical/INSHORE_polygon.RDS")
saveRDS(offshore_sed,"./Objects/physical/OFFSHORE_polygon.RDS")