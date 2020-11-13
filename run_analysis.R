####################################################
############ GETTING AND CLEANING DATA #############
############ COURSE FINAL PROJECT #################
############ LUDVING CANO FERNANDEZ ################
############ NOVEMBER OF 2020 ##################3##
#################################################33
library(data.table)
library(dplyr)

#Set your working directory
setwd("~/R/CleaningData/Project")

#Download UCI data files from the web, unzip them, and specify time/date settings
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
	download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
	unzip(destFile)
}
dateDownloaded <- date()

#Start reading files
setwd("./UCI HAR Dataset")

############### DATA READING ########################

# Reading files
ActivityTest <- read.table("./test/y_test.txt", header = FALSE)
ActivityTrain <- read.table("./train/y_train.txt", header = FALSE)
FeaturesTest <- read.table("./test/X_test.txt", header = FALSE)
FeaturesTrain <- read.table("./train/X_train.txt", header = FALSE)
SubjectTest <- read.table("./test/subject_test.txt", header = FALSE)
SubjectTrain <- read.table("./train/subject_train.txt", header = FALSE)

# Activity Labels
ActivityLabels <- read.table("./activity_labels.txt", header = FALSE)

# Reading Feature Names
FeaturesNames <- read.table("./features.txt", header = FALSE)

################# MERGING DATA FRAMES ######################

# Merging data frames
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

# Renaming colums
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

# Get factor
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

# Rename SubjectData columns
names(SubjectData) <- "Subject"
names(FeaturesData) <- FeaturesNames$V2

# Create one large Dataset with only the variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

# Create New datasets by extracting only the
# measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

# Rename the columns of the large dataset
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

# Create a tidy data set
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

#Save this tidy dataset to local file
write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)