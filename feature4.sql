SET DEFINE OFF


-- Child tables first
DROP TABLE tour_detail CASCADE CONSTRAINTS;
DROP TABLE transactions CASCADE CONSTRAINTS;
DROP TABLE message CASCADE CONSTRAINTS;
DROP TABLE facilities CASCADE CONSTRAINTS;
DROP TABLE visitors CASCADE CONSTRAINTS;
DROP TABLE parks CASCADE CONSTRAINTS;

-- Sequences
DROP SEQUENCE seq_park_id;
DROP SEQUENCE seq_visitor_id;
DROP SEQUENCE seq_facility_id;
DROP SEQUENCE seq_tour_detail_id;
DROP SEQUENCE seq_txn_id;
DROP SEQUENCE seq_message_id;


-- CREATE tables
-- Parks
CREATE TABLE parks (
    park_id   NUMBER(10)     PRIMARY KEY,
    park_name VARCHAR2(120)  NOT NULL UNIQUE,
    address   VARCHAR2(150)  NOT NULL,
    state     CHAR(2)        NOT NULL,
    zipcode   VARCHAR2(10)   NOT NULL,
    CONSTRAINT chk_parks_state CHECK (REGEXP_LIKE(state, '^[A-Z]{2}$')),
    CONSTRAINT chk_parks_zip   CHECK (REGEXP_LIKE(zipcode, '^[0-9]{5}(-[0-9]{4})?$'))
);

-- Visitors
CREATE TABLE visitors (
    visitor_id NUMBER(10)     PRIMARY KEY,
    name       VARCHAR2(120)  NOT NULL,
    email      VARCHAR2(150)  NOT NULL UNIQUE,
    address    VARCHAR2(150)  NOT NULL,
    state      CHAR(2)        NOT NULL,
    zipcode    VARCHAR2(10)   NOT NULL,
    CONSTRAINT chk_vis_state CHECK (REGEXP_LIKE(state, '^[A-Z]{2}$')),
    CONSTRAINT chk_vis_zip   CHECK (REGEXP_LIKE(zipcode, '^[0-9]{5}(-[0-9]{4})?$'))
);

-- Facilities (one table for campsites, parking lots, tours)
-- facility_type: 'campsite' | 'parking' | 'tour'
-- status: 1=open, 2=closed, 3=full, 4=limited  (used for parking lots per Feature 4/5)
CREATE TABLE facilities (
    facility_id   NUMBER(10)     PRIMARY KEY,
    park_id       NUMBER(10)     NOT NULL,
    facility_name VARCHAR2(120)  NOT NULL,
    facility_type VARCHAR2(20)   NOT NULL,
    capacity      NUMBER(6)      NOT NULL,     -- for campsite: max people; parking: total spots; tour: per-start default cap
    daily_price   NUMBER(8,2),                  -- campsite daily price
    child_price   NUMBER(8,2),                  -- tour child price (NULL for others)
    status        NUMBER(1) DEFAULT 1 NOT NULL, -- only meaningful for parking lots (Feature 4/5)
    spots_taken   NUMBER(6) DEFAULT 0,          -- only used for parking lots (Feature 5)
    CONSTRAINT fk_facilities_park FOREIGN KEY (park_id) REFERENCES parks(park_id),
    CONSTRAINT chk_fac_type CHECK (facility_type IN ('campsite','parking','tour')),
    CONSTRAINT chk_fac_status CHECK (status IN (1,2,3,4)),
    CONSTRAINT chk_fac_caps CHECK (capacity >= 0),
    CONSTRAINT chk_fac_spots CHECK (spots_taken >= 0)
);

-- Tour time slots (each row is a scheduled start with current availability)
CREATE TABLE tour_detail (
    tour_detail_id NUMBER(10)   PRIMARY KEY,
    facility_id    NUMBER(10)   NOT NULL,      -- FK to facilities(facility_type='tour')
    start_time     TIMESTAMP    NOT NULL,
    available_spots NUMBER(6)   NOT NULL,
    CONSTRAINT fk_tour_fac FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

-- Transactions (type: 1=entry/other, 2=campsite reservation, 3=tour reservation)
-- status: 1=reserved, 2=completed, 3=canceled

CREATE TABLE transactions (
    transaction_id NUMBER(10)   PRIMARY KEY,
    visitor_id     NUMBER(10)   NOT NULL,
    transaction_type NUMBER(1)  NOT NULL,
    facility_id    NUMBER(10),                 -- NULL allowed for generic entry tickets if desired
    start_time     TIMESTAMP,                  -- check-in 3pm for campsite per Feature 7
    num_of_days    NUMBER(5),                  -- 1 for tours per Feature 8
    num_adults     NUMBER(5) DEFAULT 0,
    num_children   NUMBER(5) DEFAULT 0,
    total_price    NUMBER(10,2),
    status         NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT fk_txn_visitor FOREIGN KEY (visitor_id) REFERENCES visitors(visitor_id),
    CONSTRAINT fk_txn_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id),
    CONSTRAINT chk_txn_type CHECK (transaction_type IN (1,2,3)),
    CONSTRAINT chk_txn_status CHECK (status IN (1,2,3)),
    CONSTRAINT chk_txn_nonneg CHECK (num_of_days >= 0 AND num_adults >= 0 AND num_children >= 0)
);

-- Messages (required by spec #9)
CREATE TABLE message (
    message_id   NUMBER(10)   PRIMARY KEY,
    visitor_id   NUMBER(10)   NOT NULL,
    message_time TIMESTAMP    NOT NULL,
    body         VARCHAR2(2000) NOT NULL,
    CONSTRAINT fk_msg_visitor FOREIGN KEY (visitor_id) REFERENCES visitors(visitor_id)
);


-- 2) CREATE sequences
CREATE SEQUENCE seq_park_id        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_visitor_id     START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_facility_id    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_tour_detail_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_txn_id         START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_message_id     START WITH 1 INCREMENT BY 1 NOCACHE;

-- 3) INSERT sample data 

-- Parks (3)
INSERT INTO parks(park_id, park_name, address, state, zipcode)
VALUES (seq_park_id.NEXTVAL, 'Centennial Park', '13459 Centennial Lane', 'MD', '21042');
INSERT INTO parks(park_id, park_name, address, state, zipcode)
VALUES (seq_park_id.NEXTVAL, 'Patapsco Valley Park', '8020 Baltimore National Pike', 'MD', '21228');
INSERT INTO parks(park_id, park_name, address, state, zipcode)
VALUES (seq_park_id.NEXTVAL, 'Rock Creek Park', '5200 Glover Rd NW', 'DC', '20015');

-- Visitors (3)
INSERT INTO visitors(visitor_id, name, email, address, state, zipcode)
VALUES (seq_visitor_id.NEXTVAL, 'Milly Stone', 'milly@gmail.com', '1000 Hilltop Cir', 'MD', '21250');
INSERT INTO visitors(visitor_id, name, email, address, state, zipcode)
VALUES (seq_visitor_id.NEXTVAL, 'Samuel Diaz', 'sam.diaz@example.com', '33rd & Walnut St', 'PA', '19104');
INSERT INTO visitors(visitor_id, name, email, address, state, zipcode)
VALUES (seq_visitor_id.NEXTVAL, 'Celeste Ng', 'celeste.ng@example.com', '500 W 120th St', 'NY', '10027');

-- Facilities (9) — 3 per park: one campsite, one parking lot, one tour
-- Park 1 (Centennial)
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 1, 'Campsite A1', 'campsite', 6, 45.00, NULL, 1, NULL);
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 1, 'Lot North',   'parking', 120, NULL, NULL, 1, 20);
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 1, 'Lake Tour',   'tour',     25, 30.00, 15.00, 1, NULL);

-- Park 2 (Patapsco)
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 2, 'Campsite B2', 'campsite', 8, 55.00, NULL, 1, NULL);
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 2, 'Lot River',   'parking', 80, NULL, NULL, 1, 78);
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 2, 'Ridge Tour',  'tour',     15, 25.00, 12.00, 1, NULL);

-- Park 3 (Rock Creek)
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 3, 'Campsite C3', 'campsite', 4, 35.00, NULL, 1, NULL);
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 3, 'Lot Meadow',  'parking', 200, NULL, NULL, 1, 0);
INSERT INTO facilities(facility_id, park_id, facility_name, facility_type, capacity, daily_price, child_price, status, spots_taken)
VALUES (seq_facility_id.NEXTVAL, 3, 'Creek Tour', 'tour', 20, 22.00, 11.00, 2, NULL);


-- Tour time slots 
INSERT INTO tour_detail(tour_detail_id, facility_id, start_time, available_spots)
VALUES (seq_tour_detail_id.NEXTVAL, 3, TO_TIMESTAMP('2025-10-20 09:00','YYYY-MM-DD HH24:MI'), 25);
INSERT INTO tour_detail(tour_detail_id, facility_id, start_time, available_spots)
VALUES (seq_tour_detail_id.NEXTVAL, 3, TO_TIMESTAMP('2025-10-20 14:00','YYYY-MM-DD HH24:MI'), 10);
INSERT INTO tour_detail(tour_detail_id, facility_id, start_time, available_spots)
VALUES (seq_tour_detail_id.NEXTVAL, 6, TO_TIMESTAMP('2025-10-21 10:00','YYYY-MM-DD HH24:MI'), 15);

-- Transactions 
-- Type 1 (entry/other) for stats; Type 2 (campsite); Type 3 (tour)
INSERT INTO transactions(transaction_id, visitor_id, transaction_type, facility_id, start_time, num_of_days, num_adults, num_children, total_price, status)
VALUES (seq_txn_id.NEXTVAL, 1, 1, NULL, TO_TIMESTAMP('2025-10-10 10:00','YYYY-MM-DD HH24:MI'), 1, 2, 0, 20.00, 2);
INSERT INTO transactions(transaction_id, visitor_id, transaction_type, facility_id, start_time, num_of_days, num_adults, num_children, total_price, status)
VALUES (seq_txn_id.NEXTVAL, 1, 2, 1,    TO_TIMESTAMP('2025-10-25 15:00','YYYY-MM-DD HH24:MI'), 2, 2, 1, 90.00, 1);
INSERT INTO transactions(transaction_id, visitor_id, transaction_type, facility_id, start_time, num_of_days, num_adults, num_children, total_price, status)
VALUES (seq_txn_id.NEXTVAL, 2, 3, 3,    TO_TIMESTAMP('2025-10-20 09:00','YYYY-MM-DD HH24:MI'), 1, 1, 1, 45.00, 1);

-- Messages 
INSERT INTO message(message_id, visitor_id, message_time, body)
VALUES (seq_message_id.NEXTVAL, 1, SYSTIMESTAMP, 'Welcome to Centennial Park!');
INSERT INTO message(message_id, visitor_id, message_time, body)
VALUES (seq_message_id.NEXTVAL, 2, SYSTIMESTAMP, 'Your tour reservation is pending.');
INSERT INTO message(message_id, visitor_id, message_time, body)
VALUES (seq_message_id.NEXTVAL, 3, SYSTIMESTAMP, 'Campsite tips: quiet hours begin at 10pm.');

COMMIT;

-- Feature 4: List all parking lots that have available spots in a park
create or replace procedure list_available_parking(v_park_name varchar)
as
    v_count int;
begin
    -- 1)check whether there is a park with the input park name
    select count(*) into v_count from parks where park_name = v_park_name;
    
    -- if the park doesn't exist
    if v_count = 0 then
        dbms_output.put_line('No such park');
        return;
    end if;
    
    -- 2) print the availability status of existing parking lots
    -- 1=open, 2=closed, 3=full, 4=limited
    for r in (
        select f.facility_name,
            case f.status
                when 1 then 'open'
                when 2 then 'closed'
                when 3 then 'full'
                when 4 then 'limited'
            end as status_text
        from facilities f, parks p
        where f.park_id = p.park_id and p.park_name = v_park_name and f.facility_type = 'parking' 
        -- nvl handles null values, check to make sure there are open spots
        and nvl(f.spots_taken,0) < f.capacity and f.status in (1,4)
    ) loop
        v_count := v_count +1;
        dbms_output.put_line('Parking Lot: ' || r.facility_name || ' availability is ' || r.status_text);
    end loop;
    
    -- if there are no parking lots that are available in a park
    if v_count = 0 then
        dbms_output.put_line('There are no available parking lots in this park');
    end if;
end;
/

-- Test 1: Regular Case
-- Check an existing park for available parking spots

set serveroutput on;

begin
    dbms_output.put_line('Test 1');
    list_available_parking('Centennial Park');
end;
/

-- Test 2: Special Case
-- Check a nonexiting park for parking spots

begin
    dbms_output.put_line('Test 2');
    list_available_parking('Yosemite National Park');
end;
/

-- Test 3: Special
-- Existing park but there are no available parking spots
-- have to update one of the parks to 'full'
declare
begin
    update facilities f set f.spots_taken = f.capacity, f.status = 3
    where f.facility_type = 'parking'
    and f.park_id = (
        select park_id from parks where park_name = 'Patapsco Valley Park' 
    );
    
commit;
    dbms_output.put_line('Test 3');
    list_available_parking('Patapsco Valley Park');
end;
/


-- Feature 9








