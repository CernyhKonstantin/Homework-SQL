-- ===========================================
-- 1. Create the database
-- ===========================================
CREATE DATABASE AcademyDB;
GO

USE AcademyDB;
GO

-- ===========================================
-- 2. Create tables
-- ===========================================

-- Teachers
CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Surname NVARCHAR(50) NOT NULL
);

-- Deans
CREATE TABLE Deans (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

-- Heads (Department heads)
CREATE TABLE Heads (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

-- Faculties
CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Building INT NOT NULL,
    DeanId INT NOT NULL,
    FOREIGN KEY (DeanId) REFERENCES Deans(TeacherId)
);

-- Departments
CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Building INT NOT NULL,
    FacultyId INT NOT NULL,
    HeadId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id),
    FOREIGN KEY (HeadId) REFERENCES Heads(TeacherId)
);

-- Groups
CREATE TABLE Groups (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL,
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

-- Curators
CREATE TABLE Curators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

-- GroupsCurators
CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    CuratorId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (CuratorId) REFERENCES Curators(TeacherId)
);

-- Assistants
CREATE TABLE Assistants (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

-- LectureRooms
CREATE TABLE LectureRooms (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Building INT NOT NULL
);

-- Subjects
CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

-- Lectures
CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

-- Schedules
CREATE TABLE Schedules (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    LectureId INT NOT NULL,
    LectureRoomId INT NOT NULL,
    Class INT NOT NULL,
    DayOfWeek INT NOT NULL,
    Week INT NOT NULL,
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    FOREIGN KEY (LectureRoomId) REFERENCES LectureRooms(Id)
);

-- GroupsLectures
CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

-- Students
CREATE TABLE Students (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Surname NVARCHAR(50) NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5)
);

-- GroupsStudents
CREATE TABLE GroupsStudents (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    StudentId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id)
);

-- ===========================================
-- 3. Insert sample data
-- ===========================================

-- Teachers
INSERT INTO Teachers (Name, Surname) VALUES
('Edward', 'Hopper'),
('Alex', 'Carmack'),
('Michael', 'Scott'),
('Jane', 'Doe'),
('John', 'Smith'),
('Alice', 'Johnson'),
('Robert', 'Brown');

-- Deans
INSERT INTO Deans (TeacherId) VALUES (3), (5);

-- Heads
INSERT INTO Heads (TeacherId) VALUES (4), (6);

-- Faculties
INSERT INTO Faculties (Name, Building, DeanId) VALUES
('Computer Science', 1, 3),
('Mathematics', 2, 5);

-- Departments
INSERT INTO Departments (Name, Building, FacultyId, HeadId) VALUES
('Software Development', 1, 1, 4),
('Data Science', 2, 1, 6);

-- Groups
INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('F505', 5, 1),
('D221', 2, 1);

-- Curators
INSERT INTO Curators (TeacherId) VALUES (1), (2);

-- GroupsCurators
INSERT INTO GroupsCurators (GroupId, CuratorId) VALUES
(1,1),
(1,2),
(2,1);

-- Assistants
INSERT INTO Assistants (TeacherId) VALUES (2), (6);

-- LectureRooms
INSERT INTO LectureRooms (Name, Building) VALUES
('A311', 6),
('A104', 6),
('B201', 2);

-- Subjects
INSERT INTO Subjects (Name) VALUES
('Programming'),
('Databases'),
('Networking');

-- Lectures
INSERT INTO Lectures (SubjectId, TeacherId) VALUES
(1,1), -- Programming by Edward Hopper
(2,2), -- Databases by Alex Carmack
(3,2); -- Networking by Alex Carmack

-- Schedules
INSERT INTO Schedules (LectureId, LectureRoomId, Class, DayOfWeek, Week) VALUES
(1,1,3,1,2), -- Monday
(2,2,3,3,2), -- Wednesday second week
(3,2,3,3,2); -- Wednesday second week

-- GroupsLectures
INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1,1),
(1,2),
(2,1);

-- Students
INSERT INTO Students (Name, Surname, Rating) VALUES
('Tom','Harris',4),
('Emily','Clark',5),
('Sam','Wilson',3);

-- GroupsStudents
INSERT INTO GroupsStudents (GroupId, StudentId) VALUES
(1,1),(1,2),(2,3);

-- ===========================================
-- 4. Queries
-- ===========================================

-- 1. LectureRooms where Edward Hopper teaches
SELECT DISTINCT lr.Name AS LectureRoomName
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

-- 2. Assistants teaching in group F505
SELECT DISTINCT t.Surname AS AssistantSurname
FROM Assistants a
JOIN Teachers t ON a.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.GroupId = 1
JOIN Lectures l ON gl.LectureId = l.Id
WHERE a.TeacherId = l.TeacherId;

-- 3. Subjects Alex Carmack teaches for 5th-year groups
SELECT DISTINCT sub.Name AS SubjectName
FROM Subjects sub
JOIN Lectures l ON sub.Id = l.SubjectId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

-- 4. Teachers not teaching on Monday (DayOfWeek = 1)
SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

-- 5. LectureRooms with no lectures on Wednesday second week, third class
SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT s.LectureRoomId
    FROM Schedules s
    WHERE s.DayOfWeek = 3 AND s.Week = 2 AND s.Class = 3
);

-- 6. Full names of Computer Science teachers not curating Software Development
SELECT t.Name, t.Surname
FROM Teachers t
JOIN Faculties f ON f.Id = 1 -- Computer Science
WHERE t.Id NOT IN (
    SELECT gc.CuratorId
    FROM GroupsCurators gc
    JOIN Groups g ON gc.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
);

-- 7. All building numbers from Faculties, Departments, LectureRooms
SELECT DISTINCT Building FROM Faculties
UNION
SELECT DISTINCT Building FROM Departments
UNION
SELECT DISTINCT Building FROM LectureRooms;

-- 8. Teachers in order: Deans, Heads, Teachers, Curators, Assistants
SELECT t.Name, t.Surname, 'Dean' AS Role
FROM Deans d
JOIN Teachers t ON d.TeacherId = t.Id
UNION ALL
SELECT t.Name, t.Surname, 'Head' AS Role
FROM Heads h
JOIN Teachers t ON h.TeacherId = t.Id
UNION ALL
SELECT t.Name, t.Surname, 'Teacher' AS Role
FROM Teachers t
WHERE t.Id NOT IN (SELECT TeacherId FROM Deans UNION SELECT TeacherId FROM Heads)
UNION ALL
SELECT t.Name, t.Surname, 'Curator' AS Role
FROM Curators c
JOIN Teachers t ON c.TeacherId = t.Id
UNION ALL
SELECT t.Name, t.Surname, 'Assistant' AS Role
FROM Assistants a
JOIN Teachers t ON a.TeacherId = t.Id;

-- 9. Days of the week with classes in A311 and A104 building 6
SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Name IN ('A311','A104') AND lr.Building = 6;
