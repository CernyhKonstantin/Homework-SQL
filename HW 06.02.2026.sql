--create database
CREATE DATABASE Academy;

GO
--use database
USE Academy;

GO
--drop tables if they exist
DROP TABLE Teachers;
DROP TABLE Groups;
DROP TABLE Faculties;
DROP TABLE Departments;

GO
--create table Departments
CREATE TABLE Departments
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

GO
--create table Faculties
CREATE TABLE Faculties
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Dean NVARCHAR(MAX) NOT NULL CHECK (LEN(Dean) > 0)
);

GO
--create table Groups
CREATE TABLE Groups
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5)
);

GO
--create table Teachers
CREATE TABLE Teachers
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
    IsAssistant BIT NOT NULL DEFAULT 0,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Position NVARCHAR(MAX) NOT NULL CHECK (LEN(Position) > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

GO
--insert example data into Departments
INSERT INTO Departments (Name, Financing)
VALUES
('Software Development', 30000),
('Mathematics', 10000),
('Physics', 8000),
('Design', 26000);

GO
--insert example data into Faculties
INSERT INTO Faculties (Name, Dean)
VALUES
('Computer Science', 'John Smith'),
('Engineering', 'Anna Brown'),
('Business', 'Michael White');

GO
--insert example data into Groups
INSERT INTO Groups (Name, Rating, Year)
VALUES
('CS-101', 3, 1),
('CS-202', 5, 2),
('CS-503', 4, 5),
('CS-504', 2, 5);

GO
--insert example data into Teachers
INSERT INTO Teachers (Name, Surname, EmploymentDate, IsAssistant, IsProfessor, Position, Salary, Premium)
VALUES
('John', 'Adams', '1998-05-10', 0, 1, 'Professor', 2000, 400),
('Anna', 'Clark', '2005-03-12', 1, 0, 'Assistant', 500, 200),
('Peter', 'Miller', '1995-07-01', 1, 0, 'Assistant', 450, 150),
('Kate', 'Wilson', '2010-09-15', 0, 0, 'Lecturer', 900, 100);

GO


--1. Display Departments with fields in reverse order
SELECT
    Name,
    Financing,
    Id
FROM Departments;

GO
--2. Display group names and ratings with custom column names
SELECT
    Name AS [Group Name],
    Rating AS [Group Rating]
FROM Groups;

GO
--3. Display teacher surname and salary percentages
SELECT
    Surname,
    Premium * 100 / Salary AS PremiumPercentOfSalary,
    Salary * 100 / (Salary + Premium) AS SalaryPercentOfTotal
FROM Teachers;

GO
--4. Display Faculties as one formatted field
SELECT
    'The dean of faculty ' + Name + ' is ' + Dean + '.' AS FacultyInfo
FROM Faculties;

GO
--5. Display professors with salary > 1050
SELECT
    Surname
FROM Teachers
WHERE IsProfessor = 1 AND Salary > 1050;

GO
--6. Departments with financing < 11000 or > 25000
SELECT
    Name
FROM Departments
WHERE Financing < 11000 OR Financing > 25000;

GO
--7. Faculties except "Computer Science"
SELECT
    Name
FROM Faculties
WHERE Name <> 'Computer Science';

GO
--8. Teachers who are not professors
SELECT
    Surname,
    Position
FROM Teachers
WHERE IsProfessor = 0;

GO
--9. Assistants with premium between 160 and 550
SELECT
    Surname,
    Position,
    Salary,
    Premium
FROM Teachers
WHERE IsAssistant = 1 AND Premium BETWEEN 160 AND 550;

GO
--10. Assistants surnames and salaries
SELECT
    Surname,
    Salary
FROM Teachers
WHERE IsAssistant = 1;

GO
--11. Teachers employed before 01.01.2000
SELECT
    Surname,
    Position
FROM Teachers
WHERE EmploymentDate < '2000-01-01';

GO
--12. Departments alphabetically before "Software Development"
SELECT
    Name AS [Name of Department]
FROM Departments
WHERE Name < 'Software Development'
ORDER BY Name;

GO
--13. Assistants with total salary <= 1200
SELECT
    Surname
FROM Teachers
WHERE IsAssistant = 1 AND (Salary + Premium) <= 1200;

GO
--14. 5th year groups with rating between 2 and 4
SELECT
    Name
FROM Groups
WHERE Year = 5 AND Rating BETWEEN 2 AND 4;

GO
--15. Assistants with salary < 550 or premium < 200
SELECT
    Surname
FROM Teachers
WHERE IsAssistant = 1 AND (Salary < 550 OR Premium < 200);

GO
