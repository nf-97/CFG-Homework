-- Create stored procedures and stored functions for any database
-- Stored prodecures
USE practice;

DELIMITER //
CREATE PROCEDURE retrieveDBA()
BEGIN
 	SELECT *
    FROM practice.staff
    WHERE jobtitle = 'DBA';
END //
DELIMITER ;

CALL retrieveDBA();

USE PARTS;
DELIMITER // 
CREATE PROCEDURE LondonBased()
BEGIN
	SET @CityLondon = "London";
	SELECT J_ID AS "Project Name" FROM PROJECT AS PR
	WHERE CITY = @CityLondon AND
	J_ID IN
	(SELECT J_ID FROM SUPPLY AS SLY
	WHERE S_ID IN
	(SELECT S_ID FROM SUPPLIER AS SER
	WHERE CITY = @CityLondon));
END //
DELIMITER ;

CALL LondonBased();

-- Stored functions
USE BANK;

DELIMITER //
CREATE FUNCTION balanceCalc(currentBalance INT, tax INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE taxedBalance INT;
    SET taxedBalance = currentBalance - tax;
    RETURN taxedBalance;
END //
DELIMITER ;

SELECT *, balanceCalc(balance, 10) AS "Balance after tax"
FROM bank.Accounts
WHERE Account_number = 111112;

DELIMITER //
CREATE FUNCTION maxBalance(overdraftAllowed INT, balance INT)
RETURNS INT
DETERMINISTIC
BEGIN 
	DECLARE withOverdraft INT;
    IF overdraftAllowed = 1 
    THEN SET withOverdraft = balance + 500;
    ELSE 
    SET withOverdraft = balance;
    END IF;
    RETURN withOverdraft;
END //
DELIMITER ;

SELECT  *, maxBalance(AC.overdraft_allowed, AC.balance)
FROM Accounts AS AC;