/*food_orders analytics*/

//datas overview
select * from orders;
select * from restaurant;
select * from menu;
select * from users;
--total orders 
select count(user_id) as total_orders from orders;
--total users
select count(distinct(user_id)) as total_users from users
--total count of restaurants
select count(distinct(id)) as total_restaurant from restaurant;
--count of cities
select count(distinct(city)) as total_cities from restaurant;
--available cuisine
select count(distinct(cuisine)) as cuisines_available from restaurant;

--data cleaning
	--user table find null vales
	select * from users
	where 
	     user_id is null or
	     name is null or
		 age is null or
		 gender is null or
		 marital_status is null or
		 occupation is null;
	--reataurant find null values and replace into values not found
		select * from restaurant
		where 
		     id is null or
		     name is null or
			 country is null or
			 city is null or
		     rating is null or
			 rating_count is null or
			 cuisine is null;
		update restaurant set cuisine='not_specified' where cuisine is null;
		update restaurant set rating_count = 'no_rating_count' where rating_count is null;
		update restaurant set name = 'no_users_specified' where name is null;
		
	--order table/null values
	select * from orders 
	  where
	  order_date is null or
	  sales_qty is null or
	  currency is null or
	  user_id is null or
	  r_id is null or
	  quarter is null or
	  month_name is null or
	  year is null;
	 --menu taable/null values
	 select * from menu
	 where
	 menu_id is null or
	 r_id is null or
	 f_id is null or
	 cuisine is null or
	 price is null;


--query analysis for food_orders(menu,restaunt,user,orders)
  --1.top 5 restaurant based on sales revenue over last year.
  --2.top 10 users who brought more product over last year with restaurant
  --3.which city shows as a high revenue city over year and quater
  --4.name the bottom three restaurant last year
  --5. name the top revenued restaurant over the year
  --6.mention the top 3 cities with high orders and bottom with low orders
  --7.which status of people shows more interest on orders over year
  --8.which 10 cuisines shows a greate sales over last year
  --9.mention the restaurants with more orders from users with rating over yearwise
  --10.mention each agegroup people with their popular cuision items
  --11.which city shows a high sales city 
    --12.names the restaurant with more selled cuision
	--13.top high rated cuisions and bottom rated cuision
	--14.overall average rating of restaurants in a particular city
	--15.find high demand cuision over last 2 month
	--16.age wise average cuision orders
	--17.mention which cuisine shows high unitsales
	--18.mention the name of user whose makes an orders max with restaurant,quantity,cuisine
	--19.give a orders data based on users_occupation
	--20.show a top 5 high selling year based on total revenue
  --data analysis
    --1.top 5 restaurant based on sales revenue over last year.
     select restaurant,cuisine as cuisine,city as city from(
     select o.year,r.id,r.name as restaurant ,r.cuisine as cuisine,ceil(mn.price) as unit_price,sum(o.sales_qty) as sales_qty,
	 ceil(ceil(mn.price)*sum(o.sales_qty)) as total_revenue,
	 rank() over(partition by o.year order by ceil(ceil(mn.price)*sum(o.sales_qty)) desc) as rank,r.city as city
	 from 
	 restaurant as r
	 join menu as mn on r.id=mn.r_id
	 join orders as o on mn.r_id=o.r_id 
	 group by 1,2,3,4,5 order by 1 desc,8 asc limit 5
	 )
	 --2.top 10 users who brought more product over last year with restaurant
       select u.name as user,r.name as restaurant,sum(o.sales_qty) as total_ordered_products
	   from
	   users u join orders o on 
	   u.user_id=o.user_id join restaurant r on 
	   o.r_id=r.id
	   group by 1,2 order by 3 desc limit 10;

	 --3.which city shows as a high revenue city over year and quater
	 select year,quarter,city,total_revenue from(
       select o.year as year,o.quarter as quarter,r.city as city,m.cuisine,ceil(m.price),sum(o.sales_qty),ceil(sum(o.sales_qty)*ceil(m.price)) as total_revenue,
	   rank() over(partition by o.year,o.quarter order by ceil(sum(o.sales_qty)*sum(m.price)) desc ) as rank
	   from orders o join menu m on o.r_id=m.r_id join restaurant r on m.r_id=r.id group by 1,2,3,4,5 
	   ) where rank = 1 order by year,quarter ;

	     --4.name the bottom three restaurant last year
     select restaurant,cuisine as cuisine,city as city from(
     select o.year,r.id,r.name as restaurant ,r.cuisine as cuisine,ceil(mn.price) as unit_price,sum(o.sales_qty) as sales_qty,
	 ceil(ceil(mn.price)*sum(o.sales_qty)) as total_revenue,
	 rank() over(partition by o.year order by ceil(ceil(mn.price)*sum(o.sales_qty)) asc) as rank,r.city as city
	 from 
	 restaurant as r
	 join menu as mn on r.id=mn.r_id
	 join orders as o on mn.r_id=o.r_id 
	 group by 1,2,3,4,5 order by 1 desc,8 asc limit 3
	 )
	   --5. name the top revenued restaurant over the year
       select year,restaurant,city,total_revenue from(
       select o.year as year,r.name as restaurant,r.city as city,m.cuisine,ceil(m.price),sum(o.sales_qty),ceil(sum(o.sales_qty)*ceil(m.price)) as total_revenue,
	   rank() over(partition by o.year order by ceil(sum(o.sales_qty)*sum(m.price)) desc ) as rank
	   from orders o join menu m on o.r_id=m.r_id join restaurant r on m.r_id=r.id group by 1,2,3,4,5
	   ) where rank = 1 order by year ;

	   --6.mention the top 3 cities with high orders and bottom with low orders
       select r.city,sum(o.sales_qty) as total_ordered_products
	   from
	   orders o join restaurant r on 
	   o.r_id=r.id
	   group by 1 order by 2 desc limit 3;
	   
	   select r.city,sum(o.sales_qty) as total_ordered_products
	   from
	   orders o join restaurant r on 
	   o.r_id=r.id
	   group by 1 order by 2 limit 3;
	   
	  --7.which status of people shows more interest on orders over year
      select u.occupation,sum(o.sales_qty) as total_ordered_products
	   from
	   orders o join users u on 
	   o.user_id=u.user_id
	   group by 1 order by 2 desc;

	    --8.which 10 cuisines shows a greate sales over last year
         select m.cuisine,sum(o.sales_qty) as top_sales from menu m join orders o on m.r_id=o.r_id group by 1 order by 2 desc limit 10;
	   
       --9.mention the restaurants with more orders from users with rating over yearwise

       select year,restaurant,total_orders from(
	   select o.year as year,r.name as restaurant,r.rating as rating,count(o.user_id) as total_orders,
	   rank() over(partition by o.year order by count(o.user_id) desc) as Rank
	   from
	   restaurant r join orders o on r.id=o.r_id
	   group by 1,2,3 order by 1 desc,4 desc
	   )where rank=1;
	     
		 
		 
	--10.mention each agegroup people with their popular cuision items
      select age_group_people,popular_cuisines from(
	  select u.age as age_group_people,m.cuisine as popular_cuisines,sum(o.sales_qty) as total_orders,
	   rank() over(partition by u.age order by sum(o.sales_qty) desc )
	   from users u join orders o
	   on u.user_id=o.user_id join restaurant r on o.r_id=r.id join menu m on r.id=m.r_id 
	    group by 1,2 order by 1,3 desc 
		) where rank=1;

  --11.which city shows a high sales city 
      select r.city,sum(o.sales_qty) as total_ordered_products
	   from
	   orders o join restaurant r on 
	   o.r_id=r.id
	   group by 1 order by 2 desc limit 1;
   --12.names the max poduct sales restaurant with more selled cuision
   select restaurant,top_cuisine from(
   select r.name as restaurant,r.cuisine as top_cuisine ,sum(o.sales_qty) as total_orders ,
      rank() over(partition by r.name,r.cuisine order by sum(o.sales_qty) desc ) as rank

   from restaurant r join orders o on r.id=o.r_id
   group by 1,2 order by 3 desc limit 10
   )where rank=1;
      	--13.top high rated cuisions and bottom/no rated rated cuision
	   select r.cuisine as cuisines , (avg(r.rating)) as top_rating from restaurant r group by 1
	   order by 2 desc limit 5;
	    select r.cuisine as cuisines , (avg(r.rating)) as top_rating from restaurant r group by 1
	   order by 2 asc limit 5;
	   --14.overall average rating of restaurants in a particular city

	   select r.city as city,r.name as restaurant,avg(r.rating) as rating from restaurant r 
	    where city = 'Ajmer' and rating<>0 group by 1,2 order by 3 desc;
	   

	  	--15.find high demand cuision over last 2 month
		  select year,month,cuisine,top_sales from(
       select o.year as year,o.month_name as month,r.cuisine as cuisine,sum(o.sales_qty) as top_sales,
	   rank() over(partition by o.year,o.month_name order by sum(o.sales_qty) desc ) as rank
	   from orders o join restaurant r on o.r_id=r.id where o.month_name in ('November','December')
	   group by 1,2,3 order by 1 desc,2
	   )where rank=1 limit 2;
	   
	   select distinct(month_name) from orders;
	   
	   	--16.age wise average cuision orders
     select u.age,count(o.user_id) from users u join orders o on u.user_id=o.user_id group by 1 ;
      	--17.mention which cuisine shows high unitsales
      select r.cuisine as cuisine,sum(o.sales_qty) as top_unitselled_cuisine
	  from 
	  restaurant r join orders o on r.id=o.r_id 
	  group by 1 order by 2 desc limit 1;

	  	--18.mention the name of user whose makes an  max unit orders with restaurant,quantity,cuisine
      select u.name as user,r.name as restaurant,r.cuisine as cuisine,sum(o.sales_qty) as top_unitOrder
	  from restaurant r join orders o on r.id=o.r_id join users u 
	  on u.user_id=o.user_id group by 1,2,3 order by 4 desc limit 1;

	  	--19.give a orders data based on users_occupation
          select u.occupation,sum(o.user_id) as total_orders from users u join orders o on u.user_id=o.user_id
		  group by 1 order by 2 desc;
		 --20.show a top 5 high selling year based on total revenue
   select year,total_revenue from(
   select o.year,ceil(o.sales_qty*m.price) as total_revenue,
   rank() over(partition by year order by ceil(o.sales_qty*m.price) desc)
   from orders o join menu m on o.r_id=m.r_id
   group by 1,2 order by 1 desc
   )where rank=1;
		  

	  
