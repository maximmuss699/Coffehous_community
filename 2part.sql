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

CREATE TABLE Consumer (
    ConsumerID NUMBER NOT NULL PRIMARY KEY,
    UserName VARCHAR(20) NOT NULL,
    FavoriteCoffeePreparation VARCHAR(20),
    FavoriteCoffee VARCHAR(20),
    FavoriteCafe VARCHAR(20),
    DailyCoffeeConsumption NUMBER
);

CREATE TABLE Worker (
    WorkerID NUMBER NOT NULL PRIMARY KEY,
    WorkExperience VARCHAR(20) NOT NULL,
    FOREIGN KEY (WorkerID) REFERENCES Consumer(ConsumerID)
);

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
    FOREIGN KEY (CoffeeTypeID) REFERENCES CoffeeType(CoffeeTypeID),
    FOREIGN KEY (EventID) REFERENCES Event
);

CREATE SEQUENCE ConsumerIdSequence;

CREATE OR REPLACE TRIGGER ConsumerIdGenerator
BEFORE INSERT ON Consumer
FOR EACH ROW
BEGIN
    :new.ConsumerID := ConsumerIdSequence.NEXTVAL;
END ConsumerIdGenerator;
/

-- Inserting data into the tables
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('JohnDoe', 'Espresso', 'Americano', 'Starbucks', 3);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CafeCoder', 'Cold Brew', 'Cappuccino', 'CodeCafe', 2);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CoffeeLover', 'Turkish Coffee', 'Latte', 'CoffeeHouse', 4);
INSERT INTO Consumer (UserName, FavoriteCoffeePreparation, FavoriteCoffee, FavoriteCafe, DailyCoffeeConsumption)
    VALUES ('CoffeeAddict', 'Espresso', 'Espresso', 'CoffeeHouse', 5);

INSERT INTO Worker (WorkerID, WorkExperience)
    VALUES (1, '5 years'); --maybe should be integer WorkExperience
INSERT INTO Worker (WorkerID, WorkExperience)
    VALUES (2, '3 years');

INSERT INTO Owner (OwnerID)
    VALUES (1);
INSERT INTO Owner (OwnerID)
    VALUES (2);


INSERT INTO Cafe (CafeID, CafeName, CafeAddress, OpenTime, CloseTime, Capacity, CafeDescription, OwnerID)
    VALUES (1, 'CodeCafe', 'Ceska 24', TO_TIMESTAMP('08:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('22:00:00', 'HH24:MI:SS'), 50, 'Cozy cafe with a wide selection of coffee blends.', 1);

INSERT INTO Cafe (CafeID, CafeName, CafeAddress, OpenTime, CloseTime, Capacity, CafeDescription, OwnerID)
    VALUES (2, 'CoffeeHouse', 'Slevacska 12', TO_TIMESTAMP('07:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('23:00:00', 'HH24:MI:SS'), 60, 'Modern cafe with a wide selection of coffee blends.', 2);

INSERT INTO CafeWorker (WorkerID, CafeID)
    VALUES (1, 1);
INSERT INTO CafeWorker (WorkerID, CafeID)
    VALUES (2, 2);


INSERT INTO Event (EventID, EventDate, Capacity, Price, EventDescription, OwnerID, CafeID)
    VALUES (1, TO_DATE('2024-12-24', 'YYYY-MM-DD'), 30, 5.00, 'Christmas event with live music.', 1, 1);

INSERT INTO Event (EventID, EventDate, Capacity, Price, EventDescription, OwnerID, CafeID)
    VALUES (2, TO_DATE('2024-12-31', 'YYYY-MM-DD'), 40, 10.00, 'New Year''s Eve party with fireworks.', 2, 2);

INSERT INTO Review (ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (1, TO_DATE('2024-10-24', 'YYYY-MM-DD'), 'Great coffee and atmosphere.', 5, 1);

INSERT INTO Review (ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (2, TO_DATE('2024-11-24', 'YYYY-MM-DD'), 'Good coffee, but the service could be better.', 4, 2);


INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (1, 1);
INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (2, 2);

INSERT INTO EventReview (EventReviewID, EventID)
    VALUES (1, 1);
INSERT INTO EventReview (EventReviewID, EventID)
    VALUES (2, 2);

INSERT INTO ReviewComment (CommentID, CommentDate, CommentDescription, ConsumerID, ReviewID)
    VALUES (1, TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'I agree, the coffee is amazing.', 1, 1);

INSERT INTO ReviewComment (CommentID, CommentDate, CommentDescription, ConsumerID, ReviewID)
    VALUES (2, TO_DATE('2024-11-25', 'YYYY-MM-DD'), 'I think the service is great.', 2, 2);


INSERT INTO Review(ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (3, TO_DATE('2024-12-24', 'YYYY-MM-DD'), 'Great coffee and atmosphere.', 5, 3);

INSERT INTO Review(ReviewID, ReviewDate, ReviewDescription, Rating, ConsumerID)
    VALUES (4, TO_DATE('2024-12-31', 'YYYY-MM-DD'), 'Good coffee, but the service could be better.', 4, 4);

INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (3, 1);
INSERT INTO CafeReview (CafeReviewID, CafeID)
    VALUES (4, 2);

INSERT INTO EventReview (EventReviewID, EventID)
    VALUES (3, 1);
INSERT INTO EventReview (EventReviewID, EventID)
    VALUES (4, 2);

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