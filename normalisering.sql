DROP TABLE IF EXISTS Grade;
CREATE TABLE Grade (
	GradeId INT NOT NULL AUTO_INCREMENT,
	Name VARCHAR(255) NOT NULL,
	CONSTRAINT PRIMARY KEY (GradeId)
) ENGINE=INNODB;

INSERT INTO Grade(Name)
SELECT DISTINCT Grade FROM UNF;

ALTER TABLE Student ADD COLUMN GradeId INT NOT NULL;

UPDATE Student JOIN UNF ON (StudentID = Id) JOIN Grade ON Grade.Name = UNF.Grade 
SET Student.GradeId = Grade.GradeId;

SELECT StudentId as ID FROM StudentSchool;

SELECT StudentId as ID, Student.Name FROM StudentSchool
LEFT JOIN Student USING (StudentId);

SELECT StudentId as ID, Student.Name, Grade.Name AS Grade FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId);

SELECT StudentId as ID, Student.Name, Grade.Name AS Grade, Hobbies FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentID);

SELECT StudentId as ID, Student.Name, Grade.Name AS Grade, Hobbies, School.Name AS School, City, Numbers FROM StudentSchool
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentId)
LEFT JOIN School USING (SchoolId);

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