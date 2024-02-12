DELIMITER $$
CREATE FUNCTION ufn_count_employees_by_town(`name` VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    RETURN (SELECT count(*)
            FROM employees
                     JOIN addresses a on a.address_id = employees.address_id
                     JOIN towns t on t.town_id = a.town_id
            WHERE t.name = `name`);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE usp_select_employees(max_id INT)
BEGIN
    SELECT * FROM employees WHERE employee_id < max_id;
end $$
DELIMITER ;

CALL usp_select_employees(2);

DELIMITER $$
CREATE PROCEDURE ups_raise_salaries(percent DECIMAL(3, 2), OUT total_increase DECIMAL(19, 4))
BEGIN
    DECLARE local_increase DECIMAL(19, 4);
    SET local_increase := (SELECT ABS(SUM(salary) - SUM(salary) * percent) FROM employees);
    SET total_increase = local_increase;
    UPDATE employees SET salary = salary * percent;


END $$
DELIMITER ;
;

SET @increase = 0;
CALL ups_raise_salaries(1.1, @increase);

SELECT @increase;
DELIMITER $$
CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN
    START TRANSACTION ;
    IF ((SELECT count(employee_id) FROM employees WHERE employee_id LIKE id) <> 1) THEN
        ROLLBACK ;
    ELSE
        UPDATE employees AS e
        SET salary = salary + salary * 0.05
        WHERE employee_id = id;
    END IF;
END $$
DELIMITER ;
;

CREATE TABLE deleted_employees
(
    employee_id   INT PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    jop_title     VARCHAR(50),
    department_id int,
    hire_date     TIMESTAMP(6)
);
DELIMITER $$
CREATE TRIGGER tr_after_delete_employees
    AFTER DELETE
    ON employees
    FOR EACH ROW
BEGIN
    INSERT INTO deleted_employees
    VALUES (OLD.employee_id, OLD.first_name, OLD.last_name, OLD.job_title, OLD.department_id, OLD.hire_date);
END $$

DELETE
FROM employees
WHERE employee_id = 1;