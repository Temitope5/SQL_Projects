create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR')

with total_visits AS
(
SELECT name, count(1)as total_visits, string_agg(distinct resources,',') AS resources_used
from questions.entries
group by name
),

floor_visit as
(
SELECT 
name,floor,count(1) no_of_floor_visit,
rank()over(partition by name order by count(1) desc )as rn
FROM questions.entries
GROUP BY name,floor)

select fv.name,
fv.floor as most_visited_floor, tv.total_visits, tv.resources_used
from floor_visit AS fv 
inner join total_visits as tv on fv.name =tv.name
where rn = 1
order by 1
