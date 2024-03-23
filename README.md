### Summary of SQL Queries for Olympic Data Analysis

#### Schema for athlete_events
``` sql
DROP TABLE IF EXISTS athlete_events
CREATE TABLE athlete_events (
    ID VARCHAR(5) PRIMARY KEY,
    Name VARCHAR(30),
    Sex VARCHAR(1),
    Age VARCHAR(2),
    Height VARCHAR(10),
    Weight VARCHAR(10),
    Team VARCHAR(20),
    NOC VARCHAR(5),
    Games VARCHAR(50),
    Year VARCHAR(5),
    Season VARCHAR(10),
    City VARCHAR(30),
    Sport VARCHAR(30),
    Event VARCHAR(50),
    Medal VARCHAR(10)
);
```
#### Schema for noc_regins
![image](https://github.com/RhugvedSatardekar/SQL-Olympics-Exploratory-Data-Analysis/assets/163725285/e55427af-2904-4c6d-9088-5cc0b93adc53)

---

#### How many olympics games have been held?

```sql
SELECT COUNT(DISTINCT games) FROM athlete_events;
```

This query calculates the total number of Olympic games held by counting the distinct entries in the "games" column of the athlete_events table.

---

#### List down all Olympics games held so far.

```sql
SELECT games, COUNT(games) AS NumberofGames
FROM athlete_events
GROUP BY games;
```

This query lists down all the Olympic games held so far along with the count of occurrences of each game in the athlete_events table.

---

#### Mention the total no of nations who participated in each olympics game?

```sql
SELECT a.games AS Games, COUNT(n.region) AS NationsParticipated
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
GROUP BY a.games;
```

This query provides the total number of nations that participated in each Olympic game by joining the athlete_events and noc_regions tables based on the NOC column.

---

#### Which year saw the highest and lowest no of countries participating in olympics?

```sql
SELECT a.year, COUNT(DISTINCT n.region) AS TotalCountries,
RANK() OVER (ORDER BY COUNT(DISTINCT n.region) DESC) AS countryRank
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
GROUP BY a.year;
```

This query identifies the years with the highest and lowest number of countries participating in the Olympics by counting distinct regions from the athlete_events and noc_regions tables.

---

#### which nation has participated in all of the olympic games?

```sql
SELECT region AS Nations
FROM (
    SELECT n.region, a.games
    FROM athlete_events AS a
    JOIN noc_regins AS n ON a.noc = n."NOC"
    GROUP BY n.region, a.games
    ORDER BY n.region, a.games
) AS Regions
GROUP BY region
HAVING COUNT(region) = (SELECT COUNT(DISTINCT games) FROM athlete_events);
```

This query identifies the nation that has participated in all Olympic games by counting distinct games and regions from the athlete_events and noc_regions tables.

---

#### Identify the sport which was played in all summer olympics.

```sql
SELECT sport
FROM (
    SELECT a.sport, COUNT(DISTINCT a.games) AS c
    FROM athlete_events AS a
    JOIN noc_regins AS n ON a.noc = n."NOC"
    WHERE a.games LIKE '%Summer'
    GROUP BY a.sport
    ORDER BY a.sport
) AS Country
WHERE c = (SELECT COUNT(DISTINCT games) FROM athlete_events WHERE games LIKE '%Summer');
```

This query identifies the sport played in all Summer Olympics by counting distinct games and filtering based on the count of Summer Olympic games.

---

#### Which Sports were just played only once in the olympics?

```sql
SELECT a.sport, COUNT(a.sport) AS NumberOfPlay
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
GROUP BY a.sport
ORDER BY COUNT(a.sport);
```

This query lists down the sports that were played only once in the Olympics by counting occurrences of each sport in the athlete_events table.

---

#### Fetch the total no of sports played in each olympic games.

```sql
SELECT games, COUNT(DISTINCT sport) AS Number_Of_Sports_Played
FROM athlete_events
GROUP BY games
ORDER BY games;
```

This query fetches the total number of sports played in each Olympic game by counting distinct sports in the athlete_events table.

---

#### Fetch details of the oldest athletes to win a gold medal.

```sql
SELECT *
FROM athlete_events
WHERE medal = 'Gold' AND age <> 'NA'
ORDER BY age DESC
LIMIT 1;
```

This query fetches details of the oldest athletes who won a gold medal by filtering based on the medal type and age, ordering by age in descending order, and limiting the result to one record.

---

#### Find the Ratio of male and female athletes participated in all olympic games.

```sql
SELECT athlete_events.sex, ROUND((COUNT(sex) * 100.0 / c.total), 2) AS Ratio_In_Percent
FROM (
    SELECT COUNT(*) AS total FROM athlete_events
) AS c, athlete_events
GROUP BY athlete_events.sex, c.total;
```

This query calculates the ratio of male and female athletes participated in all Olympic games by counting occurrences of each sex and calculating the percentage ratio.

---

#### Fetch the top 5 athletes who have won the most gold medals.

```sql
SELECT name, COUNT(medal) AS NumberOfMedals
FROM athlete_events
WHERE medal <> 'NA'
GROUP BY name
ORDER BY NumberOfMedals DESC
LIMIT 5;
```

This query fetches the top 5 athletes who have won the most gold medals by counting occurrences of gold medals and ordering by the count in descending order, limiting the result to 5 records.

---

#### Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

```sql
SELECT n.region, COUNT(a.medal) AS NumberOfMedals
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
WHERE a.medal <> 'NA'
GROUP BY n.region
ORDER BY NumberOfMedals DESC
LIMIT 5;
```

This query fetches the top 5 most successful countries in the Olympics based on the number of medals won, counting occurrences of medals and ordering by the count in descending order, limiting the result to 5 records.

---

#### List down total gold, silver, and bronze medals won by each country.

```sql
SELECT n.region, a.medal, COUNT(a.medal) AS NumberOfMedals
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
WHERE a.medal <> 'NA'
GROUP BY n.region, a.medal
ORDER BY n.region, a.medal, NumberOfMedals DESC;
```

This query lists down the total gold, silver, and bronze medals won by each country by counting occurrences of each medal type and grouping by country and medal type.

---

#### List down total gold, silver, and bronze medals won by each country corresponding to each olympic game.

```sql
SELECT a.games, n.region, a.medal, COUNT(a.medal) AS NumberOfMedals
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
WHERE a.medal <> 'NA'
GROUP BY a.games, n.region, a.medal
ORDER BY a.games, n.region, a.medal DESC;
```

This query lists down the total gold, silver, and bronze medals won by each country corresponding to each Olympic game by counting occurrences of each medal type and grouping by game, country, and medal type.

---

#### Identify which country won the most gold, most silver, and most bronze medals in each olympic game.


```sql
    SELECT a.games, n.region, a.medal, COUNT(a.medal) AS NumberOfMedals,
    RANK() OVER (PARTITION BY a.medal, a.games ORDER BY COUNT(a.medal) DESC) AS CountryRank
    FROM athlete_events AS a
    JOIN noc_regins AS n ON a.noc = n."NOC"
    WHERE a.medal <> 'NA'
    GROUP BY a.games, a.medal, n.region
),
TotalMedalRankTable AS (
    SELECT a.games, n.region, COUNT(a.medal) AS NumberOfMedals, 'Total' AS medal,
    RANK() OVER (PARTITION BY a.games ORDER BY COUNT(a.medal) DESC) AS TotalMedalRank
    FROM athlete_events AS a
    JOIN noc_regins AS n ON a.noc = n."NOC"
    WHERE a.medal <> 'NA'
    GROUP BY a.games, n.region
)
SELECT games, region, medal, NumberOfMedals
FROM MedalTypeRankTable
WHERE CountryRank = 1
UNION ALL
SELECT games, region, medal, NumberOfMedals
FROM TotalMedalRankTable
WHERE TotalMedalRank = 1
ORDER BY games, NumberOfMedals DESC;
```

This query identifies which country won the most gold, silver, and bronze medals in each Olympic game. It does this by ranking countries based on their medal counts and then selecting the countries with the highest medal counts for each medal type and each game.

---

#### Which countries have never won a gold medal but have won silver/bronze medals?

```sql
SELECT region
FROM noc_regins
WHERE "NOC" IN (
    SELECT a.noc
    FROM athlete_events AS a
    JOIN noc_regins AS n ON a.noc = n."NOC"
    WHERE a.medal IN ('Silver', 'Bronze')
    AND NOT EXISTS (
        SELECT 1
        FROM athlete_events AS a2
        WHERE a2.noc = a.noc
        AND a2.medal = 'Gold'
    )
    GROUP BY a.noc
)
GROUP BY region;
```

This query identifies countries that have never won a gold medal but have won silver or bronze medals. It uses subqueries and the NOT EXISTS clause to filter out countries that have won gold medals.

---

#### In which Sport/event, India has won the highest number of medals.

```sql
SELECT a.sport, COUNT(a.medal) AS MedalCount
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
WHERE a.medal <> 'NA' AND n.region = 'India'
GROUP BY a.sport
ORDER BY MedalCount DESC
LIMIT 1;
```

This query identifies the sport or event in which India has won the highest number of medals by counting occurrences of medals in each sport and filtering for India in the region column.

---

#### Break down all Olympic games where India won medals for Hockey and how many medals in each Olympic game.

```sql
SELECT a.games, COUNT(a.medal) AS HockeyMedals
FROM athlete_events AS a
JOIN noc_regins AS n ON a.noc = n."NOC"
WHERE a.medal <> 'NA' AND a.sport = 'Hockey' AND a.noc = 'IND'
GROUP BY a.games
ORDER BY a.games;
```

This query breaks down all Olympic games where India won medals for Hockey and counts the number of medals in each Olympic game. It filters for Hockey as the sport and India as the country code 'IND' in the athlete_events and noc_regions tables.

---

