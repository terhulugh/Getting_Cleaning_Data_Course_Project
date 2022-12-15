#Getting and Cleaning Data: Course Project Sript
#Author: Terhemen Hulugh 
#Date: 2017-12-15

#Data Description & Source File URLs
# 1. Merge training and test sets to create one data set
# 2. Extract only measurements on mean and standard deviation
# 3. Use descriptive activities names for activity measurements
# 4. Appropriately Label the Dataset with Descriptive Variable Names
# 5. Create tidy data set with average of each variable for each activity and subject

# 1. clear r studio memory
rm(list=ls()) 

# 2. Load Packages and get the Data
install.packages("reshape2")
pack <- c("data.table", "reshape2")
lapply(pack, require, character.only=T)

# 3. set working directory
path <- setwd("C:/Users/user/Desktop/Cousera/3.Getting and Cleaning Data/Week 4/Project")

# 4. Source File URLs
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "dataFiles.zip", method = "curl")
unzip(zipfile = "dataFiles.zip")


# 5. Load activity labels + features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))

# 6. Extracts only the measurements on the mean and standard deviation for each measurement
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# 7. Load train datasets
x_train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(x_train, colnames(x_train), measurements)
y_train <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                 , col.names = c("Activity"))
subject_train <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("Subject"))
train_data <- cbind(x_train, y_train, subject_train)

# 8. Load test datasets
x_test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(x_test, colnames(x_test), measurements)
y_test <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                , col.names = c("Activity"))
subject_test <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("Subject"))
test_data <- cbind(x_test, y_test, subject_test)

# 9. Combine test and train sets into one data set
combined <- rbind(train_data, test_data)

# 10. Convert classLabels to activityName basically. More explicit. 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])
# 11. convert subject variable to a factor 
combined[["Subject"]] <- as.factor(combined[, Subject])

# 12. convert object into dataframe
combined <- reshape2::melt(data = combined, id = c("Subject", "Activity"))

# 13. create a  tidy data set with the average of each variable for each activity and subject
tidyData <- reshape2::dcast(combined, Subject + Activity ~ variable, mean)

#14. Write tidy data to output file
write.table(tidyData, "tidyData.txt", row.names = FALSE, quote = FALSE)


