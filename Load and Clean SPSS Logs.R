# Load libraries needed during script
library(dplyr)
library(lubridate)
# Load and clean log data
logs <- read.csv("Logfile.txt", header = FALSE, sep = " ")
logs <- tbl_df(logs)
logs <- logs %>% mutate(Date = ymd(paste(V8, V5, V6, sep = " ")))
logs <- mutate(logs, DateTime = ymd_hms(paste(Date, V7, sep=" "), 
                                        tz="America/Los_Angeles"))
logs_clean <- logs %>%
    select(Date, DateTime, V11, V12, V13, V14, V15, V16) %>%
    filter(V13 == 2, V16 != "LM_SERVER", V11 == "1200")
names(logs_clean) <- c("Date", "DateTime", "Feature", "Version", "Transaction", 
                       "NumberOfKeys", "KeyLife", "User")
logs_clean$Transaction <- as.numeric(logs_clean$Transaction)
logs_clean$NumberOfKeys <- as.numeric(logs_clean$NumberOfKeys)
logs_clean$KeyLife <- as.numeric(logs_clean$KeyLife)
logs_clean$Date <- as.Date(logs_clean$Date)
logs_clean <- mutate(logs_clean, 
                     Hours = KeyLife / 60 / 60, 
                     HourOfDay = hour(DateTime))
# Group data by user to summarize usage
logs_clean %>%
    group_by(User) %>% 
    filter(Date >= today() - months(3)) %>% 
    summarize(Life = sum(Hours)) %>% 
    arrange(desc(Life))
# Group data by version to summarize usage
logs_clean %>%
    group_by(Version) %>% 
    filter(Date >= today() - months(3)) %>% 
    summarize(Life = sum(Hours)) %>% 
    arrange(desc(Life))
# Group data by user and version to summarize usage
user_version <- logs_clean %>%
    group_by(User, Version) %>% 
    filter(Date >= today() - months(3)) %>% 
    summarize(Life = sum(Hours), Count = n())
write.csv(user_version, file = "user-version.csv")
# Group data by hour of day
plot(logs_clean %>%
    group_by(HourOfDay) %>% 
    filter(Date >= today() - months(3)) %>% 
    summarize(Count = n()) %>%
    arrange(desc(Count)))
# Reformat file to produce stacked bar chart of concurrents for each version
logs_v18 <- logs_clean %>% 
    filter(Version == "v180") %>%
    select(Date, NumberOfKeys) %>%
    group_by(Date) %>%
    summarize(Max = max(NumberOfKeys))
logs_v20 <- logs_clean %>% 
    filter(Version == "v200") %>%
    select(Date, NumberOfKeys) %>%
    group_by(Date) %>%
    summarize(Max = max(NumberOfKeys))
logs_v21 <- logs_clean %>% 
    filter(Version == "v210") %>%
    select(Date, NumberOfKeys) %>%
    group_by(Date) %>%
    summarize(Max = max(NumberOfKeys))
logs_version <- inner_join(logs_v18, logs_v20, by = "Date")
names(logs_version) <- c("Date", "v18", "v20")
logs_version <- inner_join(logs_version, logs_v21, by = "Date")
names(logs_version) <- c("Date", "v18", "v20", "v21")
logs_version <- mutate(logs_version, Total = v18 + v20 + v21)
logs_version <- left_join(logs_version, 
                       logs_version %>% 
                           filter(v18 >= 20 | v20 >= 20 | v21 >= 20) %>% 
                           select(Date) %>% mutate(MaxOut = 20),
                       by = "Date")
# Filter out weekends and holidays
logs_version <- filter(logs_version, 
                       !(weekdays(Date) %in% c('Saturday','Sunday')))
logs_version <- filter(logs_version, Date != as.Date("2014-05-26"))
logs_version <- filter(logs_version, Date != as.Date("2014-09-01"))
plot(range(logs_version$Date), range(0:40), type="n", xlab="Date",
     ylab="Concurrent Licenses")
lines(logs_version$Date, logs_version$v18, type="l", col="BLACK")
lines(logs_version$Date, logs_version$v20, type="l", col="RED")
lines(logs_version$Date, logs_version$v21, type="l", col="BLUE")
lines(logs_version$Date, logs_version$Total, type="l", col="PURPLE")
lines(logs_version$Date, logs_version$MaxOut, type="p", col="GREEN")
legend("topleft", legend = c("v18", "v20", "v21", "Total", "MaxOut"), 
       lwd = c(2.5,2.5), col = c("BLACK", "RED", "BLUE", "PURPLE", "GREEN"),
       horiz = TRUE)