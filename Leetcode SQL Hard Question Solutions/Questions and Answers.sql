
--Question 1
--Write a SQL query to find the median salary of each company
-- Bonus points if you can solve it without using any buildt-in SQL functions

-- script:
create table employee 
(
emp_id int,
company varchar(10),
salary int
);

insert into employee values (1,'A',2341)
insert into employee values (2,'A',341)
insert into employee values (3,'A',15)
insert into employee values (4,'A',15314)
insert into employee values (5,'A',451)
insert into employee values (6,'A',513)
insert into employee values (7,'B',15)
insert into employee values (8,'B',13)
insert into employee values (9,'B',1154)
insert into employee values (10,'B',1345)
insert into employee values (11,'B',1221)
insert into employee values (12,'B',234)
insert into employee values (13,'C',2345)
insert into employee values (14,'C',2645)
insert into employee values (15,'C',2645)
insert into employee values (16,'C',2652)
insert into employee values (17,'C',65);

-- Answer: 

SELECT company,ROUND(avg(salary))
FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company ORDER BY salary) AS rn,
COUNT(1) over(PARTITION BY company) AS total_cnt
FROM employee) AS a
WHERE rn BETWEEN total_cnt*1.0/2 AND total_cnt * 1.0/2 +1
GROUP BY company

-- Question 2
-- Pivot the data table in such a way that it is grouped by city
--Script
create table players_location
(
name varchar(20),
city varchar(20)
);
delete from players_location;
insert into players_location
values ('Sachin','Mumbai'),('Virat','Delhi') , ('Rahul','Bangalore'),('Rohit','Mumbai'),('Mayank','Bangalore');

--Answer 
SELECT
	 MAX(case when city = 'Bangalore' then name else NULL END) as Bangalore,
	 MAX(case when city = 'Mumbai' then name else NULL END) AS Mumbai,
	 MAX(case when city = 'Delhi' then name else NULL end) as Delhi
FROM	 
(SELECT *,
row_number() OVER (PARTITION BY CITY ORDER BY name ASC)AS player_groups
from players_location) AS a
GROUP BY player_groups
ORDER BY player_groups