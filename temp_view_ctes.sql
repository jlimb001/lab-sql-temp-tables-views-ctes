USE sakila;
SELECT * FROM customer; 	

-- Creating a customer support report
-- Creating a view : it should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_support_report AS
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        a.address,
        ci.city,
        co.country,
        c.active
    FROM
        customer c
            JOIN
        address a ON c.address_id = a.address_id
            JOIN
        city ci ON a.city_id = ci.city_id
            JOIN
        country co ON ci.country_id = co.country_id;

-- Step 2:Create a Temporary Table
WITH rental_summary AS (
	SELECT 
		customer_id, 
		COUNT(*) AS total_rentals, 
        MAX(rental_date) AS last_rental_date
FROM
	rental
GROUP BY 
	customer_id
)
SELECT * FROM rental_summary;

-- Step 3: Create a CTE and the Customer Summary Report
CREATE TEMPORARY TABLE payment_summary AS
SELECT customer_id, COUNT(*) AS total_payments, SUM(amount) AS total_amount_paid, MAX(payment_date) AS last_payment_date
FROM payment
GROUP BY customer_id;

SELECT 
    cs.customer_id,
    cs.first_name,
    cs.last_name,
    cs.email,
    cs.address,
    cs.city,
    cs.country,
    cs.active,
    COALESCE(rs.total_rents, 0) AS total_rentals,
    rs.last_rental_date,
    COALESCE(ps.total_payments, 0) AS total_payments,
    COALESCE(ps.total_amount_paid, 0.00) AS total_amount_paid,
    ps.last_payment_date
FROM
    customer_support_report cs
        LEFT JOIN
    rental_summary rs ON cs.customer_id = rs.customer_id
        LEFT JOIN
    payment_summary ps ON cs.customer_id = ps.customer_id
ORDER BY ccs.customer_id;

