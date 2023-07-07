SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

select * from users;
select * from delivery_partner;
select * from food;
select * from order_details;
select * from orders;
select * from restaurants;
select * from menu;

-- How many deliveries were given by each delivery partner

select partner_id , count(order_id)
from orders
group by partner_id;

-- max deliveries given by partner name?

select partner_name
from delivery_partner
where partner_id = (
select partner_id
from orders
group by partner_id
order by count(order_id) desc
limit 1);

-- On which day were the most deliveries/orders taken?

select dayname(date) AS Day 
from orders
group by DAY
order by count(dayname(date)) desc
limit 1;

-- Find customers who have never ordered

select * 
from users
where user_id NOT IN (select distinct user_id from orders);

-- Another Method 

select * 
from users
left join orders
on users.user_id = orders.user_id 
where users.user_id NOT IN (select distinct orders.user_id from orders)
UNION
select * 
from users
left join orders
on users.user_id = orders.user_id 
where users.user_id NOT IN (select distinct orders.user_id from orders);

--  Average Price of each dish

select food.f_name , avg(menu.price)
from menu
inner join food
on menu.f_id = food.f_id
group by food.f_name
order by avg(menu.price) asc;

-- Find the top restaurant name in terms of the (highest)number of orders placed for a given month :

select r_name
from restaurants
where r_id = (
select orders.r_id
from orders
inner join restaurants
on orders.r_id = restaurants.r_id
where orders.date  LIKE '_____07___'
group by orders.r_id
order by count(orders.order_id) DESC LIMIT 1);


-- restaurants with monthly sales greater than x for 

select restaurants.r_name , sum(orders.amount)
from orders
join restaurants
on orders.r_id = restaurants.r_id
where orders.date LIKE '_____07___'
group by restaurants.r_name
having sum(orders.amount)>500;

-- Show all orders with order details for a particular customer in a particular date range

select orders.order_id , restaurants.r_name , food.f_name 
from orders
join restaurants
on restaurants.r_id = orders.r_id
join order_details
on orders.order_id = order_details.order_id 
join food
on food.f_id = order_details.f_id
where user_id = (select user_id from users where name like 'Khushboo')
and date BETWEEN '2022-05-10' AND '2022-07-01';


-- Find restaurants with max repeated customers 

select restaurants.r_name , count(*) AS 'Repeated_Customers'
from ( select r_id , user_id , count(*) AS 'visits' 
from orders
group by r_id , user_id 
having visits>1 ) t
join restaurants 
on restaurants.r_id = t.r_id 
group by t.r_id 
order by Repeated_Customers DESC LIMIT 1;


-- What is the total number of ratings (sum) received by each restaurant

select r_id , sum(restaurant_rating) 
from orders
group by r_id
order by sum(restaurant_rating) desc;


-- Which restaurant received the highest rating 

select r_id , sum(restaurant_rating) 
from orders
group by r_id
order by sum(restaurant_rating) desc
limit 1;

-- What is the name of the restaurant that received the highest rating

select r_name
from restaurants
where r_id = (
select r_id
from orders
group by r_id
order by sum(restaurant_rating) desc
limit 1);

-- Another method through join 

select r_name
from restaurants
where r_id =(
select orders.r_id
from orders
join restaurants
on orders.r_id  = restaurants.r_id
group by orders.r_id
order by sum(orders.restaurant_rating) desc
limit 1);

-- Name the delivery partner who did delivery  in the shortest time 

select partner_name
from delivery_partner
where partner_id = (
select orders.partner_id
from orders
join delivery_partner
on orders.partner_id = delivery_partner.partner_id
group by orders.partner_id
order by min(orders.delivery_time) asc
limit 1);

-- or

select distinct delivery_partner.partner_name
from orders
join delivery_partner
on orders.partner_id = delivery_partner.partner_id
where  orders.partner_id = (
select orders.partner_id
from orders
join delivery_partner
on orders.partner_id = delivery_partner.partner_id
group by orders.partner_id
order by min(orders.delivery_time) asc
limit 1);