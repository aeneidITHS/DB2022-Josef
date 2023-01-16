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

DESC UNF;

LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv'
INTO TABLE UNF 
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
/*Student*/

SELECT SUBSTRING_INDEX(Name, ' ', 1) AS FirstName, SUBSTRING_INDEX(Name, ' ', -1) AS LastName FROM UNF;

DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
    StudentId INT NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY (StudentId)
)  ENGINE=INNODB;

INSERT INTO Student(StudentId, FirstName, LastName) 
SELECT DISTINCT ID, SUBSTRING_INDEX(Name, ' ', 1), SUBSTRING_INDEX(Name, ' ', -1)
FROM UNF;

/*Phones*/

DROP TABLE IF EXISTS Phone;
CREATE TABLE Phone(
	PhoneId INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	StudentId INT NOT NULL,
	Type VARCHAR(32),
	Number VARCHAR(32) NOT NULL
)ENGINE=INNODB;


INSERT INTO Phone(StudentId,Type,Number)
SELECT Id AS StudentId, "Home" AS Type, HomePhone AS Number FROM UNF
WHERE HomePhone IS NOT NULL AND HomePhone != ''
UNION SELECT Id AS StudentId, "Job" AS Type, JobPhone AS Number FROM UNF
WHERE JobPhone IS NOT NULL AND JobPhone != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone1 as Number FROM UNF
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone2 as Number FROM UNF
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != '';


DROP VIEW IF EXISTS PhoneList;
CREATE VIEW PhoneList AS SELECT StudentId, group_concat(Number) AS Numbers FROM Phone GROUP BY StudentId;

/*School*/

DROP TABLE IF EXISTS School;
CREATE TABLE School AS SELECT DISTINCT 0 As SchoolId, School As Name, City FROM UNF;
SET @id = 0;
UPDATE School SET SchoolId =  (SELECT @id := @id + 1);
ALTER TABLE School ADD PRIMARY KEY(SchoolId);
ALTER TABLE School MODIFY COLUMN SchoolId Int AUTO_INCREMENT;/*StudentSchool*/
DROP TABLE IF EXISTS StudentSchool;
CREATE TABLE StudentSchool AS SELECT DISTINCT UNF.Id AS StudentId, School.SchoolId
FROM UNF INNER JOIN School ON UNF.School = School.Name;
ALTER TABLE StudentSchool MODIFY COLUMN StudentId INT;
ALTER TABLE StudentSchool MODIFY COLUMN SchoolId INT;
ALTER TABLE StudentSchool ADD PRIMARY KEY(StudentId, SchoolId);
SELECT StudentId, FirstName, LastName FROM Student
JOIN StudentSchool USING (StudentId);

/*Hobbies*/
DROP TABLE IF EXISTS StudentHobby;
DROP VIEW IF EXISTS StudentHobby;
CREATE VIEW StudentHobby AS
SELECT Id AS StudentId, TRIM(SUBSTRING_INDEX(Hobbies, ',' , 1)) AS Hobby FROM UNF
UNION SELECT Id AS StudentId, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Hobbies, ',' ,-2), ',' ,1)) AS Hobby FROM UNF
UNION SELECT Id AS StudentId, TRIM(SUBSTRING_INDEX(Hobbies, ',' , -1)) AS Hobby FROM UNF;
DROP TABLE IF EXISTS Hobbies;
CREATE TABLE Hobbies(
	Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	Hobby VARCHAR(40) NOT NULL
)ENGINE=INNODB;

INSERT INTO Hobbies(Hobby) SELECT DISTINCT TRIM(Hobby) FROM StudentHobby WHERE Hobby != '';


/*Grade*/

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

