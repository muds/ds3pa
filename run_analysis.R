genDataframeFromZip <- function (
  zipfile = 'getdata-projectfiles-UCI HAR Dataset.zip'
) {
  # Within the zip file, the following files contain data we want.
  # Store the names in a dataframe such that datafiles['var', 'type'],
  # with 'type' equal to either 'test' or 'train', will return the
  # path and filename to 
  datafiles <- data.frame(
    test = c(
      'UCI HAR Dataset/test/X_test.txt',
      'UCI HAR Dataset/test/y_test.txt',
      'UCI HAR Dataset/test/subject_test.txt'
    ),
    train = c(
      'UCI HAR Dataset/train/X_train.txt',
      'UCI HAR Dataset/train/y_train.txt',
      'UCI HAR Dataset/train/subject_train.txt'
    ),
    
    # End of data, start of data.frame parameters
    row.names = c(
      'X', # Actual values measured and recorded during each test
      'y', # Task ID, specifying which task was performed during the test
      'subject' # Person ID, specifying the subject who performed the test
    ),
    stringsAsFactors = F
  )
  
  # Function to return the combined data set in two files (test and train)
  combineFiles <- function (ftest, ftrain) {
    testData <- read.table(unz(zipfile, ftest))
    trainData <- read.table(unz(zipfile, ftrain))
  
    rbind(testData, trainData)
  }
  
  # Create an empty object that will have data added to it as the files
  # are read and combined
  dataset <- NULL
  
  #### Step 1: Combine the 'test' and 'train' datasets
  for (i in seq(nrow(datafiles))) {
    #dataset[rownames(datafiles)[i]]
    newdata <- combineFiles(
      datafiles[i, 'test'],
      datafiles[i, 'train']
    )
    if (is.null(dataset)) {
      dataset <- newdata
    } else {
      dataset <- cbind(dataset, newdata)
    }
  }

  dataset
}

genDataframeFromZip <- function () {
  zipfile = 'getdata-projectfiles-UCI HAR Dataset.zip'
  
  # Function to return the combined data set in two files (test and train)
  combineFiles <- function (ftest, ftrain) {
    testData <- read.table(unz(zipfile, ftest))
    trainData <- read.table(unz(zipfile, ftrain))
    
    rbind(testData, trainData)
  }
  
  X <- combineFiles(
    'UCI HAR Dataset/test/X_test.txt',
    'UCI HAR Dataset/train/X_train.txt'
  )
  y <- combineFiles(
    'UCI HAR Dataset/test/y_test.txt',
    'UCI HAR Dataset/train/y_train.txt'
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
  
  data <- cbind(y, subject, X)
  colnames(data) <- c('task.id', 'subject.id', features$description)
  
  data
}
