CREATE DATABASE Library;
USE Library;

CREATE TABLE Authors (
  AuthorID INT AUTO_INCREMENT,
  Name VARCHAR(255),
  Country VARCHAR(255),
  PRIMARY KEY (AuthorID)
);

CREATE TABLE Books (
  BookID INT AUTO_INCREMENT,
  Title VARCHAR(255),
  AuthorID INT,
  Category VARCHAR(255),
  Price DECIMAL(10, 2),
  PRIMARY KEY (BookID),
  FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Members (
  MemberID INT AUTO_INCREMENT,
  Name VARCHAR(255),
  JoinDate DATE,
  PRIMARY KEY (MemberID)
);

CREATE TABLE Borrowing (
  BorrowID INT AUTO_INCREMENT,
  MemberID INT,
  BookID INT,
  BorrowDate DATE,
  ReturnDate DATE,
  Fine DECIMAL(10, 2),
  PRIMARY KEY (BorrowID),
  FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
  FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

INSERT INTO Authors (Name, Country)
VALUES
('J.K. Rowling', 'United Kingdom'),
('J.R.R. Tolkien', 'United Kingdom'),
('Leo Tolstoy', 'Russia');

INSERT INTO Books (Title, AuthorID, Category, Price)
VALUES
('Harry Potter and the Philosopher\'s Stone', 1, 'Fantasy', 15.99),
('The Lord of the Rings', 2, 'Fantasy', 24.99),
('War and Peace', 3, 'Historical Fiction', 19.99),
('To Kill a Mockingbird', 1, 'Fiction', 12.99);

INSERT INTO Members (Name, JoinDate)
VALUES
('Alice', '2022-01-01'),
('Bob', '2023-06-01'),
('Charlie', '2024-03-01');

INSERT INTO Borrowing (MemberID, BookID, BorrowDate, ReturnDate)
VALUES
(1, 1, '2022-01-15', '2022-02-01'),
(2, 2, '2023-06-15', '2023-07-01'),
(3, 3, '2024-03-15', '2024-04-01'),
(1, 4, '2022-03-01', '2022-03-15');

SELECT B.Title, A.Name AS Author
FROM Books B
JOIN Authors A ON B.AuthorID = A.AuthorID;

SELECT B.Title
FROM Borrowing Bo
JOIN Members M ON Bo.MemberID = M.MemberID
JOIN Books B ON Bo.BookID = B.BookID
WHERE M.Name = 'Alice';

SELECT M.Name
FROM Members M
JOIN Borrowing Bo ON M.MemberID = Bo.MemberID
JOIN Books B ON Bo.BookID = B.BookID
WHERE B.Category = 'Fantasy';

CREATE INDEX idx_AuthorID ON Books (AuthorID);
CREATE INDEX idx_BookID ON Borrowing (BookID);

CREATE VIEW BorrowedBooks AS
SELECT B.Title, M.Name AS Member
FROM Borrowing Bo
JOIN Members M ON Bo.MemberID = M.MemberID
JOIN Books B ON Bo.BookID = B.BookID;

SELECT * FROM BorrowedBooks;

DELIMITER //
CREATE PROCEDURE ListBooksByCategory (IN Category VARCHAR(50))
BEGIN
    SELECT Title, Author FROM Books WHERE Category = Category;
END //
DELIMITER ;

CALL ListBooksByCategory('Fantasy');

DELIMITER //
CREATE TRIGGER UpdateFineOnLateReturn
AFTER UPDATE ON Borrowing
FOR EACH ROW
BEGIN
   UPDATE Borrowing
   SET Fine = CalculateLateFine(NEW.ReturnDate, NEW.DueDate)
   WHERE BorrowID = NEW.BorrowID;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION CalculateLateFine(ReturnDate DATE, DueDate DATE)
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE LateDays INT;
    SET LateDays = DATEDIFF(DueDate, ReturnDate) - 7;
    IF LateDays < 0 THEN
        SET LateDays = 0;
    END IF;
    RETURN LateDays * 5.00;
END //
DELIMITER ;


SHOW FUNCTION STATUS WHERE Name = 'CalculateLateFine';
DROP FUNCTION IF EXISTS CalculateLateFine;

DELIMITER //
CREATE TRIGGER UpdateFineOnLateReturn
AFTER UPDATE ON Borrowing
FOR EACH ROW
BEGIN
    UPDATE Borrowing
    SET Fine = CalculateLateFine(NEW.ReturnDate, OLD.DueDate)
    WHERE BorrowID = OLD.BorrowID;
END //
DELIMITER ;

DESCRIBE Borrowing;
ALTER TABLE Borrowing ADD COLUMN DueDate DATE;

UPDATE Borrowing
SET Fine = CalculateLateFine(NEW.ReturnDate, OLD.DueDate)
WHERE BorrowID = NEW.BorrowID;

--                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         the trigger
UPDATE Borrowing
SET ReturnDate = '2024-03-20'
WHERE BorrowID = 1;