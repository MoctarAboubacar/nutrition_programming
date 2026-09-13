# Nutrition-programming
# Optimizing the allocation of supercereal food commodities to flood-affected Wards in Nepal (2019)

rm(list = ls())

# packages ####
require(lpSolve)
require(tidyverse)
require(directlabels)

# import data ####
dat <- read.csv(here::here("data", "Ward Exposure rank v1.csv"))

# clean and prep data ####

glimpse(dat)

# 1 eliminate excel N/As: Excel #N/A s are converted to R NAs for columns 17 to 22
dat[,c(17:22)]<- as.data.frame(apply(dat[,c(17:22)], 2,
                                       function(x){
                                         as.numeric(gsub("%", "", x))
                                       }
                                    )
                              )

sum(is.na(dat$plw_affect_perc)) # 77 NAs, leaving 313-77 = 236 wards under consideration

dat <- na.omit(dat[,1:23]) # all NAs are dropped from the analysis, except those from the nutrition assessment

# 2 translate beneficiaries into KGs
dat$kg_req <- (dat$children_tot_num*6) + (dat$plw_tot_num*12)

# Linear programming algorithm for knapsack problem ####
# objective function: the number of people affected
dat <- mutate(dat, plw_children_affect_tot = plw_affect_num + children_affect_num)
knapsack.obj <- dat$plw_children_affect_tot

# constraints
knapsack.con <- matrix(dat$kg_req, nrow = 1, byrow = TRUE)
knapsack.dir <- "<="
knapsack.rhs <- c(180000) # test for 180 MT first

# LP function first iteration
ksSolution <- lp("max", 
                 knapsack.obj, 
                 knapsack.con, 
                 knapsack.dir, 
                 knapsack.rhs, 
                 all.bin = TRUE)

solution <- ksSolution$solution
sum(solution) # 40 wards are selected with 180 MT, stored in the solution vector

# LP function multiple iterations ####
# Now, we repeat the process, this time obtaining the wards selected under different scenarios.
numbers <- c(300000:975000)
ration_kg <- numbers[seq(1, length(numbers), 25000)] # progressing by intervals of 25 MTs

wards <- vector() # create empty vector for the wards

colLength <- length(dat) # number of columns for data frame

for (i in seq_along(ration_kg)){
  
  a <- lp("max", 
          knapsack.obj, 
          knapsack.con, 
          knapsack.dir, 
          ration_kg[i], 
          all.bin = TRUE)
  
  wards[i] <- sum(a$solution)
  
  dat[colLength + i] <- a$solution
}

results_lp <- data.frame(wards, ration_kg) # a list of the number of wards covered by each MT amount

# Graphing results ####
# 1. How many wards are reachable under different MT scenarios?
Wards_by_MT <- ggplot(results_lp, aes(x = (ration_kg/1000), y = wards))+
  geom_line(color = "indianred4", size = 1.2)+
  theme_bw()+
  labs(title = "Wards by possible BSFP MT Allocation",
       caption = "Total 236 Wards",
       y = "Number of Wards",
       x = "BSFP Metric Tonnes")

# 2. How many wards per district are reachable in each of the different scenarios?
viztable1 <- dat %>% 
  group_by(District) %>% 
  summarise_at(vars(starts_with('V')), sum)

ration_mt <- ration_kg/1000
names(viztable1)[2:29] <- ration_mt # rename columns according to metric tonnage designation

viztable1 <- gather(viztable1, key = "MTs", value = "Wards",
                    c(2:29))
# viztable1$MTs <- as.integer(viztable1$MTs)

nominalDistricts <- c("grey60","grey60","grey60","grey60", "indianred4","grey60")

#require('directlabels')
District_compare <- ggplot(viztable1, aes(x = MTs, y = Wards, group = District))+
  geom_line(aes(color = District), size = 1.1)+
  scale_color_manual(values = nominalDistricts)+
  scale_x_discrete(expand = c(0, 3))+
  geom_dl(aes(label = District, color = District), method = list(dl.combine('first.points', "last.points"), cex = 0.9))+
  theme_bw()+
  theme(legend.position = "none")+
  labs(title = "By-District Ward Numbers per Metric Tonnage",
       subtitle = "Sarlahi consistently counts the most wards above 375 MTs",
       x = "BSFP Metric tonnes",
       y = "Number of Wards")


# 3. What percentage of  affected people are covered by different levels of BFSP Metric Tonnage? 

viztable2 <- mutate(dat, plw_children_affect_perc = plw_children_affect_tot/sum(plw_children_affect_tot)) 

names(viztable2)[26:53] <- ration_mt

viztable2 <- gather(viztable2, key = "MTs", value = "Wards",
                    c(26:53))

viztable2 <- viztable2 %>% 
  group_by(MTs, Wards) %>% 
  summarise(perc_affected = sum(plw_children_affect_perc)) %>% 
  filter(Wards == 1)

viztable2$MTs <- as.integer(viztable2$MTs)

Percentage_coverage <- ggplot(viztable2, aes(x = MTs, y = perc_affected))+
  geom_line()+
  theme_bw()+
  labs(title = "Percentage Affected Coverage",
       subtitle = "500 MTs covers over 75% of affected people",
       x = "BSFP Metric tonnes",
       y = "% affected people reached")

