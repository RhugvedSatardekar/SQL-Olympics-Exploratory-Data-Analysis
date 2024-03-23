-- How many olympics games have been held?

select count(distinct(games)) from athlete_events

-- List down all Olympics games held so far.

select games,count(games) as NumberofGames
from athlete_events
group by games

-- Mention the total no of nations who participated in each olympics game?

select a.games as Games, count(n.region) as NationsParticipated
from athlete_events as a
join noc_regins as n
on a.noc = n."NOC"
group by a.games

-- Which year saw the highest and lowest no of countries participating in olympics?


select a.year,count(distinct(n.region)) as TotalCountries,
rank() over (order by count(distinct(n.region)) desc) as countryRank
from 
	athlete_events as a
	join noc_regins as n
	on a.noc = n."NOC"
group by a.year

-- which nation has participated in all of the olympic games?

select region as Nations from
	(select n.region,a.games
		from 
		athlete_events as a
		join noc_regins as n
		on a.noc = n."NOC"
	group by n.region,a.games
	order by n.region, a.games) as Regions
group by region
having count(region) = (select count(distinct(games)) from athlete_events)

-- Identify the sport which was played in all summer olympics.

-- Using dynamic sport count value
select sport from 
	(select a.sport,count(distinct(a.games)) as c
	from 
			athlete_events as a
			join noc_regins as n
			on a.noc = n."NOC"
	where a.games like '%Summer'
	group by a.sport
	order by a.sport) as Country
where c = (select count(distinct(games)) from athlete_events where games like '%Summer')

-- Using Static games count value as 29
select sport,count(distinct(games)) from athlete_events where games like '%Summer' group by sport having count(distinct(games)) = 29

-- Which Sports were just played only once in the olympics?

select a.sport, count(a.sport) NumberOfPlay
from 
	athlete_events as a
	join noc_regins as n
	on a.noc = n."NOC"
group by a.sport
order by  count(a.sport)

-- Fetch the total no of sports played in each olympic games.

select games,count(distinct(sport)) Number_Of_Sports_Played
from athlete_events
group by games
order by games

-- Fetch details of the oldest athletes to win a gold medal.

select * 
from athlete_events
where medal = 'Gold' and age <> 'NA'
order by age desc
limit 1 

-- Find the Ratio of male and female athletes participated in all olympic games.


select 
	   athlete_events.sex, 
	   round((count(sex)*100.0/c.total),2) as Ratio_In_Percent
from 
		(select count(*) as total from athlete_events) as c,
		athlete_events
group by 
		athlete_events.sex,c.total

-- Fetch the top 5 athletes who have won the most gold medals.

select name,count(medal) as NumberOfMedals
from athlete_events
where medal <> 'NA'
group by name
order by NumberOfMedals Desc
limit 5;

-- alt method

select name,NumberOfMedals from
	(select name,count(medal) as NumberOfMedals,
	row_number() over (order by count(medal) desc) RankofMedals
	from athlete_events
	where medal <> 'NA'
	group by name) as tbl
where RankofMedals <= 5

-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.



select n.region, count(a.medal) as NumberOfMedals
from
	athlete_events as a
	join
	noc_regins as n
	on a.noc = n."NOC"
where a.medal <> 'NA'
group by n.region
order by NumberOfMedals desc 
limit 5

select medal,count(medal) from athlete_events where medal <> 'NA' group by medal

-- List down total gold, silver and broze medals won by each country.


select n.region,a.medal, count(a.medal) as NumberOfMedals
from
	athlete_events as a
	join
	noc_regins as n
	on a.noc = n."NOC"
where a.medal <> 'NA'
group by n.region,a.medal
order by n.region,a.medal,NumberOfMedals desc 

-- List down total gold, silver and broze medals won by each country corresponding to each olympic games.

select a.games,n.region,a.medal, count(a.medal) as NumberOfMedals
from
	athlete_events as a
	join
	noc_regins as n
	on a.noc = n."NOC"
where a.medal <> 'NA'
group by a.games,n.region,a.medal
order by a.games,n.region,a.medal desc 

-- Identify which country won the most gold, most silver and most bronze medals in each olympic games.

select * from
	(select games,region,medal,NumberOfMedals from
		(select a.games,n.region,a.medal, count(a.medal) as NumberOfMedals,
		rank() over (partition by a.medal,a.games order by count(a.medal) desc) as CountryRank
		from
			athlete_events as a
			join
			noc_regins as n
			on a.noc = n."NOC"
		where a.medal <> 'NA'
		group by a.games,a.medal,n.region
		order by a.games asc, n.region,a.medal) as MadelTypeRankTable
	 where CountryRank in (1) 
	 order by games,NumberOfMedals desc) as l
union
select * from
	(select games,region,medal,NumberOfMedals from
		(select a.games,n.region, count(a.medal) as NumberOfMedals,'Total' as medal,
		rank() over (partition by a.games order by count(a.medal) desc) as TotalMedalRank
		from
			athlete_events as a
			join
			noc_regins as n
			on a.noc = n."NOC"
		where a.medal <> 'NA'
		group by a.games,n.region
		order by a.games asc, n.region) as TotalMedalRankTable
	where TotalMedalRank = 1) as r
order by games, NumberOfMedals;

-- Alternate query With CTE
WITH MedalTypeRankTable AS (
    SELECT
        a.games,
        n.region,
        a.medal,
        COUNT(a.medal) AS NumberOfMedals,
        RANK() OVER (PARTITION BY a.games, a.medal ORDER BY COUNT(a.medal) DESC) AS CountryRank
    FROM
        athlete_events AS a
    JOIN
        noc_regins AS n
    ON
        a.noc = n."NOC"
    WHERE
        a.medal <> 'NA'
    GROUP BY
        a.games, a.medal, n.region
),
TotalMedalRankTable AS (
    SELECT
        a.games,
        n.region,
        COUNT(a.medal) AS NumberOfMedals,
        'Highest' AS medal,
        RANK() OVER (PARTITION BY a.games ORDER BY COUNT(a.medal) DESC) AS TotalMedalRank
    FROM
        athlete_events AS a
    JOIN
        noc_regins AS n
    ON
        a.noc = n."NOC"
    WHERE
        a.medal <> 'NA'
    GROUP BY
        a.games, n.region
)
SELECT
    games,
    region,
    medal,
    NumberOfMedals
FROM
    MedalTypeRankTable
WHERE
    CountryRank = 1
UNION ALL
SELECT
    games,
    region,
    medal,
    NumberOfMedals
FROM
    TotalMedalRankTable
WHERE
    TotalMedalRank = 1
ORDER BY
    games,
    NumberOfMedals DESC;

-- Which countries have never won gold medal but have won silver/bronze medals?



select region from noc_regins
where "NOC" in 
(
	select a.noc
	from athlete_events as a
	join noc_regins as n 
	on a.noc = n."NOC"
	where a.medal in ('Silver','Bronze')
	and not exists (
		select 1 from athlete_events as a2 
		where a2.noc = a.noc 
		and a2.medal = 'Gold'
	)
	group by a.noc
)

select * from athlete_events
where NOC = 'CZE'

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
)
GROUP BY region;  -- Add GROUP BY to ensure distinct regions in the result


-- In which Sport/event, India has won highest medals.

select a.sport, count(a.medal) MedalCount
from
	athlete_events as a
	join
	noc_regins as n
	on a.noc = n."NOC"
where a.medal <> 'NA' and n.region = 'India'
group by a.sport
order by MedalCount Desc
limit 1;


-- Break down all olympic games where india won medal for Hockey and how many 
-- medals in each olympic games.

select a.games,count(a.medal) HockeyMedals
from
	athlete_events as a
	join
	noc_regins as n
	on a.noc = n."NOC"
where a.medal <> 'NA' and a.sport = 'Hockey' and a.noc = 'IND'
group by a.games
order by a.games