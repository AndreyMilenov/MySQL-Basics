CREATE DATABASE mountains;
USE mountains;
CREATE TABLE mountains(
    id INT AUTO_INCREMENT NOT NULL ,
    `name` VARCHAR(100) NOT NULL ,
    CONSTRAINT `pk_mountains_id` PRIMARY KEY (id)
);

INSERT INTO mountains(`name`) VALUES ('Rila'),('Pirin');

CREATE TABLE peaks
(
    id          INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name`      VARCHAR(100)       NOT NULL,
    mountain_id INT                NOT NULL,
    CONSTRAINT `fk__peaks_mountain_id__mountains_id`
        FOREIGN KEY (mountain_id)
            REFERENCES mountains (id)

);

INSERT INTO peaks(`name`,mountain_id)
VALUES ('Musala',1),('Vihren',2);

SELECT p.id,
       p.name,
       mountains.name
FROM peaks AS p
         JOIN mountains ON p.mountain_id = mountains.id;

USE camp;

SELECT driver_id,
       vehicle_type,
       CONCAT(first_name,' ',last_name) AS 'driver_name'
FROM vehicles
         JOIN campers ON driver_id = campers.id;

USE mountains;
DROP TABLE mountains;
DROP TABLE peaks;

CREATE TABLE mountains
(
    id     INT AUTO_INCREMENT NOT NULL,
    `name` VARCHAR(100)       NOT NULL,
    CONSTRAINT `pk_mountains_id` PRIMARY KEY (id)
);

CREATE TABLE peaks
(
    id          INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    `name`      VARCHAR(100)       NOT NULL,
    mountain_id INT                NOT NULL,
        CONSTRAINT `fk_peaks_mountain_id_mountains_id`
        FOREIGN KEY (mountain_id)
        REFERENCES mountains (id)
        ON DELETE CASCADE
);

SELECT starting_point, end_point, leader_id, CONCAT(first_name,' ', last_name) AS 'leader_name'
FROM routes
         JOIN campers ON routes.leader_id = campers.id;





