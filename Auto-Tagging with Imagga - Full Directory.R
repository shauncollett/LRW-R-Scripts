if(!require("RCurl")) install.packages("RCurl", repos="http://cran.us.r-project.org")
if(!require("RJSONIO")) install.packages("RJSONIO", repos="http://cran.us.r-project.org")

library('RCurl')
library('RJSONIO')
library(tools)

# Hack: Should create a single folder, then append to github url and primary directory
api_key <- "acc_de49c6c12282e6d"
github_url <- "https://raw.githubusercontent.com/shauncollett/LRW-R-Scripts/master/getting_more_specific_about_business_travel"
directory <- "~/Box Sync/Play/LRW R Scripts/getting_more_specific_about_business_travel"
imagga_api_url <- "http://api.imagga.com/draft/tags"

# character vector e.g. "001.csv", "002.csv" ... "332.csv"
file_list <- list.files(directory)

for (file in file_list){
    file_path <- paste(directory, file, sep="/")
    if(tolower(file_ext(file_path)) %in% c("jpg","jpeg","png")){
        sample.image <- curlEscape(paste(github_url, file, sep="/"))
        auto.tagging.url <- paste(imagga_api_url, "?api_key=", api_key, "&url=", sample.image, sep="")

        print(paste("Waiting for auto-tagging result for", file, sep=" "))
        auto.tagging.result <- fromJSON(getURL(auto.tagging.url))
        
        # Convert the JSON into a data frame, then data table
        df_tags <- lapply(auto.tagging.result, function(play) # Loop through each "play"
        {
            # Convert each group to a data frame.
            # This assumes you have 6 elements each time
            data.frame(matrix(unlist(play), ncol=2, byrow=T))
        })
        
        # Now you have a list of data frames, connect them together in
        # one single dataframe
        df_tags <- do.call(rbind, df_tags)
        names(df_tags) <- c("Confidence", "Tag")
        
        # Create output directory if it doesn't already exist
        dir.create(file.path(directory, "output"), showWarnings = FALSE)
        
        # Write to a CSV for storage
        write.csv(df_tags, file=paste(directory, "/output/", 
                                      strsplit(file, "\\.")[[1]][[1]],
                                      ".csv", sep=""))
    }
}