## Coursera - data cleaning course
#  Final project

library(base)
library(utils)
detach(package:plyr)
detach(package:Hmisc)
library(dplyr)       # for summarize
library(data.table)  # for rename
library(memisc)

rm(list=ls())

setwd("/Users/jialu.streeter/Dropbox/miaomiao work/Online learning courses/3-Data cleaning/Homework")

########################################################################################################
# TRAIN DATA
subject_train <- read.table("./Final project/UCI HAR Dataset/train/subject_train.txt")
n_distinct(subject_train$person)     # 21 people in training data set
table(subject_train$person)

x_train <- read.table("./Final project/UCI HAR Dataset/train/X_train.txt")
dim(x_train)

y_train <- read.table("./Final project/UCI HAR Dataset/train/Y_train.txt")
dim(y_train)

names(subject_train) <- 'person'
names(y_train) <- 'activity'
train <- cbind(subject_train, y_train, x_train)

#######################################################################################################
# TEST DATA
subject_test <- read.table("./Final project/UCI HAR Dataset/test/subject_test.txt")
n_distinct(subject_test$person)           # 9 people in the test data

x_test <- read.table("./Final project/UCI HAR Dataset/test/X_test.txt")
dim(x_test)

y_test <- read.table("./Final project/UCI HAR Dataset/test/Y_test.txt")
dim(y_test)

names(subject_test) <- 'person'
names(y_test) <- 'activity'
test <- cbind(subject_test, y_test, x_test)

##############################
# combine training and test data sets into all_data

rm(x_test, x_train, y_test, y_train, subject_test, subject_train)

all_data <- rbind(test, train)
rm(test, train)

all_data <- arrange(all_data, person, activity)
table(all_data$person)
table(all_data$activity)

##############################
# assign proper feature names
# all the 561 measurements are now labeled as v1, v2, ...v561, we need to assign
# proper names to them
feature_names <- read.table("./Final project/UCI HAR Dataset/features.txt", head=FALSE)
# setnames() needs library(data.table)
setnames(all_data, old=names(all_data)[3:563], new = as.character(feature_names$V2))
###############################
# take a look at dataFeatureNames, you will find it looks like the following:
# for a measurement e.g. tBodyAcc, there are tBodyAcc-mean()-X, tBodyAcc-mean()-Y, tBodyAcc-mean()-Z,
# tBodyAcc-std()-X, tBodyAcc-std()-Y, tBodyAcc-std()-Z, ... and many other statistics
# such as mad(), min(), max(),...
# the question is to extract only the measurements on the mean and sd for each measurement
subset_feature_names<-feature_names$V2[grep("mean\\(\\)|std\\(\\)", feature_names$V2)]

# subset the data frame by selected names of features
selected_names <- c("person", "activity", as.character(subset_feature_names))
selected_data <- subset(all_data, select = selected_names)
################################
# Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table("./Final project/UCI HAR Dataset/activity_labels.txt", head=FALSE)
is.factor(selected_data$activity)
# factorize activity in the all_data 
selected_data$activity <- factor(selected_data$activity, labels = as.character(activity_labels$V2))
is.factor(selected_data$activity)
head(selected_data$activity, 10)
################################
# Appropriately labels the data set with descriptive variable names
# currently, the variable names are shortened, from time to t, etc. 
# see feature_info for details
# t: time; Acc: Accelerometer; Gyro: Gyroscope; f: frequency; Mag: Magnitude;
names(selected_data)<- gsub("^t", "time", names(selected_data))
names(selected_data)<- gsub("^f", "frequency", names(selected_data))
names(selected_data)<- gsub("Acc", "Accelerometer", names(selected_data))
names(selected_data)<- gsub("Gyro", "Gyroscope", names(selected_data))
names(selected_data)<- gsub("Mag", "Magnitude", names(selected_data))

##################################
# create a second, independent tidy data set
# In this part,a second, independent tidy data set will be created with the 
# average of each variable for each activity and each subject based on the data set in step 4.

# working with dplyr()
# create a factor variable person_activity
# selected_data <- mutate(selected_data, person_activity= factor(paste(selected_data$person, selected_data$activity, sep="_")))
# head(selected_data$person_activity)
# n_distinct(selected_data$person_activity)   # 180 groups
# by_personactivity <- group_by(selected_data, person_activity)
# # summarize() only calculate mean for one column, summarize_each() calculates mean for all columns
# allmeans <- summarize_each(by_personactivity, funs(mean), -person, -activity)
#
# the above code is equivalent to the following chaining code
allmeans <- selected_data %>%
  mutate(person_activity=factor(paste(selected_data$person, selected_data$activity, sep="_"))) %>%
  group_by(person_activity) %>%
  summarize_each(funs(mean), -person, -activity)

# markdown to html
# knit2html("./Final project/UCI HAR Dataset/codebook.Rmd");

# codebook
# to generate a codebook, (1) type in the desired attributes, such as description, wording
# (2) save the dataframe "selected_data" as a data.set 

selected_data <- within(selected_data,{
  description(person) <- "human subject"
  description(activity) <- "physical activities"
  wording(person) <- "21 in training data, 9 in test data"
  wording(activity) <- "e.g., walking, walking_upstairs, etc."
  # foreach(x=c(person, activity),{
  #   measurement(x) <- "nominal"
  # })
  foreach(x=c(person, activity),{
    annotation(x)["Remark"] <- "30 human subjects, 6 physical activities"
  })
})

# this line is very important, otherwise, the description() doesn't work
data4codebook <- data.set(selected_data)

description(data4codebook)
codebook(data4codebook)
  
Write(description(data4codebook),
      file="./Final project/Data-desc.txt")
Write(codebook(data4codebook),
      file="./Final project/Data-cdbk.txt")
