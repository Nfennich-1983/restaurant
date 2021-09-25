#----------------Homework Assignment#4--------MaP------------------------

maprestaurant <- read.csv(file.choose())
library(ggmap)
library(ggrepel)
library("ggplot2")
base_plot<-qmplot(
  data= maprestaurant,
  x=long,
  y=lat,
  geom="blank",
  maptype = "toner-background",
  darken = .1,
  legend = "topleft"
)
base_plot +
  geom_point( data = maprestaurant, mapping = aes(x = long, y = lat), color = "red", size=1.5 ) +
  geom_label_repel(data=maprestaurant, mapping=aes(label=Name),alpha= .9, color ="blue" )+
  labs( title = "Best Mexican Restaurant in Winston Salem ")+
  theme(plot.title = element_text(color = "Red", hjust=0.5))






