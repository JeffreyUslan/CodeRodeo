
setwd("F:/client/SeattleCityLight/McClellan")
dir()
dir("data")
library(ggplot2)

dset <- read.csv("data/Denning_Apartments.csv")

dset$dateTime <- paste(dset$Date, dset$Time)
dset$time <- as.POSIXct(dset$dateTime, format = "%m/%d/%y %I:%M:%S %p", tz = "GMT")
dset$date <- as.Date(dset$time)

dset$hour <- as.numeric(dset$time) %% (3600 * 24) / 3600

names(dset)[grep("IAT", names(dset))] <- "IAT"
names(dset)[grep("OAT", names(dset))] <- "OAT"

ggplot(dset) + theme_bw() +
  geom_line(aes(x = hour, y = IAT, group = date, col = OAT), size = 2) +
  scale_colour_continuous(name = "Outdoor Temp", low = "brown", high = "black") +
  xlab("Hour of Day") + ylab("Indoor Temp") +
  ggtitle("Indoor Solarium Temp vs Hour of Day") + 
  facet_wrap(~date, nrow = 5, ncol = 2)

dset$dateChar <- as.character(dset$date)
ggplot(dset) + theme_bw() + 
  geom_point(aes(x = OAT, y = IAT, col = factor(date)), size = 3) +
  geom_point(aes(x = OAT, y = IAT, col = factor(date)), size = 3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  xlab("Outdoor Temperature") + ylab("Indoor Temp") +
  ggtitle("Indoor Solarium Temp by Indoor Air Temp") +
  xlim(43, 65) + ylim(43, 85)


