---
title: "Getting and Cleaning Data Course Project"
output: html_document
---

# Description
The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis.
One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

* The raw data is available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
* The final tidy data which is the output of the run_analysis.R is finaloutput.txt. The columns in the file are SubjectId, Activity, variable and value
* Tidy data codebook is codebook.pdf
* Tidying Recipe

        1.Read the labels of all the columns for the data captured from features.txt
        2.Read the activity labels from the activity_labels.txt so the codes can be replaced by the activity labels
        3.Read the test dataset from the test directory. The directory has the three files. X_test.txt captures the accelerometers data. subject_test.txt has the subject ids of the test subjects. y_test.txt has the activity labels ids of the activities from the test subjects. 
        4.train/X_test.txt is read and column labels are assigned for this dataset are assigned from labels read from features.txt
        5.train/y_test.txt is read and column label of activity is assigned to the read column
        6.train/subject_test.txt is read and column label of SubjectId is assigned as the read column
        7.Finally all the data read from steps 4,5,6 are merged and the subject ids in the SubjectId column are prefixed with 'TestSubject_' so the test subjects are distinguished from train subjects in case the ids are the same.
        8.Read the training dataset from the train directory. The directory has the three files. X_train.test captures the accelerometers data. subject_train.txt has the subject ids of the training subjects. y_train.txt has the activity labels ids of the activities from the training subjects. 
        9.train/X_train.txt is read and column labels are assigned for this dataset are assigned from labels read from features.txt
        10.train/y_train.txt is read and column label of activity is assigned to the read column
        11.train/subject_train.txt is read and column label of SubjectId is assigned as the read column
        12.Finally all the data read from steps 4,5,6 are merged and the subject ids in the SubjectId column are prefixed with 'TrainSubject_' so the train subjects are distinguished from test subjects in case the ids are the same.
        13.The training and test data from steps 7 and 12 are merged to create a dataset which has both test and train data
        14.The activity codes in the merged data are replaced by the actual labels instead of the codes. The activity labels are in the activity_labels.txt which was read in step 2.
        15.The columns corresponding to the mean columns are extracted out using the text match of -mean()
        16.The columns corresponding to the standard deviation columns are extracted using the text match of -std()
        17.As we will only be needing the mean and standard deviation data we subset the data from step 14 to get the data for grouping and summarizing.
        18.The data from step 17 is then grouped by SubjectIds and Activity 
        19.The grouped data is then summarized to get the mean of all the subsetted recording
        20.The grouped summarized data column names are renamed to indicate the data is now GroupedMean
        21.The summarized data is converted to a dataframe so the data can be melted by SubjectId and Activity
        22.The final data is outputted to finaloutput.txt file
        
         
## Getting Started

The UCI HAR Dataset.zip that needs to be used should be downloaded to your local machine and is accessible by RStudio. The assumption is all the files are in the zip and it is not corrupted.Also make sure there is enough disk space to write the output file

### Prerequisities

* The UCI HAR Dataset.zip should be downloaded on your local machine in a directory accessible by RStudio
* There should be enough disk space to write the output file
* The script file run_analysis.R exists in the same directory as the extracted dataset
* The dplyr package is installed
* The reshape2 package is installed

### Installing

First load the run_analysis.R script

```
source("run_analysis.R")
```

Run the script by passing the directory where the unzipped Dataset exists

```
runAnalysis("/Users/sameerabalay/Development/classes/GettingAndCleaningData/Week4/UCI HAR Dataset")
```

The script creates an output file named 'finaloutput.txt' in the same directory as the unzipped Dataset in the above example it will be in
"/Users/sameerabalay/Development/classes/GettingAndCleaningData/Week4/UCI HAR Dataset" directory


## Authors

* **Sameera Balay** 

## License

Free for all

## Acknowledgments

* Ahem to Google Search
* All the developers who are kind enough to post answers to questions on the newsgroup 
* All my fellow class takers for all the online discussions and clarifications


## Code (Since it is relatively small script)

```{r}
## runAnalysis script reads the data from UCI Har Dataset directory all the files,
## applies the cleansing principles and merges all the test and train data 
## and retrieves only the mean and std deviations data and finally groups them and 
## summarizes the data for those values

runAnalysis <- function(directory) {
        setwd(directory)
        ## Read all the column labels so they can used to rename the variables
        columnLabels <- read.table("features.txt")
        ##  Converting the columnLabels as vector to assign the column labels to x_test data
        columnLabelsAsVector <- as.vector(columnLabels$V2) 
        ## Read all the activity labels so the activity ids are replaced with the 
        ## activity names
        activityLabels <- read.table("activity_labels.txt")
        
        ## Read the test data
        XTestData <- read.table("test/X_test.txt")
        ## Label the column with the actual labels
        names(XTestData) <- columnLabelsAsVector
        subjectTestData <- read.table("test/subject_test.txt")
        ## Label the subjectId column
        names(subjectTestData) <- c("SubjectId")
        activityTestData <- read.table("test/y_test.txt")
        ## Label the activity column
        names(activityTestData) <- c("Activity")
        testDataMerged <- cbind(subjectTestData, activityTestData, XTestData)
        ## Prefix the subject id with TestSubject to distinguish them from train ids
        ## if in case they are the same
        testDataMerged$SubjectId <- paste("TestSubject_", testDataMerged$SubjectId, sep="") 
        
        ## Read the training data
        XTrainData <- read.table("train/X_train.txt")
        ## Label the column with the actual labels
        names(XTrainData) <- columnLabelsAsVector
        subjectTrainData <- read.table("train/subject_train.txt")
        ## Label the subjectId column
        names(subjectTrainData) <- c("SubjectId")
        activityTrainData <- read.table("train/y_train.txt")
        ## Label the activity column
        names(activityTrainData) <- c("Activity")
        trainDataMerged <- cbind(subjectTrainData, activityTrainData, XTrainData)
        ## Prefix the subject id with TrainSubject to distinguish them from test ids
        ## if in case they are the same
        trainDataMerged$SubjectId <- paste("TrainSubject_", trainDataMerged$SubjectId, sep="") 
        
        ## Merge the test and train Data
        testAndTrainData <- rbind(testDataMerged, trainDataMerged)
        
        ## Replace the activity codes with the actual labels
        testAndTrainData$Activity[testAndTrainData$Activity=="1"] <- "WALKING"
        testAndTrainData$Activity[testAndTrainData$Activity=="2"] <- "WALKING_UPSTAIRS"
        testAndTrainData$Activity[testAndTrainData$Activity=="3"] <- "WALKING_DOWNSTAIRS"
        testAndTrainData$Activity[testAndTrainData$Activity=="4"] <- "SITTING"
        testAndTrainData$Activity[testAndTrainData$Activity=="5"] <- "STANDING"
        testAndTrainData$Activity[testAndTrainData$Activity=="6"] <- "LAYING"
        
        ## Get the meanData column names
        meanData <- testAndTrainData[,grepl("-mean\\(\\)", names(testAndTrainData))]
        meanColumnnames <- names(meanData)
        ## Get the meanData column names
        stdData <- testAndTrainData[,grepl("-std\\(\\)", names(testAndTrainData))]
        stdColumnnames <- names(stdData)
        
        ## Final columns to select
        columnsToSelect <- c(colnames(testAndTrainData)[1], colnames(testAndTrainData)[2], meanColumnnames, stdColumnnames)
        meanAndStdData <- subset(testAndTrainData, select=columnsToSelect)
        
        ## Group and Summarise the data 
        ## Load the dplyr package
        library(dplyr)
        groupeddata <- group_by(meanAndStdData, SubjectId, Activity)
        summarisedgroupeddata <- meanAndStdData %>% group_by(SubjectId, Activity) %>% summarise_each(funs(mean))
        
        ## Renames the summarised column names
        colnames(summarisedgroupeddata)[3:68] <- paste("GroupedMean", colnames(summarisedgroupeddata)[3:68], sep="_")
        
        ## Convert the summarisedgroupeddata as dataframe so melt can be performed.
        summariseddataasdataframe <- as.data.frame(summarisedgroupeddata)
        ## Load the reshape2 package
        library(reshape2)
        mdata <- melt(summariseddataasdataframe, id=c("SubjectId", "Activity"))
        
        ## Write the output to a file
        write.table(mdata, sep=",", row.names = FALSE, file="finaloutput.txt")
        
        
}
```

