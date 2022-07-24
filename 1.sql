-- after creating the database fifa I need to create a tables 
use fifa;
create table player (
sofifa_id integer, 
short_name char(40), 
club_name char(40), 
league_name char(40), 
team_jersey_number integer,
primary key (sofifa_id)
);

create table salary (
id integer, 
club_name char(40), 
value_eur int, 
wage_eur int, 
joined date,
contract_valid_until int,
FOREIGN KEY (id)  REFERENCES player (sofifa_id)
);
alter table salary add constraint pk2 primary key (id);

create table records (
id integer, 
age char(40),
name char(40), 
b_date date, 
height_cm int, 
weight_kg int,
preferred_foot char(40),
FOREIGN KEY (id)  REFERENCES player (sofifa_id)
);
alter table records add constraint pk3 primary key (id);

create table nationality (
id integer, 
name char(40), 
nationality char(40), 
nation_jersey_number int, 
FOREIGN KEY (id)  REFERENCES player (sofifa_id)
);

-- not a good practice to name column @name@ so need to drop it and crate new one
drop table nationality;

create table nationality (
id integer, 
players_name char(40), 
nationality char(40),
nation_jersey_number int, 
FOREIGN KEY (id)  REFERENCES player (sofifa_id)
);

-- lets set up primary key, it is a good practise to have primary key in each table
alter table nationality add constraint pk1 primary key (id);

-- to keep the tables in front of own eyes))
select * from nationality;
select * from player;
select * from records;
select * from salary;


select Upper(players_name), LOwer(nationality), concat(weight_kg, "kg", height_cm, "cm") as kg_cm from nationality 
join salary on (nationality.id=salary.id)
join records on (records.id=salary.id)
order by 2;

-- show us all players who have 99 kit number 
select short_name, salary.club_name, wage_eur as salary_per_year, team_jersey_number 
from player join salary on (sofifa_id=id) 
where team_jersey_number = 99
order by 3 desc;
-- we can see that napoli, milan, roma and inter have such players (all teams from italy) and clubs paying them alot

-- show us the clubs with the biggest quantity of players at the age of 33
select club_name, count(club_name)
from player join records on (sofifa_id=id) 
where age = 33
group by club_name 
order by 2 desc;
-- it is funny, but barselona has 3 player at the age of 33

-- show us all the barsa players at the age of 33
select short_name, club_name , age from player join records on (sofifa_id=id)
where age = 33 and club_name like "%Barc%";
-- messi and suares both have the same age!

-- show us the leage where the bigest salary budget 
select league_name, sum(wage_eur) from player join salary on (sofifa_id=id)
group by league_name
order by 2 desc;
-- not surprise that English premier league got the biggest budget, spanish is second and italian has the thirst place

-- show the leage there are the most argentinian players are playng
 select league_name, count(nationality) as Argentinian from player join nationality on (sofifa_id=id)
where nationality = "Argentina"
group by league_name
order by 2 desc;
-- on the third plase is USA league with 41 player from Argentina

-- show the leage there are the most argentinian players are playng
 select league_name, count(nationality) as count_players from player join nationality on (sofifa_id=id)
group by league_name
having count_players>500
order by 2;
-- good example of using having, we see only league with more than 500 players

-- show the top 15 valuable players with name, league and current value 
select salary.club_name, short_name, max(value_eur) from player left outer join salary on (sofifa_id=id)
group by salary.club_name, short_name
order by 3 desc
limit 15;
-- good example of using limit, we see only top 15 players

-- show the player who have same kit number as in nation team as in club, club must has at least one player evaluated more than 100 million
select short_name, club_name, nationality, team_jersey_number from player join nationality on (sofifa_id=id) 
where nation_jersey_number = team_jersey_number and club_name in (select club_name from salary where value_eur > 100000000)
order by 4 desc;
-- only one player satisfied the query and it is PSG player

-- show the name, league, nationality, weight of players if their weight more 100kg
select distinct(short_name) as players_name , salary.club_name, league_name, nationality, weight_kg from player 
join salary on (player.club_name=salary.club_name) 
join nationality on (sofifa_id=nationality.id)
join records on (sofifa_id=records.id)
where weight_kg>100
order by 5 desc;

-- by using @case@ we can divede each player according to his weight
select id, name, weight_kg, 
case 
when weight_kg> 100 then "big_one"
else "regular"
end as case_st
from records
order by 4; 

-- show the quantity players in each group according to weight
select
count(case  when weight_kg>= 100 then 1 end) as big_player,
count(case  when weight_kg >= 75 and weight_kg <=99 then 1 end) as regular_player,
count(case  when weight_kg >= 50 and weight_kg <=74 then 1 end) as fast_player,
count(case  when weight_kg >= 30 and weight_kg <=49 then 1 end) as super_fast_player
from records; 
-- as result we see that 23 players in >100kg, 9908 players in 75-99kg, 9013 players in 50-74kg and 0 in 30-49kg

-- show player, his weight and wich group he belongs to
select id, name, weight_kg,
count(case  when weight_kg>= 100 then 1 end) as big_player,
count(case  when weight_kg >= 75 and weight_kg <=99 then 1 end) as regular_player,
count(case  when weight_kg >= 50 and weight_kg <=74 then 1 end) as fast_player,
count(case  when weight_kg >= 30 and weight_kg <=49 then 1 end) as super_fast_player
from records
group by id, name, weight_kg
having weight_kg < 55
order by 3; 
-- as result we see 9 players from @fast_player@ group.



