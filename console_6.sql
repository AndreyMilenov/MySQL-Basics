# first Exercise.
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
    SELECT `first_name`,
           `last_name`
    FROM employees AS e
    WHERE `salary` > 35000
    ORDER BY `first_name`, `last_name`, `employee_id`;
END $$
# second Exercise.
CREATE PROCEDURE usp_get_employees_salary_above(`target_salary` DECIMAL(19, 4))
BEGIN
    SELECT `first_name`,
           `last_name`
    FROM employees AS e
    WHERE `salary` >= target_salary
    ORDER BY `first_name`, `last_name`, `employee_id`;
END $$
#thirdt Exercise
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with(`starting_text` VARCHAR(50))
BEGIN
    SELECT `name`
    FROM towns
    WHERE `name` LIKE CONCAT(starting_text, '%')
    ORDER BY name;
END $$
#fourth Exercise
CREATE PROCEDURE usp_get_employees_from_town(searched_town VARCHAR(50))
BEGIN
    SELECT `first_name`, `last_name`
    FROM employees
             JOIN addresses AS a USING (`address_id`)
             JOIN towns AS t USING (town_id)
    WHERE t.name = searched_town
    ORDER BY first_name, last_name;
END $$

#fift Exercise
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19, 4))
    RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE `salary_level` VARCHAR(10);
    IF salary < 30000 THEN
        SET `salary_level` := 'Low';
    ELSEIF salary <= 50000 THEN
        SET salary_level := 'Average';
    ELSE
        SET salary_level := 'High';
    END IF;
    RETURN salary_level;
END;

# sixth Exercise
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(10))
BEGIN
    SELECT `first_name`, `last_name`
    FROM employees
    WHERE ufn_get_salary_level(`salary`) = salary_level
    ORDER BY first_name DESC, last_name DESC;
END;
#sevent Exercise
CREATE FUNCTION ufn_is_word_comprised(`set_of_letters` VARCHAR(50), word VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    RETURN word REGEXP (concat('^[', set_of_letters, ']+$'));

END $$

# eight Exercise
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
    SELECT CONCAT(`first_name`, ' ', `last_name`) AS 'full_name'
    FROM `account_holders`
    ORDER BY `full_name`, `id`;
END $$
# ninth Exercise
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(money DECIMAL(19, 4))
BEGIN
    SELECT ah.`first_name`, ah.`last_name`
    FROM account_holders AS ah
             LEFT JOIN accounts AS a ON ah.id = a.account_holder_id
    GROUP BY ah.`first_name`, ah.`last_name`, a.account_holder_id
    HAVING SUM(a.balance) > money
    ORDER BY a.`account_holder_id`;
END $$
# tenth Exercise
CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19, 4), yearly_rate DOUBLE, years INT)
    RETURNS DECIMAL(19, 4)
    DETERMINISTIC
BEGIN
    DECLARE future_sum DECIMAL(19, 4);
    SET future_sum := sum * POW(1 + yearly_rate, years);
    RETURN future_sum;
END $$
# eleventh Exercise
CREATE PROCEDURE usp_calculate_future_value_for_account(`id` INT, `rate` DECIMAL(19, 4))
BEGIN
    SELECT a.`id`                                         AS account_id,
           ah.`first_name`                                AS first_name,
           ah.`last_name`                                 AS last_name,
           a.`balance`                                    AS current_balance,
           ufn_calculate_future_value(a.balance, rate, 5) AS balace_in_5_years
    FROM account_holders AS ah
             JOIN accounts AS a ON ah.id = a.account_holder_id
    WHERE a.`id` = id;
END $$
# twelfth Exercise
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
    START TRANSACTION;
    IF (money_amount <= 0) THEN
        ROLLBACK;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` + money_amount
        WHERE `id` = account_id;
        COMMIT;
    END IF;
END $$

# thirteenth Exercise
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
    START TRANSACTION;
    IF (money_amount <= 0 OR (SELECT `balance` FROM accounts WHERE id = account_id) < money_amount) THEN
        ROLLBACK;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` - money_amount
        WHERE `id` = account_id;
        COMMIT;
    END IF;
END $$

# fourteenth Exercise
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19, 4))
BEGIN
    START TRANSACTION;
    IF from_account_id = to_account_id OR
       amount <= 0 OR
       (SELECT `balance` FROM accounts WHERE `id` = from_account_id) < amount OR
       (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = from_account_id) <> 1 OR
       (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = to_account_id) <> 1
    THEN
        ROLLBACK ;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` - amount
        WHERE `id` = from_account_id;
        UPDATE `accounts`
        SET `balance` = `balance` + amount
        WHERE `id` = to_account_id;
        COMMIT;
    END IF;
END $$
# fifteenth Exercise
CREATE TABLE logs
(
    `log_id`     INT PRIMARY KEY AUTO_INCREMENT,
    `account_id` INT            NOT NULL,
    `old_sum`    DECIMAL(19, 4) NOT NULL,
    `new_sum`    DECIMAL(19, 4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_change_balance_account
    AFTER UPDATE
    ON `accounts`
    FOR EACH ROW
BEGIN
    INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`)
    VALUES (OLD.`id`, OLD.`balance`, NEW.`balance`);

END $$
# sixteenth Exercise
CREATE TABLE notification_emails
(
    `id`        INT PRIMARY KEY AUTO_INCREMENT,
    `recipient` INT NOT NULL,
    `subject`   TEXT,
    `body`      TEXT
);
DELIMITER $$
CREATE TRIGGER tr_email_on_insert
    AFTER INSERT ON `logs`
    FOR EACH ROW

BEGIN
    INSERT INTO `notification_emails`(`recipient`, `subject`, `body`)
    VALUES (NEW.`account_id`,
            CONCAT('Balance change for account: ', `account_id`),
            CONCAT('On ', NOW(), ' your balance was changed from ', NEW.`old_sum`, ' to ', NEW.`new_sum`, '.'));

END $$
