--create database
CREATE DATABASE Academy;

GO
--use database
USE Academy;

GO
------------------------------------------------------------
--drop tables if they exist (in correct order)
------------------------------------------------------------
DROP TABLE GroupsLectures;
DROP TABLE GroupsCurators;
DROP TABLE Lectures;
DROP TABLE Groups;
DROP TABLE Subjects;
DROP TABLE Curators;
DROP TABLE Teachers;
DROP TABLE Departments;
DROP TABLE Faculties;

GO
------------------------------------------------------------
--create table Faculties
------------------------------------------------------------
CREATE TABLE Faculties
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0)
);

GO
------------------------------------------------------------
--create table Departments
------------------------------------------------------------
CREATE TABLE Departments
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

GO
------------------------------------------------------------
--create table Groups
------------------------------------------------------------
CREATE TABLE Groups
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

GO
------------------------------------------------------------
--create table Teachers
------------------------------------------------------------
CREATE TABLE Teachers
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0)
);

GO
------------------------------------------------------------
--create table Subjects
------------------------------------------------------------
CREATE TABLE Subjects
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
);

GO
------------------------------------------------------------
--create table Lectures
------------------------------------------------------------
CREATE TABLE Lectures
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    LectureRoom NVARCHAR(50) NOT NULL,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

GO
------------------------------------------------------------
--create table Curators
------------------------------------------------------------
CREATE TABLE Curators
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);

GO
------------------------------------------------------------
--create table GroupsCurators
------------------------------------------------------------
CREATE TABLE GroupsCurators
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

GO
------------------------------------------------------------
--create table GroupsLectures
------------------------------------------------------------
CREATE TABLE GroupsLectures
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

GO
------------------------------------------------------------
--insert example data
------------------------------------------------------------

--Faculties
INSERT INTO Faculties (Name, Financing)
VALUES
('Computer Science', 50000),
('Engineering', 30000);

GO
--Departments
INSERT INTO Departments (Name, Financing, FacultyId)
VALUES
('Software Development', 20000, 1),
('Networks', 15000, 1),
('Electronics', 10000, 2);

GO
--Groups
INSERT INTO Groups (Name, Year, DepartmentId)
VALUES
('P107', 1, 1),
('P205', 5, 1),
('E301', 3, 3);

GO
--Teachers
INSERT INTO Teachers (Name, Surname, Salary)
VALUES
('Samantha', 'Adams', 2000),
('John', 'Brown', 1800),
('Anna', 'Smith', 1500);

GO
--Subjects
INSERT INTO Subjects (Name)
VALUES
('Database Theory'),
('Programming'),
('Networks');

GO
--Lectures
INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId)
VALUES
('B103', 1, 1),
('A201', 2, 2),
('B103', 3, 3);

GO
--GroupsLectures
INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES
(1, 1),
(2, 1),
(3, 3);

GO
--Curators
INSERT INTO Curators (Name, Surname)
VALUES
('Michael', 'Johnson'),
('Laura', 'White');

GO
--GroupsCurators
INSERT INTO GroupsCurators (CuratorId, GroupId)
VALUES
(1, 1),
(2, 2);

GO
------------------------------------------------------------
--MULTI-TABLE SELECT QUERIES
------------------------------------------------------------

--1. All possible pairs of teachers and groups
SELECT
    t.Name + ' ' + t.Surname AS Teacher,
    g.Name AS [Group]
FROM Teachers t
CROSS JOIN Groups g;

GO
--2. Faculties where department financing exceeds faculty financing
SELECT
    f.Name
FROM Faculties f
JOIN Departments d ON d.FacultyId = f.Id
GROUP BY f.Id, f.Name, f.Financing
HAVING SUM(d.Financing) > f.Financing;

GO
--3. Curator surnames and their groups
SELECT
    c.Surname,
    g.Name AS GroupName
FROM Curators c
JOIN GroupsCurators gc ON gc.CuratorId = c.Id
JOIN Groups g ON g.Id = gc.GroupId;

GO
--4. Teachers who lecture group 'P107'
SELECT DISTINCT
    t.Surname
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = 'P107';

GO
--5. Teacher surnames and faculties where they lecture
SELECT DISTINCT
    t.Surname,
    f.Name AS Faculty
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId;

GO
--6. Departments and their groups
SELECT
    d.Name AS Department,
    g.Name AS GroupName
FROM Departments d
JOIN Groups g ON g.DepartmentId = d.Id;

GO
--7. Subjects taught by 'Samantha Adams'
SELECT
    s.Name
FROM Subjects s
JOIN Lectures l ON l.SubjectId = s.Id
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Samantha' AND t.Surname = 'Adams';

GO
--8. Departments where 'Database Theory' is taught
SELECT DISTINCT
    d.Name
FROM Departments d
JOIN Groups g ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON gl.GroupId = g.Id
JOIN Lectures l ON l.Id = gl.LectureId
JOIN Subjects s ON s.Id = l.SubjectId
WHERE s.Name = 'Database Theory';

GO
--9. Groups belonging to faculty 'Computer Science'
SELECT
    g.Name
FROM Groups g
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE f.Name = 'Computer Science';

GO
--10. 5th year groups and their faculties
SELECT
    g.Name,
    f.Name AS Faculty
FROM Groups g
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE g.Year = 5;

GO
--11. Teachers and lectures in room 'B103'
SELECT
    t.Surname,
    s.Name AS Subject,
    g.Name AS GroupName
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN Subjects s ON s.Id = l.SubjectId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE l.LectureRoom = 'B103';

GO
