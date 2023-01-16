# DB2022-Josef

## Entity RelationsShip Diagram

erDiagram
    Student ||--o{ Phone : has
    Student }|--o| Grade : has
    Student ||--o{ StudentSchool : attends
    School ||--o{ StudentSchool : enrolls
    Student ||--o{ StudentHobby : has
    Hobby ||--o{ StudentHobby : involves
   }
   ## Instruktioner
   Klona detta projekt till önskad mapp.
   git clone https://github.com/aeneidITHS/DB2022-Josef.git
   Skapa en mySQL databas via docker om du inte redan har en.
  
   Koperia in den icke-normaliserade datan in i databasen.
   docker cp denormalized-data.csv iths-mysql:/var/lib/mysql-files

    
