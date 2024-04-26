-- IDS projekt 2024
-- 3. část - SQL skript pro vytvoření objektů schématu databáze
-- Autor: xbalat00 a xsamus00

DROP TABLE CoffeeTypeEvent;
DROP TABLE CoffeeType;
DROP TABLE CoffeeBlend;
DROP TABLE CommentEvaluation;
DROP TABLE ReviewComment;
DROP TABLE CafeReview;
DROP TABLE EventReview;
DROP TABLE Review;
DROP TABLE Event;
DROP TABLE CafeWorker;
DROP TABLE Cafe;
DROP TABLE Owner;
DROP TABLE Worker;
DROP TABLE Consumer;
DROP SEQUENCE ConsumerIdSequence;
DROP MATERIALIZED VIEW cafe_avg_rating;

-- Consumer tabulka reprezentuje základní entitu pro systém uživatelů (Class Table Inheritance).
-- Používáme Class Table Inheritance metodu, kde základní třída (Consumer) má svou vlastní tabulku
-- a specializované třídy (Worker, Owner) mají také své vlastní tabulky, které dědí společné atributy.
CREATE TABLE Consumer (
    ConsumerID NUMBER NOT NULL PRIMARY KEY,
    UserName VARCHAR(20) NOT NULL,
    FavoriteCoffeePreparation VARCHAR(20),
    FavoriteCoffee VARCHAR(20),
    FavoriteCafe VARCHAR(20),
    DailyCoffeeConsumption NUMBER
);

-- Worker tabulka je specializací entity Consumer. Každý Worker je Consumer, ale má navíc pracovní zkušenosti.
-- Vazba na Consumer je reprezentována pomocí cizího klíče ConsumerID, čímž je zachována integrita mezi základní a odvozenou entitou.
CREATE TABLE Worker (
    WorkerID NUMBER NOT NULL PRIMARY KEY,
    WorkExperience VARCHAR(20) NOT NULL,
    FOREIGN KEY (WorkerID) REFERENCES Consumer(ConsumerID)
);

-- Owner tabulka je další úroveň specializace entity Worker a tedy i Consumer.
-- Každý Owner je Worker s odkazem na unikátní WorkerID. Tento design umožňuje, aby každý Owner měl všechny atributy Worker a Consumer.
CREATE TABLE Owner (
    OwnerID NUMBER NOT NULL PRIMARY KEY,
    FOREIGN KEY (OwnerID) REFERENCES Worker(WorkerID)
);

CREATE TABLE Cafe (
    CafeID NUMBER NOT NULL PRIMARY KEY,
    CafeName VARCHAR(20) NOT NULL,
    CafeAddress VARCHAR(20) NOT NULL,
    OpenTime TIMESTAMP,
    CloseTime TIMESTAMP,
    Capacity NUMBER,
    CafeDescription VARCHAR(256),
    OwnerID NUMBER NOT NULL,
    FOREIGN KEY (OwnerID) REFERENCES Owner(OwnerId)
);

CREATE TABLE CafeWorker (
    WorkerID NUMBER NOT NULL,
    CafeID NUMBER NOT NULL,
    PRIMARY KEY (WorkerID, CafeID),
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID),
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE Event (
    EventID NUMBER NOT NULL PRIMARY KEY,
    EventDate DATE NOT NULL,
    Capacity NUMBER,
    Price DECIMAL(5,2),
    EventDescription VARCHAR(256),
    OwnerID NUMBER NOT NULL,
    CafeID NUMBER NOT NULL,
    FOREIGN KEY (OwnerID) REFERENCES Owner(OwnerID),
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE Review (
    ReviewID NUMBER NOT NULL PRIMARY KEY,
    ReviewDate DATE NOT NULL,
    ReviewDescription VARCHAR(256),
    Rating NUMBER(1) NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ConsumerID NUMBER NOT NULL,
    FOREIGN KEY (ConsumerID) REFERENCES Consumer(ConsumerID)
);

CREATE TABLE CafeReview (
    CafeReviewID NUMBER NOT NULL PRIMARY KEY,
    CafeID NUMBER NOT NULL,
    FOREIGN KEY (CafeReviewID) REFERENCES Review(ReviewID),
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE EventReview (
    EventReviewID NUMBER NOT NULL PRIMARY KEY,
    EventID NUMBER NOT NULL,
    FOREIGN KEY (EventReviewID) REFERENCES Review(ReviewID),
    FOREIGN KEY (EventID) REFERENCES Event(EventID)
);

CREATE TABLE ReviewComment (
    CommentID NUMBER NOT NULL PRIMARY KEY,
    CommentDate DATE NOT NULL,
    CommentDescription VARCHAR(256) NOT NULL,
    ConsumerID NUMBER NOT NULL,
    ReviewID NUMBER NOT NULL,
    FOREIGN KEY (ConsumerID) REFERENCES Consumer(ConsumerID),
    FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID)
);

CREATE TABLE CommentEvaluation (
    UserID NUMBER NOT NULL,
    CommentID NUMBER NOT NULL,
    PRIMARY KEY (UserID, CommentID),
    EvaluationStatus NUMBER NOT NULL CHECK (EvaluationStatus IN (-1, 1)),
    FOREIGN KEY (UserID) REFERENCES Consumer(ConsumerID),
    FOREIGN KEY (CommentID) REFERENCES ReviewComment(CommentID)
);

CREATE TABLE CoffeeBlend (
    CoffeeBlendID NUMBER NOT NULL PRIMARY KEY,
    CoffeeBlendName VARCHAR(20) NOT NULL,
    CoffeeBlendDescription VARCHAR(256),
    CafeID NUMBER NOT NULL,
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE CoffeeType (
    CoffeeTypeID NUMBER NOT NULL PRIMARY KEY,
    CoffeeTypeName VARCHAR(20) NOT NULL,
    Taste VARCHAR(128) NOT NULL,
    AreaOfOrigin VARCHAR(20) NOT NULL ,
    Quality NUMBER NOT NULL CHECK (Quality BETWEEN 1 AND 10),
    CoffeeBlendID NUMBER NOT NULL,
    FOREIGN KEY (CoffeeBlendID) REFERENCES CoffeeBlend(CoffeeBlendID)
);

CREATE TABLE CoffeeTypeEvent (
    CoffeeTypeID NUMBER NOT NULL,
    EventID NUMBER NOT NULL,
    PRIMARY KEY (CoffeeTypeID, EventID),
    FOREIGN KEY (CoffeeTypeID) REFERENCES CoffeeType(CoffeeTypeID),
    FOREIGN KEY (EventID) REFERENCES Event
);
-- Sequence pro generování unikátního identifikátoru pro Consumer tabulku.
CREATE SEQUENCE ConsumerIdSequence
START WITH 1
INCREMENT BY 1;
-- Trigger pro generování unikátního identifikátoru pro Consumer tabulku.
CREATE OR REPLACE TRIGGER ConsumerIdGenerator
BEFORE INSERT ON Consumer
FOR EACH ROW
WHEN (new.ConsumerID IS NULL)
BEGIN
    SELECT ConsumerIdSequence.NEXTVAL
    INTO :new.ConsumerID
    FROM dual;
END;
/

-------- Vložení testovacích dat do tabulek. --------
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('JohnDoe', 'Espresso', 'Americano', 'Starbucks', 3);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CafeCoder', 'Cold Brew', 'Cappuccino', 'CodeCafe', 2);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CoffeeLover', 'Turkish Coffee', 'Latte', 'CoffeeHouse', 4);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CoffeeAddict', 'Espresso', 'Espresso', 'CoffeeHouse', 5);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CoffeeFan', 'Cappuccino', 'Cappuccino', 'Friedrich', 3);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CoffeeHolic', 'Latte', 'Latte', 'CodeCafe', 4);

INSERT INTO Worker (WorkerID, WorkExperience)
    VALUES (1, '5 years');
INSERT INTO Worker (WorkerID, WorkExperience)
    VALUES (2, '3 years');
INSERT INTO Worker (WorkerID, WorkExperience)
    VALUES (3, '2 years');

INSERT INTO Owner (OwnerID)
    VALUES (1);
INSERT INTO Owner (OwnerID)
    VALUES (2);


INSERT INTO Cafe (CafeID, CafeName, CafeAddress, OpenTime, CloseTime, Capacity, CafeDescription, OwnerID)
    VALUES (1, 'CodeCafe', 'Ceska 24', TO_TIMESTAMP('08:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('22:00:00', 'HH24:MI:SS'), 50, 'Cozy cafe with a wide selection of coffee blends.', 1);

INSERT INTO Cafe (CafeID, CafeName, CafeAddress, OpenTime, CloseTime, Capacity, CafeDescription, OwnerID)
    VALUES (2, 'CoffeeHouse', 'Slevacska 12', TO_TIMESTAMP('07:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('23:00:00', 'HH24:MI:SS'), 60, 'Modern cafe with a wide selection of coffee blends.', 2);

INSERT INTO Cafe (CafeID, CafeName, CafeAddress, OpenTime, CloseTime, Capacity, CafeDescription, OwnerID)
    VALUES (3, 'Friedrich', 'Smetanova 763', TO_TIMESTAMP('06:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('23:00:00', 'HH24:MI:SS'), 70, 'International coffee chain with a wide selection of coffee blends.', 1);



INSERT INTO CafeWorker (WorkerID, CafeID)
    VALUES (1, 1);
INSERT INTO CafeWorker (WorkerID, CafeID)
    VALUES (2, 2);
INSERT INTO CafeWorker (WorkerID, CafeID)
    VALUES (3, 3);


INSERT INTO Event (EventID, EventDate, Capacity, Price, EventDescription, OwnerID, CafeID)
    VALUES (1, TO_DATE('2024-12-24', 'YYYY-MM-DD'), 30, 5.00, 'Christmas event with live music.', 1, 1);

INSERT INTO Event (EventID, EventDate, Capacity, Price, EventDescription, OwnerID, CafeID)
    VALUES (2, TO_DATE('2024-12-31', 'YYYY-MM-DD'), 40, 10.00, 'New Year''s Eve party with fireworks.', 2, 2);

INSERT INTO Review (ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (1, TO_DATE('2024-10-24', 'YYYY-MM-DD'), 'Great coffee and atmosphere.', 5, 1);

INSERT INTO Review (ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (2, TO_DATE('2024-11-24', 'YYYY-MM-DD'), 'Good coffee, but the service could be better.', 4, 2);
INSERT INTO Review (ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (3, TO_DATE('2024-11-24', 'YYYY-MM-DD'), 'The coffee was terrible.', 1, 3);


INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (1, 1);
INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (2, 2);
INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (3, 2);

INSERT INTO EventReview (EventReviewID, EventID)
    VALUES (1, 1);
INSERT INTO EventReview (EventReviewID, EventID)
    VALUES (2, 2);

INSERT INTO ReviewComment (CommentID, CommentDate, CommentDescription, ConsumerID, ReviewID)
    VALUES (1, TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'I agree, the coffee is amazing.', 1, 1);

INSERT INTO ReviewComment (CommentID, CommentDate, CommentDescription, ConsumerID, ReviewID)
    VALUES (2, TO_DATE('2024-11-25', 'YYYY-MM-DD'), 'I think the service is great.', 2, 2);


INSERT INTO CommentEvaluation (UserID, CommentID, EvaluationStatus)
    VALUES (1, 1, 1);
INSERT INTO CommentEvaluation (UserID, CommentID, EvaluationStatus)
    VALUES (2, 2, 1);

INSERT INTO CoffeeBlend (CoffeeBlendID, CoffeeBlendName, CoffeeBlendDescription, CafeID)
    VALUES (1, 'Espresso Blend', 'A blend of coffee beans suitable for espresso.', 1);
INSERT INTO CoffeeBlend (CoffeeBlendID, CoffeeBlendName, CoffeeBlendDescription, CafeID)
    VALUES (2, 'House Blend', 'A blend of coffee beans suitable for any coffee preparation.', 2);

INSERT INTO CoffeeType (CoffeeTypeID, CoffeeTypeName, Taste, AreaOfOrigin, Quality, CoffeeBlendID)
    VALUES (1, 'Arabica', 'Sweet', 'Ethiopia', 5, 1);
INSERT INTO CoffeeType (CoffeeTypeID, CoffeeTypeName, Taste, AreaOfOrigin, Quality, CoffeeBlendID)
    VALUES (2, 'Robusta', 'Bitter', 'Vietnam', 4, 2);
INSERT INTO CoffeeType (CoffeeTypeID, CoffeeTypeName, Taste, AreaOfOrigin, Quality, CoffeeBlendID)
    VALUES (3, 'Liberica', 'Fruity', 'Liberia', 3, 1);
INSERT INTO CoffeeType (CoffeeTypeID, CoffeeTypeName, Taste, AreaOfOrigin, Quality, CoffeeBlendID)
    VALUES (4, 'Excelsa', 'Tart', 'Philippines', 4, 2);

INSERT INTO CoffeeTypeEvent (CoffeeTypeID, EventID)
    VALUES (1, 1);
INSERT INTO CoffeeTypeEvent (CoffeeTypeID, EventID)
    VALUES (2, 2);


--- SELECT dotaz na seznam kaváren a jejich pracovníků
--- Spojení dvou tabulek Cafe a CafeWorker pomocí JOIN klauzule.
SELECT CafeWorker.CafeID, CafeWorker.WorkerID,  Worker.WorkExperience
FROM CafeWorker
INNER JOIN Worker ON CafeWorker.WorkerID = Worker.WorkerID;

--- SELECT dotaz na seznam pracovníků a jejich pracovní zkušenosti
--- Spojení dvou tabulek Worker a Consumer pomocí JOIN klauzule.
SELECT Consumer.UserName, Worker.WorkExperience
FROM Worker
INNER JOIN Consumer ON Worker.WorkerID = Consumer.ConsumerID;

--- SELECT dotaz na průměrné hodnocení kaváren
--- Spojení trech tabulek Cafe, CafeReview a Review pomocí JOIN klauzule.
--- Výpočet průměrného hodnocení kaváren pomocí AVG funkce.
--- Group by klauzule slouží k seskupení výsledků podle názvu kavárny.
SELECT Cafe.CafeName, AVG(Review.Rating) AS AverageRating
FROM Cafe
INNER JOIN CafeReview ON Cafe.CafeID = CafeReview.CafeID
INNER JOIN Review  ON CafeReview.CafeReviewID = Review.ReviewID
GROUP BY Cafe.CafeName;

--- SELECT dotaz na počet pracovníků v jednotlivých kavárnách
--- Spojení dvou tabulek Cafe a CafeWorker pomocí JOIN klauzule.
--- Výpočet počtu pracovníků v jednotlivých kavárnách pomocí COUNT funkce.
--- Group by klauzule slouží k seskupení výsledků podle ID kavárny a názvu kavárny.
SELECT Cafe.CafeID, Cafe.CafeName, COUNT(CafeWorker.WorkerID) AS NumberOfWorkers
FROM CafeWorker
JOIN Cafe ON CafeWorker.CafeID = Cafe.CafeID
GROUP BY Cafe.CafeID, Cafe.CafeName;

--- SELECT dotaz na seznam kaváren, které mají nějakou událost
--- Použití poddotazu pro výběr kaváren, které mají nějakou událost.
--- Výběr kaváren pomocí EXISTS klauzule.
SELECT Cafe.CafeID, Cafe.CafeName
FROM Cafe
WHERE EXISTS (
    SELECT 1
    FROM Event
    WHERE Event.CafeID = Cafe.CafeID
);

--- SELECT dotaz, který zobrazí všechny recenze kaváren, které mají alespoň jednu událost
--- Použití poddotazu pro výběr událostí, které se konají v kavárně s ID 1.
SELECT Review.ReviewID, Review.ReviewDescription, Cafe.CafeName
FROM Review
INNER JOIN CafeReview ON Review.ReviewID = CafeReview.CafeReviewID
INNER JOIN Cafe ON CafeReview.CafeID = Cafe.CafeID
WHERE Cafe.CafeID IN (
    SELECT Event.CafeID
    FROM Event
);

-- SELECT dotaz, který zobrazí všechny uzivatele, kterí napsali recenzi na kavárnu
-- Použití poddotazu pro výběr uživatelů, kteří napsali recenzi na kavárnu.
-- Výběr uživatelů pomocí IN klauzule.
SELECT Consumer.UserName, Review.ReviewDescription
FROM Consumer
INNER JOIN Review ON Consumer.ConsumerID = Review.ConsumerID
WHERE Consumer.ConsumerID IN (
    SELECT R.ConsumerID
    FROM Review R
    JOIN CafeReview CR ON R.ReviewID = CR.CafeReviewID
);



--------- Materializovany pohled na prumerne hodnoceni kavaren
--------- Vytvoreni materializovaneho pohledu cafe_avg_rating, ktery obsahuje prumerne hodnoceni kavaren.
CREATE MATERIALIZED VIEW cafe_avg_rating AS
SELECT c.CafeID, c.CafeName, AVG(r.Rating) AS AverageRating
FROM Cafe c
JOIN CafeReview cr ON c.CafeID = cr.CafeID
JOIN Review r ON cr.CafeReviewID = r.ReviewID
GROUP BY c.CafeID, c.CafeName;

-- Zobrazení aktuálních dat z materializovaného pohledu.
SELECT * FROM cafe_avg_rating;

-- Aktualizace hodnocení v tabulce Review může ovlivnit průměrné hodnocení v pohledu.
UPDATE Review SET Rating = 5 WHERE ReviewID = 2;

-- Znovu zobrazení dat z pohledu po změně, což neodráží změnu, dokud není pohled explicitně obnoven.
SELECT * FROM cafe_avg_rating;

-- Explicitní obnovení materializovaného pohledu, aby odrážel změny v podkladových datech.
BEGIN
  DBMS_MVIEW.REFRESH('cafe_avg_rating');
END;

-- Kontrola dat po obnovení pohledu, která nyní odráží nedávné změny v hodnoceních
SELECT * FROM cafe_avg_rating;



--------- Vytvoření komplexního dotazu SELECT využívajícího klauzuli WITH a operátor CASE
WITH CafeRatings AS (
    -- Tato část SQL dotazu (CTE) slouží k výpočtu průměrného hodnocení a celkového počtu recenzí pro každé kavárny.
    -- Slouží k agregaci dat z více tabulek: Cafe, CafeReview a Review.
    SELECT
        c.CafeID,
        c.CafeName,
        AVG(r.Rating) AS AverageRating,
        COUNT(r.ReviewID) AS TotalReviews
    FROM Cafe c
    JOIN CafeReview cr ON c.CafeID = cr.CafeID
    JOIN Review r ON cr.CafeReviewID = r.ReviewID
    GROUP BY c.CafeID, c.CafeName
)
SELECT
    CafeID,
    CafeName,
    AverageRating,
    TotalReviews,
    CASE
        -- Kategorizace kaváren na základě průměrného hodnocení umožňuje snadněji hodnotit kvalitu služeb.
        WHEN AverageRating >= 4.5 THEN 'Výborné'
        WHEN AverageRating >= 3.5 THEN 'Dobré'
        WHEN AverageRating >= 2.5 THEN 'Dostatečné'
        ELSE 'Špatné'
    END AS RatingCategory -- Kategorie hodnocení založené na průměrném hodnocení.
FROM CafeRatings;
-- Tento SELECT dotaz získává data z CTE a kategorizuje kavárny podle kvality na základě průměrného hodnocení.
-- Tyto informace jsou užitečné pro zákazníky při výběru kavárny a pro majitele kaváren, kteří chtějí sledovat výkon svého podniku.




--------- Vytvoření uživatelské role XBALAT00 a přidělení oprávnění pro tabulky v databázi.
GRANT ALL ON Consumer TO XBALAT00;
GRANT ALL ON Worker TO XBALAT00;
GRANT ALL ON Owner TO XBALAT00;
GRANT ALL ON Cafe TO XBALAT00;
GRANT ALL ON CafeWorker TO XBALAT00;
GRANT ALL ON Event TO XBALAT00;
GRANT ALL ON Review TO XBALAT00;
GRANT ALL ON CafeReview TO XBALAT00;
GRANT ALL ON EventReview TO XBALAT00;
GRANT ALL ON ReviewComment TO XBALAT00;
GRANT ALL ON CommentEvaluation TO XBALAT00;
GRANT ALL ON CoffeeBlend TO XBALAT00;
GRANT ALL ON CoffeeType TO XBALAT00;
GRANT ALL ON CoffeeTypeEvent TO XBALAT00;
