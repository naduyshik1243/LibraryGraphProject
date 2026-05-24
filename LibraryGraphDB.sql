CREATE DATABASE LibraryGraphDB;
GO

USE LibraryGraphDB;
GO


IF OBJECT_ID('dbo.Borrowed', 'U') IS NOT NULL DROP TABLE dbo.Borrowed;
IF OBJECT_ID('dbo.Wrote', 'U') IS NOT NULL DROP TABLE dbo.Wrote;
IF OBJECT_ID('dbo.Recommends', 'U') IS NOT NULL DROP TABLE dbo.Recommends;

IF OBJECT_ID('dbo.Readers', 'U') IS NOT NULL DROP TABLE dbo.Readers;
IF OBJECT_ID('dbo.Books', 'U') IS NOT NULL DROP TABLE dbo.Books;
IF OBJECT_ID('dbo.Authors', 'U') IS NOT NULL DROP TABLE dbo.Authors;
GO



-- Таблица Читателей
CREATE TABLE Readers (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ReaderName NVARCHAR(100) NOT NULL,
    TicketNumber VARCHAR(20) NOT NULL,
    Age INT
) AS NODE; 

-- Таблица Книг
CREATE TABLE Books (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ISBN VARCHAR(20),
    PublishYear INT
) AS NODE;

-- Таблица Авторов
CREATE TABLE Authors (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    AuthorName NVARCHAR(100) NOT NULL,
    Country NVARCHAR(50)
) AS NODE;
GO



-- Ребро: Кто какую книгу взял
CREATE TABLE Borrowed (
    BorrowDate DATE NOT NULL,
    ReturnStatus NVARCHAR(20) NOT NULL, -- 'На руках', 'Вернул'
    ReaderRating INT, -- Оценка от 1 до 5 (если вернул)
    
    -- Ограничение: связь может идти строго от Читателя к Книге
    CONSTRAINT EC_Borrowed CONNECTION (Readers TO Books)
) AS EDGE;

-- Ребро: Какой автор какую книгу написал
CREATE TABLE Wrote (
    CreationYear INT,
    
    -- Ограничение: связь строго от Автора к Книге
    CONSTRAINT EC_Wrote CONNECTION (Authors TO Books)
) AS EDGE;

-- Ребро: Читатель рекомендует другого читателя (сообщество читателей)
CREATE TABLE Recommends (
    RecommendationDate DATE NOT NULL,
    
    -- Ограничение: связь от Читателя к Читателю
    CONSTRAINT EC_Recommends CONNECTION (Readers TO Readers)
) AS EDGE;
GO


USE LibraryGraphDB;
GO

-- 1. Заполняем Авторов (10 строк)
INSERT INTO Authors (AuthorName, Country) VALUES 
(N'Лев Толстой', N'Россия'),
(N'Фёдор Достоевский', N'Россия'),
(N'Джордж Оруэлл', N'Великобритания'),
(N'Стивен Кинг', N'США'),
(N'Габриэль Гарсиа Маркес', N'Колумбия'),
(N'Джоан Роулинг', N'Великобритания'),
(N'Харуки Мураками', N'Япония'),
(N'Агата Кристи', N'Великобритания'),
(N'Рэй Брэдбери', N'США'),
(N'Виктор Пелевин', N'Россия');

-- 2. Заполняем Книги (10 строк)
INSERT INTO Books (Title, ISBN, PublishYear) VALUES 
(N'Война и мир', '978-5-17-087819-2', 1869),
(N'Преступление и наказание', '978-5-389-06254-2', 1866),
(N'1984', '978-0-451-52493-5', 1949),
(N'Сияние', '978-0-307-74365-7', 1977),
(N'Сто лет одиночества', '978-5-17-028731-4', 1967),
(N'Гарри Поттер и философский камень', '978-0-7475-3269-9', 1997),
(N'Охота на овец', '978-5-17-041443-7', 1982),
(N'Убийство в Восточном экспрессе', '978-5-17-100234-3', 1934),
(N'451 градус по Фаренгейту', '978-0-345-34296-6', 1953),
(N'Generation П', '978-5-699-33311-0', 1999);

-- 3. Заполняем Читателей (10 строк)
INSERT INTO Readers (ReaderName, TicketNumber, Age) VALUES 
(N'Иван Иванов', 'B-101', 20),
(N'Пётр Петров', 'B-102', 22),
(N'Анна Сидорова', 'B-103', 19),
(N'Мария Николаева', 'B-104', 25),
(N'Дмитрий Волков', 'B-105', 31),
(N'Елена Кузнецова', 'B-106', 18),
(N'Алексей Попов', 'B-107', 45),
(N'Ольга Лебедева', 'B-108', 28),
(N'Сергей Морозов', 'B-109', 21),
(N'Татьяна Соколова', 'B-110', 35);
GO


-- 1. Связываем Авторов и Книги (Ребро Wrote)
INSERT INTO Wrote ($from_id, $to_id, CreationYear) VALUES 
((SELECT $node_id FROM Authors WHERE AuthorName = N'Лев Толстой'), (SELECT $node_id FROM Books WHERE Title = N'Война и мир'), 1869),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Фёдор Достоевский'), (SELECT $node_id FROM Books WHERE Title = N'Преступление и наказание'), 1866),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Джордж Оруэлл'), (SELECT $node_id FROM Books WHERE Title = N'1984'), 1949),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Стивен Кинг'), (SELECT $node_id FROM Books WHERE Title = N'Сияние'), 1977),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Габриэль Гарсиа Маркес'), (SELECT $node_id FROM Books WHERE Title = N'Сто лет одиночества'), 1967),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Джоан Роулинг'), (SELECT $node_id FROM Books WHERE Title = N'Гарри Поттер и философский камень'), 1997),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Харуки Мураками'), (SELECT $node_id FROM Books WHERE Title = N'Охота на овец'), 1982),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Агата Кристи'), (SELECT $node_id FROM Books WHERE Title = N'Убийство в Восточном экспрессе'), 1934),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Рэй Брэдбери'), (SELECT $node_id FROM Books WHERE Title = N'451 градус по Фаренгейту'), 1953),
((SELECT $node_id FROM Authors WHERE AuthorName = N'Виктор Пелевин'), (SELECT $node_id FROM Books WHERE Title = N'Generation П'), 1999);

-- 2. Связываем Читателей и Книги (Ребро Borrowed — история выдач)
INSERT INTO Borrowed ($from_id, $to_id, BorrowDate, ReturnStatus, ReaderRating) VALUES 
((SELECT $node_id FROM Readers WHERE ReaderName = N'Иван Иванов'), (SELECT $node_id FROM Books WHERE Title = N'1984'), '2026-01-15', N'Вернул', 5),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Иван Иванов'), (SELECT $node_id FROM Books WHERE Title = N'Generation П'), '2026-02-10', N'На руках', NULL),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Пётр Петров'), (SELECT $node_id FROM Books WHERE Title = N'1984'), '2026-02-01', N'Вернул', 4),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Анна Сидорова'), (SELECT $node_id FROM Books WHERE Title = N'Война и мир'), '2025-11-20', N'Вернул', 3),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Мария Николаева'), (SELECT $node_id FROM Books WHERE Title = N'Гарри Поттер и философский камень'), '2026-03-01', N'На руках', NULL),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Дмитрий Волков'), (SELECT $node_id FROM Books WHERE Title = N'Сияние'), '2026-01-10', N'Вернул', 5),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Елена Кузнецова'), (SELECT $node_id FROM Books WHERE Title = N'Преступление и наказание'), '2026-02-15', N'Вернул', 5),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Алексей Попов'), (SELECT $node_id FROM Books WHERE Title = N'Убийство в Восточном экспрессе'), '2026-03-10', N'На руках', NULL),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Ольга Лебедева'), (SELECT $node_id FROM Books WHERE Title = N'Сто лет одиночества'), '2026-04-05', N'На руках', NULL),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Сергей Морозов'), (SELECT $node_id FROM Books WHERE Title = N'451 градус по Фаренгейту'), '2026-01-20', N'Вернул', 4),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Татьяна Соколова'), (SELECT $node_id FROM Books WHERE Title = N'1984'), '2026-04-12', N'На руках', NULL);

-- 3. Связываем Читателей друг с другом (Ребро Recommends — цепочки рекомендаций)
INSERT INTO Recommends ($from_id, $to_id, RecommendationDate) VALUES 
((SELECT $node_id FROM Readers WHERE ReaderName = N'Иван Иванов'), (SELECT $node_id FROM Readers WHERE ReaderName = N'Пётр Петров'), '2026-01-20'),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Пётр Петров'), (SELECT $node_id FROM Readers WHERE ReaderName = N'Анна Сидорова'), '2026-02-05'),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Анна Сидорова'), (SELECT $node_id FROM Readers WHERE ReaderName = N'Мария Николаева'), '2026-02-22'),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Мария Николаева'), (SELECT $node_id FROM Readers WHERE ReaderName = N'Дмитрий Волков'), '2026-03-05'),
((SELECT $node_id FROM Readers WHERE ReaderName = N'Дмитрий Волков'), (SELECT $node_id FROM Readers WHERE ReaderName = N'Елена Кузнецова'), '2026-03-12');
GO


SELECT * FROM Borrowed;


USE LibraryGraphDB;
GO

SELECT 
    A.AuthorName,
    B.Title AS BookTitle,
    R.ReaderName,
    Br.BorrowDate,
    Br.ReturnStatus
FROM 
    Authors A, Wrote W, Books B, Borrowed Br, Readers R
WHERE 
    MATCH(A-(W)->B<-(Br)-R)
    AND A.AuthorName = N'Джордж Оруэлл';


    SELECT 
    R1.ReaderName AS WhoRecommended,
    R2.ReaderName AS WhoReceivedRecommendation,
    B.Title AS BookTitle,
    Br.ReturnStatus
FROM 
    Readers R1, Recommends Rec, Readers R2, Borrowed Br, Books B
WHERE 
    MATCH(R1-(Rec)->R2-(Br)->B)
    AND R1.ReaderName = N'Иван Иванов';


    SELECT 
    R1.ReaderName AS Originator,
    R2.ReaderName AS Middleman,
    R3.ReaderName AS FinalRecipient,
    Rec1.RecommendationDate AS FirstStepDate,
    Rec2.RecommendationDate AS SecondStepDate
FROM 
    Readers R1, Recommends Rec1, Readers R2, Recommends Rec2, Readers R3
WHERE 
    MATCH(R1-(Rec1)->R2-(Rec2)->R3)
    AND R1.ReaderName = N'Иван Иванов';


    SELECT 
    R1.ReaderName AS Starter,
    R2.ReaderName AS Reader,
    B.Title AS ReadBook,
    A.AuthorName AS Author
FROM 
    Readers R1, Recommends Rec, Readers R2, Borrowed Br, Books B, Wrote W, Authors A
WHERE 
    MATCH(R1-(Rec)->R2-(Br)->B<-(W)-A)
    AND R1.ReaderName = N'Иван Иванов';


    SELECT 
    A.AuthorName,
    B.Title AS RatedBook,
    R.ReaderName,
    Br.ReaderRating AS Score
FROM 
    Authors A, Wrote W, Books B, Borrowed Br, Readers R
WHERE 
    MATCH(A-(W)->B<-(Br)-R)
    AND Br.ReaderRating = 5;


    USE master;
GO

--Поиск кратчайших путей

ALTER DATABASE LibraryGraphDB SET COMPATIBILITY_LEVEL = 150;
GO
USE LibraryGraphDB;
GO

USE LibraryGraphDB;
GO

-- Рекурсивный CTE для обхода графа через системные ID рёбер
WITH RecommendationPaths AS (
    -- Якорь рекурсии: находим стартовую точку (Иван Иванов)
    SELECT 
        R_Start.$node_id AS CurrentNodeId,
        CAST(N'' AS NVARCHAR(MAX)) AS PathLog, -- Начало пути пустое
        CAST(R_Start.ReaderName AS NVARCHAR(MAX)) AS LastNodeName,
        1 AS Depth
    FROM Readers R_Start
    WHERE R_Start.ReaderName = N'Иван Иванов'
    
    UNION ALL
    
    -- Рекурсивная часть: идем по ребрам Recommends ($from_id -> $to_id)
    SELECT 
        R_Next.$node_id,
        CASE 
            WHEN P.PathLog = N'' THEN P.LastNodeName
            ELSE P.PathLog + N' -> ' + P.LastNodeName
        END,
        CAST(R_Next.ReaderName AS NVARCHAR(MAX)),
        P.Depth + 1
    FROM RecommendationPaths P
    JOIN Recommends Rec ON P.CurrentNodeId = Rec.$from_id
    JOIN Readers R_Next ON Rec.$to_id = R_Next.$node_id
)
SELECT TOP 1
    N'Иван Иванов' AS FromReader,
    PathLog AS RecommendationPath,
    LastNodeName AS ToReader
FROM RecommendationPaths
WHERE LastNodeName = N'Елена Кузнецова'
ORDER BY Depth ASC; -- Гарантирует, что путь будет КРАТЧАЙШИМ
GO

USE LibraryGraphDB;
GO

WITH LimitedPaths AS (
    SELECT 
        R_Start.$node_id AS CurrentNodeId,
        CAST(N'' AS NVARCHAR(MAX)) AS PathLog,
        CAST(R_Start.ReaderName AS NVARCHAR(MAX)) AS LastNodeName,
        0 AS PathLength
    FROM Readers R_Start
    WHERE R_Start.ReaderName = N'Иван Иванов'
    
    UNION ALL
    
    SELECT 
        R_Next.$node_id,
        CASE 
            WHEN P.PathLog = N'' THEN P.LastNodeName
            ELSE P.PathLog + N' -> ' + P.LastNodeName
        END,
        CAST(R_Next.ReaderName AS NVARCHAR(MAX)),
        P.PathLength + 1
    FROM LimitedPaths P
    JOIN Recommends Rec ON P.CurrentNodeId = Rec.$from_id
    JOIN Readers R_Next ON Rec.$to_id = R_Next.$node_id
    WHERE P.PathLength < 3 -- Строгое ограничение глубины поиска (до 3 шагов)
)
SELECT 
    N'Иван Иванов' AS FromReader,
    PathLog AS RecommendationPath,
    LastNodeName AS ToReader,
    PathLength
FROM LimitedPaths
WHERE PathLength > 0 -- Исключаем самого Ивана из результатов
ORDER BY PathLength ASC, LastNodeName;
GO