################################################################################
##
##  Author:  Brendan McDougall
##  Proj Purpose: Project 1 of Getting and Cleaning Data / Johns Hopkins Univ
##  File Purpose: Acquire "experimental" data, transform into analytic, data
##                  data, provide Code Book & ReadMe file
##  MOOC:  Coursera
##  Course ID:  getdata-013
##  Date:  4/25/15
##
##
################################################################################
##
##  System Info:  Windows 7, 64 bit, i7 processor, RStudio Version 0.98.1102
##                  R x64 3.1.2, git scm 1.9.5
##
################################################################################
##
## Revision History
##
##      4/25/15: Downloaded raw data; version control with master branch GitHub
##               Coded data read;
##               Coded summarize block;
##               Coded plotting functions
##                  "
##                  
##
##      
##
################################################################################
##
##  Methdology:
##  (1a) Load reshape2 library for table manipulation;
##  (1b) Load tidyr library for table manipulating;
##  (1c) Load the dyplyr  for table manipulating;
##  (2a) Read data -> (2b) Transform exptl data into analytic data;
##  (3)  Analyze data
##  (4)  Write summary data to "Tidy Data" txt file:  SECgalaxyS_Tidy.txt
##       
##
################################################################################
##
## Part (1a, 1b, 1c):
##
library(reshape2)
library(tidyr)
library(dplyr)
# library(lubridate)
# library(lattice)
# library(RCurl)
# library(ggplot2)
##
################################################################################
##
## Part (2a & 2b):
##
##  raw data imported into R using tbl_df and chaining (%>%) data transformations
##  per the workflow of the dplyr library, e.g. tbl_df vs data.frame
##

runAnalysis <- function() {
    curDir <- getwd()
    fileList <- dir()
    sessionInfo()
    print("One moment please")
    zipFile <- tempfile()
    download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', destfile=zipFile, method='curl')
    unzip(zipFile, overwrite = TRUE)
    print("One more moment please")
    unlink(zipFile)
    
    features <- read.table('features.txt')
    activityLabels <- read.table('activity_labels.txt')
    
    xTestData <- tbl_df( read.table( 'test/X_test.txt' ) )
    xTrainData <- tbl_df( read.table( 'train/X_train.txt' ))
    testSubjects <- tbl_df( read.table( 'test/subject_test.txt' ))
    trainSubjects <- tbl_df( read.table( 'train/subject_train.txt' ))
    yTestActivity <- tbl_df( read.table( 'test/y_test.txt' ))
    yTrainData <- tbl_df( read.table( 'train/y_train.txt' ))
    
    files <- ls()
    View(files)
    
    # naming columns to make vector handling more convenient
    colnames(yTrainData) <- c("activity")
    colnames(yTestActivity) <- c("activity")
    colnames(testSubjects) <- c("subject")
    colnames(trainSubjects) <- c("subject")
    
    # Pulling vector of names from features table
    # Prevent many to one names 
    namesVector <- as.character(features$V2)
    colnames(xTrainData) <- make.names(namesVector, unique=TRUE)
    colnames(xTestData) <- make.names(namesVector, unique=TRUE)
    
    trainAll <- cbind(trainSubjects, yTrainData, xTrainData) # was xTrainCombined
    testAll <- cbind(testSubjects, yTestActivity, xTestData) #was xTestCombined
    
    # Introduce factor variable to enable group_by summary
    trainAll$originFac = c("train")
    testAll$originFac = c("test")
    
    # Final combining
    trainTestAllTbldf <- tbl_df( rbind(trainAll, testAll) )
    
    print("Extracting only the measurements on the mean and standard deviation for each measurement...")
    trainTestAllTbldfMeans <- select(trainTestAllTbldf, subject, activity, grep("\\.mean\\.|\\.std\\.", names(trainTestAllTbldf)))
    
    print("Setting activities to descriptive labels...")
    trainTestAllTbldfMeans$activity <- factor(trainTestAllTbldfMeans$activity, levels=activityLabels$V1, labels=activityLabels$V2)
    
    print("Reshaping data to create a data set with the average of each variable for each activity and each subject...")
    # All data described by features.txt are set to variables; subject and activity are defined as ids
    trainTestAllTbldf.melt <- melt(trainTestAllTbldfMeans,id=c("subject","activity"),measure.vars=names(select(trainTestAllTbldfMeans, -subject, -activity)))
    
    # Calculating the mean of each feature grouped by activity and subject
    trainTestAllTbldf.summarised <- summarise(group_by(trainTestAllTbldf.melt, subject, activity, variable), mean=mean(value))
    
    print("Separating the average mean and the average standard deviation in their own column...")
    trainTestAllTbldf.cbind <- cbind(trainTestAllTbldf.summarised, estimatedValue=sub('^.*(mean|std).*$', "\\1", trainTestAllTbldf.summarised$variable))
    trainTestAllTbldf.cbind$variable = gsub('\\.*|mean|std', '', trainTestAllTbldf.cbind$variable)
    trainTestAllTbldf.cbind <- spread(trainTestAllTbldf.cbind, estimatedValue, mean)
    
    print("Cleaning up feature names...")
    trainTestAllTbldf.tidy <- rename(trainTestAllTbldf.cbind, feature=variable)
    trainTestAllTbldf.tidy <- rename(trainTestAllTbldf.tidy, avgmean=mean)
    trainTestAllTbldf.tidy <- rename(trainTestAllTbldf.tidy, avgstd=std)
    trainTestAllTbldf.tidy$feature <- sub('Acc', 'Acceleration', trainTestAllTbldf.tidy$feature)
    trainTestAllTbldf.tidy$feature <- sub('Mag', 'Magnitude', trainTestAllTbldf.tidy$feature)
    trainTestAllTbldf.tidy$feature <- sub('Gyro', 'AngularVelocity', trainTestAllTbldf.tidy$feature)
    trainTestAllTbldf.tidy$feature <- sub('BodyBody', 'Body', trainTestAllTbldf.tidy$feature)
    trainTestAllTbldf.tidy$feature <- sub('^t', 'Time', trainTestAllTbldf.tidy$feature)
    trainTestAllTbldf.tidy$feature <- sub('^f', 'Frequency', trainTestAllTbldf.tidy$feature)
    
    print("Writing final dataset to file 'finalDataset.txt'...")
    write.table(trainTestAllTbldf.tidy, "SEC_GalaxyS_ATdata.txt", row.name=FALSE)
}


##
################################################################################