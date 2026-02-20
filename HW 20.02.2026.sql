
CREATE DATABASE Library_PV521;

GO

USE Library_PV521;

GO

CREATE TABLE genres(
  id INT PRIMARY KEY IDENTITY(1,1),
  title NVARCHAR(50) NOT NULL
)

GO

CREATE TABLE authors(
  id INT PRIMARY KEY IDENTITY(1,1),
  name NVARCHAR(30) NOT NULL,
  surname NVARCHAR(30) NOT NULL
);

GO

CREATE TABLE books(
  id INT PRIMARY KEY IDENTITY(1,1),
  title NVARCHAR(50) NOT NULL,
  [year] int NOT NULL,
  price decimal(10,2) NOT NULL,
  id_author int FOREIGN KEY REFERENCES authors(id)
  ON DELETE CASCADE ON UPDATE CASCADE
);

GO

CREATE TABLE booktToGenres(
  id INT PRIMARY KEY IDENTITY(1,1),
  id_book INT FOREIGN KEY REFERENCES books(id),
  id_genre INT FOREIGN KEY REFERENCES genres(id)
);

GO

INSERT INTO genres (title) VALUES 
('Fantasy'),
('Science Fiction'),
('Detective'),
('Romance'),
('Horror'),
('Historical'),
('Adventure'),
('Drama');

GO

INSERT INTO authors (name, surname) VALUES
('Stephen', 'King'),
('Agatha', 'Christie'),
('J.K.', 'Rowling'),
('George', 'Orwell'),
('Jane', 'Austen'),
('Ernest', 'Hemingway'),
('Mark', 'Twain'),
('Arthur', 'Doyle');

GO

INSERT INTO books (title, [year], price, id_author) VALUES
('The Shining', 1977, 15.99, 1),
('Murder on the Orient Express', 1934, 12.50, 2),
('Harry Potter and the Philosopher''s Stone', 1997, 20.00, 3),
('1984', 1949, 14.30, 4),
('Pride and Prejudice', 1813, 10.99, 5),
('The Old Man and the Sea', 1952, 13.45, 6),
('Adventures of Huckleberry Finn', 1884, 11.25, 7),
('Sherlock Holmes: A Study in Scarlet', 1887, 16.75, 8),
('Animal Farm', 1945, 9.99, 4),
('It', 1986, 18.60, 1);

GO

INSERT INTO bookToGenres (id_book, id_genre) VALUES
(1, 5),  -- The Shining -> Horror
(2, 3),  -- Murder on the Orient Express -> Detective
(3, 1),  -- Harry Potter -> Fantasy
(3, 7),  -- Harry Potter -> Adventure
(4, 2),  -- 1984 -> Science Fiction
(4, 8),  -- 1984 -> Drama
(5, 4),  -- Pride and Prejudice -> Romance
(6, 8),  -- The Old Man and the Sea -> Drama
(7, 7),  -- Huckleberry Finn -> Adventure
(8, 3),  -- Sherlock Holmes -> Detective
(9, 2),  -- Animal Farm -> Science Fiction
(10, 5); -- It -> Horror

GO

SELECT * FROM genres;

GO

SELECT * FROM authors;

GO

SELECT * FROM books;

GO

SELECT * FROM booktToGenres;

GO

SELECT
    b.id,
    b.title AS Book,
    a.name + ' ' + a.surname AS Author,
    g.title AS Genre,
    b.year,
    b.price
FROM books b
JOIN authors a ON a.id = b.id_author
JOIN booktToGenres btg ON btg.id_book = b.id
JOIN genres g ON g.id = btg.id_genre
ORDER BY b.id;

GO

SELECT
    b.id,
    b.title AS Book,
    a.name + ' ' + a.surname AS Author,
    COUNT(btg.id_genre) AS Genre_Count
FROM books AS b
JOIN authors AS a
    ON a.id = b.id_author
LEFT JOIN booktToGenres AS btg
    ON btg.id_book = b.id
GROUP BY b.id, b.title, a.name, a.surname
ORDER BY b.id;

GO

SELECT
    a.id,
    a.name + ' ' + a.surname AS Author,
    COUNT(btg.id_genre) AS Genre_Count
FROM authors AS a
LEFT JOIN books AS b
    ON b.id_author = a.id
LEFT JOIN booktToGenres AS btg
    ON btg.id_book = b.id
GROUP BY a.id, a.name, a.surname
ORDER BY Genre_Count DESC;

GO

SELECT
    g.title AS Genre,
    b.title AS Book,
    b.price
FROM books AS b
JOIN booktToGenres AS btg
    ON btg.id_book = b.id
JOIN genres AS g
    ON g.id = btg.id_genre
WHERE b.price = (
    SELECT MAX(b2.price)
    FROM books AS b2
    JOIN booktToGenres AS btg2
        ON btg2.id_book = b2.id
    WHERE btg2.id_genre = g.id
)
ORDER BY b.price DESC;

GO

-- ?????? ???????, ???????? ???????, ??????? ??? ????????
--bit
ALTER TABLE books
ADD is_active BIT DEFAULT(1);

GO
SELECT * FROM books;
GO

UPDATE books SET is_active=1;

GO

ALTER TABLE books
DROP CONSTRAINT FK__books__id_author__3B75D760;


GO
CREATE TRIGGER booksDeleteTrigger
ON books
INSTEAD OF DELETE
AS
BEGIN
  -- inserted, deleted
  UPDATE books SET is_active=0
  WHERE id IN(
  SELECT id FROM deleted)
END

GO

DROP TRIGGER  booksDeleteTrigger
GO

DELETE FROM books WHERE id IN(2,3);

SELECT * FROM books;



USE Library_PV521;
GO

ALTER TABLE authors
ADD discount DECIMAL(5,2) DEFAULT(0);
GO

SELECT * FROM authors;
GO

CREATE TRIGGER AuthorsDiscountUpdateTrigger
ON authors
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(discount)
    BEGIN
        UPDATE b
        SET b.price = b.price * (1 - i.discount / 100.0)
        FROM books b
        INNER JOIN inserted i
            ON b.id_author = i.id;
    END
END
GO

SELECT 
    a.name + ' ' + a.surname AS Author,
    a.discount,
    b.title,
    b.price
FROM authors a
JOIN books b ON b.id_author = a.id
WHERE a.id = 1;
GO

UPDATE authors
SET discount = 10
WHERE id = 1;
GO

SELECT 
    a.name + ' ' + a.surname AS Author,
    a.discount,
    b.title,
    b.price
FROM authors a
JOIN books b ON b.id_author = a.id
WHERE a.id = 1;
GO

--Transaction
BEGIN TRANSACTION;

BEGIN TRY

    -- Update author discount
    UPDATE authors
    SET discount = 15
    WHERE id = 2;

    -- Update related books
    UPDATE books
    SET price = price * 0.85
    WHERE id_author = 2;

    COMMIT;
    PRINT 'Transaction completed successfully';

END TRY
BEGIN CATCH

    ROLLBACK;
    PRINT 'Transaction failed and was rolled back';

END CATCH;
GO

SELECT 
    b.id AS BookID,
    b.title AS BookTitle,
    a.name + ' ' + a.surname AS AuthorName,
    ISNULL(a.discount, 0) AS AuthorDiscount,
    b.price AS FinalPrice,
    CAST(b.price / (1 - ISNULL(a.discount, 0) / 100.0) AS DECIMAL(10,2)) AS OriginalPrice
FROM books b
JOIN authors a
    ON b.id_author = a.id
ORDER BY b.id;
GO
