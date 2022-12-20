**Getting-and-Cleaning-Data-Course-Project**
Author-Terhemen Hulugh Date- 2022-12-15

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 
a tidy data set as described below,a link to a Github repository with your script for performing the analysis, anda code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. 

This repo explains how all of the scripts work and how they are connected.
One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
  
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:
  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

An R script called run_analysis.R was cereated to do the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set 
4. Appropriately labels the data set with descriptive variable names.
5. create an independent tidy data set with the average of each variable for each activity and each subject.

In the run_analysis.R script, were recreated each step.

This file 'run_analysis.R' contains all the code to perform the analyses as described in the steps below. 
  
1. clear r studio memory
rm(list=ls())

2. Load Packages and get the Data
install.packages("reshape2") pack <- c("data.table", "reshape2") lapply(pack, require, character.only=T)

3. set working directory
path <- setwd("C:/Users/user/Desktop/Cousera/3.Getting and Cleaning Data/Week 4/Project")

4. Source File URLs
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" download.file(url, "dataFiles.zip", method = "curl") unzip(zipfile = "dataFiles.zip")

5. Load activity labels + features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt") , col.names = c("classLabels", "activityName")) features <- fread(file.path(path, "UCI HAR Dataset/features.txt") , col.names = c("index", "featureNames"))

# 6. Extracts only the measurements on the mean and standard deviation 
#for each measurement and assign appropriately labels the data set with #descriptive variable names

featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
featuresWanted <- grep("(mean|Mean|std).*", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
measurements<-gsub("^t", "Time_", measurements)
measurements<-gsub("tBody", "Time_Body", measurements)
measurements<-gsub("fBody", "Frequency_Body", measurements)
measurements<-gsub("Acc", "_Accelerometer", measurements)
measurements<-gsub("Gravity", "_Gravity", measurements)
measurements<-gsub("Jerk", "_Jerk", measurements)
measurements<-gsub("Gyro", "_Gyroscope", measurements)
measurements<-gsub("Mag", "_Magnitude", measurements)
measurements<-gsub("fBody", "Frequency_Body", measurements)
measurements<-gsub("BodyBody", "_Boby", measurements)
measurements<-gsub("Mean", "-Mean", measurements)
measurements<-gsub("mean", "Mean", measurements)
measurements<-gsub("std", "Std", measurements)
measurements<-gsub("angle", "Angle_", measurements)
measurements<-gsub(",", "_", measurements)

7. Load train datasets
x_train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE] data.table::setnames(x_train, colnames(x_train), measurements) y_train <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt") , col.names = c("Activity")) subject_train <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt") , col.names = c("Subject")) train_data <- cbind(x_train, y_train, subject_train)

8. Load test datasets
x_test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE] data.table::setnames(x_test, colnames(x_test), measurements) y_test <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt") , col.names = c("Activity")) subject_test <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt") , col.names = c("Subject")) test_data <- cbind(x_test, y_test, subject_test)

9. Combine test and train sets into one data set
combined <- rbind(train_data, test_data)

10. Convert classLabels to activityName basically. More explicit.
combined[["Activity"]] <- factor(combined[, Activity] , levels = activityLabels[["classLabels"]] , labels = activityLabels[["activityName"]])

11. convert subject variable to a factor
combined[["Subject"]] <- as.factor(combined[, Subject])

12. convert object into dataframe
combined <- reshape2::melt(data = combined, id = c("Subject", "Activity"))

13. create a tidy data set with the average of each variable for each activity and subject
tidyData <- reshape2::dcast(combined, Subject + Activity ~ variable, mean)

14. Write tidy data to output file 
write.table(tidyData, "tidyData.txt", row.names = FALSE, quote = FALSE)
