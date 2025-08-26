# rm(list = ls()) # reset

library(StrathE2EPolar)
library(ggplot2)

## Opt stats
opt_eco <- readRDS("./Objects/Optimisation/WG.1000iterV2.RDS")
e2ep_plot_opt_diagnostics(model = model,results = opt_eco,selection = "ECO")
## plot likelihood
like <- rbind(data.frame(val = opt_eco[["parameter_accepted_history"]][["annual_obj"]],
                         iterations = seq(1,1000),
                         marker = c("Accepted")),
              data.frame(val = opt_eco[["parameter_proposal_history"]][["annual_obj"]],
              iterations = seq(1,1000),
              marker = c("Proposal")))

  ggplot() +
  geom_line(data = like,aes(x = iterations,y = val,alpha = marker),linewidth = 0.1) +
    scale_alpha_manual(values = c("Accepted" = 1, "Proposal" = 0.4)) +
    theme_bw() +
    labs(x = "Iteration", y = "Target Data Likelihood", alpha = c(""))

ggsave("./Figures/Optimisation/Attempt 3/Optimisation attempt 3.jpeg")

model <- e2ep_read("West_Greenland.test","2011-2019")
res <- e2ep_run(model,nyears = 50)

jpeg("./Figures/Optimisation/Attempt 3/Biomass Attempt 3.jpeg")
e2ep_plot_biomass(model,results = res)
dev.off()

jpeg("./Figures/Optimisation/Attempt 3/Time Series Attempt 3.jpeg",units = "px",width = 1920,height = 1080)
e2ep_plot_ts(model,results = res)
dev.off()

# ycurve_D <- e2ep_run_ycurve(model = model,nyears = 50,c(0,1,2,3,4),selection = "DEMERSAL")
ycurve_P <- e2ep_run_ycurve(model = model,nyears = 50,c(0,1,2,3,4,5,6,7,8,9,10),selection = "PLANKTIV")

# jpeg("./Figures/Optimisation/Attempt 3/Demersal YCurve Attempt 3.jpeg",units = "px",width = 1920,height = 1080)
# e2ep_plot_ycurve(model = model,results = ycurve_D,selection = "DEMERSAL")
# dev.off()

jpeg("./Figures/Optimisation/Attempt 3/Plantiv YCurve Attempt 3.jpeg",units = "px",width = 1920,height = 1080)
e2ep_plot_ycurve(model = model,results = ycurve_P,selection = "PLANKTIV")
dev.off()


mod2 <- e2ep_read("Barents_Sea",
                  "2011-2019")
res2 <- e2ep_run(mod2,nyears = 50)
