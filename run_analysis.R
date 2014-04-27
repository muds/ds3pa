################################################################################
# Function:
#   tidyDataFromZip
#
# Description:
#   Extracts testing and training data from the Samsung dataset stored
#   in the .zip archive specified by `zipfile`, and merges them into a
#   single dataset. Activity names are read from the `activity_labels.txt`
#   file in the archive and added as a factor. Column descriptions for
#   the measured quantities are generated based on the list contained in
#   `features.txt`, and those that have previously been aggregated and
#   identified as either `-mean()` or `-std()` are combined into a new,
#   intermediate dataset. These features are then further aggregated,
#   to find the single value that is the mean of each one, over all
#   measurements for a single subject and a single activity.
#
# Input:
#   `zipfile` (optional, character) -
#     Location of the .zip archive containing the Samsung data.
#     Defaults to the provided value of,
#       'getdata-projectfiles-UCI HAR Dataset.zip'
#   `progress.reports` (optional, logical) -
#     Whether or not to display messages containing progress updates
#     as the various steps of the process are performed.
#     Default is TRUE (i.e. messages will be shown).
#
# Output:
#   Returns a data.frame object containing average mean and average
#   standard deviation for each of the measured properties, over each
#   subject's performance of each activity.
tidyDataFromZip <- function (
  zipfile = 'getdata-projectfiles-UCI HAR Dataset.zip',
  progress.reports = T
) {
  # Record the initial start time, to determine elapsed time when finished
  start.time = Sys.time()
  
  # Define two 'helper' functions that are used repeatedly during the process
  
  ######################################################################
  # Function:
  #   combineFiles
  #
  # Description:
  #   Extracts the two files, `ftest` and `ftrain`, from the archive
  #   `zipfile`, and appends one to the other via `rbind`. Optionally
  #   sets the column names in the returned data set to those given
  #   in the `cnames` parameter, if any.
  #
  # Input:
  #   `ftest`, `ftrain` (character) -
  #     The path and filename within the `zipfile` archive of the
  #     testing and training datasets to be combined.
  #   `cnames` (optional, character vector) -
  #     Names to be applied to the columns in the output.
  #
  # Output:
  #   A data frame containing both the testing and training data from
  #   one pair of files in the Samsung data.
  combineFiles <- function (ftest, ftrain, cnames = NULL) {
    # Read the test and train data from the specified locations in
    # the zip archive, into local variables
    testData <- read.table(unz(zipfile, ftest))
    trainData <- read.table(unz(zipfile, ftrain))
    
    # Combine the two frames by appending the training data rows
    # to the test data rows
    fullSet <- rbind(testData, trainData)
    
    # If column names were provided, apply them to the data frame
    if (!is.null(cnames)) {
      colnames(fullSet) <- cnames
    }
    
    # Return the full combined data set
    fullSet
  }
  
  
  ######################################################################
  # Function:
  #   pmsg
  #
  # Description:
  #   Prints a message containing an optional timestamp, if the
  #   parameter `progress.reports` is TRUE.
  #
  # Input:
  #   `msg` (character) -
  #     The message to be displayed
  #   `timestamp` (optional, logical) -
  #     Whether or not to prepend the message with the current time.
  #     Default is TRUE (i.e. timestamps will be printed)
  #
  # Output:
  #   None
  pmsg <- function (msg, timestamp = T) {
    if (progress.reports) {
      if (timestamp) {
        # If the timestamp variable is TRUE, paste the current time
        # to the beginning of the message, with a space between them
        msg <- paste(format(Sys.time(), '%H:%M:%S'), msg, sep = ' ')
      }
      message(msg)
    }
  }
  
  #########################
  # Start of main routine
  #########################
  
  pmsg('Extracting activity information...')
  # Retrieve the list of Activity IDs in the order in which they were recorded
  activity.performed <- combineFiles(
    'UCI HAR Dataset/test/y_test.txt',
    'UCI HAR Dataset/train/y_train.txt',
    c('id')
  )
  # Extract definitions of the activity IDs and corresponding names
  activity.defn <- read.table(
    unz(zipfile, 'UCI HAR Dataset/activity_labels.txt')
  )
  colnames(activity.defn) <- c('id', 'activity')
  # Create a vector of the names of the activities by row
  activity <- activity.defn$activity[
    match(activity.performed$id, activity.defn$id)
  ]
  
  pmsg('Extracting measurement data...')
  # Retrieve the mesaurements from the zip archive
  results <- combineFiles(
    'UCI HAR Dataset/test/X_test.txt',
    'UCI HAR Dataset/train/X_train.txt'
  )
  
  pmsg('Retrieving subject data...')
  # Load the lists of which subject performed each measured activity
  subject <- combineFiles(
    'UCI HAR Dataset/test/subject_test.txt',
    'UCI HAR Dataset/train/subject_train.txt'
  )
  
  pmsg('Generating feature descriptions...')
  # Extract the list of the names of the activities that were performed
  features <- read.table(
    unz(zipfile, 'UCI HAR Dataset/features.txt'),
    stringsAsFactors = F
  )
  colnames(features) <- c('feat.id', 'description')
  
  # Create a logical vector that is TRUE only for features whose description
  # contains either 'mean()' or 'std()'
  wantedFeats <- grepl('-(mean|std)\\(\\)', features$description)
  wantedFeatNames <- features[wantedFeats, 'description']
  
  pmsg('Combining data by columns...')
  # Bind together the columns of the Task ID, Subject ID, and wanted features
  data <- cbind(activity, subject, results[,wantedFeats])
  # Give these columns appropriate names
  colnames(data) <- c(
    'activity',
    'subject',
    wantedFeatNames
  )
  
  pmsg('Aggregating data...')
  agg <- aggregate(
    data[wantedFeatNames],
    by = list(
      activity = data$activity,
      subject = data$subject
    ),
    FUN = 'mean'
  )
  
  colnames(agg) <- gsub(
    '([a-zA-Z]+)-(mean|std)\\(\\)(-(X|Y|Z))?',
    '\\1\\4.avg.\\2',
    colnames(agg)
  )
  
  pmsg(paste0(
    'Total time: ',
    as.numeric(
      round(difftime(Sys.time(), start.time, units = 'secs'), 2)
    ),
    ' seconds'
  ))
  pmsg('Done!', timestamp = F)
  
  agg
}

