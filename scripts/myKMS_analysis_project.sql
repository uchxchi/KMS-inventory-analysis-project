create database KMS_Inventory_Analysis
select * from orders

--Q1. Product Category With Highest Sales--

select top 1 product_category, sum(sales) as total_sales from orders 
group by product_category
order by total_sales desc

--Insight:
--Technology had the highest sales with a total of $5,984,248.50

--Q2. Top 3 and Bottom 3 Regions in Terms of Sales--

select region, total_sales, 'Top 3' as sales_rank
from (
select top 3 region, sum(sales) as total_sales from orders
group by region
order by total_sales desc) as top_regions
union
select region,total_sales, 'Bottom 3' as sales_rank
from (
select top 3 region, sum(sales) as total_sales from orders
group by region
order by total_sales asc) as bottom_regions

--Insight:
--Top 3 Regions and their total sales:
--West $3,597,549.41 -Ontario $3,063,212.60 -Prarie $2,837,304.60

--Bottom 3 Regions and their total sales:
--Nunavut $116,376.47 --Northwest Territories $800,847.35
--Yukon $975,867.39

 --Q3. Total Sales of Appliances in Ontario--

 select product_sub_category, region, sum(sales) as total_sales_appliance from orders
 where product_sub_category = 'Appliances' and region = 'Ontario'
 group by product_sub_category, region

 --Q4. Advise the management of KMS on what to do to increase the revenue from the bottom 10 customers--

--Bottom 10 customers

with customer_totals as (
    select 
        customer_name, 
        sum(sales) as total_sales,
        count(order_id) as total_orders, 
        avg(discount) as avg_discount,
        avg(order_quantity) as order_quantity
    from orders
    group by customer_name
),

-- Rank orders by most recent date per customer
recent_customer_info as (
    select
        customer_name, 
        region,
        customer_segment,
        row_number() over (partition by customer_name order by order_date desc) as rn
    from Orders
)

-- Main query: Top 10 customers with lowest total sales
select top 10
    ct.customer_name,
    ct.total_sales,
    ct.total_orders,
    ct.avg_discount,
    ct.order_quantity,
    rci.customer_segment,
    rci.region
from customer_totals ct
join recent_customer_info rci on ct.customer_name = rci.customer_name
where rci.rn = 1
order by ct.total_sales asc;

--Top 10 customers

with  customer_totals as (
    select 
        customer_name, 
        sum(sales) as total_sales,
        count(order_id) as total_orders, 
        avg(discount) as avg_discount,
        avg(order_quantity) as order_quantity
    from orders
    group by customer_name
),

-- Rank orders by most recent date per customer
recent_customer_info as (
    select 
        customer_name, 
        region,
        customer_segment,
        row_number() over (partition by Customer_Name order by Order_Date desc) as rn
    from orders
)

-- Main query: Top 10 customers with lowest total sales
select top 10
    ct.customer_name,
    ct.total_sales,
    ct.total_orders,
    ct.avg_discount,
    ct.order_quantity,
    rci.customer_segment,
    rci.region
from customer_totals ct
join recent_customer_info rci on ct.customer_name = rci.customer_name
where rci.rn = 1
order by ct.total_sales desc

--Insight:
--The bottom 10 customers placed fewer orders with 
--lower quantities and received lower discounts.
--In contrast, top customers had higher discounts, 
--more frequent purchases, and larger order sizes.
--Recommendation: Offer volume-based discounts and 
--engagement strategies to boost revenue from low-value customers.


--Q5. KMS incurred the most shipping cost using which shipping method?--

select top 1 ship_mode, sum(shipping_cost) as shipping_cost from orders
group by ship_mode
order by shipping_cost desc

--Q6. Who are the most valuable customers, and what products or services do they typically purchase?--

select o.customer_name, o.product_name, sum(o.sales) as product_sales
from orders o
join(
		select top 10 customer_name
		from orders
		group by customer_name
		order by sum(sales) desc)top_customers 
		on o.customer_name = top_customers.customer_name
group by o.customer_name, o.product_name
order by o.customer_name, product_sales desc



--Q7. Which small business customer had the highest sales?--

select top 1 customer_name, customer_segment, sum(sales) as total_sales from orders
where customer_segment = 'Small Business'
group by customer_name, customer_segment
order by sum(sales) desc

--Insight:
--Dennis Kane from the small business segment 
--had the highest sales with a total of $75,967.59

--Q8. Which Corporate Customer placed the most number of orders in 2009 – 2012? --

select top 2 customer_name, count(distinct order_id) as total_orders
from orders
where customer_segment = 'Corporate' and year(order_date) between 2009 and 2012
group by customer_name
order by total_orders desc

--Insight:
--Adam Hart and Roy Skaria placed the most orders, total of 18 orders each.

--Q9. Which consumer customer was the most profitable one?--

select top 1 customer_name, count(Order_ID) as total_orders, sum(profit) as total_profit 
from orders
where customer_segment = 'Consumer'
group by customer_name
order by total_profit desc

--Insight:
--Emily Phan was the most profitable customer from the consumer segment


--Q10. Which customer returned items, and what segment do they belong to?--

select distinct o.customer_name, o.customer_segment,s.return_status
from orders o
join order_status s
on o.order_id = s.order_id
where s.return_status = 'returned'

--Insight:
--Customers in the corporate, home office, small business
--and consumer segments returned items


--Q11. If the delivery truck is the most economical but the slowest shipping method and 
--Express Air is the fastest but the most expensive one, do you think the company 
--appropriately spent shipping costs based on the Order Priority? Explain your answer

select ship_mode, order_priority, 
count(*) as total_orders,
sum(shipping_cost) as total_shipping_cost,
avg(shipping_cost) as avg_shipping_cost
from orders
group by ship_mode, order_priority
order by ship_mode, order_priority 

--Insight:
-- No, KMS did not consistently spend shipping costs appropriately based on order priority.
--A significant portion of Critical and High priority orders
--were shipped using Delivery Truck, which is the slowest method,
--despite Express Air being designed for urgent deliveries and having lower average costs.
--Additionally, Express Air was used for Low and Not Specified priority orders,
--increasing cost unnecessarily.
-- Recommendation: KMS should align shipping modes with priority levels 
--(e.g., Express Air for Critical/High,
-- Delivery Truck for Low/Not Specified) and implement logic to enforce 
--this for cost-effective operations.
