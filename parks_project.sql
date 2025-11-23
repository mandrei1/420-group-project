SET DEFINE OFF;

--------------------------------------------------------------
-- 1. DROP TABLES 
--------------------------------------------------------------
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tour_detail CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE transactions CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE facilities CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE visitors CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE parks CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE message CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

--------------------------------------------------------------
-- 2. DROP SEQUENCES 
--------------------------------------------------------------
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_park_id';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_visitor_id';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_facility_id';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_tour_detail_id'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_txn_id';         EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_message_id';     EXCEPTION WHEN OTHERS THEN NULL; END;
/

--------------------------------------------------------------
-- 3. CREATE TABLES
--------------------------------------------------------------
CREATE TABLE parks (
    park_id      NUMBER PRIMARY KEY,
    park_name    VARCHAR2(100),
    address      VARCHAR2(200),
    state        VARCHAR2(20),
    zipcode      VARCHAR2(10)
);

CREATE TABLE visitors (
    visitor_id NUMBER PRIMARY KEY,
    name       VARCHAR2(100),
    email      VARCHAR2(200) UNIQUE,
    address    VARCHAR2(200),
    state      VARCHAR2(20),
    zipcode    VARCHAR2(10)
);

CREATE TABLE facilities (
    facility_id   NUMBER PRIMARY KEY,
    park_id       NUMBER REFERENCES parks(park_id),
    facility_name VARCHAR2(100),
    facility_type VARCHAR2(30),
    capacity      NUMBER,
    daily_price   NUMBER(8,2),
    child_price   NUMBER(8,2),
    status        NUMBER,
    spots_taken   NUMBER
);

CREATE TABLE tour_detail (
    tour_detail_id  NUMBER PRIMARY KEY,
    facility_id     NUMBER REFERENCES facilities(facility_id),
    start_time      TIMESTAMP,
    available_spots NUMBER
);

CREATE TABLE transactions (
    transaction_id   NUMBER PRIMARY KEY,
    visitor_id       NUMBER REFERENCES visitors(visitor_id),
    transaction_type NUMBER,
    facility_id      NUMBER REFERENCES facilities(facility_id),
    start_time       TIMESTAMP,
    num_of_days      NUMBER,
    num_adults       NUMBER,
    num_children     NUMBER,
    total_price      NUMBER(10,2),
    status           NUMBER
);

CREATE TABLE message (
    message_id   NUMBER PRIMARY KEY,
    visitor_id   NUMBER REFERENCES visitors(visitor_id),
    message_time TIMESTAMP,
    message_body VARCHAR2(4000)
);

--------------------------------------------------------------
-- 4. CREATE SEQUENCES
--------------------------------------------------------------
CREATE SEQUENCE seq_park_id        START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE seq_visitor_id     START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE seq_facility_id    START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE seq_tour_detail_id START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE seq_txn_id         START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE seq_message_id     START WITH 4 INCREMENT BY 1;

--------------------------------------------------------------
-- 5. INSERT SAMPLE DATA
--------------------------------------------------------------

-- ===== PARKS =====
INSERT INTO parks VALUES (1, 'Rock Creek Park',   '123 Park Lane',     'MD', '20852');
INSERT INTO parks VALUES (2, 'Blue Ridge Park',   '555 Mountain Rd',   'VA', '22030');
INSERT INTO parks VALUES (3, 'Walnut Woods Park', '900 Forest Dr',     'PA', '19019');

-- ===== VISITORS =====
INSERT INTO visitors VALUES (1, 'John Doe',   'john@gmail.com',  '1 Main St', 'MD', '21001');
INSERT INTO visitors VALUES (2, 'Sarah Kim',  'sarah@gmail.com', '22 Pine St','VA', '22033');
INSERT INTO visitors VALUES (3, 'Carlos Ruiz','carlos@yahoo.com','98 Lake Rd','PA', '19020');

-- ===== FACILITIES =====
-- Campsites
INSERT INTO facilities VALUES (1, 1, 'Oak Campsite',   'campsite', 6, 45, NULL, 1, NULL);
INSERT INTO facilities VALUES (2, 1, 'Pine Campsite',  'campsite', 4, 35, NULL, 1, NULL);

-- Parking Lots
INSERT INTO facilities VALUES (3, 1, 'Lot A',          'parking', 100, NULL, NULL, 1, 20);
INSERT INTO facilities VALUES (4, 2, 'Lot B',          'parking', 80,  NULL, NULL, 3, 80);

-- Tours
INSERT INTO facilities VALUES (5, 3, 'Creek Tour',     'tour', 20, 22, 11, 1, NULL);
INSERT INTO facilities VALUES (6, 3, 'Forest Adventure','tour', 15, 18, 9,  1, NULL);

-- ===== TOUR DETAILS =====
INSERT INTO tour_detail VALUES (1, 5, TO_TIMESTAMP('2025-12-21 10:00','YYYY-MM-DD HH24:MI'), 15);
INSERT INTO tour_detail VALUES (2, 5, TO_TIMESTAMP('2025-12-21 14:00','YYYY-MM-DD HH24:MI'), 10);
INSERT INTO tour_detail VALUES (3, 6, TO_TIMESTAMP('2025-12-22 09:00','YYYY-MM-DD HH24:MI'), 12);

-- ===== TRANSACTIONS =====
INSERT INTO transactions VALUES (
    1, 1, 2, 1,
    TO_TIMESTAMP('2025-12-20 15:00','YYYY-MM-DD HH24:MI'),
    2, 2, 1, 90, 1
);

INSERT INTO transactions VALUES (
    2, 2, 3, 5,
    TO_TIMESTAMP('2025-12-21 10:00','YYYY-MM-DD HH24:MI'),
    1, 1, 1, 33, 1
);

INSERT INTO transactions VALUES (
    3, 3, 2, 2,
    TO_TIMESTAMP('2025-12-23 15:00','YYYY-MM-DD HH24:MI'),
    3, 2, 0, 105, 1
);

-- ===== MESSAGES =====
INSERT INTO message VALUES (1, 1, SYSTIMESTAMP, 'Welcome to Rock Creek Park!');
INSERT INTO message VALUES (2, 2, SYSTIMESTAMP, 'Your tour reservation is confirmed.');
INSERT INTO message VALUES (3, 3, SYSTIMESTAMP, 'Your campsite reservation is confirmed.');

--------------------------------------------------------------
-- END OF SETUP SECTION
-- Next section is for FEATURES (1–10)
-- Add your procedures below this line
--------------------------------------------------------------
