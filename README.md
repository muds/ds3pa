# Using `tidyDataFromZip()`

The processing of the Samsung data set contained in the zip archive
`getdata-projectfiles-UCI HAR Dataset.zip` is accomplished from the included
`run_analysis.R` script via the single function `tidyDataFromZip()`, which is
defined in the script.

It is assumed that the zip archive has the above name and is located
in the current working directory (as returned by `getwd()`).

## Running the script

When the script is loaded into R via the `source` command, it will define the
`tidyDataFromZip()` function. To store the results of the script into a variable
named `tidy.set`, run the script as

    > tidy.set <- tidyDataFromZip()

This will produce a sequence of progress reports, such as

> 15:12:56 Extracting activity information...
> 15:12:56 Extracting measurement data...
> 15:13:22 Retrieving subject data...
> 15:13:22 Generating feature descriptions...
> 15:13:22 Combining data by columns...
> 15:13:22 Aggregating data...
> 15:13:24 Total time: 27.25 seconds
> Done!

The results can then be saved to a text file for storage or transmission,

    > write.table(tidy.set, 'tidyset.txt')

## Additional documentation

The source code within the `run_analysis.R` script contains further
documentation in the form of code comments and function-description blocks.

## Code book

A description of the variables in the output, as well as the process undergone
to create the data, can be found in the included `codebook.md` in this
repository.
