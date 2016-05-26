# data_cleaning_finalproject
Final project for Coursera data cleaning course

## Data source: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

## Task 1: combine training and test data sets 
Outcome: all_data

## Task 2: extract only the mean and std measurements 
Outcome: selected_data

## Task 3: use descriptive activity names 
Used activity_labels.txt 
Factorized the activity variable in selected_data

## Task 4: use descriptive variable names 
Used features.txt
Substitute abbreviated names with completed variable names. E.g., t is now time

## Task 5: create a second, independent tidy data set
Create group variable to capture person and activity. E.g., 1_Walking is the 1st person's Walking activity
Use group_by() and submmarize_each() to calculate means for every column
Outcome: allmeans

## Codebook
Outcome: Data-cdbk.txt
