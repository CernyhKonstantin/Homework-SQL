CREATE DATABASE Academy;

GO

USE Academy;

GO

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
    Financing MONEY NOT NULL DEFAULT 0 CHECK(Financing >= 0),
    FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(Id)
);

GO

-- Teachers
CREATE TABLE Teachers(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL,
    Salary MONEY NOT NULL CHECK(Salary > 0),
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
);

GO

-- Subjects
CREATE TABLE Subjects(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
);

GO

-- Groups
CREATE TABLE Groups(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE,
    [Year] INT NOT NULL CHECK([Year] BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

GO

-- Lectures
CREATE TABLE Lectures(
    Id INT PRIMARY KEY IDENTITY(1,1),
    DayOfWeek INT NOT NULL CHECK(DayOfWeek BETWEEN 1 AND 7),
    LectureRoom NVARCHAR(20) NOT NULL,
    SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

GO

-- GroupsLectures
CREATE TABLE GroupsLectures(
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id)
);

GO

INSERT INTO Faculties (Name)
VALUES ('Computer Science'), ('Business');

GO

INSERT INTO Departments (Name, Financing, FacultyId)
VALUES 
('Software Development', 50000, 1),
('Cyber Security', 30000, 1),
('Management', 20000, 2);

GO

INSERT INTO Teachers (Name, Surname, Salary, DepartmentId)
VALUES
('Dave', 'McQueen', 3000, 1),
('Jack', 'Underhill', 3500, 1),
('John', 'Smith', 2800, 2),
('Anna', 'Brown', 2600, 3);

GO

INSERT INTO Subjects (Name)
VALUES
('C#'),
('Databases'),
('Networks'),
('Management');

GO

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES
('CS101', 1, 1),
('CS201', 2, 1),
('CS301', 3, 2);

GO

INSERT INTO Lectures (DayOfWeek, LectureRoom, SubjectId, TeacherId)
VALUES
(1, 'D201', 1, 1),
(2, 'D201', 2, 2),
(3, 'D202', 3, 3),
(4, 'D203', 4, 4),
(5, 'D201', 1, 2);

GO

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES
(1,1),(1,2),(2,3),(3,4),(2,5);

GO

-- 1. Number of teachers in "Software Development"
SELECT COUNT(*) AS Teachers_Count
FROM Teachers t
JOIN Departments d ON d.Id = t.DepartmentId
WHERE d.Name = 'Software Development';

GO

-- 2. Number of lectures by "Dave McQueen"
SELECT COUNT(*) AS Lectures_Count
FROM Lectures l
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Dave' AND t.Surname = 'McQueen';

GO

-- 3. Number of lectures in room D201
SELECT COUNT(*) AS Lectures_In_D201
FROM Lectures
WHERE LectureRoom = 'D201';

GO

-- 4. Rooms and number of lectures in each
SELECT LectureRoom, COUNT(*) AS Lectures_Count
FROM Lectures
GROUP BY LectureRoom;

GO

-- 5. Number of students groups attending lectures of "Jack Underhill"
SELECT COUNT(DISTINCT gl.GroupId) AS Groups_Count
FROM GroupsLectures gl
JOIN Lectures l ON l.Id = gl.LectureId
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Jack' AND t.Surname = 'Underhill';

GO

-- 6. Average salary of teachers in faculty "Computer Science"
SELECT AVG(t.Salary) AS Avg_Salary
FROM Teachers t
JOIN Departments d ON d.Id = t.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE f.Name = 'Computer Science';

GO

-- 7. Minimum and maximum number of students (groups) among all groups
SELECT MIN(cnt) AS Min_Groups, MAX(cnt) AS Max_Groups
FROM (
    SELECT GroupId, COUNT(*) AS cnt
    FROM GroupsLectures
    GROUP BY GroupId
) AS GroupCounts;

GO

-- 8. Average financing of departments
SELECT AVG(Financing) AS Avg_Financing
FROM Departments;

GO

-- 9. Full teacher names and number of subjects they teach
SELECT 
    t.Name + ' ' + t.Surname AS Teacher,
    COUNT(DISTINCT l.SubjectId) AS Subjects_Count
FROM Teachers t
LEFT JOIN Lectures l ON l.TeacherId = t.Id
GROUP BY t.Name, t.Surname;

GO

-- 10. Number of lectures for each day of week
SELECT DayOfWeek, COUNT(*) AS Lectures_Count
FROM Lectures
GROUP BY DayOfWeek
ORDER BY DayOfWeek;

GO

-- 11. Rooms and number of departments whose lectures are held there
SELECT 
    l.LectureRoom,
    COUNT(DISTINCT t.DepartmentId) AS Departments_Count
FROM Lectures l
JOIN Teachers t ON t.Id = l.TeacherId
GROUP BY l.LectureRoom;

GO

-- 12. Faculties and number of subjects taught in them
SELECT 
    f.Name AS Faculty,
    COUNT(DISTINCT l.SubjectId) AS Subjects_Count
FROM Faculties f
JOIN Departments d ON d.FacultyId = f.Id
JOIN Teachers t ON t.DepartmentId = d.Id
JOIN Lectures l ON l.TeacherId = t.Id
GROUP BY f.Name;

GO

-- 13. Number of lectures for each Teacher-Room pair
SELECT 
    t.Name + ' ' + t.Surname AS Teacher,
    l.LectureRoom,
    COUNT(*) AS Lectures_Count
FROM Lectures l
JOIN Teachers t ON t.Id = l.TeacherId
GROUP BY t.Name, t.Surname, l.LectureRoom
ORDER BY Teacher;

GO
