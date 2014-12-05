rm(list=ls())

if (!require("wordcloud")) install.packages("wordcloud")

library(tools)
topic <- "household_activities"
directory <- paste("~/Box Sync/Play/LRW R Scripts",topic,"output", sep="/")

file_list <- list.files(directory)

for (file in file_list){
    file_path <- paste(directory, file, sep="/")
    if(tolower(file_ext(file_path)) %in% c("csv")){
        # if the merged dataset doesn't exist, create it
        if (!exists("dataset")){
            dataset <- read.csv(file_path, header=TRUE)
        } 
        else {
            # if the merged dataset does exist, append to it
            temp_dataset <- read.csv(file_path, header=TRUE)
            dataset <- rbind(dataset, temp_dataset)
            rm(temp_dataset)
        }
    }
}

datatable <- data.table(dataset)
summary <- datatable[, list(Count = length(Confidence), Mean = mean(Confidence)), by = "Tag"]
summary[order(-Count,-Mean),]

wordcloud(words=summary$Tag, freq=summary$Count, min.freq=3, 
          random.color=TRUE, colors = c("tomato", "wheat", "lightblue"))

write.csv(dataset, paste(directory,paste(topic,".csv",sep=""),sep="/"))