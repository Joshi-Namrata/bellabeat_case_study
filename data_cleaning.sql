-- Data Cleaning Steps using SQL queries

--1) Identifying and Removing duplicate data

--a) daily_activity table

--Explore the table

SELECT *
FROM `fitbit_user_data.daily_activity`

--There are 940 rows of data

--Finding distinct Ids representing fitbit users

SELECT DISTINCT Id
FROM `fitbit_user_data.daily_activity`

--Output is 33 distinct ids

--Use of a temp table, window function- Row_NUMBER() and partition by to see rows containing the same data.

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY
            Id,
            ActivityDate,
            TotalSteps,
            CAST(TotalDistance AS INT64),
            CAST(LoggedActivitiesDistance AS INT64),
            VeryActiveMinutes,
            Calories
         ORDER BY
            Id
               ) row_num
FROM `fitbit_user_data.daily_activity`
)

SELECT *
FROM RowNumCTE
WHERE row_num >1

--No duplicate rows found in daily_activity

--b) sleep_day table

--Explore the table

SELECT *
FROM `fitbit_user_data.sleep_day`

--There are 413 rows of data.

-- Finding distinct Ids representing the users in the table

SELECT DISTINCT Id
FROM `fitbit_user_data.sleep_day`

--Output is 24 unique Ids of fitbit users

--Use of a temp table, window function- Row_NUMBER() and partition by to see rows containing the same data.

WITH RowNumCTE AS(
   SELECT *,
     ROW_NUMBER() OVER (
        PARTITION BY
           Id,
           SleepDay,
           TotalSleepRecords,
           TotalMinutesAsleep,
           TotalTimeInBed
         ORDER BY
          Id
             ) row_num
FROM `fitbit_user_data.sleep_day`
)

SELECT *
FROM RowNumCTE
WHERE row_num >1

--3 rows found with duplicate data

--Removing the duplicates by creating a new table selecting the data without duplicate rows

WITH RowNumCTE AS(
   SELECT *,
     ROW_NUMBER() OVER (
       PARTITION BY
          Id,
          SleepDay,
          TotalSleepRecords,
          TotalMinutesAsleep,
          TotalTimeInBed
        ORDER BY
          Id
             ) row_num
FROM `fitbit_user_data.sleep_day`
)

SELECT *
FROM RowNumCTE
WHERE row_num <> 2

--Query results saved into a new table(sleep_day_revised)

-- C) weight_log_info table

--Explore the table

SELECT *
FROM `fitbit_user_data.weight_log_info`

--There are 67 rows of data.

--Finding distinct Ids representing the users in the table

SELECT DISTINCT Id
FROM `fitbit_user_data.weight_log_info`

--Output is 8 unique Ids of fitbit users

--Use of a temp table, window function- Row_NUMBER() and partition by to see rows containing the same data.

WITH RowNumCTE AS(
   SELECT *,
     ROW_NUMBER() OVER (
       PARTITION BY
          Id,
          Date,
          Time,
          CAST(WeightPounds AS INT64),
          CAST(BMI AS INT64)
        ORDER BY
          Id
             ) row_num
FROM `fitbit_user_data.weight_log_info`
)

SELECT *
FROM RowNumCTE
WHERE row_num >1

--No duplicate rows of data found


--2) Maintaining consistency of date and time columns across the tables

--Creating columns for month and weekday by extracting data from Date and Time columns and formatting table by excluding unwanted columns

--a) daily_activity table

--Checking number of 0 values in LoggedActivitiesDistance and SedentaryActivitiesDistance Columns

SELECT COUNTIF(LoggedActivitiesDistance = 0) AS num_of_zero_logged_distance_values,
COUNTIF(SedentaryActiveDistance = 0) AS num_of_zero_sedendary_distance_values
FROM `fitbit_user_data.daily_activity`

--There are 908 zero values in LoggedActivitiesDistance and 858 zero values in SedentaryActivitiesDistance Columns out of 940 rows of data

--Extracting week and weekday from ActivityDate and excluding unwanted columns with mostly 0 values(LoggedActivitiesDistance and SedentaryActivitiesDistance)

SELECT
  Id,
  ActivityDate as Date,
  EXTRACT(MONTH FROM ActivityDate) AS Month,
  FORMAT_DATE('%A', ActivityDate) AS WeekDay,
  *
  EXCEPT (Id,ActivityDate,LoggedActivitiesDistance,SedentaryActiveDistance)--Excluding columns already included above and columns with zero values 
FROM `fitbit_user_data.daily_activity`

--Exported results to a new table(daily_activity_cleaned) in the same dataset

--b)sleep_day_revised table

SELECT
  Id,
  SleepDay AS Date,
  EXTRACT (MONTH FROM SleepDay) AS Month,
  FORMAT_DATE('%A',SleepDay) AS WeekDay,
  *
  EXCEPT(Id,SleepDay,row_num)--Excluding the columns already mentioned above and the unwanted column
FROM  `fitbit_user_data.sleep_day_revised`

--Exported results to a new table(sleep_day_cleaned) in the same dataset

--c) weight_log_info table

SELECT
  Id,
  Date,
  EXTRACT (MONTH FROM Date) AS Month,
  FORMAT_DATE('%A',Date) AS WeekDay,
  *
  EXCEPT(Id,Date,Fat)--Excluding the columns already mentioned above along with the fat column containing mostly null values
FROM  `fitbit_user_data.weight_log_info`

--Exported results to a new table(weight_log_info_cleaned) in the same dataset


