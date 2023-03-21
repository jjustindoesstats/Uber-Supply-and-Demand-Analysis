#Take a look at the data
select *
from uber_data;

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
alter table uber_data
add ID int not null auto_increment key;

#True or False: Driver supply always increases when demand increases during the two week period? y=Driver Supply and requests = x
#First we should group the 

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
#Visulaize in Python





                              




