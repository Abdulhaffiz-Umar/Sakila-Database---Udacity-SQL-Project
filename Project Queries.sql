-- Question 1.1: We want to understand more about the movies that families are watching. 
-- The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music. 
-- Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.

SELECT  f.title as film_title, 
		c.name as category_name, 
		COUNT (r.rental_id) as rental_count 
FROM category c 
	JOIN film_category fc 
	ON c.category_id = fc.category_id
	AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	
	JOIN film f
	ON fc.film_id = f.film_id 
	
	JOIN inventory i 
	ON f.film_id = i.film_id 
	
	JOIN rental r 
	ON i.inventory_id = r.inventory_id 
	
GROUP BY 1,2
ORDER BY 2;

-- Question 2.1: We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. 
-- Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. 
-- Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.

SELECT  DATE_PART('year', r.rental_date) year_rented,
		DATE_PART('month', r.rental_date) month_rented,
		s.store_id Store_id,
		COUNT (*) count_rentals 
FROM store s 
	JOIN staff st 
	ON s.store_id = st.store_id
	JOIN rental r
	ON st.staff_id = r.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

--Question 2.2: We would like to know who were our top 10 paying customers, 
--how many payments they made on a monthly basis during 2007, 
--and what was the amount of the monthly payments. 
--Can you write a query to capture the customer name, month and year of payment, 
--and total payment amount for each month by these top 10 paying customers?

WITH t1 as 
		(SELECT (first_name || ' ' || last_name) full_name,
				c.customer_id,
				p.amount,
				p.payment_date
			FROM customer c
			JOIN payment p
			ON c.customer_id = p.customer_id),
	  
	  t2 as 
	  	(SELECT t1.customer_id
		  	FROM t1
		  	GROUP BY 1
		 	ORDER BY SUM(t1.amount) DESC
		  	LIMIT 10)

SELECT  t1.full_name,
		DATE_PART('year', t1.payment_date) year_of_payment,
		DATE_PART('month', t1.payment_date) month_of_payment,
		COUNT (*) pay_per_month,
		SUM(t1.amount) total_amount
FROM t1
JOIN t2
ON t1.customer_id = t2.customer_id
WHERE t1.payment_date BETWEEN '20070101' AND '20080101'
GROUP BY 1,2,3;


-- Question 3: Query to determine the highest grossing actors.
-- That is, actors that generate the most income. 


WITH t1 as 
		(SELECT (a.first_name || ' ' || a.last_name) actor, 
				p.amount
			FROM actor a 
			JOIN film_actor fa
			ON a.actor_id = fa.actor_id
			JOIN film f
			ON fa.film_id = f.film_id
			JOIN inventory i
			ON f.film_id = i.film_id
			JOIN rental r 
			ON i.inventory_id = r.inventory_id 
			JOIN payment p
			ON r.rental_id = p.rental_id)
			
SELECT DISTINCT actor,
				COUNT(actor) OVER (PARTITION BY actor) as rental_count, 
				SUM(amount) OVER (PARTITION BY actor) as income_generated
FROM t1 
ORDER BY 3 DESC
LIMIT 10;




