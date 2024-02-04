# first exer
SELECT d.manager_id                       AS employee_id,
       CONCAT(first_name, ' ', last_name) AS full_name,
       d.department_id,
       d.name                             AS department_name
FROM departments AS d
         JOIN employees AS a ON d.manager_id = a.employee_id
ORDER BY a.employee_id
LIMIT 5;

# fourth exer

SELECT count(*)
FROM employees AS e

WHERE salary > (SELECT AVG(e1.salary)
                FROM employees AS e1);

# second exer

SELECT a.town_id,
       t.name,
       address_text
FROM addresses AS a
         JOIN towns AS t ON t.town_id = a.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY t.town_id, a.address_id;

# third Exer
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_id,
    e.salary

FROM employees AS e
         RIGHT JOIN
    departments AS d ON e.department_id = d.department_id
WHERE e.manager_id IS NULL;