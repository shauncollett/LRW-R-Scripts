# http://imagga.com
# Required libraries - RCurl and RJSONIO
print("Installing RCurl library...")
install.packages('RCurl', repos='http://cran.us.r-project.org')
print("Installing RJSONIO library...")
install.packages('RJSONIO', repos='http://cran.us.r-project.org')

library('RCurl')
library('RJSONIO')

sample.image <- curlEscape("http://playground.imagga.com/static/img/example_photo.jpg")
selected.classifier <- 'personal_photos'
auto.categorization.url <- "http://api.imagga.com/draft/classify/personal_photos?api_key=acc_de49c6c12282e6d"

print("Waiting for auto-categorization result...")
auto.categorization.result <- fromJSON(postForm(auto.categorization.url, .params=list(urls=sample.image)))

# Get the tag with the highest confidence (the first one)
#print(paste0("The top auto-suggested category for this image is: ",
#             auto.categorization.result[[1]]["tags"][[1]][1][[1]]["name"], " with confidence: ", auto.categorization.result[[1]]["tags"][[1]][1][[1]]["confidence"]))


# Convert the JSON into a data frame, then data table
df_category <- lapply(auto.categorization.result, function(play) # Loop through each "play"
{
    # Convert each group to a data frame.
    # This assumes you have 6 elements each time
    data.frame(matrix(unlist(play), ncol=2, byrow=T))
})

# Now you have a list of data frames, connect them together in
# one single dataframe
df_category <- do.call(rbind, df_category)
names(df_category) <- c("Confidence", "Tag")

write.csv(df_category, file="~/Box Sync/Play/LRW R Scripts/Output/Auto-Tagging.csv")