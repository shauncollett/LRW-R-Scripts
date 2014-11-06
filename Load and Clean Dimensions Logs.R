library(dplyr)

#setwd("~/Temp/DimensionsAppLogs")
logfile <- "2013-11.csv"
# Create a table of date/times over the last 6 months to track concurrency
# date.seq <- seq.POSIXt(from = as.POSIXct(today() - months(6)), 
#                        to = as.POSIXct(today()), 
#                        by = "min")
date.seq <- seq.POSIXt(from = as.POSIXct("2013-11-01"), to = as.POSIXct("2013-12-01"), by = "min")
# Load and clean log file csv
logs <- read.csv(file = logfile, header = TRUE, sep = ",")
logs <- tbl_df(logs)
logs <- mutate(logs, StartTime = as.POSIXct(ApplicationSessionStart, format = "%Y-%m-%d %H:%M:%OS"))
logs <- mutate(logs, EndTime = as.POSIXct(ApplicationSessionEnd, format = "%Y-%m-%d %H:%M:%OS"))
logs_clean <- logs %>% 
    filter(ApplicationID %in% c("Reporter")) %>%
    select(UserName, ProjectID, StartTime, EndTime)

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

# Plot
plot(range(concurrent$Date), range(0:max(concurrent$Count)+10), type="n", xlab="Date",
     ylab="Concurrent Licenses")
lines(concurrent$Date, concurrent$Count, type="l", col="BLACK")
legend("topleft", legend = c("Reporter"), 
       lwd = c(2.5,2.5), col = c("BLACK"),
       horiz = TRUE)

rm(list=ls())