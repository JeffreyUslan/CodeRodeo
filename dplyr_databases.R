# install.packages("RSQLite")
library("RSQLite")
library(nycflights13)
library("dplyr")
#make a database
my_db <- src_sqlite("my_db.sqlite3", create = T)

#add the flights table
copy_to(my_db, flights, temporary = FALSE, indexes = list(c("year", "month", "day"), "carrier", "tail_num"))

# pull flights from the database
query=paste0("SELECT * FROM flights")
flights_sqlite <- tbl(my_db, sql(query))
#name selection
select(flights_sqlite, year:day, dep_delay, arr_delay)
#conditional search
filter(flights_sqlite, dep_deply > 240)
#sorting
arrange(flights_sqlite, year, month, day)
#variable creation
mutate(flights_sqlite, speed = air_time / distance)
#summarise
summarise(flights_sqlite, delay = mean(dep_time))


#hold off on the actual query as long as possible
query=paste0("SELECT * FROM flights")
c1 <- filter(tbl(my_db, sql(query)), year == 2013, month == 1, day == 1)
c2 <- select(c1, year, month, day, carrier, dep_delay, air_time, distance)
c3 <- mutate(c2, speed = distance / air_time * 60)
c4 <- arrange(c3, year, month, day, carrier)
explain(c4)
flights_sqlite=collect(c4)
#writes the whole query for you
