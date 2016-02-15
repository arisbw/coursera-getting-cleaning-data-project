rm(list=ls())
wd <- "D:/Coursera/Data Science/" #change for your own purpose
setwd(wd)
library(dplyr)

#import data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
features <- read.table("UCI HAR Dataset/features.txt")
labels <- read.table("UCI HAR Dataset/activity_labels.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

#combine all data
data <- bind_rows(x_test,x_train)

#change column names of x
colnames(data) <- features$V2

#subset data by take only mean and standard deviation
mean_data <- data[grep("mean",colnames(data),value = TRUE)]
std_data <- data[grep("std",colnames(data),value = TRUE)]
data <- bind_cols(mean_data,std_data)

#Appropriately labels the data set with descriptive variable names
colnames(data) <- gsub('-mean', 'Mean', colnames(data))
colnames(data) <- gsub('-std', 'Std', colnames(data))
colnames(data) <- gsub('[-()]','',colnames(data))

#build activity column
y <- bind_rows(y_test,y_train)
y <- left_join(y,labels, "V1")
y <- select(y, V2)
names(y)<-"activity"
data <- bind_cols(data,y)

#add subject
subject <- bind_rows(subject_test, subject_train)
names(subject)<-"subject"
data <- bind_cols(subject,data)
data <- arrange(data, subject)

#now for the last:  creates a second, independent tidy data set with the average of each variable for each activity and each subject.
group <- group_by(data, subject, activity)
tidy <- summarise_each(group, funs(mean))
write.table(tidy, 'tidy.txt', row.names = FALSE)