USE iths;

DROP TABLE IF EXISTS UNF;

CREATE TABLE `UNF` (
    `Id` DECIMAL(38, 0) NOT NULL,
    `Name` VARCHAR(26) NOT NULL,
    `Grade` VARCHAR(11) NOT NULL,
    `Hobbies` VARCHAR(25),
    `City` VARCHAR(10) NOT NULL,
    `School` VARCHAR(30) NOT NULL,
    `HomePhone` VARCHAR(15),
    `JobPhone` VARCHAR(15),
    `MobilePhone1` VARCHAR(15),
    `MobilePhone2` VARCHAR(15)
)  ENGINE=INNODB;

LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv'
INTO TABLE UNF
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/* Normalisera Student */

DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
    StudentId INT NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (StudentId)
)  ENGINE=INNODB;

INSERT INTO Student (StudentId, FirstName, LastName) 
SELECT DISTINCT Id, SUBSTRING_INDEX(Name, ' ', 1), SUBSTRING_INDEX(Name, ' ', -1) 
FROM UNF;

/* Normalisera School */
DROP TABLE IF EXISTS School;
CREATE TABLE School AS SELECT DISTINCT 0 As SchoolId, School As Name, City FROM UNF;
SET @id = 0;
UPDATE School SET SchoolId =  (SELECT @id := @id + 1);
ALTER TABLE School ADD PRIMARY KEY(SchoolId);
ALTER TABLE School MODIFY COLUMN SchoolId Int AUTO_INCREMENT;
DROP TABLE IF EXISTS StudentSchool;

/*StudentSchool Tabell*/
CREATE TABLE StudentSchool AS SELECT DISTINCT UNF.Id AS StudentId, School.SchoolId
FROM UNF INNER JOIN School ON UNF.School = School.Name;
ALTER TABLE StudentSchool MODIFY COLUMN StudentId INT;
ALTER TABLE StudentSchool MODIFY COLUMN SchoolId INT;
ALTER TABLE StudentSchool ADD PRIMARY KEY(StudentId, SchoolId);
SELECT StudentId, FirstName, LastName FROM Student
JOIN StudentSchool USING (StudentId);
SELECT StudentId, FirstName, LastName, Name, City FROM Student
JOIN StudentSchool USING (StudentId) 
JOIN School USING (SchoolId);

/* Normalsiera Phones */

DROP TABLE IF EXISTS Phone;
CREATE TABLE Phone (
    PhoneId INT NOT NULL AUTO_INCREMENT,
    StudentId INT NOT NULL,
    Type VARCHAR(32),
    Number VARCHAR(32) NOT NULL,
    CONSTRAINT PRIMARY KEY(PhoneId)
);

INSERT INTO Phone(StudentId, Type, Number) 
SELECT ID As StudentId, "Home" AS Type, HomePhone as Number FROM UNF
WHERE HomePhone IS NOT NULL AND HomePhone != ''
UNION SELECT ID As StudentId, "Job" AS Type, JobPhone as Number FROM UNF
WHERE JobPhone IS NOT NULL AND JobPhone != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone1 as Number FROM UNF
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone2 as Number FROM UNF
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != ''
;
/*PhoneList View*/
DROP VIEW IF EXISTS PhoneList;
CREATE VIEW PhoneList AS SELECT CONCAT(FirstName, ' ', LastName) as Name, group_concat(Number) AS Numbers FROM Phone JOIN Student using(StudentId) GROUP BY StudentId;
/* School Hobby */

DROP TABLE IF EXISTS Hobby;
CREATE TABLE Hobby(
HobbyId INT NOT NULL AUTO_INCREMENT,
Name VARCHAR (100) NOT NULL,
CONSTRAINT PRIMARY KEY(HobbyId)
)ENGINE = INNODB;
INSERT INTO Hobby(Name)
 SELECT  trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF WHERE Hobbies != '' AND Hobbies != 'Nothing'
UNION
SELECT trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) AS Hobby FROM UNF WHERE Hobbies != '' AND Hobbies != 'Nothing'
UNION
SELECT trim(substring_index(Hobbies, ",", -1)) AS Hobby FROM UNF WHERE Hobbies != '' AND Hobbies != 'Nothing';


/* School StudentHobby */

DROP TABLE IF EXISTS StudentHobby;
CREATE TABLE StudentHobby(
HobbyId INT NOT NULL ,
StudentId INT NOT NULL,
CONSTRAINT PRIMARY KEY(HobbyId, StudentId)
);

INSERT INTO StudentHobby(StudentId, HobbyId)
SELECT StudentIdHobbyName.Id, Hobby.HobbyId FROM
( SELECT Id, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF
UNION SELECT  Id, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) AS Hobby FROM UNF
UNION SELECT Id, trim(substring_index(Hobbies, ",", -1)) AS Hobby FROM UNF) AS StudentIdHobbyName
JOIN Hobby ON Hobby.Name = StudentIdHobbyName.Hobby;

/*Grade*/
SELECT DISTINCT Grade FROM UNF;

DROP TABLE IF EXISTS Grade;
CREATE TABLE Grade (
    GradeId INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (GradeId)
)  ENGINE=INNODB;

INSERT INTO Grade(Name) 
SELECT DISTINCT Grade FROM UNF;

ALTER TABLE Student ADD COLUMN GradeId INT NOT NULL;

UPDATE Student JOIN UNF ON (StudentID = Id) JOIN Grade ON Grade.Name = UNF.Grade 
SET  Student.GradeId =  Grade.GradeId;

/* GRUND TABELL */
SELECT StudentId as ID  FROM StudentSchool;

/* LEFT JOIN 1 */
SELECT StudentId as ID, Student.Name FROM StudentSchool 
LEFT JOIN Student USING (StudentId);

/* LEFT JOIN 2 */
SELECT StudentId as ID, Student.Name, Grade.Name AS Grade FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId);


/* LEFT JOIN 3 */
SELECT StudentId as ID, Student.Name, Grade.Name AS Grade, Hobbies FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentID);

/* LEFT JOIN 4 */
SELECT StudentId as ID, Student.Name, Grade.Name AS Grade, Hobbies, School.Name AS School, City FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentID)
LEFT JOIN School USING (SchoolId);

/* LEFT JOIN 5 */
SELECT StudentId as ID, Student.Name, Grade.Name AS Grade, Hobbies, School.Name AS School, City, Numbers FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentId)
LEFT JOIN School USING (SchoolId)
LEFT JOIN PhoneList USING (StudentId);


DROP VIEW IF EXISTS AVSLUT;
CREATE VIEW AVSLUT AS
SELECT StudentId as ID, Student.Name, Grade.Name AS Grade, Hobbies, School.Name AS School, City, Numbers FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentId)
LEFT JOIN School USING (SchoolId)
LEFT JOIN PhoneList USING (StudentId);





