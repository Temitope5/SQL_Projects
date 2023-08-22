
--Question 1
--Write a SQL query to find the median salary of each company
--Bonus points if you can solve it without using any buildt-in SQL functions

--Table Creation Script:
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

--Pivot the data table in such a way that it is grouped by city
--Table Creation Script
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
	 MAX(CASE when city = 'Bangalore' THEN name ELSE NULL END) as Bangalore,
	 MAX(CASE when city = 'Mumbai' THEN name ELSE NULL END) AS Mumbai,
	 MAX(CASE when city = 'Delhi' THEN name ELSE NULL END) as Delhi
FROM	 
(SELECT *,
ROW_NUMBER() OVER (PARTITION BY CITY ORDER BY name ASC)AS player_groups
FROM players_location) AS a
GROUP BY player_groups
ORDER BY player_groups

-- Questions 3: Get the second most recent activity, if there is only one activity, return that one

--Table Creation Script
CREATE TABLE UserActivity
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);

INSERT INTO UserActivity VALUES 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');

-- Answer 
WITH cte AS
(
SELECT *, COUNT(1) OVER(PARTITION BY username)AS activity_count, RANK() OVER (PARTITION BY username ORDER BY startdate DESC)AS RANK
FROM useractivity
)

SELECT username, activity,startdate,enddate
FROM CTE
WHERE activity_count = 1 OR RANK = 2

-- Question 4
-- Table Creation Script
CREATE TABLE sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

INSERT INTO sales VALUES(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);
-- Answers 
