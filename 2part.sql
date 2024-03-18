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
    ConsumerID NUMBER PRIMARY KEY,
    UserName VARCHAR(20) NOT NULL,
    FavoriteCoffeePreparation VARCHAR(20),
    FavoriteCoffee VARCHAR(20),
    FavoriteCafe VARCHAR(20),
    DailyCoffeeConsumption NUMBER
);

CREATE TABLE Worker (
    WorkerID NUMBER PRIMARY KEY,
    WorkExperience VARCHAR(20) NOT NULL,
    ConsumerID  NUMBER NOT NULL,
    FOREIGN KEY (ConsumerID) REFERENCES Consumer(ConsumerID)
);

CREATE TABLE Owner (
    OwnerID NUMBER PRIMARY KEY,
    WorkerID NUMBER NOT NULL,
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID)
);

CREATE TABLE Cafe (
    CafeID NUMBER PRIMARY KEY,
    CafeName VARCHAR(20) NOT NULL,
    CafeAddress VARCHAR(20),
    OpenTime TIMESTAMP,
    CloseTime TIMESTAMP,
    Capacity NUMBER,
    CafeDescription VARCHAR(256),
    OwnerID NUMBER NOT NULL,
    FOREIGN KEY (OwnerID) REFERENCES Owner(OwnerId)
);

CREATE TABLE CafeWorker (
    WorkerID NUMBER,
    CafeID NUMBER,
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID),
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE Event (
    EventID NUMBER PRIMARY KEY,
    EventDate DATE NOT NULL,
    Capacity NUMBER,
    Price DECIMAL(5,2),
    EventDescription VARCHAR(256),
    OwnerID NUMBER NOT NULL,
    CafeID NUMBER,
    FOREIGN KEY (OwnerID) REFERENCES Owner(OwnerID),
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE Review (
    ReviewID NUMBER PRIMARY KEY,
    ReviewDate DATE,
    ReviewDescription VARCHAR(256),
    Rating NUMBER(1) CHECK (Rating BETWEEN 1 AND 5),
    ConsumerID NUMBER NOT NULL,
    FOREIGN KEY (ConsumerID) REFERENCES Consumer(ConsumerID)
);

CREATE TABLE CafeReview (
    ReviewID NUMBER,
    CafeID NUMBER,
    FOREIGN KEY (ReviewID) REFERENCES Review,
    FOREIGN KEY (CafeID) REFERENCES Cafe
);

CREATE TABLE EventReview (
    ReviewID NUMBER PRIMARY KEY,
    EventID NUMBER NOT NULL,
    FOREIGN KEY (ReviewID) REFERENCES Review,
    FOREIGN KEY (EventID) REFERENCES Event
);

CREATE TABLE ReviewComment (
    CommentID NUMBER PRIMARY KEY,
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
    EvaluationStatus NUMBER CHECK (EvaluationStatus IN (-1, 1)),
    FOREIGN KEY (UserID) REFERENCES Consumer(ConsumerID),
    FOREIGN KEY (CommentID) REFERENCES ReviewComment(CommentID)
);

CREATE TABLE CoffeeBlend (
    CoffeeBlendID NUMBER PRIMARY KEY,
    CoffeeTypeID NUMBER,
    CoffeeBlendName VARCHAR(20) NOT NULL,
    CoffeeBlendDescription VARCHAR(256),
    CafeID NUMBER NOT NULL,
    FOREIGN KEY (CafeID) REFERENCES Cafe(CafeID)
);

CREATE TABLE CoffeeType (
    CoffeeTypeID NUMBER PRIMARY KEY,
    CoffeeTypeName VARCHAR(20) NOT NULL,
    Taste VARCHAR(128),
    AreaOfOrigin VARCHAR(20),
    Quality NUMBER,
    CoffeeBlendID NUMBER NOT NULL,
    FOREIGN KEY (CoffeeBlendID) REFERENCES CoffeeBlend(CoffeeBlendID)
);

CREATE TABLE CoffeeTypeEvent (
    CoffeeTypeID NUMBER,
    EventID NUMBER,
    FOREIGN KEY (CoffeeTypeID) REFERENCES CoffeeType,
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