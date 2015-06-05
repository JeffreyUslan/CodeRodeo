#Corrplot demo with rbsa Metering data
library(foreign)
library(corrplot)


cdx("rbsaSM2")

#Start with plot of category summaries
daily<-read.dta("../SMdata/13222/daily.dta")
sumvars<-subset(daily,select=c(ODT,HVAC,Appliance,DHW,PLUG,Lighting))
sumvars<-na.omit(sumvars)
corrplot(cor(sumvars))


#Stupid example with a fake "season" variable
times<-as.POSIXlt(daily$time/1000,origin='1960-01-01')
doy<-times$yday

lag.days<-80
daily$season<-sin((doy-lag.days)*2*pi/365)
sumvars<-subset(daily,select=c(season,ODT,HVAC,Appliance,DHW,PLUG,Lighting))
sumvars<-na.omit(sumvars)
corrplot(cor(sumvars))



#How much is DHW correlated with ODT after controlling for "season"?
DHWseason<-lm(DHW~season,data=sumvars)
par(mfrow=c(2,2))
plot(DHWseason)

par(mfrow=c(1,1))
plot(sumvars$season,sumvars$DHW)
abline(DHWseason)

DHWresids<-DHWseason$residuals
sumvars$DHW<-DHWresids
corrplot(cor(sumvars))

#Answer, not much

#Pre-empting the Ben Larson comment that the seasonality of water heating is lagged behind the 
#solar seasons.  (Previous "season" var was 0 at equinoxes, +-1 at solstices
lag.days<-120
daily$season<-sin((doy-lag.days)*2*pi/365)
sumvars<-subset(daily,select=c(season,ODT,HVAC,Appliance,DHW,PLUG,Lighting))
sumvars<-na.omit(sumvars)
DHWseason<-lm(DHW~season,data=sumvars)
DHWresids<-DHWseason$residuals
sumvars$DHW<-DHWresids
corrplot(cor(sumvars))



#How much is HVAC correlated with ODT after controlling for "season"?
lag.days<-120
daily$season<-sin((doy-lag.days)*2*pi/365)
sumvars<-subset(daily,select=c(season,ODT,HVAC,Appliance,DHW,PLUG,Lighting))
sumvars<-na.omit(sumvars)

HVACseason<-lm(HVAC~season,data=sumvars)
par(mfrow=c(2,2))
plot(HVACseason)

par(mfrow=c(1,1))
plot(sumvars$season,sumvars$HVAC)
plot(sumvars$season,log(sumvars$HVAC))

HVACseason<-lm(log(HVAC)~season,data=sumvars)

par(mfrow=c(2,2))
plot(HVACseason)

par(mfrow=c(1,1))
resids<-HVACseason$residuals
sumvars$HVAC<-resids
corrplot(cor(sumvars))


