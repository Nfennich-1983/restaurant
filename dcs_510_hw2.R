install.packages("httr")
install.packages("jsonlite")
install.packages("ggrepel")
install.packages("dplyr")
installed.packages("RSQLite")
library("dplyr")
library("DBI")
library(httr)
library("dplyr")
library("ggplot2")
library("ggrepel")
library(jsonlite)
library(RSQLite)
# YEP API = yelp_key <- "NFfRqo0ueFg4rCfT9lRQFiOZqbf508dKLXIuuMOXLKShnx1zpo5ayRFrkWChn8NqAVbhwmtUoRYslwIEk1Xnj8WnNa8lHmky57mHJea_sUmGp_uacFPfMURk3ARFYXYx"

# retrieve Yelp API from  yelp_api_key.R file

source("./yelp_api_key.R")

base_uri<- "https://api.yelp.com/v3"
end_point<-"/businesses/search"
search_uri<-paste0(base_uri,end_point)


# send query to retrieve specific Info 

query_params<-list(
  term = "restaurant",
  categories = "mexican",  
  location = "Winston-Salem, NC", 
  sort_by = "rating", 
  radius = 10000 
  
)
# authorization

response<-GET(
  search_uri,
  query = query_params,
  add_headers(authorization=paste("bearer",yelp_key))
)

response_text<-content(response,type = "text")
View(response_text)
response_data <- fromJSON(response_text)
names(response_data)

restaurants<-flatten(response_data$businesses)

# Pipe to select the desire Query 


restaurants<- restaurants%>% 
  mutate("Address"= paste0(location.address1, location.city, location.zip_code, location.state))%>%
  mutate("phone Number"= display_phone)%>%
  mutate("Rating"= rating)%>%
  mutate("Name"= name)%>%
  mutate("Review Count"= review_count)%>%
  mutate(Rank = row_number()) %>%
  filter( review_count >= 30 , Rank < 10 )%>%
  arrange(desc(rating)) %>%
  select(Rank,Name, Rating,'Review Count' ,"Address",'phone Number')






# Print the result 
print(restaurants)

# save the result into CSV file 

write.csv(restaurants,'ws_mexican_restaurants.csv', row.names = FALSE)

# create connection R and SQLite

db_connection <-dbConnect(SQLite(),dbname ="C:/Users/NZ/Documents/sqlite/dcs510.db")

dbListTables(db_connection)

#connect to the Table 
restaurant_T<-tbl(db_connection,"restaurants_table")

# Print result FROM SQLite
restaurant_T

#Pipe to select the desire Query
rating<- restaurant_T %>% filter(rating>=4.5)%>% select(Rank,"Name",Rating ,"phone Number")

#Print result 

rating

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






