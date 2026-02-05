--create database Academy
CREATE DATABASE Academy;

GO
--select database
USE Academy;

GO
--drop tables if they exist
DROP TABLE Teachers;
DROP TABLE Groups;
DROP TABLE Departments;
DROP TABLE Faculties;

GO
--create table Groups
CREATE TABLE Groups
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Rating INT NOT NULL CHECK (Rating >= 0 AND Rating <= 5),
    Year INT NOT NULL CHECK (Year >= 1 AND Year <= 5)
);

GO
--create table Departments
CREATE TABLE Departments
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

GO
--create table Faculties
CREATE TABLE Faculties
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

GO
--create table Teachers
CREATE TABLE Teachers
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

GO
--insert example data into Groups
INSERT INTO Groups (Name, Rating, Year)
VALUES 
    ('CS-101', 4, 1),
    ('CS-202', 5, 2);

GO
--insert example data into Departments
INSERT INTO Departments (Name, Financing)
VALUES
    ('Computer Science', 50000),
    ('Mathematics', 30000);

GO
--insert example data into Faculties
INSERT INTO Faculties (Name)
VALUES
    ('Engineering'),
    ('Science');

GO
--insert example data into Teachers
INSERT INTO Teachers (Name, Surname, EmploymentDate, Salary, Premium)
VALUES
    ('John', 'Smith', '2005-09-01', 2500, 500),
    ('Anna', 'Brown', '2012-02-15', 2200, 300);

GO
--example run: select all data
SELECT * FROM Groups;
SELECT * FROM Departments;
SELECT * FROM Faculties;
SELECT * FROM Teachers;

GO
--example run: show current year
PRINT(YEAR(GETDATE()));

GO
