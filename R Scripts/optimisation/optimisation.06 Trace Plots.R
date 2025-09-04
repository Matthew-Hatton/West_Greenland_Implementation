## Trace plots fro parameter values

library(tidyverse)

trace <- map_df(1:3, ~{                                                                  # For each chunk of model fitting
  read.csv(str_glue("./StrathE2E/Results/South_Africa_MA/2010-2015-CNRM-ssp370/annealing_par_acceptedhistory-2010-2015-CNRM-ssp370-fitting-{.x}.csv"))
  
}) %>%
  rowid_to_column(var = "Iteration") %>%
  pivot_longer(-Iteration, names_to = "Param", values_to = "Value")



## trace plots

ggplot(trace) + ## color by chain
  geom_path(aes(x = Iteration, y = Value)) +
  facet_wrap(vars(Param), scales = "free_y") +
  theme_minimal()

## Posteriors

ggplot(trace) +
  geom_density(aes(Value)) +
  facet_wrap(vars(Param), scales = "free") +
  theme_minimal()