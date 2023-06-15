--Data Analysis of Fitbit user data using SQL queries.
--Skills used: Aggregate functions, case statements, joins, temp table.

--Explore the table(daily_activity_cleaned)

SELECT *
FROM `fitbit_user_data.daily_activity_cleaned`

--Counting unique number of users who have logged activity data across the data timeframe to ensure how many users have worn fitbit device each day

SELECT Date AS date,
COUNT(DISTINCT Id) AS users_wearing_fitbit
FROM `fitbit_user_data.daily_activity_cleaned`
WHERE TotalSteps <> 0
AND TotalDistance <> 0
AND SedentaryMinutes <> 1440
GROUP BY date

--User engagement is high with more users wearing their fitbit device to track their physical activity levels at the start of the data recording duration (April) which gradually declined in May.

--Looking at the average total steps, total distance and calories burnt by users wearing fitbit across the data timeframe

SELECT Date AS date,
AVG(TotalSteps) AS avg_daily_steps,
AVG(TotalDistance) AS avg_daily_distance,
AVG(Calories) AS avg_calories
FROM `fitbit_user_data.daily_activity_cleaned`
WHERE TotalSteps <> 0
AND TotalDistance <> 0
AND SedentaryMinutes <> 1440
GROUP BY date
ORDER by 2 desc

--Most Users wearing fitbit devices burnt calories between 1280-2480 and covered distance between 3-6.9 miles on an average per day.

--Looking at the average activity minute distribution of users wearing fitbit across the data timeframe

SELECT Date AS date,
AVG(VeryActiveMinutes) AS avg_very_active_minutes,
AVG(FairlyActiveMinutes) AS avg_fairly_active_minutes,
AVG(LightlyActiveMinutes) AS avg_light_active_minutes,
AVG(SedentaryMinutes) AS avg_sedentary_minutes
FROM `fitbit_user_data.daily_activity_cleaned`
WHERE TotalSteps <> 0
AND TotalDistance <> 0
AND SedentaryMinutes <> 1440
GROUP BY date

-- Users mostly had their recorded time spent being sedentary, followed by being lightly active, very active and then fairly active.

-- Looking at different activity distribution percentages of each user vs their daily recorded minutes
--Creating a temp table

WITH new_daily_activity_table AS (
  SELECT *,
(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) AS RecordedDailyMinutes
FROM `fitbit_user_data.daily_activity_cleaned`
ORDER BY Date
)
 
SELECT Id AS id,
(AVG(VeryActiveMinutes)/AVG(RecordedDailyMinutes))*100 AS percent_very_active,
(AVG(FairlyActiveMinutes)/AVG(RecordedDailyMinutes))*100 AS percent_fairly_active,
(AVG(LightlyActiveMinutes)/AVG(RecordedDailyMinutes))*100 AS percent_lightly_active,
(AVG(SedentaryMinutes)/AVG(RecordedDailyMinutes))*100 AS percent_sedentary
FROM new_daily_activity_table
WHERE SedentaryMinutes<> 1440
GROUP BY id
ORDER BY 4 DESC

-- According to the results, all the users spent most of their recorded minutes being sedentary on an average.
-- Many users spent 4-34% of their recorded minutes in lightly active minutes and < 5% of their recorded minutes in very active and fairly active minutes.


--Categorizing the user type depending upon average number of steps taken each day using a case statement
--Looking at total and average steps, average distance, calories burnt, activity minutes of each user.

SELECT Id AS id,
SUM(TotalSteps) AS total_daily_steps,
AVG(TotalSteps) AS avg_daily_steps,
AVG(TotalDistance) AS avg_daily_distance,
AVG(Calories) AS avg_calories,
CASE WHEN AVG(TotalSteps) < 5000 THEN "SEDENTARY"
      WHEN AVG(TotalSteps) BETWEEN 5000 AND 7000 THEN "LIGHTLY_ACTIVE"
      WHEN AVG(TotalSteps) BETWEEN 7001 AND 9999 THEN "FAIRLY_ACTIVE"
      WHEN AVG(TotalSteps) > 9999 THEN "VERY_ACTIVE"
      END
      AS user_category,
AVG(VeryActiveMinutes) AS avg_very_active_minutes,
AVG(FairlyActiveMinutes) AS avg_fairly_active_minutes,
AVG(LightlyActiveMinutes) AS avg_light_active_minutes,
AVG(SedentaryMinutes) AS avg_sedentary_minutes
FROM `fitbit_user_data.daily_activity_cleaned`
WHERE TotalSteps <> 0
AND TotalDistance <> 0
AND SedentaryMinutes <> 1440
GROUP BY id
ORDER by id

--Exploring the Sleep_day table

SELECT *
FROM `fitbit_user_data.sleep_day_cleaned`

-- Average Sleep time distribution of all the users

SELECT Id AS id,
AVG(TotalMinutesAsleep/60) AS total_asleep_hours,
AVG(TotalTimeInBed/60) AS total_bedtime_hours
FROM `fitbit_user_data.sleep_day_cleaned`
GROUP BY id
ORDER BY 2 desc

--24 unique users have their sleep data recorded.

--Looking at the percentage of TotalMinutesAsleep vs TotalTimeInBed.

SELECT Id AS id,
AVG((TotalMinutesAsleep/TotalTimeInBed)*100) AS Percent_asleep
FROM `fitbit_user_data.sleep_day_cleaned`
GROUP BY id
ORDER BY 2

--20 out of 24 users had > 90% of their sleep time out of the total time in bed.

--Categorizing the average sleep minutes of users for further analysis

SELECT Id AS id,
AVG(TotalMinutesAsleep/60) AS average_sleep_hours,
CASE WHEN AVG(TotalMinutesAsleep) < 360 THEN "LESS_THAN_6_HOURS"
WHEN AVG(TotalMinutesAsleep) BETWEEN 360 AND 480 THEN "6_TO_8_HOURS"
WHEN AVG(TotalMinutesAsleep) > 480 THEN "GREATER_THAN_8_HOURS"
END AS sleep_category,
FROM `fitbit_user_data.sleep_day_cleaned`
GROUP BY id
ORDER BY 2

-- 14-24 users slept between 6-8 hours on an average.
--8 users slept less than 6 hours and 2 users slept more than 8 hours on average.

-- Distribution of users average sleep hours and bedtime hours based on sleep categories across the timeframe

SELECT Id AS id,
Date AS date,
AVG(TotalMinutesAsleep/60) AS average_sleep_hours,
AVG(TotalTimeInBed/60) AS average_bedtime_hours,
CASE WHEN AVG(TotalMinutesAsleep) < 360 THEN "LESS_THAN_6_HOURS"
WHEN AVG(TotalMinutesAsleep) BETWEEN 360 AND 480 THEN "6_TO_8_HOURS"
WHEN AVG(TotalMinutesAsleep) > 480 THEN "GREATER_THAN_8_HOURS"
END AS sleep_category,
FROM `fitbit_user_data.sleep_day_cleaned`
GROUP BY id,date
ORDER BY 1,2

--Joining daily_activity_cleaned and sleep_day_cleaned tables using the columns to be analyzed later

SELECT a.Id,
s.Date,
a.TotalSteps,
a.VeryActiveMinutes,
a.FairlyActiveMinutes,
a.LightlyActiveMinutes,
a.SedentaryMinutes,
s.TotalMinutesAsleep,
s.TotalTimeInBed
FROM `fitbit_user_data.daily_activity_cleaned` AS a
JOIN `fitbit_user_data.sleep_day_cleaned` AS s
ON a.Id = s.Id
AND a.Date = s.Date
ORDER BY 8

-- Looking at average daily steps and average sleep hours of the users across the timeframe

SELECT
a.Id AS id,
a.Date AS date,
AVG(a.TotalSteps) AS avg_daily_steps,
AVG(s.TotalMinutesAsleep/60) as avg_sleep_hours,
FROM `fitbit_user_data.daily_activity_cleaned` AS a
JOIN `fitbit_user_data.sleep_day_cleaned` AS s
ON a.Id = s.Id
AND a.Date = s.Date
WHERE a.TotalSteps<>0
AND a.SedentaryMinutes<>1440
GROUP BY a.Id, a.Date
ORDER BY 1

-- Average sleep hours of users kept fluctuating across the time frame and did not depend upon average daily steps taken.

--Looking at the average activity minutes vs average sleep minutes of users

SELECT
a.Id AS id,
a.Date AS date,
AVG(s.TotalMinutesAsleep) AS avg_sleep_minutes,
AVG(a.SedentaryMinutes) AS avg_sedentary_minutes,
AVG(a.LightlyActiveMinutes) AS avg_lightly_active_minutes,
AVG(a.FairlyActiveMinutes) AS avg_fairly_active_minutes,
AVG(a.VeryActiveMinutes) AS avg_very_active_minutes
FROM `fitbit_user_data.daily_activity_cleaned` AS a
JOIN `fitbit_user_data.sleep_day_cleaned` AS s
ON a.Id = s.Id
AND a.Date = s.Date
WHERE a.TotalSteps<>0
AND a.SedentaryMinutes<>1440
GROUP BY a.Id,a.Date
ORDER BY 2

--Looking at the average daily activities minutes and average sleep minutes by user category

SELECT
a.Id as id,
a.Date AS date,
CASE WHEN AVG(a.TotalSteps) < 5000 THEN "SEDENTARY"
      WHEN AVG(a.TotalSteps) BETWEEN 5000 AND 7000 THEN "LIGHTLY_ACTIVE"
      WHEN AVG(a.TotalSteps) BETWEEN 7001 AND 9999 THEN "FAIRLY_ACTIVE"
      WHEN AVG(a.TotalSteps) > 9999 THEN "VERY_ACTIVE"
      END
      AS user_category,
AVG(a.SedentaryMinutes) AS avg_sedentary_minutes,
AVG(s.TotalMinutesAsleep) AS avg_sleep_minutes,
CASE WHEN AVG(s.TotalMinutesAsleep) < 360 THEN "LESS_THAN_6_HOURS"
WHEN AVG(s.TotalMinutesAsleep) BETWEEN 360 AND 480 THEN "6_TO_8_HOURS"
WHEN AVG(s.TotalMinutesAsleep) > 480 THEN "GREATER_THAN_8_HOURS"
END AS sleep_category,
AVG(a.VeryActiveMinutes) AS avg_very_active_minutes,
AVG(a.FairlyActiveMinutes) AS avg_fairly_active_minutes,
AVG(a.LightlyActiveMinutes) AS avg_lightly_active_minutes
FROM `fitbit_user_data.daily_activity_cleaned` AS a
JOIN `fitbit_user_data.sleep_day_cleaned` AS s
ON a.Id = s.Id
AND a.Date = s.Date
WHERE a.TotalSteps<>0
AND a.SedentaryMinutes<>1440
GROUP BY a.Id,a.Date
ORDER BY id

-- Looking at weight_log_info_cleaned table

SELECT *
FROM `fitbit_user_data.weight_log_info_cleaned`

--Joining 2 tables
--Looking at the average calories burnt, daily Steps, sedentary minutes vs average weight and BMI of users who wore fitbit

SELECT a.Id,
AVG(a.Calories) AS avg_calories,
AVG(a.SedentaryMinutes) AS avg_sedentary_minutes,
AVG(w.BMI) AS avg_bmi,
AVG(w.WeightPounds) AS avg_weight,
AVG(a.TotalSteps) AS avg_total_steps
FROM `fitbit_user_data.daily_activity_cleaned` AS a
JOIN `fitbit_user_data.weight_log_info_cleaned` AS w
ON a.Id = w.Id
AND a.Date = w.Date
WHERE a.TotalSteps<>0
AND a.SedentaryMinutes<>1440
GROUP BY a.Id
ORDER BY 3 desc

--There are only 8 unique users who have logged their weight info, which is not sufficient data to draw patterns applicable to all the users.
--From the results above for the 8 users, average calories burnt, average total steps and average sedentary minutes do not have much correlation with BMI.

-- Looking at the average of daily steps, calories burnt, sedentary minutes vs average BMI and weight of users across the timeframe

SELECT a.Id AS id,
a.Date AS date,
AVG(a.Calories) AS avg_calories,
AVG(a.SedentaryMinutes) AS avg_sedentary_minutes,
AVG(w.BMI) AS avg_bmi,
AVG(w.WeightPounds) AS avg_weight,
AVG(a.TotalSteps) AS avg_total_steps
FROM `fitbit_user_data.daily_activity_cleaned` AS a
JOIN `fitbit_user_data.weight_log_info_cleaned` AS w
ON a.Id = w.Id
AND a.Date = w.Date
WHERE a.TotalSteps<>0
AND a.SedentaryMinutes<>1440
GROUP BY a.Id,a.Date
ORDER BY date,id

--Looking at the sleep minutes and BMI

SELECT s.Id AS id,
AVG(s.TotalMinutesAsleep) AS avg_sleep_minutes,
AVG(w.BMI) AS avg_bmi,
AVG(w.WeightPounds) AS avg_weight
FROM `fitbit_user_data.sleep_day_cleaned` AS s
JOIN `fitbit_user_data.weight_log_info_cleaned` AS w
ON s.Id = w.Id
AND s.Date = w.Date
GROUP BY s.Id
ORDER BY 2 desc

--It's hard to draw any patterns as only 5 out of 24 users who have recorded sleep have also recorded BMI and weight which are not enough data to draw conclusions which can be applicable to all users.


