genDataframeFromZip <- function () {
  zipfile = 'getdata-projectfiles-UCI HAR Dataset.zip'
  
  # Function to return the combined data set in two files (test and train)
  combineFiles <- function (ftest, ftrain, cnames = NULL) {
    testData <- read.table(unz(zipfile, ftest))
    trainData <- read.table(unz(zipfile, ftrain))
    
    fullSet <- rbind(testData, trainData)
    if (!is.null(cnames)) {
      colnames(fullSet) <- cnames
    }
    
    fullSet
  }

  # Retrieve the list of Activity IDs in the order in which they were recorded
  activity.performed <- combineFiles(
    'UCI HAR Dataset/test/y_test.txt',
    'UCI HAR Dataset/train/y_train.txt',
    c('id')
  )
  # Definition of the activity IDs and corresponding names
  activity.defn <- read.table(
    unz(zipfile, 'UCI HAR Dataset/activity_labels.txt')
  )
  colnames(activity.defn) <- c('id', 'activity')
  # Create a vector of the names of the activities by row
  activity <- activity.defn$activity[
    match(activity.performed$id, activity.defn$id)
  ]
  
  results <- combineFiles(
    'UCI HAR Dataset/test/X_test.txt',
    'UCI HAR Dataset/train/X_train.txt'
  )
  subject <- combineFiles(
    'UCI HAR Dataset/test/subject_test.txt',
    'UCI HAR Dataset/train/subject_train.txt'
  )
  
  features <- read.table(
    unz(zipfile, 'UCI HAR Dataset/features.txt'),
    stringsAsFactors = F
  )
  colnames(features) <- c('feat.id', 'description')
  
  # Create a logical vector that is TRUE only for features whose description
  # contains either 'mean()' or 'std()'
  wantedFeats <- grepl('-(mean|std)\\(\\)', features$description)
  
  # Bind together the columns of the Task ID, Subject ID, and wanted features
  data <- cbind(activity, subject, results[,wantedFeats])
  # Give these columns appropriate names
  colnames(data) <- c(
    'activity',
    'subject',
    features[wantedFeats,'description']
  )
  
  data
}

