-- Homework
-- Find the name and status of each supplier who supplies project J2
SELECT DISTINCT SER.SNAME AS SupplierName, SER.STATUS AS Status, SLY.J_ID AS J, SER.S_ID AS SupplierID
FROM SUPPLIER AS SER
LEFT JOIN SUPPLY AS SLY
ON SER.S_ID = SLY.S_ID
WHERE SLY.J_ID = "J2";
 
SELECT SUPPLIER.SNAME, SUPPLIER.STATUS
FROM SUPPLIER
WHERE S_ID IN 
(SELECT S_ID 
FROM SUPPLY
WHERE J_ID = 'J2');

--  Find the name and city of each project supplied by a London-based supplier
SELECT DISTINCT P.JNAME AS "Project Name", P.CITY AS "Project City"
FROM SUPPLY AS SLY
LEFT JOIN SUPPLIER AS SER
ON SLY.S_ID = SER.S_ID
LEFT JOIN PROJECT AS P
ON SLY.J_ID = P.J_ID
WHERE SER.CITY = "London";

SELECT PR.JNAME AS PROJECTNAME, PR.CITY AS PRCITY
FROM PROJECT AS PR
WHERE J_ID IN 
(SELECT J_ID 
FROM SUPPLY AS SLY
WHERE S_ID IN 
(SELECT S_ID 
FROM SUPPLIER AS SER
WHERE SER.CITY = "London"));

--  Find the name and city of each project not supplied by a London-based supplier
SELECT PR.JNAME AS PROJECTNAME, PR.CITY AS PRCITY, PR.J_ID 
FROM PROJECT AS PR
WHERE J_ID NOT IN 
(SELECT J_ID 
FROM SUPPLY AS SLY
WHERE S_ID IN 
(SELECT S_ID 
FROM SUPPLIER AS SER
WHERE SER.CITY = "London"));


-- Find the supplier name, part name and project name for each case where a supplier supplies a project with a part, but also the supplier city, project city and part city are the same
SELECT DISTINCT SER.SNAME AS "Supplier Name", PA.PNAME AS "Part Name", PR.JNAME AS "Project Name"
FROM SUPPLY AS SLY
LEFT JOIN PART AS PA
ON SLY.P_ID = PA.P_ID
LEFT JOIN SUPPLIER AS SER
ON SLY.S_ID = SER.S_ID
LEFT JOIN PROJECT AS PR
ON SLY.J_ID = PR.J_ID
WHERE SER.CITY = PA.CITY
AND PR.CITY = PA.CITY;