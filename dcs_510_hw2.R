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
  mutate(address=paste(location.address1,"," ,location.city,",",location.zip_code,",", location.country))%>% 
  rename('phone Number'= display_phone)%>%
  rename(Rating= rating)%>%
  rename(Name= name)%>%
  rename(Address= address)%>%
  rename('Review Count'= review_count)%>%
  arrange(desc(Rating)) %>%
  mutate(rank = 1:nrow(restaurants))%>%
  filter(rank<=10)%>%
  select(rank,Name, Rating,'Review Count' ,Address,'phone Number')

# Print the result 
print(restaurants)

# save the result into CSV file 

write.csv(restaurants,'ws_mexican_restaurants.csv')

# create connection R and SQLite
db_connection <-dbConnect(SQLite(),dbname ="C:/Users/NZ/Documents/sqlite/dcs510.db")

dbListTables(db_connection)

#connect to the Table 
restaurant_T<-tbl(db_connection,"restaurants_table")

# Print result FROM SQLite
restaurant_T

#Pipe to select the desire Query
rating<- restaurant_T %>% filter(rating>=4.5)%>% select(rank,Name,Rating ,`phone Number`)

#Print result 

rating
