-- DROP DATABASE IF EXISTS
IF DB_ID('SportStoreDB') IS NOT NULL
    DROP DATABASE SportStoreDB;
GO

-- CREATE DATABASE
CREATE DATABASE SportStoreDB;
GO

USE SportStoreDB;
GO

-- EMPLOYEES TABLE
CREATE TABLE Employees
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Gender NVARCHAR(10),
    Salary DECIMAL(10,2) NOT NULL
);
GO

-- EMPLOYEES ARCHIVE TABLE
CREATE TABLE EmployeesArchive
(
    ArchiveId INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    HireDate DATE,
    Gender NVARCHAR(10),
    Salary DECIMAL(10,2),
    FiredDate DATETIME DEFAULT GETDATE()
);
GO

-- PRODUCTS TABLE
CREATE TABLE Products
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    ProductType NVARCHAR(50),
    QuantityInStock INT NOT NULL,
    CostPrice DECIMAL(10,2) NOT NULL,
    Manufacturer NVARCHAR(100),
    SalePrice DECIMAL(10,2) NOT NULL
);
GO

-- CUSTOMERS TABLE
CREATE TABLE Customers
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Gender NVARCHAR(10),
    DiscountPercent INT DEFAULT 0,
    IsSubscribed BIT DEFAULT 0
);
GO

-- SALES TABLE
-- IMPORTANT:
-- EmployeeId allows NULL
-- ON DELETE SET NULL
CREATE TABLE Sales
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    EmployeeId INT NULL,
    CustomerId INT NULL,
    SalePrice DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    SaleDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(Id) ON DELETE SET NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
);
GO

-- SAMPLE DATA
INSERT INTO Employees (FullName, Position, HireDate, Gender, Salary)
VALUES
('John Smith', 'Manager', '2022-01-10', 'Male', 3000),
('Anna Brown', 'Seller', '2023-03-15', 'Female', 2200),
('Michael Lee', 'Seller', '2021-07-01', 'Male', 2400);
GO

INSERT INTO Products (ProductName, ProductType, QuantityInStock, CostPrice, Manufacturer, SalePrice)
VALUES
('Running Shoes', 'Shoes', 50, 40, 'Nike', 80),
('Football T-Shirt', 'Clothing', 100, 10, 'Adidas', 25);
GO

INSERT INTO Customers (FullName, Email)
VALUES
('David Miller', 'david@mail.com');
GO

INSERT INTO Sales (ProductId, EmployeeId, CustomerId, SalePrice, Quantity)
VALUES
(1, 2, 1, 80, 1);
GO

-- TRIGGER: Archive employee after delete
CREATE TRIGGER trg_ArchiveEmployee
ON Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO EmployeesArchive
    (
        EmployeeId,
        FullName,
        Position,
        HireDate,
        Gender,
        Salary
    )
    SELECT
        d.Id,
        d.FullName,
        d.Position,
        d.HireDate,
        d.Gender,
        d.Salary
    FROM DELETED d;
END;
GO

-- Fire employee Id = 2
DELETE FROM Employees WHERE Id = 2;
GO

-- Check archive
SELECT * FROM EmployeesArchive;

-- Check sales (EmployeeId should be NULL now)
SELECT * FROM Sales;
GO
