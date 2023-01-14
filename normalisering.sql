USE iths;

SELECT DISTINCT Grade FROM UNF;

DROP TABLE IF EXISTS Grade;
CREATE TABLE Grade (
	GradeId INT NOT NULL AUTO_INCREMENT,
	Name VARCHAR(255) NOT NULL,
	CONSTRAINT PRIMARY KEY (GradeId)
) ENGINE=INNODB;

INSERT INTO Grade(Name)
SELECT DISTINCT Grade FROM UNF;
select * from Grade;

ALTER TABLE Student DROP COlUMN GradeId;
ALTER TABLE Student ADD COLUMN GradeId INT NOT NULL;

UPDATE Student JOIN UNF ON (StudentId = Id) JOIN Grade ON Grade.Name = UNF.Grade 
SET StudentSchool.GradeId = Grade.GradeId;

SELECT StudentId as ID FROM Student;

SELECT StudentId as ID, StudentSchool.Name FROM Student
LEFT JOIN Student USING (StudentId);

SELECT StudentId as ID, StudentSchool.Name, Grade.Name AS Grade FROM Student
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId);

SELECT StudentId as ID, StudentSchool.Name, Grade.Name AS Grade, Hobbies FROM Student
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentID);

SELECT StudentId as ID, StudentSchool.Name, Grade.Name AS Grade, Hobbies, School.Name AS School, City, Numbers FROM Student
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentId)
LEFT JOIN School USING (SchoolId);

SELECT StudentId as ID, StudentSchool.Name, Grade.Name AS Grade, Hobbies, School.Name AS School, City, Numbers FROM Student
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentId)
LEFT JOIN School USING (SchoolId)
LEFT JOIN PhoneList USING (StudentId);

DROP VIEW IF EXISTS AVSLUT;
CREATE VIEW AVSLUT AS
SELECT StudentId as ID, StudentSchool.Name, Grade.Name AS Grade, Hobbies, SchoolSchool.Name AS School, City, Numbers FROM Student
LEFT JOIN Student USING (StudentId)
LEFT JOIN Grade USING (GradeId)
LEFT JOIN HobbiesList USING (StudentId)
LEFT JOIN School USING (SchoolId)
LEFT JOIN PhoneList USING (StudentId);