#basic dplyr stuff

# install.packages("nycflights13")
# install.packages("dplyr")
library(nycflights13)
library(dplyr)

#use table wrapper
flights=tbl_df(flights)
flights
head(flights)


#faster data subsetting
filter(flights, month == 1, day == 1)
flights[which(flights$month==1 & flights$day==1),]


#data sorting
arrange(flights, year, month, day)

#quick data selection
select(flights, year, month, day)
flights[, c("year","month","day")]

#renaming
rename(flights, tail_num = tailnum)
names(flights)[which(names(flights)=="tailnum")]="tail_num"


#finding distinct values
distinct(select(flights, tail_num))
flights[!duplicated(flights$tail_num),"tail_num"]

#apply functions by a group
by_tailnum <- group_by(flights, tail_num)
delay <- summarise(by_tailnum,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))

