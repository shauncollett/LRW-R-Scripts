library(dplyr)
library(lubridate)
library(ggplot2)

#setwd("~/Temp/DimensionsAppLogs")
logfile <- "2015-01-29ReporterLogs.csv"
userfile <- "2015-01-29Users.csv"
startdate <- as.POSIXct("2013-12-01")
enddate <- as.POSIXct("2015-02-01")
plotdate <- as.POSIXct("2014-06-01")
date.seq <- seq.POSIXt(from = startdate, to = enddate, by = (5*60))

# Load and clean log and user csv files
logs <- read.csv(file = logfile, header = FALSE, sep = ",", stringsAsFactors=FALSE)
logs <- tbl_df(logs)
names(logs) <- c("Description","Username","ApplicationId","ProjectId",
                 "ApplicationSessionStart","ApplicationSessionEnd",
                 "DurationInSeconds")

users <- read.csv(file = userfile, header = FALSE, sep = ",", stringsAsFactors=FALSE)
users <- tbl_df(users)
names(users) <- c("FirstName","LastName","Title","DeptNumber","Department","Username")

logs <- mutate(logs, StartTime = as.POSIXct(ApplicationSessionStart, 
                                            format = "%Y-%m-%d %H:%M:%OS"))
logs <- mutate(logs, EndTime = as.POSIXct(ApplicationSessionEnd, 
                                          format = "%Y-%m-%d %H:%M:%OS"))
logs$Username <- substring(logs$Username, 6, length(logs$Username))

# Merge logs and users data tables
userlogs <- merge(logs, users, by="Username", all.x=TRUE, all.y=FALSE)

# Filter to only reporter data
reporter <- logs %>% 
    filter(ApplicationId %in% c("Reporter")) %>%
    select(UserName, ProjectId, StartTime, EndTime, DurationInSeconds)

# Count number of concurrents for each time interval
count <- sapply(date.seq, function(x) reporter %>% 
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
concurrent_plot <- filter(concurrent, Date > plotdate)
concurrent_plot <- filter(concurrent_plot, Count > 0)

# Plot using box plot
ggplot(concurrent_plot, aes(x=format(Date, "%Y-%m"), y=Count)) + 
    geom_boxplot() + xlab("Date") + 
    geom_hline(aes(yintercept = 55, color="red"))

# Exploratory analysis
quantile(reporter$DurationInSeconds, na.rm=TRUE)

rm(list=ls())