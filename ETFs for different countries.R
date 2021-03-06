#Idea is to repeat my tool from VBA: 
#	1) takes certain ETFs
#	2) get the quotes from yahoo
#	3) calculates certain returns
#	4) draws charts
#	5) creates PDF with charts
#	6) sends the PDF to the email
###############################################

library(RCurl) 
library(plyr)
library(stringr)
library(quantmod)
library(data.table)
library(lubridate)
library(ggplot2)

######Creating database of ETFs (it was impossible to get the database from google drive, because of firewall in the office)##########


#### ETF database is on google drive now (status Feb 2016)
id <- "0BxvMvfwI5rgZZ3YxdmlDaFZEVDA" # google file ID
ETFDB <- read.csv2(sprintf("https://docs.google.com/uc?id=%s&export=download", id),row.names = NULL)


# the part below is not needed anymore

Symbol <- c("ARGT", "BRAF", "BRAQ", "BRF", "BRXX", "CHIE", "CHII", "CHIM", "CHIQ", "CHIX", "CNDA", "CQQQ", "ECH", "ECNS", "EDEN", "EFNL", "EGPT", "EIDO", "EIRL", "ENY", "ENZL", "EPHE", "EPOL", "EPU", "EWA", "EWC", "EWD", "EWG", "EWGS", "EWH", "EWI", "EWL", "EWM", "EWN", "EWP", "EWQ", "EWS", "EWT", "EWU", "EWUS", "EWW", "EWY", "EWZ", "EZA", "FBZ", "FXI", "GREK", "GXG", "INCO", "INDA", "INXX", "IWM", "KROO", "MCHI", "NKY", "NORW", "RSX", "RSXJ", "SCIF", "SCJ", "THD", "TUR", "VNM", "XLE", "XLF", "XLI", "XLU", "XLV", "XLY", "UAE", "ISRA", "QAT", "PGAL", "NGE", "CN")
Name <- c("Global X FTSE Argentina 20 ETF", "Global X Brazil Financials ETF", "Global X Brazil Consumer ETF", "Market Vectors Brazil Small-Cap ETF", "EGShares Brazil Infrastructure", "Global X China Energy ETF", "Global X China Industrials ETF", "Global X China Materials ETF", "Global X China Consumer ETF", "Global X China Financials ETF", "IQ Canada Small Cap ETF", "Guggenheim China Technology", "iShares MSCI Chile Investable Mkt Idx", "iShares MSCI China Small Cap Index", "iShares MSCI Denmark Cppd Investable Mkt", "iShares MSCI Finland Capped Inv Mkt", "Market Vectors Egypt Index ETF", "iShares MSCI Indonesia Invstble Mkt Idx", "iShares MSCI Ireland Cppd Invstb Mkt Idx", "Guggenheim Canadian Energy Income", "iShares MSCI New Zealand Invstb Mkt Idx", "iShares MSCI Philippines Invstb Mkt Idx", "iShares MSCI Poland Investable Mkt Index", "iShares MSCI All Peru Capped Index", "iShares MSCI Australia Index", "iShares MSCI Canada Index", "iShares MSCI Sweden Index", "iShares MSCI Germany Index", "iShares MSCI Germany Small Cap", "iShares MSCI Hong Kong Index", "iShares MSCI Italy Index", "iShares MSCI Switzerland Index", "iShares MSCI Malaysia Index", "iShares MSCI Netherlands Invstbl Mkt Idx", "iShares MSCI Spain Index", "iShares MSCI France Index", "iShares MSCI Singapore Index", "iShares MSCI Taiwan Index", "iShares MSCI United Kingdom Index", "iShares MSCI United Kingdom Small Cap", "iShares MSCI Mexico Investable Mkt Idx", "iShares MSCI South Korea Index", "iShares MSCI Brazil Index", "iShares MSCI South Africa Index", "Brazil AlphaDEX Fund", "iShares FTSE China 25 Index Fund", "Global X FTSE Greece 20 ETF", "Global X FTSE Colombia 20 ETF", "EGShares India Consumer", "iShares MSCI India Index", "EGShares India Infrastructure", "iShares Russell 2000 Index", "IQ Australia Small Cap ETF", "MSCI China Index Fund", "MAXIS Nikkei 225 Index ETF", "Global X Norway ETF", "Market Vectors Russia ETF", "Market Vectors Russia Small-Cap ETF", "Market Vectors India Small-Cap ETF", "iShares MSCI Japan Small Cap Index", "iShares MSCI Thailand Invest Mkt Index", "iShares MSCI Turkey Invest Mkt Index", "Market Vectors Vietnam ETF", "Energy Select Sector SPDR", "Financial Select Sector SPDR", "Industrial Select Sector SPDR", "Utilities Select Sector SPDR", "Health Care Select Sector SPDR", "Consumer Discret Select Sector SPDR", "MSCI UAE Capped ETF", "Market Vectors Israel ETF", "MSCI Qatar Capped ETF", "FTSE Portugal 20 ETF", "Global X Nigeria Index ETF", "Harvest MSCI All China Equity Fund")
ETF_Currency <- c("USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD", "USD")
Local_Curr <- c("ARS", "BRL", "BRL", "BRL", "BRL", "CNY", "CNY", "CNY", "CNY", "CNY", "CAD", "CNY", "CLP", "CNY", "DKK", "EUR", "EGP", "IDR", "EUR", "CAD", "NZD", "PHP", "PLN", "PEN", "AUD", "CAD", "SEK", "EUR", "EUR", "HKD", "EUR", "CHF", "MYR", "EUR", "EUR", "EUR", "SGD", "TWD", "GBP", "GBP", "MXN", "KRW", "BRL", "ZAR", "BRL", "CNY", "EUR", "COP", "INR", "INR", "INR", "USD", "AUD", "CNY", "JPY", "NOK", "RUB", "RUB", "INR", "JPY", "THB", "TRY", "VND", "USD", "USD", "USD", "USD", "USD", "USD", "AED", "ILS", "QAR", "EUR", "NGN", "CNY")
Region <- c("Americas", "Americas", "Americas", "Americas", "Americas", "Asia Pacific", "Asia Pacific", "Asia Pacific", "Asia Pacific", "Asia Pacific", "Americas", "Asia Pacific", "Americas", "Asia Pacific", "Europe", "Europe", "MENA", "Asia Pacific", "Europe", "Americas", "Asia Pacific", "Asia Pacific", "Europe", "Americas", "Asia Pacific", "Americas", "Europe", "Europe", "Europe", "Asia Pacific", "Europe", "Europe", "Asia Pacific", "Europe", "Europe", "Europe", "Asia Pacific", "Asia Pacific", "Europe", "Europe", "Americas", "Asia Pacific", "Americas", "MENA", "Americas", "Asia Pacific", "Europe", "Americas", "MENA", "MENA", "MENA", "Americas", "Asia Pacific", "Asia Pacific", "Asia Pacific", "Europe", "Europe", "Europe", "MENA", "Asia Pacific", "Asia Pacific", "Europe", "Asia Pacific", "Americas", "Americas", "Americas", "Americas", "Americas", "Americas", "MENA", "MENA", "MENA", "Europe", "MENA", "Asia Pacific")
Country <- c("Argentina", "Brazil", "Brazil", "Brazil", "Brazil", "China", "China", "China", "China", "China", "Canada", "China", "Chile", "China", "Denmark", "Finland", "Egypt", "Indonesia", "Ireland", "Canada", "New Zealand", "Philippines", "Poland", "Peru", "Australia", "Canada", "Sweden", "Germany", "Germany", "HK", "Italy", "Swiss", "Malaysia", "Netherlands", "Spain", "France", "SG", "Taiwan", "UK", "UK", "Mexico", "Skorea", "Brazil", "South Africa", "Brazil", "China", "Greece", "Colombia", "India", "India", "India", "US", "Australia", "China", "Japan", "Norway", "Russia", "Russia", "India", "Japan", "Thailand", "Turkey", "Vietnam", "US", "US", "US", "US", "US", "US", "UAE", "Israel", "Qatar", "Portugal", "Nigeria", "China")
ETFs<- data.table(Symbol,Name,ETF_Currency,Local_Curr,Region,Country) # creating the data.table

#############  Checking if all the symbols are still available ##############################################################


check <- lapply(ETFs$Symbol, 
		function(x) try(# try returns "ERROR" if ... 
				Ad(getSymbols(x,from=Sys.Date()-30, auto.assign=FALSE)), # ... symbol doesn't exist (i.e. if getsymbol cannot find quotes)
		silent=TRUE)) 
Available_ETFs<-do.call(merge.xts,check) # transforming list
colnames(Available_ETFs) <- gsub("[.].*$","",colnames(Available_ETFs)) # removing everything after dot in the name
Available_ETFs<-t(Available_ETFs) # transposing matrix
Available_ETFs<- cbind(Available_ETFs, Symbol=rownames(Available_ETFs)) # addidng another column ...
ETFs <- merge(ETFs, Available_ETFs, by="Symbol") # Leaving in database only those ETFs, which have data


#############  Preparing & visualize ############################################################################################

# all the quotes are stored in separate columns for every date. We need to make only one column. 
ETFs <-data.table::melt(ETFs,id.vars =c(1:6),variable.factor=FALSE,variable.name = "Date", value.name = "Adj_Close") 
ETFs[,Date:=lubridate::ymd(Date)] # trasforming to date format
ETFs[,Adj_Close:=as.numeric(Adj_Close)] # trasforming to numeric format (otherwise ggplot will not connect dots).


ggplot(ETFs[Symbol=="FBZ" | Symbol=="ENY" | Symbol=="BRAQ"],
	 aes(x=Date,
	     y=Adj_Close,
	     colour=Symbol))+
	geom_point()+
	geom_line()+
	ylim(0,20)+
	facet_wrap(~Symbol,scales = "free_y",ncol=1) 

ETFs

lapply(ETFs,class)

ETFs_Final <- ETFs # just not to re-run the code above several times

################################################################################################################################

Add_Col_ETF <- function(ret) { # I decided to go with function in order to have less code for calculation of returns of different length
				Start_Date = Sys.Date()-(ret*2) #format should be “2015-01-19”
				Stocks <- lapply(ETFs_Final$Symbol, 
						function(sym) ROC( # calculating the return
								  Ad(na.omit(getSymbols(sym, from=Start_Date, auto.assign=FALSE))),
								  n=ret)) 
				Stocks <- do.call(merge.xts,Stocks) # transforming list
				Stocks <-Stocks[Sys.Date()-1,] # leaving only the returns for the last date
				colnames(Stocks) <- gsub("[.].*$","",colnames(Stocks)) # removing everything after dot in the name
				Stocks<-t(Stocks) # transposing matrix
				Stocks<- cbind(Stocks, rownames(Stocks)) # adding another column ...
				colnames(Stocks)<- c(paste("Ret_",ret, sep=""),"Symbol") #...and renaming both columns
				ETFs_Final <<- merge(ETFs_Final, Stocks, by = "Symbol") # adding the returns to the main database of ETFs (the sign "<<-" does this)
				remove(Stocks) # cleaning the Stocks variable
				ETFs_Final # displaying the database with new data
}
Add_Col_ETF(1) # adding 1D return to database
Add_Col_ETF(5) # adding 5D (i.e. 1W) return to database
Add_Col_ETF(20) # adding 20D (i.e. 1M) return to database
ETFs_Final <- ETFs_Final[order(ETFs$Region, ETFs$Country),] # sorting by region
ETFs_Final[,7:ncol(ETFs_Final)]<- sapply(ETFs_Final[,7:ncol(ETFs_Final)], 
					 function(x) as.numeric(as.character(x))) # transforming last 4 columns into numeric
ETFs_Final[,"Ret_4"] <- (ETFs_Final$Ret_5+1)/(ETFs_Final$Ret_1+1) - 1 # Calculating 4D return
ETFs_Final[,"Ret_3W"] <- (ETFs_Final$Ret_20+1)/(ETFs_Final$Ret_5+1) - 1 # Calculating 3W return
