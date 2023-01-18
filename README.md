# DB2022-Josef

## Entity Relationship Diagram
```mermaid
erDiagram
    Student ||--o{ Phone : has
    Student }|--o| Grade : has
    Student ||--o{ StudentSchool : attends
    School ||--o{ StudentSchool : enrolls
    Student ||--o{ StudentHobby : has
    Hobby ||--o{ StudentHobby : involves
    
    
    Student {
        int StudentId
        varchar FirstName
	varchar LastName
        int GradeId
    }
    
    Phone {
        int PhoneId
        int StudentId
        varchar Type
	varchar Number
    }
    
    School {
        int SchoolId
        string name
        string City
    }
    
    StudentSchool {
        int StudentId
        int SchoolId
    }
    
    Hobbies {
        int HobbyId
        varchar name
    }
    StudentHobby {
        int StudentId
        int HobbyId
    }
    
    Grade {
        int GradeId
        string name
    }
   ``` 
   ## Instruktioner
   Klona detta projekt till önskad mapp.
   
   ```
   git clone https://github.com/aeneidITHS/DB2022-Josef.git
   ```
   
   Skapa en mySQL databas via docker om du inte redan har en.
   
   ```
docker run -d --name iths-mysql\
	 -e MYSQL_ROOT_USERNAME=root\
	 -e MYSQL_ROOT_PASSWORD=root\
	 -e MYSQL_USER=iths\
	 -e MYSQL_PASSWORD=iths\
	 -e MYSQL_DATABASE=iths\
	 -p 3306:3306\
	 -d mysql/mysql-server:latest
 ```

   Koperia in den icke-normaliserade datan in i databasen.
   ```
   docker cp denormalized-data.csv iths-mysql:/var/lib/mysql-files
   ```
   Kör SQL scriptfilen som normaliserar data i filen ovan. 
   ```
   docker exec -i iths-mysql -uroot -proot < normalisering.sql
   ```
   Kör java projektet
   ```
   gradle test 
   ```
