--Creating tables using SQL queries to use them for data visualizations in tableau

--Table 1
--Counting unique number of users who have logged activity data across the data timeframe to ensure how many users have worn fitbit device each day

SELECT Date AS date,
COUNT(DISTINCT Id) AS users_wearing_fitbit
FROM `fitbit_user_data.daily_activity_cleaned`
WHERE TotalSteps <> 0
AND TotalDistance <> 0
AND SedentaryMinutes <> 1440
GROUP BY date

--Table 2
--Looking at total and average daily steps, average distance, calories burnt, activity minutes and categorizing users based on user type.

SELECT
Id AS id,
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
ORDER by 1

--Table 3
--Distribution of users average sleep hours and bedtime hours based on sleep categories across the timeframe

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

--Table 4
--Looking at the average daily sleep hours,activities minutes by user category

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
