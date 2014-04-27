# Tidy Samsung data set code book

This document describes the methods used and decisions made in the
transformation of the given Samsung training and testing data sets, into a
single tidy data set containing the averages of each of the measured means
and standard deviations per activity, per subject.


## Decisions made

### 1. Selection of data to include

The goal in the creation of this tidy data set was to extract and combine from
the supplied zip archive (`getdata-projectfiles-UCI HAR Dataset.zip`), only the
mean and standard deviations of each set of measured quantities. To achieve
this, the regular expression `-(mean|std)\\(\\)` is used in the R function
`grepl` to create a logical vector along the feature descriptions contained in
`UCI HAR Dataset/features.txt`:

    wanted.features <- grepl('-(mean|std)\\(\\)', features$description)

This vector contains `TRUE` only for those features whose names contain either
of the strings `-mean()` and `-std()`. It is these features that were included
in the final tidy data set. There are 33 such features, described below in the
*Variables* section.

### 2. Calculations to be performed

Each of the rows in the Samsung data set of measured values contains many mean
and standard deviation values, as the activities were performed multiple times
by each subject. To obtain a single final value for each subject's performance
of each activity, the R function `mean` is applied to each group of values for
each distinct (activity, subject)-pair. Specifically, the means are calculated
by the `aggregate` command:

    aggregate(
      data[wanted.features],
      by = list(activity = data$activity, subject = data$subject),
      FUN = 'mean'
    )

### 3. Naming of output variables

The input features are described in the initial data set with names such as
`tGravityAcc-mean()-X` for the mean gravity acceleration in the X-direction. To
make the names more in line with standard R notation, and allow their use as
column labels such as `data$tGravityAccX.mean`, the hypens are replaced with
periods, the parentheses removed, and the direction (when present) attached to
the variable, as in the preceding example.

Since the output variables are averages of the input variables, the names are
further altered to indicate this with the inclusion of `avg` between the
physical and statistical quantities. This is accomplished using the regular
expressions and the R function `gsub`:

    gsub(
      '([a-zA-Z]+)-(mean|std)\\(\\)(-(X|Y|Z))?',
      '\\1\\4.avg.\\2',
      colnames(data)
    )

This matches any combination of upper and lower case letters followed by a
hyphen, then either `mean()` or `std()`, and either zero or one of `-X`, `-Y`,
or `-Z`. When it finds this, it keeps the same inital set of letters (the main
descriptive name), then the direction (`'X'`, `'Y'`, `'Z'`, or `''`). It then
adds `'.avg.'` before the feature type, `'mean'` or `'std'`. As specific
examples, the input feature names `tGravityAccMag-mean()` and `fBodyGyro-X-std()`
are translated to the output feature names `tGravityAccMag.avg.mean` and
`fBodyGyroX.avg.std`, respectively


## Variables

There are 68 variables accounted for in the output tidy data set. The first two
specify the activity that was being performed and the test subject who was
performing it, as the data aggregated into the remaining 66 columns were
collected. Specifically, the first two variables are:

`activity`, a factor specifying which of the activities the values in the
row were collected during. Allowed values are `WALKING`, `WALKING_UPSTAIRS,
`WALKING_DOWNSTAIRS', `SITTING`, `STANDING`, and `LAYING`.

`subject`, a unique number indicating which test subject performed the
activities of the row. Allowed values are the integers `1` to `30`.

The remaining 66 variables are the aggregated averages of the means and standard
deviations of each of the 33 quantities present in the initial data set. The
description of these is best left to their original creators, whose
documentation is quoted here:

> The features selected for this database come from the accelerometer and
> gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain
> signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz.
> Then they were filtered using a median filter and a 3rd order low pass
> Butterworth filter with a corner frequency of 20 Hz to remove noise.
> Similarly, the acceleration signal was then separated into body and gravity
> acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low
> pass Butterworth filter with a corner frequency of 0.3 Hz. 
> 
> Subsequently, the body linear acceleration and angular velocity were derived
> in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also
> the magnitude of these three-dimensional signals were calculated using the
> Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag,
> tBodyGyroJerkMag). 
> 
> Finally a Fast Fourier Transform (FFT) was applied to some of these signals
> producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag,
> fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain
> signals). 

The combination of properties, axial directions, time and frequency domains,
and statistical aggregations via mean and standard deviation, along with
the renaming conventions described above, leads to the inclusion of these
variables in the final tidy data set:

tBodyAccX.avg.mean,            tBodyAccY.avg.mean,           
tBodyAccZ.avg.mean,            tBodyAccX.avg.std,            
tBodyAccY.avg.std,             tBodyAccZ.avg.std,            
tGravityAccX.avg.mean,         tGravityAccY.avg.mean,        
tGravityAccZ.avg.mean,         tGravityAccX.avg.std,         
tGravityAccY.avg.std,          tGravityAccZ.avg.std,         
tBodyAccJerkX.avg.mean,        tBodyAccJerkY.avg.mean,       
tBodyAccJerkZ.avg.mean,        tBodyAccJerkX.avg.std,        
tBodyAccJerkY.avg.std,         tBodyAccJerkZ.avg.std,        
tBodyGyroX.avg.mean,           tBodyGyroY.avg.mean,          
tBodyGyroZ.avg.mean,           tBodyGyroX.avg.std,           
tBodyGyroY.avg.std,            tBodyGyroZ.avg.std,           
tBodyGyroJerkX.avg.mean,       tBodyGyroJerkY.avg.mean,      
tBodyGyroJerkZ.avg.mean,       tBodyGyroJerkX.avg.std,       
tBodyGyroJerkY.avg.std,        tBodyGyroJerkZ.avg.std,       
tBodyAccMag.avg.mean,          tBodyAccMag.avg.std,          
tGravityAccMag.avg.mean,       tGravityAccMag.avg.std,       
tBodyAccJerkMag.avg.mean,      tBodyAccJerkMag.avg.std,      
tBodyGyroMag.avg.mean,         tBodyGyroMag.avg.std,         
tBodyGyroJerkMag.avg.mean,     tBodyGyroJerkMag.avg.std,     
fBodyAccX.avg.mean,            fBodyAccY.avg.mean,           
fBodyAccZ.avg.mean,            fBodyAccX.avg.std,            
fBodyAccY.avg.std,             fBodyAccZ.avg.std,            
fBodyAccJerkX.avg.mean,        fBodyAccJerkY.avg.mean,       
fBodyAccJerkZ.avg.mean,        fBodyAccJerkX.avg.std,        
fBodyAccJerkY.avg.std,         fBodyAccJerkZ.avg.std,        
fBodyGyroX.avg.mean,           fBodyGyroY.avg.mean,          
fBodyGyroZ.avg.mean,           fBodyGyroX.avg.std,           
fBodyGyroY.avg.std,            fBodyGyroZ.avg.std,           
fBodyAccMag.avg.mean,          fBodyAccMag.avg.std,          
fBodyBodyAccJerkMag.avg.mean,  fBodyBodyAccJerkMag.avg.std,  
fBodyBodyGyroMag.avg.mean,     fBodyBodyGyroMag.avg.std,     
fBodyBodyGyroJerkMag.avg.mean, fBodyBodyGyroJerkMag.avg.std
