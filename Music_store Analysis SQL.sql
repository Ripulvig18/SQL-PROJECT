#DATA ANALYST PROJECT

#SENIOR MOST EMPLOYEE ON JOB TITLE
SELECT * FROM music_store.employee
order by levels desc
limit 1;

#COUNTRIES HAVE THE MOST INVOICES

SELECT COUNT(*), billing_country
FROM music_store.invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC;

# TOP 3 TOTAL INVOICES

SELECT total FROM music_store.invoice
ORDER BY total DESC
LIMIT 3;

#CITY HAS THE BEST CUSTOMERS

SELECT billing_city, SUM(total) AS S FROM music_store.invoice
GROUP BY billing_city
ORDER BY S DESC
LIMIT 1;

#Maximum amount spent by the customer declared as "Best Customer"

select customer.customer_id,customer.first_name,customer.last_name, SUM(invoice.total) as total from music_store.customer
inner join music_store.invoice on
customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by total desc
limit 1;

#Details about "Rock Music" listeners

SELECT DISTINCT email,first_name, last_name 
FROM music_store.customer
JOIN music_store.invoice ON customer.customer_id = invoice.customer_id
JOIN music_store.invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN music_store.track ON invoice_line.track_id = track.track_id
JOIN music_store.genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

#Artists who have written most "Rock Music"

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM music_store.track
JOIN music_store.album2 ON track.album_id = album2.album_id
JOIN music_store.artist ON artist.artist_id = album2.artist_id
JOIN music_store.genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id,artist.name
ORDER BY number_of_songs DESC
LIMIT 10;  

#Track names that have length above the average song length

SELECT name,milliseconds FROM music_store.track
WHERE milliseconds > 
( SELECT AVG(milliseconds) AS avg_track_length FROM music_store.track)
ORDER BY milliseconds DESC;

#Amount spent by customer on Top Artist

WITH best_artists AS (
     SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
     SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
     FROM music_store.invoice_line 
     JOIN music_store.track ON track.track_id = invoice_line.track_id
     JOIN music_store.album2 ON track.album_id = album2.album_id
     JOIN music_store.artist ON album2.artist_id = artist.artist_id
     GROUP BY artist_id, artist_name
     ORDER BY total_sales DESC
     LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, ba.artist_name,
SUM(il.unit_price * il.quantity) AS amount_spent
FROM music_store.customer c 
JOIN music_store.invoice i ON c.customer_id = i.customer_id
JOIN music_store.invoice_line il ON il.invoice_id = i.invoice_id
JOIN music_store.track t ON il.track_id = t.track_id
JOIN music_store.album2 a ON t.album_id = a.album_id
JOIN best_artists ba ON a.artist_id = ba.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

#Most popular music genre with highest number of purchases  

WITH popular_genre AS
 (
     SELECT COUNT(invoice_line.quantity) AS total_purchases, customer.country,
     genre.name, genre.genre_id, ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rownumber
     FROM  music_store.invoice_line
     JOIN music_store.invoice ON invoice.invoice_id = invoice_line.invoice_id
     JOIN music_store.customer ON invoice.customer_id = customer.customer_id
     JOIN music_store.track ON track.track_id = invoice_line.track_id
     JOIN music_store.genre ON track.genre_id = genre.genre_id
     GROUP BY 2,3,4
     ORDER BY 2 ASC, 1 DESC
	
)
SELECT * FROM popular_genre WHERE rownumber <= 1;

#Top customer spent maximum amount on music for each country

WITH RECURSIVE 
     customer_with_country AS (
     SELECT customer.customer_id,customer.first_name, customer.last_name, 
     invoice.billing_country, SUM(invoice.total) AS total_spending FROM music_store.invoice
     JOIN music_store.customer ON invoice.customer_id = customer.customer_id
     GROUP BY 1,2,3,4
     ORDER BY 1,5 DESC
     ),
     country_max_spending AS (
     SELECT billing_country,MAX(total_spending) AS max_spending
     FROM customer_with_country
     GROUP BY billing_country)
     
SELECT cc.billing_country,cc.first_name,cc.last_name,cc.total_spending
FROM customer_with_country cc 
JOIN country_max_spending mc
ON cc.billing_country = mc.billing_country
WHERE cc.total_spending = mc.max_spending
ORDER BY 1;












































