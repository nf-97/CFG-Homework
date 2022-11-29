-- create database
CREATE DATABASE canal_surveys;
USE canal_surveys;

-- create tables
CREATE TABLE sections
(id INT,
grid_ref VARCHAR(30));

CREATE TABLE section_data
(section_id INT,
survey_id INT,
shading_percentage NUMERIC(3), 
depth_cm INT,
bank_type ENUM("vegetated", "unvegetated", "partially vegetated"));

ALTER TABLE section_data
MODIFY COLUMN depth_cm FLOAT;

CREATE TABLE surveyors
(id INT,
first_name VARCHAR(50),
last_name VARCHAR(50),
contact_number VARCHAR(50),
email VARCHAR(50),
company VARCHAR(50)); 

ALTER TABLE surveyors 
MODIFY COLUMN first_name VARCHAR(50) NOT NULL, 
MODIFY COLUMN last_name VARCHAR(50) NOT NULL, 
MODIFY COLUMN company VARCHAR(50) NOT NULL;

CREATE TABLE surveys
(id INT,
surveyor_id INT,
avg_temp INT,
avg_cloud_cover NUMERIC(3),
avg_rainfall ENUM("heavy", "moderate", "light"),
date_time DATETIME);

ALTER TABLE surveys
RENAME COLUMN avg_cloud_cover TO avg_percentage_cloud_cover;

ALTER TABLE surveys
MODIFY COLUMN surveyor_id INT NOT NULL, 
MODIFY COLUMN date_time DATETIME NOT NULL,
MODIFY COLUMN avg_rainfall ENUM("heavy", "moderate", "light", "dry");

CREATE TABLE plant_data
(section_id INT NOT NULL,
survey_id INT NOT NULL,
common_name VARCHAR(50) NOT NULL,
scientific_name VARCHAR(50) NOT NULL,
invasive BOOLEAN NOT NULL,
abundance ENUM("dominant", "abundant", "frequent", "occasional", "rare") NOT NULL);

-- define primary keys
ALTER TABLE sections
ADD CONSTRAINT PK_id
PRIMARY KEY(id);

ALTER TABLE surveys
ADD CONSTRAINT PK_id
PRIMARY KEY(id);

ALTER TABLE surveyors
ADD CONSTRAINT PK_id
PRIMARY KEY(id);

-- define foreign keys
ALTER TABLE section_data
ADD CONSTRAINT FK_section_id_section_data
FOREIGN KEY(section_id)
REFERENCES sections(id);

ALTER TABLE surveys
ADD CONSTRAINT FK_surveyor_id
FOREIGN KEY(surveyor_id)
REFERENCES surveyors(id);

ALTER TABLE section_data
ADD CONSTRAINT FK_survey_id_section_data
FOREIGN KEY(survey_id)
REFERENCES surveys(id);

ALTER TABLE plant_data
ADD CONSTRAINT FK_section_id_plant_data
FOREIGN KEY(section_id)
REFERENCES sections(id);

ALTER TABLE plant_data
ADD CONSTRAINT FK_survey_id_plant_data
FOREIGN KEY(survey_id)
REFERENCES surveys(id);

-- add values into tables
INSERT INTO sections
VALUES
(1, "SK 23451 12123"),
(2, "SK 25467 78234");

SELECT * FROM sections;

INSERT INTO surveyors
VALUES
(1, "John", "Smith", "+44 827012348", "john.smith@hotmail.com", "The Ecology Company"),
(2, "Rebecca", "Black", "01210127590", "rebecca.black@aol.com", "Fan of Nature ltd");

-- need safe mode off for code below
UPDATE surveyors
SET company =  "Fan of Nature LTD."
WHERE company = "Fan of Nature ltd";

SELECT * FROM surveyors;

INSERT INTO surveys
VALUES 
(1, 1, 27, 22, "light", "2021-09-02 12:45:21"),
(2, 2, 22, 75, "dry", "2022-09-27 14:21:56");

SELECT * FROM surveys;

INSERT INTO section_data
VALUES
(1, 1, 52, 240, "unvegetated"),
(1, 2, 58, 231, "partially vegetated"),
(2, 1, 10, 132.5, "vegetated"),
(2, 2, 10, 133, "vegetated");

SELECT * FROM section_data;

INSERT INTO plant_data
VALUES
(1, 1, "white lily pad", "liliosa snowpad", 0, "frequent"),
(1, 1, "white flower", "flora blanc", 0, "frequent"),
(1, 2, "white lily pad", "liliosa snowpad", 0, "occasional"),
(1, 2, "white flower", "flora blanc", 0, "occasional"), 
(1, 2, "small flower", "flora smol", 0, "abundant"), 
(2, 1, "chunky algae", "algae chungos", 0, "frequent"),
(2, 1, "purple lily pad", "lilosa purpeapad", 0, "frequent"), 
(2, 1, "long weed", "weedio longue", 1, "rare"), 
(2, 2, "long weed", "weedio longue", 1, "dominant");

SELECT * FROM plant_data pd
WHERE pd.common_name LIKE "w_i%"
AND pd.abundance LIKE "%l";

-- use a join to create a view that creates multiple tables in a logical way
-- the client wants to see the species that were present in section 1 of the canal in survey 1, and the grid reference of section 1, and relevant surveyor's email and company name
CREATE VIEW vw_pd_sct1_svy1 AS
SELECT DISTINCT pd.common_name AS "common name", pd.scientific_name AS "scientific name", sct.grid_ref AS "grid reference", svor.email, svor.company
FROM plant_data AS pd
LEFT JOIN sections AS sct
ON pd.section_id = sct.id
LEFT JOIN surveys AS svy
ON pd.survey_id = svy.id
LEFT JOIN surveyors AS svor
ON svy.surveyor_id = svor.id
WHERE pd.section_id = 1 AND pd.survey_id = 1;

SELECT * FROM vw_pd_sct1_svy1;

-- create a stored function that can be applied to a query in your DB
-- the client wants to see if a species is invasive in 'yes' or 'no' rather than 1 or 0 as it's easier to understand
DELIMITER //
CREATE FUNCTION is_invasive(invasive_status BOOLEAN)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN 
	DECLARE invasive_outcome VARCHAR(10);
    IF invasive_status = 1 
    THEN SET invasive_outcome = "yes";
    ELSE 
    SET invasive_outcome = "no";
    END IF;
    RETURN invasive_outcome;
END //
DELIMITER ;

SELECT DISTINCT pd.common_name, pd.scientific_name, is_invasive(pd.invasive) AS "is it invasive?"
FROM plant_data AS pd
WHERE common_name = 'long weed';

-- prepare an example query with a subquery to demonstrate how to extract data from your DB for analysis
-- the client wants to see which surveyor (and the surveyors corresponding company) did survey 2
SELECT svor.first_name, svor.last_name, svor.company FROM surveyors AS svor
WHERE svor.id IN 
	(SELECT svy.surveyor_id 
	FROM surveys as svy
    WHERE id = 2);

-- another subquery example
-- the client wants to see the average depth of all canal sections where plants have been recorded as 'occassional', 
SELECT AVG(sd.depth_cm)
FROM section_data sd 
WHERE sd.section_id IN
	(SELECT pd.section_id 
    FROM plant_data pd
    WHERE pd.abundance = "occasional");
    
-- create a stored procedure and demonstrate how it runs
-- the client wants to be able to see the common name, scientific name and abundance from seperate surveys, and also see the depth, bank type, and shading of each section. 
DELIMITER //
CREATE PROCEDURE specific_survey_data(survey_number INT)
BEGIN
	SELECT DISTINCT pd.common_name AS "common name", pd.scientific_name AS "scientific name", pd.abundance, sd.depth_cm AS "depth (cm)", sd.shading_percentage AS "shading (%)", sd.bank_type AS "canal bank type", sd.section_id as "section"
	FROM plant_data pd
	LEFT JOIN section_data sd
	ON pd.section_id = sd.section_id
	WHERE pd.survey_id = survey_number AND sd.survey_id = survey_number;
END //
DELIMITER ;

-- this query gets data for only survey number 2
CALL specific_survey_data(2);

-- in your database, create a trigger and demonstrate how it runs
-- below, a trigger is created which prevents the user from entering an average cloud cover percentage of > 100 into the surveys table
DELIMITER //
CREATE TRIGGER avg_percentage_cloud_cover_bi BEFORE INSERT
ON surveys
FOR EACH ROW 
IF NEW.avg_percentage_cloud_cover > 100 THEN
SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Value must be 100 or less";
END IF; //
DELIMITER ;

-- below the user attempts to insert an average cloud cover percentage value of > 100 (avg_percentage_cloud_cover = 123)
INSERT INTO surveys
VALUES 
(3, 1, 21, 123, "dry", "2023-06-06 10:09:21");
-- as a result, SQL returns "Error Code: 1644. Value must be 100 or less"

-- create a view that uses at least 3-4 base tables; prepare and demonstrate a query that uses the view to produce a logically arranged result set for analysis.
-- the client wants to see the canal depths, plant common name, abundance, date and time and surveyor phone number within a view
CREATE VIEW four_table_view AS
SELECT DISTINCT sd.depth_cm, pd.common_name, pd.abundance, svy.date_time, svor.first_name, svor.last_name
FROM plant_data as pd
LEFT JOIN surveys as svy
ON pd.survey_id = svy.id
LEFT JOIN section_data as sd
ON pd.section_id = sd.section_id
LEFT JOIN surveyors as svor
ON svy.surveyor_id = svor.id;

-- demonstrate a query that uses the view to produce a logically arranged result set for analysis
-- the client wants to use the view to see abundant and frequent plants where the canal depth is > 200 cm
SELECT depth_cm AS "canal depth (cm)", abundance
FROM four_table_view 
WHERE abundance IN("abundant", "frequent")
AND depth_cm > 200
ORDER BY depth_cm ASC;

-- the client also wants to see the maximum depth recorded by John Smith
SELECT MAX(depth_cm) AS "maximum canal depth (cm)"
FROM four_table_view
WHERE first_name = "John" AND last_name = "Smith";

-- prepare an example query with group by and having to demonstrate how to extract data from your DB for analysis
-- the client wants to know which surveys had a count of plants >= 5
SELECT survey_id AS "survey id", COUNT(pd.survey_id) AS "number of plants recorded"
FROM plant_data pd
GROUP BY survey_id
HAVING COUNT(pd.survey_id) >= 5; 