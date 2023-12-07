use sakila;
-- 1. **Join Practice:**
-- Write a query to display the customer's first name, last name, email, and city they live in.
SELECT c.first_name, c.last_name, c.email, ci.city
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id;

-- 2. **Subquery Practice (Single Row):**
-- 2)Retrieve the film title, description, and release year for the film that has the longest duration.
SELECT title, description, release_year
FROM film
WHERE length = (
    SELECT MAX(length)
    FROM film
);
-- 3)List the customer name, rental date, and film title for each rental made. Include customers who have never
-- rented a film.

SELECT c.first_name, c.last_name, r.rental_date, f.title
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id;


-- 4)4. **Subquery Practice (Multiple Rows):**
-- Find the number of actors for each film. Display the film title and the number of actors for each film.

SELECT f.title AS film_title, COUNT(fa.actor_id) AS num_actors
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;

-- 5)Display the first name, last name, and email of customers along with the rental date, film title, and rental
-- return date.
SELECT c.first_name, c.last_name, c.email, r.rental_date, f.title AS film_title, rr.return_date AS rental_return_date
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
LEFT JOIN rental rr ON r.rental_id = rr.rental_id;

-- 6) Retrieve the film titles that are rented by customers whose email domain ends with '.net'.
SELECT DISTINCT f.title AS film_title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE SUBSTRING_INDEX(c.email, '@', -1) = 'net';

-- 7)Show the total number of rentals made by each customer, along with their first and last names.
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS total_rentals
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;
-- 8)List the customers who have made more rentals than the average number of rentals made by all
-- customers.
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS total_rentals
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) > (
    SELECT AVG(rental_count)
    FROM (
        SELECT COUNT(rental_id) AS rental_count
        FROM rental
        GROUP BY customer_id
    ) AS avg_rentals
);

-- 9)Display the customer first name, last name, and email along with the names of other customers living in
-- the same city.
SELECT
    c1.first_name AS customer_first_name,
    c1.last_name AS customer_last_name,
    c1.email AS customer_email,
    c2.first_name AS other_customer_first_name,
    c2.last_name AS other_customer_last_name
FROM
    customer c1
JOIN
    address a1 ON c1.address_id = a1.address_id
JOIN
    city ci ON a1.city_id = ci.city_id
JOIN
    address a2 ON a1.city_id = a2.city_id
JOIN
    customer c2 ON a2.address_id = c2.address_id
WHERE
    c1.customer_id != c2.customer_id
    AND c1.customer_id < c2.customer_id;

-- 10)Retrieve the film titles with a rental rate higher than the average rental rate of films in the same category.
SELECT f.title AS film_title, f.rental_rate
FROM film f
WHERE f.rental_rate > (
    SELECT AVG(f2.rental_rate)
    FROM film f2
    JOIN film_category fc ON f2.film_id = fc.film_id
    WHERE fc.category_id IN (
        SELECT fc2.category_id
        FROM film_category fc2
        WHERE fc2.film_id = f.film_id
    )
);

-- 11)Retrieve the film titles along with their descriptions and lengths that have a rental rate greater than the
-- average rental rate of films released in the same year.
SELECT f.title AS film_title, f.description, f.length
FROM film f
WHERE f.rental_rate > (
    SELECT AVG(f2.rental_rate)
    FROM film f2
    WHERE YEAR(f2.release_year) = YEAR(f.release_year)
);

-- 12)List the first name, last name, and email of customers who have rented at least one film in the
-- 'Documentary' category.
SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Documentary';

-- 13)Show the title, rental rate, and difference from the average rental rate for each film.
SELECT
    title,
    rental_rate,
    rental_rate - avg_rental_rate AS difference_from_average
FROM
    film,
    (SELECT AVG(rental_rate) AS avg_rental_rate FROM film) AS average_rates;
    
-- 14)Retrieve the titles of films that have never been rented.
SELECT title
FROM film
WHERE film_id NOT IN (SELECT DISTINCT film_id FROM rental);

-- 15)List the titles of films whose rental rate is higher than the average rental rate of films released in the same
-- year and belong to the 'Sci-Fi' category.

SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE f.rental_rate > (
    SELECT AVG(f2.rental_rate)
    FROM film f2
    JOIN film_category fc2 ON f2.film_id = fc2.film_id
    JOIN category c2 ON fc2.category_id = c2.category_id
    WHERE c2.name = 'Sci-Fi' AND YEAR(f2.release_year) = YEAR(f.release_year)
) AND c.name = 'Sci-Fi';

-- 16)Find the number of films rented by each customer, excluding customers who have rented fewer than five
-- films.

SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS num_films_rented
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) >= 5;


