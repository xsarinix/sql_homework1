use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select concat(first_name, ' ', last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name="Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

select actor_id, first_name, last_name from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select actor_id, first_name, last_name from actor where last_name like "%LI%" order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor add description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

alter table actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select count(actor_id) as 'Actor Count', last_name as 'Last Name' from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select count(actor_id) as 'Actor Count', last_name as 'Last Name' from actor group by last_name having count(actor_id)>1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor set first_name = 'GROUCHO' where first_name='HARPO' and last_name='WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select concat(staff.first_name, " ", staff.last_name) as 'Name', address.address as 'Address' from address
inner join staff on 
staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select concat(staff.first_name, " ", staff.last_name) as 'Name', sum(payment.amount) as 'Total Sales' 
from staff
 inner join payment 
 on staff.staff_id=payment.staff_id
 group by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select film.title as 'Title', count(film_actor.actor_id) as 'Total Actors'
from film
inner join film_actor
on film.film_id=film_actor.film_id
group by film_actor.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select film.title as 'Title', count(inventory.film_id) as '# of Copies'
from film
inner join inventory
on film.film_id=inventory.film_id
group by inventory.film_id
having film.title="HUNCHBACK IMPOSSIBLE";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select concat(customer.last_name, ", ", customer.first_name) as 'Name', sum(payment.amount) as 'Total Paid'
from customer
inner join payment
on customer.customer_id=payment.customer_id
group by payment.customer_id
order by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title from film where title like "K%" or title like "Q%" and language_id in
(
	select language_id from language where name in ("English")
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select concat(first_name, " ", last_name) as 'Actors in Alone Trip' from actor where actor_id in
(
	select actor_id from film_actor where film_id in
    (
		select film_id from film where title='ALONE TRIP'
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select concat(customer.first_name, " ", customer.last_name) as 'Name', customer.email as 'Email', country.country as 'Country'
from customer
inner join address
on customer.address_id=address.address_id
inner join city
on address.city_id=city.city_id
inner join country
on city.country_id=country.country_id
having country="CANADA";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select film.title, category.name as 'Title'
from film
left join film_category
on film.film_id=film_category.film_id
left join category
on film_category.category_id=category.category_id
having category.name="Family";

-- 7e. Display the most frequently rented movies in descending order.

select film.title as 'Title', count(rental.rental_id) '# of Rentals'
from film
inner join inventory
on film.film_id=inventory.film_id
inner join rental
on inventory.inventory_id=rental.inventory_id
group by rental.inventory_id
order by count(rental.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id as 'Store ID', sum(payment.amount) as 'Total Revenue'
from store
inner join staff
on store.store_id=staff.store_id
inner join payment
on staff.staff_id=payment.staff_id
group by staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id as 'Store ID', city.city as 'City', country.country as 'Country'
from store
inner join address
on store.address_id=address.address_id
inner join city
on address.city_id=city.city_id
inner join country
on city.country_id=country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select category.name as 'Genre', sum(payment.amount) as 'Gross Revenue'
from category
inner join film_category
on category.category_id=film_category.category_id
inner join inventory
on film_category.film_id=inventory.film_id
inner join rental
on inventory.inventory_id=rental.inventory_id
inner join payment
on rental.rental_id=payment.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres as
select category.name as 'Genre', sum(payment.amount) as 'Gross Revenue'
from category
inner join film_category
on category.category_id=film_category.category_id
inner join inventory
on film_category.film_id=inventory.film_id
inner join rental
on inventory.inventory_id=rental.inventory_id
inner join payment
on rental.rental_id=payment.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_five_genres;
