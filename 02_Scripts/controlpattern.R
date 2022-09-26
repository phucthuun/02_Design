rm(list=ls())

{library(rstudioapi)
  library(dplyr)
  library(stringr)
  library(reshape2)
  library(ggplot2)
  library(tidyverse)
}
# Get df and specs

# Choose file name
filename = "senspatt.csv"
{
  directory = dirname(getSourceEditorContext()$path) %>% str_extract(pattern = '.+(?<=Design)') 
  datapath = file.path(directory,'01_Data')
  visualpath = file.path(directory,'03_Visualization')
  
}

df = read.csv(file.path(datapath,filename), header = F)
# df = read.csv(file.choose(),header = F)


# Prepare df ----
df1 <- df %>%
  mutate(n1 = str_split_fixed(V1, ";", 12)[,1],
         n2 = str_split_fixed(V1, ";", 12)[,2],
         n3 = str_split_fixed(V1, ";", 12)[,3],
         n4 = str_split_fixed(V1, ";", 12)[,4],
         n5 = str_split_fixed(V1, ";", 12)[,5],
         n6 = str_split_fixed(V1, ";", 12)[,6],
         n7 = str_split_fixed(V1, ";", 12)[,7],
         n8 = str_split_fixed(V1, ";", 12)[,8],
         n9 = str_split_fixed(V1, ";", 12)[,9],
         n10 = str_split_fixed(V1, ";", 12)[,10],
         n11 = str_split_fixed(V1, ";", 12)[,11],
         n12 = str_split_fixed(V1, ";", 12)[,12]) %>%
  mutate(setID = rep(c(1:10),nrow(df)/10) %>% factor(),
         instanceID = rep(c(1:(nrow(df)/10)), each = 10) %>% factor()) %>%
  select(setID, instanceID,n1:n12)
  

# convert 1d position to 2d position (x,y)
a <- t(array(1:625, dim=c(25,25))) %>% as.data.frame() 
names(a) <- c(1:25)
a <- a %>%
  rownames_to_column(var = "y")
  


b <- melt(a, id.vars = "y", variable.name = "x", value.name = "neuron") %>%
  mutate(x = as.numeric(x),  y = as.numeric(y))

df2 <- melt(df1, id.vars = c("setID", "instanceID"), variable.name = "neuronID", value.name = "neuron") %>%
  group_by(setID,neuron) %>%
  mutate(neurontype = ifelse(n() > 1,"shared","unique") %>% factor(levels = c('shared','unique')))%>%
  # mutate(neurontype = case_when(neuronID %in% c("n1","n2","n3","n4","n5","n6") ~ "shared",
  #                               !(neuronID %in% c("n1","n2","n3","n4","n5","n6")) ~ "unique")) %>%
  mutate(neuron = as.numeric(neuron))


df3 <- left_join(df2,b,by="neuron")

# Plot ----
dfplot <- df3 %>% filter(setID == 3) %>%
  mutate(condition = ' ', area = 'V1')

# dfplotV1 = dfplot %>% mutate(instanceID = paste0('Instance ', instanceID))
# dfplotCN = dfplot
# dfplotDN = dfplot

dfplotA1 = rbind(dfplotCN,dfplotDN) %>%
  mutate(instanceID = paste0('Instance ', instanceID),
         condition = toupper(condition),
         area = 'A1')

dfplot = rbind(dfplotV1,dfplotA1) %>%
  mutate(condition = case_when(condition == 'CONSISTENT NAME' ~ 'CATEGORY LABEL',
                               condition == 'DISTINCT NAME' ~ 'PROPER NAME',
                               condition == ' ' ~ ''))

p1<-ggplot(dfplot)+
  geom_point(aes(x=x,y=y, color=neurontype), size = 2.5)+
  scale_color_manual(name = 'Active neuron', values = c('black','purple'), drop=F)+
  scale_y_reverse(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
  scale_x_continuous(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
  facet_grid(condition+area~instanceID)+
  theme(aspect.ratio = 1,
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        legend.position="bottom",
        legend.title=element_text(size=25), 
        legend.text=element_text(size=20),
        strip.text.x = element_text(size = 15),
        strip.text.y = element_text(size = 15))
p1
ggsave(filename = paste0(visualpath,filename,"_patt3.png"), p1, width = 1000, height = 600, units = "px", dpi = "screen")


p2<-ggplot(df3)+
  geom_point(aes(x=x,y=y, color=instanceID), size = 2)+
  # scale_size_manual(values = c(4.5,3.5,2))+
  # scale_alpha_manual(values = c(1,.8,6))+
  geom_point(data=df3 %>% filter(neurontype=="shared"), aes(x=x,y=y), color = "black", size = 2)+
  scale_y_reverse(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
  scale_x_continuous(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
  facet_wrap(~setID)+
  theme(aspect.ratio = 1)
p2
ggsave(filename = paste0(visualpath,filename,"_patt.png"), p2, width = 1000, height = 600, units = "px", dpi = "screen")

p3 <- ggplot(df3)+
  geom_point(aes(x=x,y=y))+
  scale_y_reverse(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
  scale_x_continuous(minor_breaks = seq(0 , 25, 1), breaks = seq(0, 25, 1))+
  theme(aspect.ratio = 1)
p3
ggsave(filename = paste0(visualpath,filename,"_patt_all.png"), p3, width = 1000, height = 600, units = "px", dpi = "screen")
