getwd()

search()
library()

install.packages("curl")

#Load packages
library(RCurl) # the following functions from the package are used:...
library(plyr) # the following functions from the package are used:...
library(stringr) # the following functions from the package are used:...
library(quantmod) # the following functions from the package are used:...
library(data.table)
library(lubridate)
library(ggplot2)
library(BurStMisc)
library(PerformanceAnalytics)
library(Hmisc)
library(curl)

####################################################################################################
#######################    TECHNICAL    ############################################################
####################################################################################################


getSymbols(c("SPY", "^VIX","F"))
showSymbols()
Path<-"L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\"
saveSymbols(Symbols = SPY, file.path=paste0(Path,"SPY",".csv"))


sp500 <- new.env()
getSymbols("^GSPC", env = sp500)
# Below are 3 ways of getting a ticker from the environment:
GSPC <- sp500$GSPC
GSPC1 <- get("GSPC", envir = sp500)
GSPC2 <- with(sp500, GSPC)




managers[,1]

data(managers)
head(cbind(
		managers[,1],
		apply.fromstart(managers[,1,drop=FALSE],FUN="mean", width=3), # from "PerformanceAnalytics": begins always from the 1st element, i.e. kind of cumulative avg
		apply.rolling(managers[,1,drop=FALSE],FUN="mean", width=3) # from "PerformanceAnalytics". Wrapper function for "rollapply" to hide some complex stuff.
		),
	10)




####################################################################################################
#######################    GETTING QUOTES FUNCTIONS    #############################################
####################################################################################################

getSymbols(c("SPY", "^VIX","F","^GSPC","^GDAXI"))
getSymbols("^GSPC", from="2000-01-01", to="2008-12-07")

TESLA = getSymbols("TSLA", auto.assign=F) # with "auto.assign=F" you can only request one symbol at a time

data <- new.env()
getSymbols("COKE", src = 'yahoo', env = data, auto.assign = T)

getFX("USD/EUR") # A convenience wrapper to getSymbols(x,src='oanda')
to.weekly(USDEUR)
getMetals(c("XAU","XAG","XPD","XPT"), from=Sys.Date()-365) # XAG (silver), XPD (palladium), XPT (platinum). A convenience wrapper to getSymbols(x,src='oanda')
cbind(XAUUSD,XAGUSD,XPDUSD,XPTUSD)
XAU


row.names(oanda.currencies)
getFX("USD/EUR") # A convenience wrapper to getSymbols(x,src='oanda')


oanda.metals

yahooQF() # the names of all indicators are available separately	
standardQuote()
getQuote("SPY") # with such command, R gets the columns from "standardQuote()". The function gets the data with 15min delay. A maximum of 200 symbols may be requested per call.
getQuote("F;SPY;^VXN",what=yahooQF(c("Bid","Ask")))





####################################################################################################
#######################    PLAYING WITH TIMESERIES and PERIODICITY    ##############################
####################################################################################################


SPY['2017'] # only 2017
SPY['2017-1'] # only Jan 2017
SPY['2016-12::2017-1'] # 2 months
dates<-c('2017-1','2016-1','2015-1')
SPY[dates]

last(SPY,"3 weeks")
last(SPY,"-15 years") # all except last 15 years
last(first(SPY,"1 year"),"3 weeks") # last 3 weeks in the 1st year

periodicity(F)
periodicity(SPY)
to.weekly(SPY["2016"])
to.monthly(SPY["2016"])
ndays(SPY)
nweeks(SPY)
nmonths(SPY)
nyears(SPY)


seriesHi(SPY)
seriesLo(SPY)
cbind(Ad(SPY),seriesIncr(Ad(SPY),thresh=0),seriesIncr(Ad(SPY),thresh=1))



endpoints(SPY,on="months")
apply.yearly(SPY,function(x) { max(Cl(x)) })
period.apply(SPY,endpoints(SPY,on="months"),function(x) {max(Cl(x))} )
period.max(Ad(SPY),endpoints(SPY,on="months")) # same thing - only 50x faster! There is also period.min
period.sum(Vo(SPY),endpoints(SPY,on="months")) There is also period.prod



####################################################################################################
#######################    RETURNS & LAGS    #######################################################
####################################################################################################


OpCl(SPY)
head(HLC(SPY))

head(cbind(Ad(SPY),
	     lag(Ad(SPY)),
	     lag(Ad(SPY),3), # puts to the date t the values from the date t-3
	     Next(Ad(SPY),3)), # puts to the date t the values from the date t+3
	10)
# apply additionlly the na.remove function from the package "tseries"
head(na.remove(
	     cbind(Ad(SPY),
	     lag(Ad(SPY)),
	     lag(Ad(SPY),3), # puts to the date t the values from the date t-3
	     Next(Ad(SPY),3)), # puts to the date t the values from the date t+3
	),10)


head(SPY)
head(Delt(Op(SPY),Cl(SPY),k=0:3)) # 2 options: arithmetic & log


allReturns(SPY)
monthlyReturn(SPY) # there are also "dailyReturn", "weeklyReturn", etc. Thre is type "log" and "arithmetic"
periodReturn(SPY,period="yearly",subset="2003::") # other returns: "daily", "weekly", "monthly", "quarterly" 


# product of all the individual period return: (1+r1)*(1+r2)..
Return.cumulative(dailyReturn(Ad(SPY)))

# ratio of the cumulative performance for two assets through time
Return.relative(dailyReturn(Ad(SPY)),dailyReturn(Ad(F))) # There is also the chart functioin for this (see below)


####################################################################################################
#######################    PERFORMANCE RATIOS & RISK     #######################################################
####################################################################################################

SharpeRatio(dailyReturn(SPY))
SharpeRatio.annualized(dailyReturn(SPY))





# Lower Partial Moment around the mean or a specified threshold. 
# Captures only negative deviation from a reference point
lpm(monthlyReturn(Ad(SPY))) # from "PerformanceAnalytics"

AdjustedSharpeRatio(dailyReturn(SPY)) # from "PerformanceAnalytics".incorporates a penalty factor for negative skewness and excess kurtos
AdjustedSharpeRatio(na.remove(dailyReturn(SPY)))

DownsideFrequency(dailyReturn(SPY)) # subset of returns that are less than the target (or
Minimum  Acceptable  Returns  (MAR))  returns  and  divide  the  length  of  this  subset  by  the  total
number of returns.

# ratio used to penalise loss since most people feel loss greater than gain. See the formula in the
ProspectRatio(dailyReturn(SPY),0)







# Any time the cumul ret dips below max cumul ret,  it?s a drawdown.
# Drawdowns are measured as % of that max cumul ret (i.e. measured from peak equity).
maxDrawdown(monthlyReturn(SPY)) # option "invert=TRUE" will provide the drawdown as a positive number
AverageDrawdown(annualReturn(Ad(SPY)))
AverageDrawdown(monthlyReturn(Ad(SPY)))
AverageLength(monthlyReturn(Ad(SPY))) # average length (in periods) of the observed drawdown
PainIndex(monthlyReturn(Ad(SPY))) # the mean value of the drawdowns over the entire analysis period. Different than the average drawdown, in that the numerator is the total number of observations rather than the number off drawdowns.

DrawdownDeviation(monthlyReturn(Ad(SPY)))
findDrawdowns(monthlyReturn(SPY))
sortDrawdowns(findDrawdowns(monthlyReturn(SPY)))


# Both the Calmar and the Sterling ratio are the ratio of annualized return over the absolute value of the max drawdown.  
# The Sterling ratio adds an excess risk measure to the maximum drawdown, traditionally and defaulting to 10%.
CalmarRatio(dailyReturn(SPY)) # from "PerformanceAnalytics"
SterlingRatio(dailyReturn(SPY)) # from "PerformanceAnalytics"
# There is opinion of this author that newer measures such as Sortino?s UpsidePotentialRatio or Favre?s modified SharpeRatio are both ?better? measures, and should be preferred to the Calmar or Sterling Rati









# Active Premium = Investment?s annualized return - Benchmark?s annualized return
ActiveReturn(dailyReturn(Ad(F)["2016"]),
		 dailyReturn(Ad(SPY)["2016"])) # from "PerformanceAnalytics"
cbind(annualReturn(Ad(F)["2016"]),
	annualReturn(Ad(SPY)["2016"]),
	annualReturn(Ad(F)["2016"])-annualReturn(Ad(SPY)["2016"]))

# InformationRatio = ActivePremium/TrackingError. 
# i.e. the degree to which an investment has beaten the benchmark to the consistency with which the investment has beaten the benchmark
InformationRatio(dailyReturn(F["2016"]),
		     dailyReturn(SPY["2016"]),
		     scale = 252)
TrackingError(monthlyReturn(F),monthlyReturn(SPY),scale = 12) 









####################################################################################################
#######################    FINANCIALS & MACRO    ###################################################
####################################################################################################



getDividends("F",auto.assign = TRUE)# gets the quotes + dividends. If auto.assign = TRUE, the dividends go to the environment specified in env with a .div appended to the name
getSplits("F",auto.assign = TRUE)
F
F.div


getFinancials("F")
viewFin(F.f,"IS","Q") #  BS for balance sheet, IS for income statement, CF for cash flow statement, (A) for annual and (Q) for quarterly. As with all free data, you may be getting exactly what you pay for






####################################################################################################
#######################   CHARTS  ##################################################################
####################################################################################################


########### FROM QUANTMOD
chartSeries(SPY)
barChart(last(SPY,"2 months"),theme='white.mono',bar.type='hlc')
candleChart(to.weekly(SPY["2016"]),multi.col=TRUE,theme='white')
lineChart(to.monthly(SPY),line.type='h',TA=NULL)
chartSeries(SPY,theme="white.mono",TA="addROC();addMomentum()")

saveChart("pdf")


########### FROM tseries
data(USeconomic) # from package "tseries"
x <- ts.union(log(M1), log(GNP), rs, rl)
m.ar <- ar(x, method = "ols", order.max = 5)
y <- predict(m.ar, x, n.ahead = 200, se.fit = FALSE)
seqplot.ts(x, y) # function is from package "tseries"


########### FROM PerformanceAnalytics
chart.Bar(dailyReturn(SPY))
charts.Bar(monthlyReturn(SPY),main="Monthly Returns")





# auto-correlation of the returns with the previous lags
chart.ACF(dailyReturn(SPY))
chart.ACFplus(dailyReturn(SPY))
table.Autocorrelation(dailyReturn(SPY)) #  table of autocorrelation coefficien


# Scatter plot of Up Capture versus Down Capture against a benchmark:
chart.CaptureRatios(dailyReturn(F),dailyReturn(SPY)) 

chart.CumReturns(dailyReturn(SPY))
chart.CumReturns(dailyReturn(SPY),wealth.index = TRUE)
data(managers)
chart.CumReturns(managers,main="Cumulative Returns",begin="first")
chart.CumReturns(managers,main="Cumulative Returns",begin="axis")
table.CalendarReturns(monthlyReturn(SPY))


library(Hmisc)
data(managers)
result = t(table.CalendarReturns(managers[,c(1,8)]))
textplot(format.df(result, 
			 na.blank=TRUE, 
			 numeric.dollar=FALSE,
			 cdec=rep(1,dim(result)[2])), 
	   rmar = 0.8, cmar = 1,
	   max.cex=.9, 
	   halign = "center", 
	   valign = "top",
	   row.valign="center", 
	   wrap.rownames=20, wrap.colnames=10,
	   col.rownames=c(rep("darkgray",12), 
				    "black", 
				    "blue"),
	   mar = c(0,0,3,0)+0.1)
         title(main="Calendar Returns")




table.AnnualizedReturns(dailyReturn(SPY))

data(managers)
result = t(table.AnnualizedReturns(managers[,1:8], Rf=.04/12))
# The below format function is from package "Hmisc"
textplot(format.df(result, 
			 na.blank=TRUE, numeric.dollar=FALSE,
	  		 cdec=c(3,3,1)), rmar = 0.8, cmar = 2,  max.cex=.9,
			 halign = "center", valign = "top", row.valign="center",
			 wrap.rownames=20, wrap.colnames=10, col.rownames=c("red",
											     rep("darkgray",5), 
											     rep("orange",2)), 
			 mar = c(0,0,3,0)+0.1)
	    title(main="Annualized Performance")

# "table.Arbitrary" - wrapper function for combining arbitrary function list into a table


table.Distributions(dailyReturn(SPY))





# Any time the cumul ret dips below max cumul ret,  it?s a drawdown.
# Drawdowns are measured as % of that max cumul ret (i.e. measured from peak equity).
chart.Drawdown(dailyReturn(SPY))
table.Drawdowns(dailyReturn(SPY))


chart.Histogram(dailyReturn(SPY), methods ="add.normal")
chart.Scatter(monthlyReturn(F),monthlyReturn(SPY))



data(EuStockMarkets) # from package "tseries"
dax <- log(EuStockMarkets[,"DAX"])
mdd <- maxdrawdown(dax) # function is from package "tseries"
plot(dax)
segments(time(dax)[mdd$from], dax[mdd$from],time(dax)[mdd$to], dax[mdd$from], col="grey")
segments(time(dax)[mdd$from], dax[mdd$to],time(dax)[mdd$to], dax[mdd$to], col="grey")
mid <- time(dax)[(mdd$from + mdd$to)/2]
arrows(mid, dax[mdd$from], mid, dax[mdd$to], col="red", length = 0.16)





# The function below shows the ratio of the cumul ret for two assets at each point in time. 
# If the slope is positive, the first asset is outperforming the second.
chart.RelativePerformance(dailyReturn(F),dailyReturn(SPY)) 


data(managers)
chart.RollingCorrelation(monthlyReturn(F),monthlyReturn(SPY),
				 width=24, 
				 main = "Rolling 12-Month Correlation")

chart.RollingMean(dailyReturn(F),width=50)
chart.RollingPerformance(monthlyReturn(F), width=12)

chart.SnailTrail(monthlyReturn(SPY))

chart.VaRSensitivity(monthlyReturn(SPY),
			   methods=c("HistoricalVaR", "ModifiedVaR", "GaussianVaR"),
			   colorset=bluefocus, lwd=2)


charts.PerformanceSummary(monthlyReturn(SPY),wealth.index=TRUE)
charts.RollingPerformance(monthlyReturn(SPY),begin="first")
table.Stats(monthlyReturn(SPY))









####################################################################################################
#######################    MODEL FUNCTIONS    ######################################################
####################################################################################################

getSymbols("SPY")
getSymbols("NDX")


########### FROM QUANTMOD

my.model <- specifyModel(Next(OpCl(SPY)) ~ Lag(Cl(NDX),0:5))
m <- specifyModel(Next(OpCl(SPY)) ~ Cl(SPY) + OpHi(SPY) + Lag(Cl(SPY))) # Create a single reusable model specification for subsequent buildModel ca
# another example specifyModel(Next(OpCl(QQQQ)) ~ Lag(OpHi(QQQQ),0:3) + Hi(DIA)) # if QQQQ is not in the Global environment, an attempt will be made to retrieve it from the source specified with getSymbols.Default
getModelData(my.model)
tail(modelData(my.model))
tail(modelData(m))

m <- specifyModel(Next(OpCl(SPY)) ~ Lag(OpHi(SPY)))
m.built <- buildModel(m,
			    method="rpart", #  the fitting method. There are many types, I didn't get
			    training.per=c("2014-01-01","2016-04-01"))
tradeModel(m.built)
tradeModel(m.built,leverage=2)
tradeModel(m.built,plot.model=TRUE)

modelSignal(m) # for use after a call to tradeModel to extract the generated signal of a given quantmod model









































































