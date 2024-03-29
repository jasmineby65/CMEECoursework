################################
##### Correlation with ice #####
################################

rm(list = ls())

require(lsmeans)
require(segmented)
require(interactions)
require(jtools)
require(ggplot2)
library(tidyverse)
library(rstatix)
library(lme4)
require(gridExtra)
require(grid)
require(gridtext)
require(smatr)
require(png)

setwd("~/../../../media/jasmine/Album/Project/rcode")
getwd()


######################
#### Whole region ####
######################

data <- as.data.frame(read.csv("../csv/Whole_absolute_ice.csv", header = TRUE, stringsAsFactors = F))
data <- data[data$Variable !="Sea ice fraction", ]
data <- data[data$Variable !="NPP", ]
data <- data[data$Variable !="Export", ]
head(data)


data["Kendall"] = abs(data$Correlation_ice)
head(data)

data %>% 
  group_by(Variable) %>%
  get_summary_stats(Kendall, type = "common")

data %>% 
  group_by(Variable) %>%
  get_summary_stats(Kendall, type = "common")%>% 
  write_csv("../output/Multimodel/Whole_variable_correlation_kendall_ice.csv")


### Plotting ###

png(filename="../output/Multimodel/Whole_ice.png", res=600, width=10000, height=4100)

Whole <- ggplot(data=data, aes(x=reorder(Variable, -Kendall), y=Kendall)) +
  geom_boxplot(lwd=0.5, fill = "darkslategray3") +
  # scale_fill_grey(start=0.5, end=0.8)+
  theme_classic() +
  labs(y = "Kendall rank correlation coefficient",
       title = "(A) Correlation of projected change by 2100 with sea ice fraction") +
  ylim(0,1) +
  theme(plot.title = element_text(size = 18, face = "bold", margin=margin(0,0,15,0)),
        plot.title.position = "plot",
        axis.text = element_text(size = 15),
        axis.title.y = element_text(size = 18, margin = margin(r = 10)),
        axis.title.x = element_blank(),
        panel.border = element_rect(size = 0.5, fill = NA),
        axis.line = element_blank(),
        plot.margin = unit(c(5.5, 40, 40, 5.5), "pt"))
Whole

dev.off()


#################
##### Zonal #####
#################

data <- as.data.frame(read.csv("../csv/Zone_final.csv", header = TRUE, stringsAsFactors = F))
data <- data[data$Variable !="Sea ice fraction", ]
head(data)

data["Kendall"] = abs(data$Correlation_ice_k)
head(data)

## Correlation ##
data %>% 
  group_by(Variable, Zone) %>%
  get_summary_stats(Kendall, type = "common")

res.kruskal_correlation <- data %>% 
  group_by(Variable) %>%
  kruskal_test(Kendall ~ Zone)

res.kruskal_correlation

write_csv(res.kruskal_correlation, "../csv/Zonal_correlation_ice.csv")

## Percentage ##
data %>% 
  group_by(Variable, Zone) %>%
  get_summary_stats(Percentage, type = "common")

res.kruskal_per <- data %>% 
  group_by(Variable) %>%
  kruskal_test(Percentage ~ Zone)

res.kruskal_per
write_csv(res.kruskal_per, "../csv/Zonal_percentage_ice.csv")


### Plotting ###

data[data == "NPP"] <- "NPP***"
data[data == "Diatom"] <- "Diatom*"
data[data == "PAR"] <- "PAR**"
data[data == "Export"] <- "Export***"

data <- data %>% 
  group_by(Variable, Zone) %>%
  mutate(Mean_cor = mean(Kendall))
head(data)

data <- data %>%
  mutate(Zone = factor(Zone, levels = c("Inc", "Dec"))) %>%
  mutate(Variable = factor(Variable, levels = c("SST", "Nitrate", "MLD", "PAR**","Export***", "NPP***", "Diatom*", "Iron")))
head(data)


png(filename="../output/Multimodel/Zonal_ice.png", res=600, width=10000, height=4000)

Zone <- ggplot(data=data, aes(x = Zone, y=Percentage, fill = Mean_cor)) +
  scale_fill_viridis_c(limits=c(0, 1), direction = -1) +
  geom_boxplot(lwd=0.5) +
  theme_classic() +
  ggtitle("(B) Percentage change by 2100 in increasing and decreasing export zones") +
  labs(y = "Percentage change by 2100",
       fill='Correlation')  +
  theme(plot.title = element_text(size = 18, face = "bold", margin=margin(0,0,15,0)),
        plot.title.position = "plot",
        strip.text.x = element_text(size = 13, hjust = 0.5, face = "bold", color = "#333333"), 
        axis.title.y = element_text(size = 18, margin = margin(r = 10)),
        axis.title.x = element_blank(),
        axis.text = element_text(size = 15),
        panel.border = element_rect(size = 0.5, fill = NA),
        axis.line = element_blank(),
        strip.background = element_rect(colour="white", fill="white"),
        legend.key.height = unit(0.06, units = "npc"),
        legend.key.width = unit(0.03, units = "npc"),
        legend.title = element_text(size=15),
        legend.text = element_text(size=12),
        legend.spacing.y = unit(0.02, units = 'npc'),
        legend.box.margin=margin(0,10,0,0)) +
  facet_wrap(. ~ Variable, scales="free", nrow = 1)
Zone

dev.off()


###### Final plot #####
png(filename="../output/Multimodel/Final_ice.png", res=600, width=10000, height=9000)
grid.arrange(Whole, Zone, ncol = 1)
dev.off()

