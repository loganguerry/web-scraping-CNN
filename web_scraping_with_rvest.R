# -------------------- #
# Author: Logan Guerry #
# -------------------- #

## This script explores the rvest package and outlines a few practice applications.
      ## - scrape, recreate and manipulate live stock market data

# ================================== #
# Preparation #
{
# rvest package #
#install.packages('rvest')
library(rvest)

# assign url (CNN) #
url <- 'https://money.cnn.com/data/us_markets/'

# assign HTML data from CNN and convert to XML document #
webpage <- read_html(url)
webpage 

# capture session information #
session <- html_session(url)
session
}

# ================================== #
# Sector Performance (30 Day) #
{
# pull sector names #
sectors <- html_text(html_nodes(webpage, "a[href*='sectors']")) ## can also be done with "[a href='sectors']"
head(sectors,2)

# pull '30 Day % Change' values by sector #
sect_change <- html_text(html_nodes(webpage, "div[id*='sector'] [class$='ChangePct']"))
head(sect_change,2)

# merge sector and data into a df #
SectorPerformance <- data.frame(sectors,sect_change)
names(SectorPerformance) <- c('Sector', '30 Day Change (%)')

# Final Sector Performance df
SectorPerformance
}

# ================================== #
# Highest Volatility Tickers (Daily) #
{
# extract entire 'What's Moving" table into a dataframe #
raw_whats_moving <- html_table(html_nodes(webpage, "div table")[[1]])
raw_whats_moving

# capture links for all stocks in the 'Whats Moving' dataframe #
raw_whats_moving$url <- paste0("https://money.cnn.com", html_attr(html_nodes(webpage, "td .wsod_symbol"), "href"))
head(raw_whats_moving,2)

# parse ticker symbol using 'stringr'#
install.packages('stringr')
library(stringr)
unparsed_ticker <- str_extract_all(raw_whats_moving$`Gainers & Losers`, '\\w[[:upper:]]{2,5}', simplify = TRUE)
parsed_ticker <- substr(unparsed_ticker,1,nchar(unparsed_ticker)-1)
raw_whats_moving$Ticker <- parsed_ticker

# use parsed Ticker to return Company #
for (i in 1:nrow(raw_whats_moving)) {
  raw_whats_moving$Company[i] <- gsub(raw_whats_moving$Ticker[i], '', raw_whats_moving$`Gainers & Losers`[i]) }

# create final df #
Today <- raw_whats_moving[,c('Company', 'Ticker', 'Price', 'Change', '% Change', 'url')]
Today

# Return Daily Highest Performer #
Today[Today$`% Change` == max(Today$`% Change`),c(1,2,5)]
}

# ------------------------------------------------------ #
# ------------------------------------------------------ #

## Notes ##
# Try using rvest to pull Ticker and Company Name seperately instead of manual parsing ticker from incorrect Name scapre.
# Consider how to calculate trading metrics from web scraping.
        #  - What are the pros and cons of web scrapping as opposed to an API?
# How would you store scraped information on a recurring basis?
        #  - How could this be automated?

# ------------------------------------------------------ #
# ------------------------------------------------------ #
