library(dplyr)
library(lubridate)

#setwd("~/Temp/DimensionsAppLogs")
logfile <- "2014-12-01ReporterLogs.csv"
# Create a table of date/times over the last 6 months to track concurrency
# date.seq <- seq.POSIXt(from = as.POSIXct(today() - months(6)), 
#                        to = as.POSIXct(today()), 
#                        by = "min")
#date.seq <- seq.POSIXt(from = as.POSIXct("2013-12-01"), to = as.POSIXct("2014-12-01"), by = "min")
date.seq <- seq.POSIXt(from = as.POSIXct("2013-12-01"), to = as.POSIXct("2014-12-01"), by = (5*60))
# Load and clean log file csv
logs <- read.csv(file = logfile, header = TRUE, sep = "\t", stringsAsFactors=FALSE)
logs <- tbl_df(logs)
logs <- mutate(logs, StartTime = as.POSIXct(ApplicationSessionStart, format = "%Y-%m-%d %H:%M:%OS"))
logs <- mutate(logs, EndTime = as.POSIXct(ApplicationSessionEnd, format = "%Y-%m-%d %H:%M:%OS"))
logs_clean <- logs %>% 
    filter(ApplicationId %in% c("Reporter")) %>%
    select(UserName, ProjectId, StartTime, EndTime)

# Count number of concurrents for each time interval
count <- sapply(date.seq, function(x) logs_clean %>%
    filter(StartTime <= x & EndTime > x) %>%
    summarize(Count = n()))
count <- unlist(count)

# Bind to a table and format
concurrent <- cbind.data.frame(date.seq, unlist(count))
names(concurrent) <- c("Date", "Count")
concurrent <- tbl_df(concurrent)

# Filter out weekends
concurrent <- filter(concurrent, !(weekdays(Date) %in% c('Saturday','Sunday')))

# Filter to only a given time frame
concurrent_plot <- filter(concurrent, Date > '2014-06-01')
#concurrent_plot <- filter(concurrent_plot, hour(Date) >= 8 & hour(Date) <= 20)
concurrent_plot <- filter(concurrent_plot, Count > 0)

# Create trend line using regression model
fit <- lm(Count~Date, data=concurrent_plot)

# Line Plot
plot(range(concurrent_plot$Date), range(0:max(concurrent_plot$Count)+10), type="n", xlab="Date",
     ylab="Concurrent Licenses")
lines(concurrent_plot$Date, concurrent_plot$Count, type="l", col="BLACK")
lines(concurrent_plot$Date, fitted(fit), col="BLUE")
legend("topleft", legend = c("Reporter"), 
       lwd = c(2.5,2.5), col = c("BLACK"),
       horiz = TRUE)

#nrow(concurrent_plot[concurrent_plot$Count > 55,])

# Histogram Plot
hist(concurrent_plot$Count, col="green")
rug(concurrent_plot$Count)
abline(v=55, lwd=2)

summary(concurrent_plot$Count)

# Box Plot
boxplot(concurrent_plot$Count, col="blue")
abline(h=55)

boxplot(Count ~ month(Date), concurrent)
abline(h=55)


rm(list=ls())