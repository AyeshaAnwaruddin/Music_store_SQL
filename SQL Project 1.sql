use [Ayesha's Projects]
select * from INFORMATION_SCHEMA.TABLES
drop table employees

select * from album
select * from employee

/*Q1: Who is the senior most employee based on job title? */

 select top 1 CONCAT(first_name,' ',last_name) as Employee_name ,title,levels
from employee
order by levels desc


/* Q2: Which countries have the most Invoices? */
select * from invoice

select COUNT(invoice_id) as Invoices,billing_country
from invoice
group by billing_country
order by COUNT(invoice_id) desc

/* Q3: What are top 3 values of total invoice? */
select top 3 total 
from invoice
order by total desc


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city 
we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select * from invoice

select top 1billing_city,sum(total) as Invoice_Total
from invoice
group by billing_city
order by sum(total) desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select *from customer
select * from invoice

select concat(first_name,'',last_name) from customer where customer_id in (select top 1customer_id,sum(total)as Spent
from invoice
group by customer_id
order by sum(total) desc)

select customer.customer_id,sum(invoice.total)as Spent from
customer join invoice on invoice.customer_id=customer.customer_id
group by customer.customer_id
order by sum(invoice.total) desc

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */ 

select * from track
select * from genre
select * from customer
select * from invoice
select * from invoice_line

select distinct customer.email,customer.first_name,customer.last_name  from customer join invoice
on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
where track_id in (select track_id from track join genre on track.genre_id=genre.genre_id
where genre.name like 'rock')
order by customer.email asc

select distinct email,concat(first_name,'',last_name),genre.name from customer 
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
order by email


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select * from artist
select * from album
select * from track
select * from genre

select top 10 artist.artist_id,count(artist.artist_id)as total_tracks from artist
join album on album.artist_id=artist.artist_id
join track on track.album_id=album.album_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'rock'
group by artist.artist_id
order by total_tracks desc

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select * from album
select * from track


select name ,milliseconds from track
where milliseconds>(select AVG(milliseconds)as Avgerage_milli from track)
order by milliseconds desc

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */


select * from customer
select * from invoice
select * from invoice_line
select * from track
select * from album
select * from artist

with best_selling as (
select top 1 artist.artist_id as artist_id,artist.name as artist_name ,sum(invoice_line.unit_price*invoice_line.quantity)as Total_sale
from invoice_line 
join track on invoice_line.track_id=track.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.artist_id,artist.name
order by sum(invoice_line.unit_price*invoice_line.quantity) desc
)

SELECT c.customer_id, c.first_name, c.last_name,SUM(il.unit_price*il.quantity) AS amount_spent,bsa.artist_name
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling bsa ON bsa.artist_id = alb.artist_id
GROUP BY  c.customer_id, c.first_name, c.last_name,bsa.artist_name
ORDER BY SUM(il.unit_price*il.quantity) DESC;




/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */

select * from genre
select * from invoice
select * from invoice_line
select * from track
select * from customer

with popular as(
  select top 10000000 count(invoice_line.quantity ) as purchases,customer.country,genre.name,genre.genre_id,
  ROW_NUMBER()over(partition by customer.country order by count(invoice_line.quantity) desc) as row_num
  from invoice_line 
  join invoice on invoice_line.invoice_id=invoice.invoice_id
  join customer on invoice.customer_id=customer.customer_id
  join track on track.track_id =invoice_line.track_id
  join genre on genre.genre_id=track.genre_id
  group by customer.country,genre.name,genre.genre_id
  order by customer.country asc,count(invoice_line.quantity ) desc
  )

select * from popular where row_num=1


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */


select * from invoice
select * from customer

with country_pop as (
  select top 100000 customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,sum(total)as total_spending,
  ROW_NUMBER()over(partition by invoice.billing_country order by sum(total)desc) as row_num
  from invoice
  join customer on invoice.customer_id=customer.customer_id
  group by customer.customer_id,invoice.billing_country,customer.first_name,customer.last_name
  order by invoice.billing_country asc,sum(total) desc
)
select * from country_pop where row_num<=1




