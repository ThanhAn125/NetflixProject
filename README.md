# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
##--Identify Total Null Row
```sql
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
```
##-- Total 3479 Null Data
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
Select 
	type,
	count(*)
from netflix_data
group by type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
Select title, release_year
from netflix_data
where type like 'movie'
order by release_year DESC
;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select 
	title, 
	duration 
from netflix_data
where type like 'movie' 
	and duration = (select max(duration) from netflix_data)
;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
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
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select 
	*
from netflix_data
where director like 'rajiv chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select * 
from netflix_data
where type like '%TV%'
and  cast(left(duration,1) as int) > 5
;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select 
	distinct(rating), 
	count(show_id) as total_item
from netflix_data
where rating is not null
group by rating
;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
select top 5
	release_year, 
	avg(cast(replace(show_id,'s','') as int) ) as Avg_Content_India
from netflix_data
where country like 'India'
group by release_year
order by Avg_Content_India DESC
;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select * 
from netflix_data
where type like 'movie'
and listed_in like '%Doc%'
;
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select *
from netflix_data
where director is null
;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
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
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
