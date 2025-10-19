-- to create schema videogames
CREATE SCHEMA IF NOT EXISTS videogames;


-- Create videogames.vgsales table
CREATE TABLE videogames.vgsales (
Rank INTEGER PRIMARY KEY, -- primary key
Name VARCHAR NOT NULL, -- not null
Platform VARCHAR NOT NULL, -- not null
Year VARCHAR NOT NULL, -- not null
Genre VARCHAR NOT NULL, -- not null
Publisher VARCHAR NOT NULL, -- not null
NA_SALES DECIMAL (10,2) NOT NULL, -- not null
EU_SALES DECIMAL (10,2) NOT NULL, -- not null
JP_SALES DECIMAL (10,2) NOT NULL, -- not null
OTHER_SALES DECIMAL (10,2) NOT NULL, -- not null
GLOBAL_SALES DECIMAL (10,2) NOT NULL, -- not null
);

-- import data from vgasales.csv to populate vgsales table
COPY videogames.vgsales 
FROM ('\\wsl$\Ubuntu\home\engpookw\3m-data-assignment-1.1\vgsales.csv');

-- select all records from videogames.vgsales table
SELECT * FROM videogames.vgsales;

-- Question 1
SELECT genre, sum(global_sales) 
FROM videogames.vgsales 
GROUP BY genre 
ORDER BY sum(global_sales) DESC;

-- to check wehther Global_Sales = NA_SALES+EU_SALES+JP_SALES+OTHER_SALES
SELECT 
NA_SALES+EU_SALES+JP_SALES+OTHER_SALES, GLOBAL_SALES
FROM videogames.vgsales 
WHERE rank =1;

-- Question 1: Which genres contribute the most to global sales?
SELECT 
genre, sum(global_sales) 
FROM videogames.vgsales
GROUP BY genre 
ORDER BY sum(global_sales) DESC;

-- Question 1: to return the No.1 genre with the most global sales
SELECT 
genre, sum(global_sales) 
FROM videogames.vgsales
GROUP BY genre 
ORDER BY sum(global_sales) DESC
LIMIT 1;

-- Question 2: Which platforms generate the highest global sales?
SELECT 
Platform, sum(global_sales) 
FROM videogames.vgsales
GROUP BY platform 
ORDER BY sum(global_sales) DESC;

-- Question 2: to returm the No.1 platform with the highest global sales 
SELECT 
Platform, sum(global_sales) 
FROM videogames.vgsales
GROUP BY platform 
ORDER BY sum(global_sales) DESC
LIMIT 1;

-- Question 3: Which publishers are the most successful in terms of global sales?
SELECT 
publisher, sum(global_sales) 
FROM videogames.vgsales 
GROUP BY publisher 
ORDER BY sum(global_sales) DESC;

-- Question 3: to return the No.1 publisher most successful in terms of global sales
SELECT 
publisher, sum(global_sales) 
FROM videogames.vgsales 
GROUP BY publisher 
ORDER BY sum(global_sales) DESC
LIMIT 1;

-- 	QUESTION 4: How does success vary across regions (North America, Europe, Japan, Others)?
SELECT 
sum(na_sales), sum(eu_sales), sum(jp_sales), sum(other_sales) 
FROM videogames.vgsales 

SELECT
  ROUND(SUM(na_sales), 2)    AS na_total,
  ROUND(SUM(eu_sales), 2)    AS eu_total,
  ROUND(SUM(jp_sales), 2)    AS jp_total,
  ROUND(SUM(other_sales), 2) AS other_total,
  ROUND(SUM(global_sales),2) AS global_total,
  ROUND(SUM(na_sales)    / NULLIF(SUM(global_sales),0) * 100, 2) AS na_share_pct,
  ROUND(SUM(eu_sales)    / NULLIF(SUM(global_sales),0) * 100, 2) AS eu_share_pct,
  ROUND(SUM(jp_sales)    / NULLIF(SUM(global_sales),0) * 100, 2) AS jp_share_pct,
  ROUND(SUM(other_sales) / NULLIF(SUM(global_sales),0) * 100, 2) AS other_share_pct
FROM videogames.vgsales;

-- Question 5: What are the trends over time in game sales by genre and platform?

-- return total global sales over the years for Platform
SELECT 
DISTINCT year, platform, 
-- sum(na_sales), sum(eu_sales), sum(jp_sales), sum(other_sales), 
sum(global_sales) 
FROM videogames.vgsales 
-- where year <> 'N/A'
GROUP BY year, platform 
-- ORDER BY year ASC
ORDER BY sum(global_sales) DESC

-- return total global sales over the year = N/A for Platform
SELECT 
year, platform, 
-- sum(na_sales), sum(eu_sales), sum(jp_sales), sum(other_sales), 
sum(global_sales) 
FROM videogames.vgsales 
where year = 'N/A'
GROUP BY year, platform 
ORDER BY year ASC

SELECT 
--year, 
DISTINCT platform,
-- sum(na_sales), sum(eu_sales), sum(jp_sales), sum(other_sales), 
sum(global_sales) 
FROM videogames.vgsales 
where year = 'N/A'
GROUP BY 
-- year, 
platform 
-- ORDER BY year ASC


-- return total global sales over the years for Genre
SELECT 
DISTINCT year, genre, platform,
-- sum(na_sales), sum(eu_sales), sum(jp_sales), sum(other_sales), 
sum(global_sales) 
FROM videogames.vgsales 
-- where year <> 'N/A'
GROUP BY year, genre, platform
-- ORDER BY year ASC
ORDER BY sum(global_sales) DESC


-- model answer for Question 5
WITH 
    base AS (
        SELECT 
            year,
            genre,
            SUM(global_sales) total_sales
        FROM videogames.vgsales 
        GROUP BY 
            year,
            genre
    )
SELECT 
    base.year,
    base.genre,
    base.total_sales
FROM base
    JOIN (
        SELECT 
            year,
            MAX(total_sales) max_sales
        FROM base
        GROUP BY 
            year
    ) max ON base.year=max.year
        AND base.total_sales=max.max_sales
ORDER BY 
    base.year;

WITH 
    base AS (
        SELECT 
            year,
            platform,
            SUM(global_sales) total_sales
        FROM videogames.vgsales 
        GROUP BY 
            year,
            platform
    )
SELECT 
    base.year,
    base.platform,
    base.total_sales
FROM base
    JOIN (
        SELECT 
            year,
            MAX(total_sales) max_sales
        FROM base
        GROUP BY 
            year
    ) max ON base.year=max.year
        AND base.total_sales=max.max_sales
ORDER BY 
    base.year
    
-- Model Answer #2
    WITH 
    base AS (
        SELECT 
            genre,
            platform,
            SUM(global_sales) total_sales,
            ROW_NUMBER() OVER (PARTITION BY genre ORDER BY SUM(global_sales) DESC) rank
        FROM videogames.vgsales 
        GROUP BY 
            genre,
            platform
    )
SELECT 
    *
FROM base 
WHERE 
    rank<4
ORDER BY 
    genre,
    rank