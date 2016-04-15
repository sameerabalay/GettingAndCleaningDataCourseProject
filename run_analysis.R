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