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

--------------------------------------------------------------
-- Feature 1 (Udoka) — Add a Visitor
--------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_visitor (
    p_name    IN VARCHAR2,
    p_email   IN VARCHAR2,
    p_address IN VARCHAR2,
    p_state   IN VARCHAR2,
    p_zip     IN VARCHAR2
)
AS
    v_visitor_id visitors.visitor_id%TYPE;
BEGIN
    -- Try to find an existing visitor by email
    BEGIN
        SELECT visitor_id
          INTO v_visitor_id
          FROM visitors
         WHERE email = p_email;

        -- If found, update their info
        UPDATE visitors
           SET name    = p_name,
               address = p_address,
               state   = p_state,
               zipcode = p_zip
         WHERE visitor_id = v_visitor_id;

        DBMS_OUTPUT.PUT_LINE(
            'The visitor already exists. Updated information for visitor ID = ' || v_visitor_id
        );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- No existing visitor → insert a new one
            v_visitor_id := seq_visitor_id.NEXTVAL;

            INSERT INTO visitors (
                visitor_id, name, email, address, state, zipcode
            ) VALUES (
                v_visitor_id, p_name, p_email, p_address, p_state, p_zip
            );

            DBMS_OUTPUT.PUT_LINE(
                'New visitor added. Visitor ID = ' || v_visitor_id
            );
    END;
END;
/
--------------------------------------------------------------
-- Feature 2 (Mara) — List all transactions placed by a visitor
--------------------------------------------------------------
CREATE OR REPLACE PROCEDURE list_transactions_by_visitor (p_name IN VARCHAR2) AS
  v_id visitors.visitor_id % TYPE;
BEGIN
  BEGIN
    SELECT
      visitor_id INTO v_id
    FROM
      visitors
    WHERE
      name = p_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE ('No such visitor');
      RETURN;
  END;
  DBMS_OUTPUT.PUT_LINE ('Transactions for visitor: ' || p_name);
  FOR rec IN (
    SELECT
      t.transaction_id,
      t.transaction_type,
      f.facility_name,
      t.start_time,
      t.num_of_days,
      t.status,
      t.total_price
    FROM
      transactions t
      LEFT JOIN facilities f ON t.facility_id = f.facility_id
    WHERE
      t.visitor_id = v_id
    ORDER BY
      t.start_time
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE (
      'Txn ID: ' || rec.transaction_id || ', Type: ' || rec.transaction_type || ', Facility: ' || NVL (rec.facility_name, 'n/a') || ', Start: ' || TO_CHAR(rec.start_time, 'YYYY-MM-DD HH24:MI') || ', Days: ' || rec.num_of_days || ', Status: ' || rec.status || ', Total: $' || rec.total_price
    );
  END LOOP;
END;
/
    
--------------------------------------------------------------
-- Feature 6 (Udoka) — List Available Campsites
--------------------------------------------------------------
CREATE OR REPLACE PROCEDURE list_available_campsites (
    p_park_name  IN VARCHAR2,
    p_start_date IN DATE,
    p_end_date   IN DATE,
    p_num_people IN NUMBER
)
AS
    v_park_id   parks.park_id%TYPE;
    v_conflicts NUMBER;
    v_match     BOOLEAN := FALSE;
BEGIN
    -- 1) Check park exists
    BEGIN
        SELECT park_id
          INTO v_park_id
          FROM parks
         WHERE park_name = p_park_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUTLINE('No such park.');
            RETURN;
    END;

    -- 2) Loop through campsites in this park that can fit p_num_people
    FOR camp_rec IN (
        SELECT facility_id,
               facility_name,
               capacity
          FROM facilities
         WHERE park_id = v_park_id
           AND facility_type = 'campsite'
           AND capacity >= p_num_people
    )
    LOOP
        -- 3) Check for conflicting reservations
        SELECT COUNT(*)
          INTO v_conflicts
          FROM transactions t
         WHERE t.facility_id = camp_rec.facility_id
           AND t.transaction_type = 2          -- campsite
           AND t.status <> 3                   -- not canceled
           AND TRUNC(t.start_time) < p_end_date
           AND p_start_date < TRUNC(t.start_time)
                                + NUMTOINTERVAL(t.num_of_days, 'DAY');

        IF v_conflicts = 0 THEN
            v_match := TRUE;
            DBMS_OUTPUT.PUT_LINE(
                'Campsite: ' || camp_rec.facility_name ||
                ' | Max people: ' || camp_rec.capacity
            );
        END IF;
    END LOOP;

    -- 4) If nothing matched
    IF NOT v_match THEN
        DBMS_OUTPUT.PUT_LINE('No matches');
    END IF;
END;
/
--------------------------------------------------------------
-- Feature 8 (Mara) — Reserve a tour
--------------------------------------------------------------
CREATE OR REPLACE PROCEDURE reserve_tour (
    p_facility_id   IN NUMBER,
    p_visitor_id    IN NUMBER,
    p_start_time    IN TIMESTAMP,
    p_num_adults    IN NUMBER,
    p_num_children  IN NUMBER
)
AS
    v_is_tour        NUMBER;
    v_visitor_exists NUMBER;
    v_tour_detail_id NUMBER;
    v_avail_spots    NUMBER;
    v_daily_price    NUMBER;
    v_child_price    NUMBER;
    v_total_price    NUMBER;
    v_facility_name  VARCHAR2(200);
    v_txn_id         NUMBER;
    v_msg_id         NUMBER;
BEGIN
    -- Check if the facility has a tour
    SELECT COUNT(*)
    INTO v_is_tour
    FROM facilities
    WHERE facility_id = p_facility_id
      AND facility_type = 'tour';

    IF v_is_tour = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No such tour');
        RETURN;
    END IF;
    -- Check if visitor exists
    SELECT COUNT(*)
    INTO v_visitor_exists
    FROM visitors
    WHERE visitor_id = p_visitor_id;

    IF v_visitor_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No such visitor');
        RETURN;
    END IF;

    -- Check if there  is a tour at that start time
    BEGIN
        SELECT tour_detail_id, available_spots
        INTO v_tour_detail_id, v_avail_spots
        FROM tour_detail
        WHERE facility_id = p_facility_id
          AND start_time = p_start_time;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No tour at the given time');
            RETURN;
    END;
    -- Check sufficient capacity
    IF v_avail_spots < (p_num_adults + p_num_children) THEN
        DBMS_OUTPUT.PUT_LINE('Insufficient capacity');
        RETURN;
    END IF;
    -- Compute the total price
    SELECT daily_price, child_price, facility_name
    INTO v_daily_price, v_child_price, v_facility_name
    FROM facilities
    WHERE facility_id = p_facility_id;

    v_total_price :=
          v_daily_price  * p_num_adults
        + v_child_price  * p_num_children;
    --  Insert transaction
    v_txn_id := seq_txn_id.NEXTVAL;

    INSERT INTO transactions (
        transaction_id, visitor_id, transaction_type,
        facility_id, start_time, num_of_days,
        num_adults, num_children, total_price, status
    )
    VALUES (
        v_txn_id, p_visitor_id, 3,
        p_facility_id, p_start_time, 1,
        p_num_adults, p_num_children, v_total_price, 1
    );

    -- Reduce available spots
    UPDATE tour_detail
    SET available_spots = available_spots - (p_num_adults + p_num_children)
    WHERE tour_detail_id = v_tour_detail_id;

    -- Insert message

    v_msg_id := seq_message_id.NEXTVAL;

    INSERT INTO message (message_id, visitor_id, message_time, body)
    VALUES (
        v_msg_id,
        p_visitor_id,
        SYSTIMESTAMP,
        'Thanks for reserving tour ' || v_facility_name ||
        ' starting at ' || TO_CHAR(p_start_time,'YYYY-MM-DD HH24:MI')
    );
    DBMS_OUTPUT.PUT_LINE('Tour reserved successfully.');

END;
/

