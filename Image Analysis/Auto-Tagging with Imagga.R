install.packages('RCurl', repos='http://cran.us.r-project.org')
install.packages('RJSONIO', repos='http://cran.us.r-project.org')

library('RCurl')
library('RJSONIO')

api_key <- "acc_de49c6c12282e6d"
sample.image <- curlEscape("http://playground.imagga.com/static/img/example_photo.jpg")
auto.tagging.url <- paste("http://api.imagga.com/draft/tags?api_key=", api_key, "&url=", sample.image, sep="")

print("Waiting for auto-tagging result...")
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

# Write to a CSV for storage
write.csv(df_tags, file="~/Box Sync/Play/LRW R Scripts/Output/Auto-Tagging-Family.csv")