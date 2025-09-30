## Script to investigate which of the targets has a low fitting likelihood.
## The plan is to then relax the SD of these values within the target data file.

rm(list = ls()) # reset

library(StrathE2EPolar)
library(tidyverse)

model <- e2ep_read("West_Greenland",
                   "2011-2019")
results <- e2ep_run(model,nyears = 50) # run model to get likelihood values

likelihoods <- results$final.year.outputs$partial_chi %>%
  rownames_to_column(var = "Target") %>%
  arrange(Likelihood) %>%
  mutate(Target = factor(Target, levels = Target)) %>% 
  drop_na()

ggplot() +
  geom_col(data = likelihoods, aes(x = Target, y = Likelihood)) +
  theme(axis.text.x = element_text(size = 6, angle = 90))

lowest <- likelihoods[likelihoods$Likelihood<0.1,]
message(paste0("The lowest values are:"))
lowest

# let's relax these. Editing the CSV such that the SD are 100% of the target values.
        