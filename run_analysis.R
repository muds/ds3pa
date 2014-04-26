# The Samsung data are stored in the following ZIP archive, which is
# assumed to be in the current working directory.
zipfile <- 'getdata-projectfiles-UCI HAR Dataset.zip'

# Retrieve a list of all filenames stored in the archive
fnames <- unzip(zipfile, list = T)

# Subset those files whose names contain the string 'X_test.txt'
# or 'y_test.txt'
testfiles <- sort(fnames$Name[grepl('/(X|y)_test.txt', fnames$Name)])
# And those containing 'X_train.txt' or 'y_train.txt'
trainfiles <- sort(fnames$Name[grepl('/(X|y)_train.txt', fnames$Name)])
# We now have two lists of two files each, which need to be combined
# pairwise (i.e. first with first, and second with second).

# Define a function that will combine two of the files into one
combineFiles <- function (ftest, ftrain) {
  # We want to turn 'dir/file_test.txt' into 'file.txt', which will
  # be the output filename for the combination of the two input files
  start <- nchar('UCI HAR Dataset/test/') + 1
  # Remove the initial path info
  fname <- substring(ftest, start)
  # Remove the end of the filename
  end <- nchar(fname) - nchar('_test.txt')
  fname <- substring(fname, 1, end)
  # We now have 'file'; append '.txt' with no separation
  fname <- paste(fname, '.txt', sep='')
  # fname is now 'file.txt' as desired
  
  # Since combining the files is somewhat time consuming, we
  # only want to do it if it hasn't already been done.
  if (!file.exists(fname)) {
    # Next step into it Combine the two files into one
    testData <- read.table(unz(zipfile, ftest), headers = F)
    trainData <- read.table(unz(zipfile, ftrain), headers = F)
  
    data <- rbind(testData, trainData)
  
    write.table(data, file = fname)
  }
  
  # Return the processed filename as the function output
  fname
}

#### Step 1: Combine the 'test' and 'train' datasets
for (i in seq_along(testfiles)) {
  combineFiles(testfiles[i], trainfiles[i])
}
