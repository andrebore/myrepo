CREATE TABLE rooms
(
    ID INTEGER PRIMARY KEY ASC,
    Description TEXT NOT NULL
);

INSERT INTO rooms (ID, Description) VALUES(1, "Livingroom");
INSERT INTO rooms (ID, Description) VALUES(2, "Kitchen");
INSERT INTO rooms (ID, Description) VALUES(3, "Office");
INSERT INTO rooms (ID, Description) VALUES(4, "Wardrobe");
INSERT INTO rooms (ID, Description) VALUES(5, "Bedroom");
INSERT INTO rooms (ID, Description) VALUES(6, "Bath");
INSERT INTO rooms (ID, Description) VALUES(7, "Balcony");

CREATE TABLE trend
(
    ID INTEGER PRIMARY KEY ASC,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    room INTEGER,
    temp REAL,
    humidity INTEGER
);
