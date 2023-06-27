-- define the database
USE imdb_ijs;
-- SET SESSION MAX_EXECUTION_TIME=20000;
-- SET GLOBAL MAX_EXECUTION_TIME=20000;

SET session max_execution_time=300000;

-- SET GLOBAL connect_timeout=20000;
-- SET SESSION MAX_EXECUTION_TIME=20000;

/******
The Big Picture
******/

-- 1) How many actors are there in the actors table
SELECT COUNT(*) FROM actors;
-- 817718


-- 2)How many directors are there in the directors table?
SELECT COUNT(*) FROM directors;
-- 86880


-- 3)How many movies are there in the movies table?
SELECT COUNT(*) FROM movies;
-- 388269

/******
Exploring the Movies
******/

-- 4)From what year are the oldest and the newest movies? What are the names of those movies?

SELECT name,year FROM movies ORDER BY year ASC LIMIT 1;
-- oldest movie=Roundhay Garden Scene
SELECT name,year FROM movies ORDER BY year DESC LIMIT 1;
-- newest movie= Harry Potter and the Half-Blood Prince

-- **** or****
select name,year
from movies
where year=(select max(year) from movies)  or
	year=(select  min(year) from movies);
    
-- 'Harry Potter and the Half-Blood Prince', '2008'
-- 'Roundhay Garden Scene', '1888'
-- 'Traffic Crossing Leeds Bridge', '1888'


-- 5)What movies have the highest and the lowest ranks?
SELECT name, `rank`
FROM movies
WHERE  `rank` = (SELECT MAX( `rank`) FROM movies)
OR  `rank` = (SELECT MIN( `rank`) FROM movies);

-- There are so many movies with maximum rank 9.9 and minimum rank 1

-- 6)What is the most common movie title?
SELECT name, COUNT(name) as name_count
FROM movies
GROUP BY name
ORDER BY name_count DESC
LIMIT 1;
-- Eurovision Song Contest, The ,49

/******
Understanding the Database
******/

-- 7)Are there movies with multiple directors? 

select movie_id,count(director_id) as no_of_directors
from movies_directors
group by movie_id
having no_of_directors>1
order by no_of_directors desc ;

-- 8)What is the movie with the most directors? Why do you think it has so many?

select movies.name,count(movies_directors.director_id) as directors_count
from movies
join movies_directors 
on movies.id=movies_directors.movie_id 
group by movies.id order by directors_count DESC ;
-- (movies.name is not correct bcos there are so many movies with same name)
-- "Bill, The", 87 

-- 9)On average, how many actors are listed by movie?

SELECT AVG(count_of_actors) 
FROM (
select roles.movie_id ,count(actors.id)  as count_of_actors
from roles 
LEFT JOIN actors 
on actors.id=roles.actor_id
group by roles.movie_id
) avg_actors;
-- 11.43

-- ANOTHER WAY
 WITH  actors_per_movie as( 
		select movie_id,count(actor_id) as no_of_actors
		from roles
		group by movie_id)
 select avg (no_of_actors)
 from actors_per_movie;
 
 -- 10) Are there movies with more than one  genre
 
SELECT movie_id ,count(genre) as count 
from  movies_genres 
group by movie_id 
having count>1 ;
-- yes

/******
Looking for specific movies
******/

-- 11 )Can you find the movie called “Pulp Fiction”?

select * from movies where movies.name like "%La Dolce Vita";
-- YES
-- Who directed it?

 select m.name ,d.first_name,d.last_name
 from movies m
 join movies_directors md
 on m.id=md.movie_id
 join directors d
 on d.id=md.director_id
 where m.name like "Pulp Fiction";

-- Pulp Fiction,  Quentin Tarabtino
 
 
-- Which actors where casted on it?

select a.first_name,a.last_name
from movies m 
join roles r
on r.movie_id=m.id
join actors a
on r.actor_id=a.id
where m.name like "Pulp Fiction";
 
 -- 12)Can you find temployee_detailshe movie called “La Dolce Vita”?
 
 select * from movies where movies.name like "%La Dolce Vita%";
-- No ..But got a movie Dolce Vita, la

  	-- Who directed it?
 
 select m.name ,d.first_name,d.last_name
 from movies m
 join movies_directors md
 on m.id=md.movie_id
 join directors d
 on d.id=md.director_id
 where m.name like "Dolce Vita, la";
 
  -- Dolce vita, La	Federico	Fellini
  
-- Which actors where casted on it?

select a.first_name,a.last_name
from movies m 
join roles r
on r.movie_id=m.id
join actors a
on r.actor_id=a.id
where m.name like "Dolce Vita, la";

 -- 13)When was the movie “Titanic” by James Cameron released?
-- Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
-- Hint 2: the name “James Cameron” is stored with a weird character on it.

select * from movies 
left join movies_directors 
on movies.id=movies_directors.movie_id
left join directors
 on directors.id=movies_directors.director_id
where movies.name= "Titanic"
and directors.first_name
 like "%James%"
 and directors.last_name 
 like "%Cameron%" ;
-- 1997

/******
Actors and directors
******/

-- 14)Who is the actor that acted more times as “Himself”?

select actors.first_name,actors.last_name ,count(roles.role) as appearances
from actors 
left join roles 
on actors.id=roles.actor_id
where roles.role="Himself"
GROUP BY actors.first_name,actors.last_name
ORDER BY appearances DESC
LIMIT 1;
-- Adolf Hitler : 206 

-- 15)What is the most common name for actors? 

select first_name,last_name ,count(*) as appearences
from actors
group by first_name,last_name
order by appearences DESC ; 

-- Shauna MacDonald : 7 ,is the most common name

select first_name,count(first_name) as appearences
from actors
group by first_name
order by appearences DESC;

-- Most commom first_name is John -4371

select last_name,count(last_name) as appearences
from actors
group by last_name
order by appearences DESC;

-- Most commom last_name is Smith - 2425

-- And for directors?

select first_name,last_name ,count(*) as appearences
from directors
group by first_name,last_name
order by appearences DESC limit 1;

-- Karou UmeZawa : 10 -- Most common name
 
 
 select first_name,count(first_name) as appearences
from directors
group by first_name
order by appearences DESC limit 1;

-- Michael ,670 ---Most common First name

select last_name ,count(last_name) as appearences
from directors
group by last_name
order by appearences DESC limit 1;

-- smith, 243 --- Most Common Last name

/******
Analysing genders
******/

-- 16) How many actors are male and how many are female?
select gender,count(*) as count
from actors
group by gender;
-- MALE : 513306
-- FEMALE : 304412

-- 17) What percentage of actors are female, and what percentage are male?

select gender ,count(id) *100 /( select count(id) from actors ) as percentage
from actors 
group by gender;
-- M :62.7730
-- F :37.2270


/******
Movies across time
******/

-- 18)How many of the movies were released after the year 2000?

select count(*) 
from movies 
where year>2000;
 -- 46006
 
 -- 19)How many of the movies where released between the years 1990 and 2000?
 
select count(*) 
from movies
 where year between 1990 and 2000 ;
-- 91138

-- 20)Which are the 3 years with the most movies? How many movies were produced on those years?
select year,count(*) as count 
from movies 
group by year
order by count desc limit 3;
 -- 2002	12056
--  2003	11890
--  2001	11690

 -- 21)What are the top 5 movie genres?
 
select genre,count(*) as count
from movies_genres
group by genre 
order by count desc limit 5;

-- Short	81013
-- Drama	72877
-- Comedy	56425
-- Documentary	41356
-- Animation	17652

-- 21 a)What are the top 5 movie genres before 1920?

select genre, count(*) as count 
from movies_genres 
left join movies 
on movies_genres.movie_id = movies.id
where year <1920
group by movies_genres.genre
order by count DESC limit 5;

-- Short	18559
-- Comedy	8676
-- Drama	7692
-- Documentary	3780
-- Western	1704

-- 21)b What is the evolution of the top movie genres across all the decades of the 20th century?
with genre_year_count as (
select *, rank() over (partition by decade order by movies_per_genre desc) as ranking
from
(select mg.genre,  FLOOR(m.year / 10) * 10 AS decade, count(mg.genre) as movies_per_genre
from movies_genres mg
join movies m 
on mg.movie_id=m.id
GROUP BY decade , genre)
sub )
select * from genre_year_count where ranking=1;
-- Short	1880	2
-- Documentary	1890	1062
-- Short	1900	3929
-- Short	1910	13764
-- Short	1920	5583
-- Short	1930	5218
-- Short	1940	4458
-- Drama	1950	5427
-- Drama	1960	7234
-- Drama	1970	8304
-- Drama	1980	9625
-- Drama	1990	12232
-- Short	2000	13451
/******
Putting it all together: names, genders, and time
******/ 

-- 22)Has the most common name for actors changed over time?
-- 23)Get the most common actor name for each decade in the XX century.

with actornames_count_per_decade as(
select * ,rank() over( partition by decade order by counts DESC) as ranking
from
(SELECT floor(m.year/10)*10 as decade,a.first_name, count(a.first_name) as counts
from actors a 
join roles  r
on a.id= r.actor_id
join movies m
on  m.id=r.movie_id
group by decade,a.first_name)
sub)
select decade,first_name,counts
from actornames_count_per_decade
where ranking=1;
 
-- 1890	Petr	26
-- 1900	Florence	180
-- 1920	Charles	1009
-- 1910	Harry	1662
-- 1960	John	1823
-- 1950	John	2027
-- 1940	George	2128
-- 1930	Harry	2161
-- 1970	John	2657
-- 1980	John	3855
-- 2000	Michael	3914
-- 1990	Michael	5929

with actorfullnames_count_per_decade as(
select * ,rank() over( partition by decade order by counts DESC) as ranking
from
(SELECT floor(m.year/10)*10 as decade,
concat(a.first_name," ",a.last_name) as fullname,
count(concat(a.first_name," ",a.last_name)) as counts
from actors a 
join roles  r
on a.id= r.actor_id
join movies m
on  m.id=r.movie_id
group by decade,a.first_name)
sub)
select decade,fullname,counts
from actorfullnames_count_per_decade
where ranking=1;

-- 1890	Petr Lenícek	26
-- 1900	Florence Auer	180
-- 1910	Harry Ahlin	1662
-- 1920	Charles Alexandra	1009
-- 1930	Harry Abdy	2161
-- 1940	George Adrian	2128
-- 1950	John Aamdahl	2027
-- 1960	John Abbey	1823
-- 1970	John Abbey	2657
-- 1980	John Aasen	3855
-- 1990	Michael Abelar	5929
-- 2000	Michael 'babeepower' Viera	3914

-- 24)Re-do the analysis on most common names, splitted for males and females.

-- for MALE

with actorfullnames_count_per_decade as(
select * ,rank() over( partition by decade order by counts DESC) as ranking
from
(SELECT floor(m.year/10)*10 as decade,
concat(a.first_name," ",a.last_name) as fullname,
count(concat(a.first_name," ",a.last_name)) as counts
from actors a 
join roles  r
on a.id= r.actor_id
join movies m
on  m.id=r.movie_id
where a.gender like "m"
group by decade,a.first_name)
sub)
select decade,fullname,counts
from actorfullnames_count_per_decade
where ranking=1;

-- 1890	Petr Lenícek	26
-- 1900	Mack Sennett	168
-- 1910	Harry Ahlin	1662
-- 1920	Charles Alexandra	1009
-- 1930	Harry Abdy	2161
-- 1940	George Adrian	2128
-- 1950	John Aamdahl	2027
-- 1960	John Abbey	1823
-- 1970	John Abbey	2657
-- 1980	John Aasen	3855
-- 1990	Michael Abelar	5907
-- 2000	Michael 'babeepower' Viera	3899


-- for FEMALE

with actorfullnames_count_per_decade as(
select * ,rank() over( partition by decade order by counts DESC) as ranking
from
(SELECT floor(m.year/10)*10 as decade,
concat(a.first_name," ",a.last_name) as fullname,
count(concat(a.first_name," ",a.last_name)) as counts
from actors a 
join roles  r
on a.id= r.actor_id
join movies m
on  m.id=r.movie_id
where a.gender like "f"
group by decade,a.first_name)
sub)
select decade,fullname,counts
from actorfullnames_count_per_decade
where ranking=1;

-- 1890	Rosemarie Quednau	16
-- 1900	Florence Auer	180
-- 1910	Florence Alliston	782
-- 1920	Mary Akin	649
-- 1930	Dorothy Adams	830
-- 1940	Maria Abbate	739
-- 1950	María Abelenda	1005
-- 1960	Maria Adelina	1059
-- 1970	María Abradelo	1191
-- 1980	Maria Acosta-Colon	1228
-- 1990	Maria Abel	1728
-- 2000	María Adánez	1148


-- 25)How many movies had a majority of females among their cast?

select count( *) from
 (select r.movie_id ,
 count( case when a.gender='m' then 1 end) as m_count,
  count( case when a.gender='f' then 1 end) as f_count

 from roles r
 join actors a
 on a.id=r.actor_id
 group by r.movie_id) sub
 where f_count>m_count;


-- 50666

-- 26) What percentage of the total movies had a majority female cast?



SELECT 
(SELECT COUNT(movie_title) 
FROM (SELECT r.movie_id AS movie_title,
 COUNT(CASE WHEN a.gender='M' THEN 1 END) AS male_count, 
 COUNT(CASE WHEN a.gender='F' THEN 1 END) AS female_count 
 FROM roles r JOIN actors a
 ON r.actor_id = a.id GROUP BY r.movie_id 
 HAVING female_count > male_count) sub) *100/
 (SELECT COUNT(DISTINCT movie_id) FROM roles) 
 AS percentage_female_cast;

-- 16.87