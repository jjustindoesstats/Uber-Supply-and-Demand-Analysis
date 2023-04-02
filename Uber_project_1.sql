#Take a look at the data
select *
from uber_data;

#Add IDs to the table
alter table uber_data
add ID int not null auto_increment key;

#Which date had the most completed trips during the two week period?
select  date ,sum(`Completed Trips`) as total_completed_trips 
from uber_data
group by date
order by total_completed_trips desc
limit 1
;
#September 22nd 2012

#What was the highest number of completed trips within a 24 hour period?
#Use the above query to answer, 248


#Which hour of the day had the most requests during the two week period?
select `Time (Local)` , sum(requests) as total_requests
from uber_data
group by `Time (Local)`
order by total_requests desc
limit 1;
#23:00 had the most total ride requests


#What percentages of all zeroes during the two week period occurred on weekend (Friday at 17:00 to Sunday at 3:00)
#We can observe that the weekend occured on the following days: 14 (17:00),15,16 (3:00) and 21 (17:00),22,23 (3:00)
select (select sum(Zeroes)
from uber_data
where ((date = '14-Sep-12' or date = '21-Sep-12') and `Time (Local)` between 17 and 23) 
or (date = '15-Sep-12' or date = '22-Sep-12') 
or ((date = '16-Sep-12'or date = '23-Sep-12') and `Time (Local)` between 0 and 2))*100
/sum(Zeroes) as percentage_weekend
from uber_data
;

#Using subqueries we find that the percentage is 44.8565%


#What is the weighted average ratio of completed trips per driver during the two week period?
#Check how many rows are in the data set
select count(*) as number_rows
from uber_data;

#we want to sum all the values and divide.  We want to make sure we aren't representing smaller quanities of completed trips and unique drivers disproportionately
select  `Completed Trips` , `Unique Drivers` ,`Completed Trips`/`Unique Drivers` as Trip_to_Driver_ratio 
from uber_data
where `Unique Drivers` != 0;



#We have an idea what the ratios look like now we will produce a weighted average using the weights as the proportion of completed trips in the hour to the total
#Get the total number of completed trips
select sum(`Completed Trips`) as sum
from uber_data
;
#1365 completed trips in total

#Calculate weighted average (sum(w*x)/sum(w) where w=completed_trip/sum_of_completed_trips
select sum(`Completed Trips`*(`Completed Trips`/1365)/`Unique Drivers`)/sum(`Completed Trips`/1365) as weighted_average
from uber_data
where `Unique Drivers` != 0;
#The weighted average is 0.828277 completed trips per driver



#In drafting a driver schedule in terms of 8 hours shifts, when are the busiest 8 consecutive hours over the two week period in terms of unique requests?

#We want the highest consecutive hours across the two weeks
#So we want to group the time in consecutive 8 hour groups then average the requests out for every instance

#we can test out which sums give us the highest values

select sum(Requests) as total_requests , `Time (Local)`
from uber_data
group by `Time (Local)`
order by total_requests DESC
;

#Our interval must contain 0,22,23,19,18,21,20,17

#So the busiest consecutive interval is 17:00-01:00. so the optimal driving shift is 17:00 - 1:00


#True or False: Driver supply always increases when demand increases during the two week period? y=Driver Supply and requests = x
#Group the data by requests and take the max(unique drivers) to get an intitial hypothesis
select max(`Unique Drivers`) , Requests
from uber_data
group by Requests
order by Requests;

#From this query I already get the suspiscion thats its False
#We can use a self join and check for negative values given a sinlge increase in requests

select distinct u1.Requests as requests_1, u2.Requests as requests_2, u1.`Unique Drivers` - u2.`Unique Drivers` as increase_in_drivers
from uber_data u1 , uber_data u2
where u1.requests - u2.requests =1 and  u1.`Unique Drivers` - u2.`Unique Drivers`<0
;

#We see plenty of negative values given a one increase
#So we can concluse False
#Visulaize in Tableau

#In which 72 hour period is the ratio of Zeroes to Eyeballs the highest?
#Check if we have zero eyeballs anywhere
select *
from uber_data
where Eyeballs = 0;


#We do have one null value
select d1.date as date_1 , d2.date as date_2 , min(d1.Zeroes/d1.Eyeballs) as zero_eyeball_ratio 
from uber_data d1 , uber_data d2
where d1.Eyeballs != 0 and abs(d2.date - d1.date) = 1 and d1.date < d2.date
group by d1.Date , d2.date
;

#Using an inner join we see that the highest zero to eyeball ratio is from 14-Sep-12 to 15-Sep-12

#If you could add 5 drivers to any single hour of every day during the two week period, which hour should you add them to?
#We want the difference in eyeballs and unique drivers, that way we can see where exactly there is a lack of drivers
#Take the unique drivers and subtract by eyeballs to get the surplus or defieciency of drivers
#Take the average of the driver_minus_eyeballs 
select `Time (Local)` , avg(`Unique Drivers`- Eyeballs) as drivers_minus_eyeballs
from uber_data
group by `Time (Local)`
order by drivers_minus_eyeballs 
limit 1
;

#We do add five drvers to 23:00

#Are there exactly two weeks in this analysis?
#Take the latest date subtract from the starting time, take the latest hour of the latest hour and subtract
#Output should be 14 and 0 respectively

#Find ID of last row
select max(ID) as last_ID
from uber_data
;
#Last ID is 336

#Use self join
select d1.date - d2.date as difference_days , d1.`Time (Local)`-d2.`Time (Local)` as difference_time
from uber_data d1, uber_data d2
where d1.ID = 336 and d2.ID = 1
;

#We are one hour off from the analysis being exactly two weeks
#So False


#Looking at the data from all two weeks, which time might make the most sense to consider a true "end day" instead of midnight?
#We should look at the time of day in which the supply and demand are at there minimums (unique drivers and requests)
#Since we want a cumulative calculation we should take the addition of requests and unique drivers, and average them out (grouped by each date)
select `Time (Local)`,avg(`Unique Drivers`+Requests) as total_supply_demand 
from uber_data
group by `Time (Local)`
order by total_supply_demand ;

#Therefore, the time in which the total supply and demand is at its lowest is 4:00am

#Take the average eyeballs and subtract from average requests 
select avg(Eyeballs-Requests) cust_acq
from uber_data;

#Which time is this most prevalent?
select avg(Eyeballs-Requests) cust_acq , `Time (Local)`
from uber_data
group by `Time (Local)`
;



#How many Requests actually get completed?
select avg(Requests - `Completed Trips`)
from uber_data
;
#Does this problem effect some times disproportionately?
select avg(Requests - `Completed Trips`), `Time (Local)`
from uber_data
group by `Time (Local)`
;



