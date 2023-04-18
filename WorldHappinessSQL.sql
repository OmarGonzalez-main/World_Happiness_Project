SELECT * 
FROM dbo.WorldHappinessReport




--	What is the overall trend in global happiness over time? Are people becoming happier or less happy?

SELECT 
	years,COUNT(Life_Ladder) AS num_observations,AVG(Life_Ladder) AS avg_happiness
FROM 
	WorldHappinessReport
GROUP BY 
	years
ORDER BY 
	years

-- We can see that we only have 27 observations from 2005 compared to 100+ observations from most other years, we need to take this into account for all future
-- results.





--  Calculate the average Life Ladder score per country for the entire period (2005-2022)
SELECT 
    Country_Name, 
    AVG(Life_Ladder) AS Avg_Life_Ladder
FROM 
    WorldHappinessReport
GROUP BY 
    Country_Name
ORDER BY 
    Avg_Life_Ladder DESC;

-- Denmark has the highest average Life Ladder from 2005-2022






--  Calculate the average GDP per capita per region for the entire period (2005-2022)
SELECT 
    Regional_Indicator, 
    AVG(Log_GDP_Per_Capita) AS Avg_GDP_Per_Capita
FROM 
    WorldHappinessReport
GROUP BY 
    Regional_Indicator
ORDER BY 
    Avg_GDP_Per_Capita DESC;
 
-- Overall GDP averages range from 8-11


--	Are there any regional patterns in happiness from 2005-2022? Do countries in specific regions (e.g., Europe, Asia, Africa) tend to be happier than others?

SELECT Regional_Indicator, AVG(Life_Ladder) AS avg_life_ladder, (SELECT AVG(Life_Ladder) as two_five FROM WorldHappinessReport) AS global_avg
FROM WorldHappinessReport
WHERE Regional_Indicator IS NOT NULL
GROUP BY Regional_Indicator
ORDER BY 2 DESC

-- We can see that North American and ANZ, Western Europe and Latin America and Caribbean have the top 3 highest Life Ladder
-- We can also see the differences in places like East Asia, Southeat Asia and South Asia for example and see East Asia is generally the happiest part of Asia









--  Analyzing the yearly average happiness scores by region. Are there any trends or patterns?

SELECT Regional_Indicator, years, AVG(Life_Ladder) AS avg_life_ladder
FROM WorldHappinessReport
WHERE Regional_Indicator IS NOT NULL
GROUP BY Regional_Indicator, years
ORDER BY Regional_Indicator, years
















--	Which countries consistently rank as the top 10 happiest countries, and which countries consistently rank as the least happy?

-- Top 10

SELECT
  Country_Name, COUNT(happiness_rank) AS num_times_top10,
  (SELECT COUNT(Country_Name) FROM WorldHappinessReport whr2 WHERE whr2.Country_Name = whr1.Country_Name) AS num_observations
FROM (
  SELECT
    Country_Name,
    years,
    Life_Ladder,
    RANK() OVER (PARTITION BY years ORDER BY Life_Ladder DESC) AS happiness_rank
  FROM
    WorldHappinessReport
) AS whr1
WHERE
  happiness_rank <= 10
GROUP BY
  Country_Name
ORDER BY 2 DESC



-- Bottom 10

SELECT
  Country_Name, COUNT(happiness_rank) AS num_times_bottom10,
  (SELECT COUNT(Country_Name) FROM WorldHappinessReport whr2 WHERE whr2.Country_Name = whr1.Country_Name) AS num_observations
FROM (
  SELECT
    Country_Name,
    years,
    Life_Ladder,
    RANK() OVER (PARTITION BY years ORDER BY Life_Ladder) AS happiness_rank
  FROM
    WorldHappinessReport
) AS whr1
WHERE
  happiness_rank <= 10
GROUP BY
  Country_Name
ORDER BY 2 DESC

















--	How do the six key variables (GDP per capita, social support, healthy life expectancy, freedom to make life choices, generosity, 
--   and perceptions of corruption) correlate with happiness scores? Which variables have the strongest correlations?

SELECT Country_Name, Regional_Indicator, AVG(Life_Ladder) AS avg_life_ladder,AVG(Log_GDP_Per_Capita) AS avg_GDP,AVG(Social_Support) AS avg_social_support,
	AVG(Healthy_Life_Expectancy_At_Birth) AS avg_life_expectancy,AVG(Freedom_To_Make_Life_Choices) AS avg_freedom,
	AVG(generosity) AS avg_generosity,AVG(Perceptions_Of_Corruption) AS avg_corruption, AVG(Confidence_In_National_Government) AS confidence_in_gov
FROM WorldHappinessReport
WHERE Regional_Indicator IS NOT NULL
GROUP BY Country_Name, Regional_Indicator
ORDER BY 3 DESC

-- GDP,social support, life expectancy and freedom do seem to have a positive correlation with happiness scores.
-- Generocity and Trust in national government do not appear to be related to happiness scores.
-- Perception of corruption has a negative relationship with happiness score which makes sense since we would expect happier countries to have 
-- trust in their government.










--	How do happiness scores and the six key variables change over time for specific regions? Are there any noticeable trends?


SELECT years,Regional_Indicator,AVG(Life_Ladder) AS avg_happiness, AVG(Log_GDP_Per_Capita) AS avg_GDP,AVG(Social_Support) AS avg_social_support,
	AVG(Healthy_Life_Expectancy_At_Birth) AS avg_life_expectancy,AVG(Freedom_To_Make_Life_Choices) AS avg_freedom,
	AVG(generosity) AS avg_generosity,AVG(Perceptions_Of_Corruption) AS avg_corruption, AVG(Confidence_In_National_Government) AS confidence_in_gov
FROM WorldHappinessReport
WHERE Regional_Indicator IS NOT NULL
GROUP BY years, Regional_Indicator
ORDER BY Regional_Indicator,years








--  Which countries experienced the largest increase or decrease in happiness scores over the years?

-- Top 10

WITH min_max_years AS (
  SELECT
    Country_Name,
    MIN(years) AS first_year, -- getting the first year observed for given country
    MAX(years) AS last_year   -- getting the last year observed for given country
  FROM
    WorldHappinessReport
  GROUP BY
    Country_Name
),
happiness_diff AS (
  SELECT
    mm.Country_Name,
    first.Life_Ladder AS first_year_happiness, -- the happiness score for the first year observed
    last.Life_Ladder AS last_year_happiness,   -- the happiness score for the last year observed
    last.Life_Ladder - first.Life_Ladder AS happiness_difference -- the difference of the last and first year
  FROM
    min_max_years mm
  JOIN
    WorldHappinessReport first
  ON
    mm.Country_Name = first.Country_Name AND mm.first_year = first.years  -- "first" version used to extract first years happiness score
  JOIN
    WorldHappinessReport last
  ON
    mm.Country_Name = last.Country_Name AND mm.last_year = last.years	   -- "last" version used to extract last years happiness score
)
SELECT TOP 10
  Country_Name,
  first_year_happiness,
  last_year_happiness,
  happiness_difference
FROM
  happiness_diff
ORDER BY
  happiness_difference DESC;



-- Bottom 10

WITH min_max_years AS (
  SELECT
    Country_Name,
    MIN(years) AS first_year,
    MAX(years) AS last_year
  FROM
    WorldHappinessReport
  GROUP BY
    Country_Name
),
happiness_diff AS (
  SELECT
    mm.Country_Name,
    first.Life_Ladder AS first_year_happiness,
    last.Life_Ladder AS last_year_happiness,
    last.Life_Ladder - first.Life_Ladder AS happiness_difference
  FROM
    min_max_years mm
  JOIN
    WorldHappinessReport first
  ON
    mm.Country_Name = first.Country_Name AND mm.first_year = first.years
  JOIN
    WorldHappinessReport last
  ON
    mm.Country_Name = last.Country_Name AND mm.last_year = last.years
)
SELECT TOP 10
  Country_Name,
  first_year_happiness,
  last_year_happiness,
  happiness_difference
FROM
  happiness_diff
ORDER BY
  happiness_difference;










--  What are the top and bottom countries in terms of GDP per capita, social support, healthy life expectancy, freedom to make life choices, 
--   generosity, and perceptions of corruption? How do they differ in their happiness scores?

WITH top_bottom_countries AS (
  SELECT
    Country_Name,
    Life_Ladder,
    Log_GDP_Per_Capita,
    Social_Support,
    Healthy_Life_Expectancy_At_Birth,
    Freedom_To_Make_Life_Choices,
    Generosity,
    Perceptions_Of_Corruption,
    RANK() OVER (ORDER BY Log_GDP_Per_Capita DESC) AS gdp_rank,
    RANK() OVER (ORDER BY Social_Support DESC) AS social_support_rank,
    RANK() OVER (ORDER BY Healthy_Life_Expectancy_At_Birth DESC) AS healthy_life_exp_rank,
    RANK() OVER (ORDER BY Freedom_To_Make_Life_Choices DESC) AS freedom_rank,
    RANK() OVER (ORDER BY Generosity DESC) AS generosity_rank,
    RANK() OVER (ORDER BY Perceptions_Of_Corruption DESC) AS corruption_rank
  FROM
    WorldHappinessReport
)
SELECT
  Country_Name,
  Life_Ladder,
  Log_GDP_Per_Capita,gdp_rank,
  Social_Support,social_support_rank,
  Healthy_Life_Expectancy_At_Birth,healthy_life_exp_rank,
  Freedom_To_Make_Life_Choices,freedom_rank,
  Generosity,generosity_rank,
  Perceptions_Of_Corruption,corruption_rank
FROM
  top_bottom_countries
WHERE	-- These where clauses extract all countries having the first and last rank for all the following variables
  gdp_rank = 1 OR gdp_rank = (SELECT COUNT(*) FROM top_bottom_countries WHERE Log_GDP_Per_Capita IS NOT NULL)
  OR social_support_rank = 1 OR social_support_rank = (SELECT COUNT(*) FROM top_bottom_countries WHERE Social_Support IS NOT NULL)
  OR healthy_life_exp_rank = 1 OR healthy_life_exp_rank = (SELECT COUNT(*) FROM top_bottom_countries WHERE Healthy_Life_Expectancy_At_Birth IS NOT NULL)
  OR freedom_rank = 1 OR freedom_rank = (SELECT COUNT(*) FROM top_bottom_countries WHERE Freedom_To_Make_Life_Choices IS NOT NULL)
  OR generosity_rank = 1 OR generosity_rank = (SELECT COUNT(*) FROM top_bottom_countries WHERE Generosity IS NOT NULL)
  OR corruption_rank = 1 OR corruption_rank = (SELECT COUNT(*) FROM top_bottom_countries WHERE Perceptions_Of_Corruption IS NOT NULL)
ORDER BY Life_Ladder DESC


-- Here we take note that last rank varies because of null values but they appear to mostly be in the rank 2,000's











--  Which countries have the highest and lowest positive and negative affect scores? Investigate their key variables and happiness scores.

SELECT TOP 5
*,
RANK () OVER(ORDER BY Positive_Affect DESC) AS Positive_Affect_Rank
FROM WorldHappinessReport
WHERE Positive_Affect IS NOT NULL 
ORDER BY Positive_Affect_Rank


SELECT TOP 5
*,
RANK () OVER(ORDER BY Negative_Affect DESC) AS Negative_Affect_Rank
FROM WorldHappinessReport
WHERE Negative_Affect IS NOT NULL
ORDER BY Negative_Affect_Rank;


-- By looking at these two tables we see the biggest differences in Social Support, Life Expectancy, and Freedom
-- These values are much higher in the countries with the highest Positive Affect










--  Investigate how the key variables (GDP per capita, social support, healthy life expectancy, etc.) have changed over time for a specific country or region.
--Good Visual

SELECT
  years, Regional_Indicator,
  AVG(Log_GDP_Per_Capita) AS avg_gdp,
  AVG(Social_Support) AS avg_social_support,
  AVG(Healthy_Life_Expectancy_At_Birth) AS avg_life_expectancy,
  AVG(Freedom_To_Make_Life_Choices) AS avg_freedom,
  AVG(Generosity) AS avg_generosity,
  AVG(Perceptions_Of_Corruption) AS avg_corruption
FROM WorldHappinessReport
--WHERE Regional_Indicator LIKE '%latin%'
WHERE Regional_Indicator IS NOT NULL
GROUP BY Regional_Indicator,years
ORDER BY Regional_Indicator,years







--  Are there any countries with high happiness scores but low GDP per capita (or vice versa)? What other factors might contribute to their happiness scores?
-- Good Visual


WITH country_averages AS (
  SELECT
    Country_Name, Regional_Indicator, 
	AVG(Social_Support) AS support, AVG(Healthy_Life_Expectancy_At_Birth) AS life_expectancy, AVG(Freedom_To_Make_Life_Choices) AS freedom,
    AVG(Life_Ladder) AS avg_happiness,    
	RANK() OVER (ORDER BY AVG(Life_Ladder) DESC) AS happiness_rank, -- Last rank is 162
    AVG(Log_GDP_Per_Capita) AS avg_gdp,
    RANK() OVER (ORDER BY AVG(Log_GDP_Per_Capita) DESC) AS gdp_rank -- Last rank is 162
  FROM
    WorldHappinessReport
  WHERE 
	Life_Ladder IS NOT NULL AND Log_GDP_Per_Capita IS NOT NULL
  GROUP BY
    Regional_Indicator,Country_Name
)
SELECT TOP 15
  *
FROM
  country_averages
WHERE
  gdp_rank - happiness_rank > 30
ORDER BY
  happiness_rank;




SELECT AVG(Social_Support) AS avg_supoort,AVG(Healthy_Life_Expectancy_At_Birth) as avg_health,
	AVG(Freedom_To_Make_Life_Choices) AS avg_freedom
FROM WorldHappinessReport


-- We can see that most of the countries with a big difference in happiness rank and gdp rank and Latin America and Caribbean countries.
-- We also note that most of these countries' averages for social support,life expectancy and freedom are above the global averages








--How do the happiness scores correlate with the population size or population density of a country? You may need to join the dataset with another table containing this information.





--Investigate how key variables and happiness scores are related to other country-level indicators, such as education, unemployment rate, or Human Development Index. You may need to join the dataset with another table containing this information.











/*
This query calculates the difference between the Life Ladder score of each country
and the regional average Life Ladder score for each year. It then selects the top 20
rows with the highest (positive) differences in descending order.

- A CTE (Common Table Expression) called regional_avg_life_ladder is used to calculate
  the average Life Ladder score for each region and year.
- The main query then joins the WorldHappinessReport table with the CTE on both years
  and Regional_Indicator.
- It calculates the difference between each country's Life Ladder score and the regional
  average by subtracting the CTE's average_life_ladder from the original table's Life_Ladder.
- Finally, it selects the top 20 rows with the highest life_ladder_difference in descending order.
*/

WITH regional_avg_life_ladder AS (
  SELECT
    years,
    Regional_Indicator,
    AVG(Life_Ladder) AS average_life_ladder
  FROM
    WorldHappinessReport
  GROUP BY
    years,
    Regional_Indicator
)
SELECT TOP 20
  hd.Country_Name,
  hd.Regional_Indicator,
  hd.years,
  hd.Life_Ladder,
  ravg.average_life_ladder,
  hd.Life_Ladder - ravg.average_life_ladder AS life_ladder_difference
FROM
  WorldHappinessReport hd
JOIN
  regional_avg_life_ladder ravg
ON
  hd.years = ravg.years AND hd.Regional_Indicator = ravg.Regional_Indicator
ORDER BY
	life_ladder_difference DESC




-- This shows the coountries with the biggest (negative) difference with their corresponding region

WITH regional_avg_life_ladder AS (
  SELECT
    years,
    Regional_Indicator,
    AVG(Life_Ladder) AS average_life_ladder
  FROM
    WorldHappinessReport
  GROUP BY
    years,
    Regional_Indicator
)
SELECT TOP 20
  hd.Country_Name,
  hd.Regional_Indicator,
  hd.years,
  hd.Life_Ladder,
  ravg.average_life_ladder,
  hd.Life_Ladder - ravg.average_life_ladder AS life_ladder_difference
FROM
  WorldHappinessReport hd
JOIN
  regional_avg_life_ladder ravg
ON
  hd.years = ravg.years AND hd.Regional_Indicator = ravg.Regional_Indicator
ORDER BY
	life_ladder_difference 









-- Let's create a table that shows the biggest change in a given country from one year to the next.
-- If happiness rank dropped significantly, this can help us examine what may have happened at that point in time to help 
-- other countries avoid going through the same.
-- On the other hand wwe can look at points in time where happiness rank rose quickly and find out what was the cause.
-- This can help find ways for other countries to maybe increase happiness levels as well.

-- Create a CTE (Common Table Expression) with the initial ranking data, and then one to calculate the difference
WITH ranked_data AS (
  SELECT 
    Country_Name,
    Regional_Indicator,
    years,
    Life_Ladder,
    -- Calculate the happiness rank within each region for each year
    RANK() OVER (PARTITION BY Regional_Indicator, years ORDER BY Life_Ladder DESC) AS happiness_rank
  FROM 
    WorldHappinessReport
  -- Filter out any rows with NULL regional indicators
  WHERE Regional_Indicator IS NOT NULL
), 
	diff AS(
	SELECT   -- Select the columns from the ranked_data CTE and calculate the rank difference using the LAG() function
	  Country_Name,
	  Regional_Indicator,
	  years,
	  Life_Ladder,
	  happiness_rank,
	  -- Calculate the difference in happiness rank from the previous year to the current year
	  happiness_rank - LAG(happiness_rank) OVER (PARTITION BY Country_Name ORDER BY years) AS rank_difference
	FROM
	  ranked_data
)
SELECT 
	* 
FROM 
	diff 
WHERE 
	ABS(rank_difference)> 10
ORDER BY 
	rank_difference DESC

-- Positive difference means ranking got WORSE
-- Negative difference means ranking got BETTER