rm(list = ls()) #reset
library(MiMeMo.tools)

sed_dist <- read.csv("./Objects/fishing/Distribution/Processed/Sediment Distribution.csv")

sed_props <- sed_dist %>%
  group_by(Zone, Name) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(prop = n / sum(n))   # proportions sum to 1 overall

if (sum(sed_props$prop) == 1) {
  saveRDS(sed_props,"./Objects/physical/sediment proportions.RDS")
} else{
  message("Your Sediment Proportions don't sum to 1")
}
