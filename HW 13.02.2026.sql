-- Create the Academy Database
CREATE DATABASE Academy_DB;
GO

USE Academy_DB;
GO

-- Create Tables
-- Faculties
CREATE TABLE Faculties(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Departments
CREATE TABLE Departments(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Building INT NOT NULL,
    Financing MONEY NOT NULL DEFAULT 0,
    FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(Id)
);
GO

-- Groups
CREATE TABLE Groups(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);
GO

-- Curators
CREATE TABLE Curators(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);
GO

-- Groups and Curators
CREATE TABLE GroupsCurators(
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    CuratorId INT NOT NULL FOREIGN KEY REFERENCES Curators(Id)
);
GO

-- Teachers
CREATE TABLE Teachers(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK(Salary > 0),
    IsProfessor BIT NOT NULL DEFAULT 0
);
GO

-- Subjects
CREATE TABLE Subjects(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Lectures
CREATE TABLE Lectures(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL CHECK(Date <= GETDATE()),
    LectureRoom NVARCHAR(MAX) NOT NULL,
    SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);
GO

-- Groups and Lectures
CREATE TABLE GroupsLectures(
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id)
);
GO

-- Students
CREATE TABLE Students(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Rating INT NOT NULL CHECK(Rating BETWEEN 0 AND 5)
);
GO

-- Groups and Students
CREATE TABLE GroupsStudents(
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id)
);
GO

-- Sample Data (simplified)
-- Faculties
INSERT INTO Faculties(Name) VALUES
('Computer Science'),
('Software Engineering'),
('Mathematics');
GO

-- Departments
INSERT INTO Departments(Name, Building, Financing, FacultyId) VALUES
('Software Development', 1, 120000, 1),
('Data Science', 2, 80000, 1),
('Cybersecurity', 1, 95000, 2),
('Applied Math', 3, 70000, 3);
GO

-- Groups
INSERT INTO Groups(Name, Year, DepartmentId) VALUES
('D221', 2, 1),
('D222', 5, 1),
('S501', 5, 2),
('M301', 3, 3);
GO

-- Curators
INSERT INTO Curators(Name, Surname) VALUES
('Anna', 'Smith'),
('John', 'Doe'),
('Mary', 'Johnson');
GO

-- GroupsCurators
INSERT INTO GroupsCurators(GroupId, CuratorId) VALUES
(1,1),
(2,2),
(2,3),
(3,1);
GO

-- Teachers
INSERT INTO Teachers(Name, Surname, Salary, IsProfessor) VALUES
('Dave', 'McQueen', 4500, 1),
('Jack', 'Underhill', 3800, 1),
('Samantha', 'Adams', 3200, 0),
('Michael', 'Brown', 5000, 1);
GO

-- Subjects
INSERT INTO Subjects(Name) VALUES
('Databases'),
('Software Engineering'),
('Algorithms'),
('Cybersecurity');
GO

-- Lectures
INSERT INTO Lectures(Date, LectureRoom, SubjectId, TeacherId) VALUES
('2026-02-01', 'D201', 1, 1),
('2026-02-02', 'D201', 2, 2),
('2026-02-03', 'C101', 3, 3),
('2026-02-04', 'B103', 4, 4),
('2026-02-05', 'D201', 1, 1),
('2026-02-06', 'D202', 2, 2);
GO

-- GroupsLectures
INSERT INTO GroupsLectures(GroupId, LectureId) VALUES
(1,1),
(1,2),
(2,3),
(2,4),
(3,5),
(3,6);
GO

-- Students
INSERT INTO Students(Name, Surname, Rating) VALUES
('Alice', 'Green', 4),
('Bob', 'White', 5),
('Charlie', 'Black', 3),
('Diana', 'Brown', 5),
('Eve', 'Blue', 2);
GO

-- GroupsStudents
INSERT INTO GroupsStudents(GroupId, StudentId) VALUES
(1,1),
(1,2),
(2,3),
(2,4),
(3,5);
GO

-- Queries from your tasks
-- 1. Buildings with total department financing > 100000
SELECT Building, SUM(Financing) AS Total_Financing
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

-- 2. 5th-year groups in Software Development with >10 lectures in first week
SELECT g.Name AS Group_Name
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
WHERE g.Year = 5
  AND d.Name = 'Software Development'
  AND l.Date BETWEEN '2026-02-01' AND '2026-02-07'
GROUP BY g.Id, g.Name
HAVING COUNT(gl.Id) > 10;

-- 3. Groups with average student rating > D221
SELECT g.Name AS Group_Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Id, g.Name
HAVING AVG(s.Rating) > (
    SELECT AVG(s2.Rating)
    FROM Groups g2
    JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
    JOIN Students s2 ON gs2.StudentId = s2.Id
    WHERE g2.Name = 'D221'
);

-- 4. Teachers with salary higher than average professor salary
SELECT t.Name + ' ' + t.Surname AS Full_Name, t.Salary
FROM Teachers t
WHERE t.Salary > (
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);

-- 5. Groups with more than one curator
SELECT g.Name AS Group_Name
FROM Groups g
JOIN GroupsCurators gc ON g.Id = gc.GroupId
GROUP BY g.Id, g.Name
HAVING COUNT(gc.CuratorId) > 1;

-- 6. Groups with avg rating < min rating of 5th-year groups
WITH FifthYearAvg AS (
    SELECT g2.Id AS GroupId, AVG(s2.Rating) AS AvgRating
    FROM Groups g2
    JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
    JOIN Students s2 ON gs2.StudentId = s2.Id
    WHERE g2.Year = 5
    GROUP BY g2.Id
)
SELECT g.Name AS Group_Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Id, g.Name
HAVING AVG(s.Rating) < (SELECT MIN(AvgRating) FROM FifthYearAvg);

-- 7. Faculties with total department funding > Computer Science
SELECT f.Name AS Faculty_Name
FROM Faculties f
JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Id, f.Name
HAVING SUM(d.Financing) > (
    SELECT SUM(d2.Financing)
    FROM Faculties f2
    JOIN Departments d2 ON f2.Id = d2.FacultyId
    WHERE f2.Name = 'Computer Science'
);

-- 8. Subjects and teachers with the most lectures
SELECT sub.Name AS Subject, t.Name + ' ' + t.Surname AS Teacher, COUNT(l.Id) AS Lecture_Count
FROM Lectures l
JOIN Subjects sub ON l.SubjectId = sub.Id
JOIN Teachers t ON l.TeacherId = t.Id
GROUP BY sub.Id, sub.Name, t.Id, t.Name, t.Surname
HAVING COUNT(l.Id) = (
    SELECT MAX(LectureCount)
    FROM (
        SELECT COUNT(l2.Id) AS LectureCount
        FROM Lectures l2
        WHERE l2.SubjectId = sub.Id
        GROUP BY l2.TeacherId
    ) AS SubQuery
);

-- 9. Subject with the fewest lectures
SELECT TOP 1 sub.Name AS Subject_Name, COUNT(l.Id) AS Lecture_Count
FROM Lectures l
JOIN Subjects sub ON l.SubjectId = sub.Id
GROUP BY sub.Id, sub.Name
ORDER BY COUNT(l.Id) ASC;

-- 10. Number of students and subjects in Software Development
SELECT COUNT(DISTINCT gs.StudentId) AS Student_Count,
       COUNT(DISTINCT l.SubjectId) AS Subject_Count
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
WHERE d.Name = 'Software Development';
