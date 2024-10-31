drop table if exists netflix_data;
Create Table netflix_data	
	(
	show_id	varchar(10),
	type varchar(15),
	title	varchar(255),
	director	nvarchar(255),
	casts	varchar(1000),
	country	nvarchar(255),
	date_added	varchar(50),
	release_year	int,
	rating	varchar(10),
	duration	varchar(15),
	listed_in	nvarchar(255),
	description nvarchar(255)
	)
	;
Select * from netflix_data;

--Identify Total Null Row
Select count(*)
From netflix_data
Where 
	show_id	is null or
	type is null or
	title	is null or
	director	is null or
	casts	is null or
	country	is null or
	date_added	is null or
	release_year	is null or
	rating	is null or
	duration	is null or
	listed_in	is null or
	description is null
;-- Total 3479 Null Data

--Check Null Data

Select *
From netflix_data
Where 
	show_id	is null or
	type is null or
	title	is null or
	director	is null or
	casts	is null or
	country	is null or
	date_added	is null or
	release_year	is null or
	rating	is null or
	duration	is null or
	listed_in	is null or
	description is null
;

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
Select 
	type,
	count(*)
from netflix_data
group by type
;
--2. Find the most common rating for movies and TV shows
with Rank_rating as 
(
select type,rating,count(rating) as total_rating,
Rank() over (partition by type order by count(rating) DESC) as Ranks
from netflix_data
Group by type,rating
)
Select 
	type, 
	rating, 
	total_rating
from Rank_rating
Where Ranks = 1
;
--3. List all movies released in a specific year (e.g., 2020)
Select title, release_year
from netflix_data
where type like 'movie'
order by release_year DESC
;

--4. Find the top 5 countries with the most content on Netflix
with all_country as 
(
select 
	show_id,
	trim(cs.Value) as country1 --SplitData
from netflix_data
cross apply STRING_SPLIT (country, ',') cs
)
select top 5
	country1,
	count(distinct(show_id)) as total_film
from all_country
group by country1
order by count(distinct(show_id)) DESC
;

--5. Identify the longest movie\
select 
	title, 
	duration 
from netflix_data
where type like 'movie' 
	and duration = (select max(duration) from netflix_data)
;
--6. Find content added in the last 5 years
with part_year as 
(
select 
	*,
	datepart(year,getdate()) - cast(right(date_added,4) as int) as partyear
from netflix_data
)
select * 
from part_year
where partyear < 5
;
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select 
	*
from netflix_data
where director like 'rajiv chilaka';
--8. List all TV shows with more than 5 seasons
select * 
from netflix_data
where type like '%TV%'
and  cast(left(duration,1) as int) > 5
;
--9. Count the number of content items in each genre
select 
	distinct(rating), 
	count(show_id) as total_item
from netflix_data
where rating is not null
group by rating
;
--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
select top 5
	release_year, 
	avg(cast(replace(show_id,'s','') as int) ) as Avg_Content_India
from netflix_data
where country like 'India'
group by release_year
order by Avg_Content_India DESC
;
--11. List all movies that are documentaries
select * 
from netflix_data
where type like 'movie'
and listed_in like '%Doc%'
;
--12. Find all content without a director
select *
from netflix_data
where director is null
;
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
with part_year as 
(
select 
	*,
	datepart(year,getdate()) - cast(right(date_added,4) as int) as partyear
from netflix_data
)
select title 
from part_year
where casts like '%Salman Khan%' and partyear < 10
;
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
with actor_list as 
(
select 
	show_id,
	trim(cs.Value) as actor --SplitData
from netflix_data
cross apply STRING_SPLIT (casts, ',') cs
)
select top 10
	actor, 
	count(show_id) as total_film
from actor_list
group by actor
order by total_film DESC
--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
with film_keyword as
(
select 
*,
case
	when description like '%kill%' or description like '%violence%' then 'Bad'
	else 'Good'
end as keywords
from netflix_data
)
select keywords, count(show_id)
from film_keyword
group by keywords
;
