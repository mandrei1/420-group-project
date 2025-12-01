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
--Update Statements to tour_detail table, alter and update for Feature 3

alter table tour_detail
add tour_name varchar2(250); 

UPDATE TOUR_DETAIL
SET TOUR_NAME = 'Tour A'
WHERE TOUR_DETAIL_ID = 1;
UPDATE TOUR_DETAIL
SET TOUR_NAME = 'Tour B'
WHERE TOUR_DETAIL_ID = 2;
UPDATE TOUR_DETAIL
SET TOUR_NAME = 'Tour C'
WHERE TOUR_DETAIL_ID = 3;


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
-----------------------------------------------------------------------
--Feature 3 (Shreyan) Given a tour and a date, list all available tour start time and available spots. 
-----------------------------------------------------------------------
create or replace procedure listTimeSpots ( tname in varchar2 , tdate in date ) 
is
checkCond number; 
begin 
select count(*)
into checkCond
from tour_detail
where tour_name=tname and trunc(start_time)=tdate; 
-- If there is a tour with this name than proceed, if not print 'No such tour' 
if checkCond=0 then
    dbms_output.put_line( 'No such tour' ) ; 
    return;
    end if; 
for allspots in (      
select start_time , available_spots 
from tour_detail
where tour_name=tname and trunc(start_time)=tdate
)
 loop
    --print out all start times and number of available spots of that tour on the input date.  
dbms_output.put_line('Start time: '|| allspots.start_time || ' Available Spots: ' || allspots.available_spots );
end loop;

end;
/
EXEC listTimeSpots(  'Tour A' ,DATE '2025-12-21' );
EXEC listTimeSpots('Tour C' , DATE '2025-12-22');
--Special case where the tour does not exist because wrong date and name
EXEC listTimeSpots('Tour D' , DATE '2025-12-22');
    
-----------------------------------------------------------------------
-- Feature 4 (Alex) - List all parking lots that have available spots in a park
-----------------------------------------------------------------------
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
    

--feature 5 (Rosaire) update status of a parking lot
CREATE OR REPLACE PROCEDURE update_parking_status (
    p_facility_id IN NUMBER,
    p_spots_taken IN NUMBER
)
IS
    v_exist       NUMBER;
    v_capacity    facilities.capacity%TYPE;
    v_name        facilities.facility_name%TYPE;
BEGIN
    -- 1) Validate facility ID AND ensure it's a parking lot
    SELECT COUNT(*)
    INTO v_exist
    FROM facilities
    WHERE facility_id = p_facility_id
      AND facility_type = 'parking';

    IF v_exist = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Invalid facility ID');
        RETURN;
    END IF;

    -- Retrieve capacity + name
    SELECT capacity, facility_name
    INTO v_capacity, v_name
    FROM facilities
    WHERE facility_id = p_facility_id;

    -- 2) Update spots_taken
    UPDATE facilities
    SET spots_taken = p_spots_taken
    WHERE facility_id = p_facility_id;

    -- 3) FULL
    IF p_spots_taken >= v_capacity THEN
        UPDATE facilities
        SET status = 3   -- full
        WHERE facility_id = p_facility_id;

        DBMS_OUTPUT.PUT_LINE('The parking lot ' || v_name || ' becomes FULL.');

    -- 4) LIMITED
    ELSIF p_spots_taken >= 0.9 * v_capacity THEN
        UPDATE facilities
        SET status = 4   -- limited
        WHERE facility_id = p_facility_id;

        DBMS_OUTPUT.PUT_LINE('The parking lot ' || v_name || ' becomes LIMITED.');

    -- 5) OPEN
    ELSE
        UPDATE facilities
        SET status = 1   -- open
        WHERE facility_id = p_facility_id;

        DBMS_OUTPUT.PUT_LINE('The parking lot ' || v_name || ' is OPEN.');
    END IF;
END;
/
-- Feature 6 (Rosaire) — List Available Campsites
CREATE OR REPLACE PROCEDURE list_available_campsites (
    p_park_name  IN VARCHAR2,
    p_start_date IN DATE,
    p_end_date   IN DATE,
    p_num_people IN NUMBER
)
AS
    v_park_id   parks.park_id%TYPE;
    v_conflicts NUMBER;
    v_match     NUMBER := 0;  -- 0 = no matches, 1 = at least one match
BEGIN
    -- 1) Check that the park exists
    BEGIN
        SELECT park_id
          INTO v_park_id
          FROM parks
         WHERE park_name = p_park_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No such park.');
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
        -- 3) Check for conflicting reservations on this campsite
        --    Reserved duration: TRUNC(start_time) to TRUNC(start_time) + num_of_days
        SELECT COUNT(*)
          INTO v_conflicts
          FROM transactions t
         WHERE t.facility_id = camp_rec.facility_id
           AND t.transaction_type = 2           -- campsite reservation
           AND t.status <> 3                    -- not canceled
           AND TRUNC(t.start_time) < p_end_date
           AND p_start_date < TRUNC(t.start_time) + t.num_of_days;

        IF v_conflicts = 0 THEN
            v_match := 1;

            DBMS_OUTPUT.PUT_LINE(
                'Campsite: ' || camp_rec.facility_name ||
                ' | Max people: ' || camp_rec.capacity
            );
        END IF;
    END LOOP;

    -- 4) If no campsite matched
    IF v_match = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No matches');
    END IF;
END;
/
--------------------------------------------------------------
/* Feature 7 (Shreyan) - Reserve a campsite. 
    Input includes a facility id, a visitor ID a start date, 
    number of days, number of adults, number of children. 
*/
--------------------------------------------------------------
set serveroutput on; 

create or replace procedure featureSevens(fid in number, vid in number, sDate in date, daysnumber in number, adultnumber in number, childnumber in number) 
is 
  
-- variables
checkCamp number; 
checkVisit number; 
totalInput number:= adultnumber+childnumber;
totalPrice number;
v_getDPrice number;
findMaxFID number;
findMaxMID number;
v_capacity number;
v_count number; 
v_CurEndCalc timestamp;
v_CurStCalc  timestamp;
v_newendCalc timestamp;
v_newstCalc timestamp;
v_fType facilities.facility_type%type;
v_fStatus facilities.status%type;
v_stTime transactions.start_time%type;
v_numDays transactions.num_of_days%type;

v_getFname facilities.facility_name%type;
insertbody varchar2(4000); 



begin 

-- use select statement and if campsite exists 

select count (*) 
into checkCamp
from facilities
where facility_type = 'campsite'  and facility_id=fid;

if checkCamp= 0 then 
    dbms_output.put_line('No Such Campsite  ') ; 
    return;
    end if; 

--use select statement and check if the visitor exists

select count(*)
into checkVisit
from visitors
where visitor_id=vid;

if checkVisit= 0 then 
    dbms_output.put_line('No Such Visitor  ') ; 
    return; 
    end if; 
    
    
--Use select staterment and totalInput to check capacity

select capacity
into v_capacity
from facilities
where facility_id=fid;

if totalInput> v_capacity then
    dbms_output.put_line('Insuffient Capacity' ); 
    return; 
    end if;
    
    
    
--use select statement and go to step 3 of feature 6 -- use durationCalc

select count(*) into v_count
from transactions t
where t.facility_id=fid
and t.transaction_type=2
and t.status !=3
and trunc(sDate) < trunc(t.start_time) + NUMTODSINTERVAl(t.num_of_days, 'DAY')
and trunc(t.start_time)< trunc(sdate)+ NUMTODSINTERVAL(daysnumber, 'DAY'); 

if v_count > 0 then 
 dbms_output.put_line ('The campsite is not available due to a conflict');
 return; 
 end if; 

 
select daily_price
into v_getDPrice
from facilities
where facility_id=fid;

totalPrice:= daysnumber*v_getDPrice; 



-- insert if no conflict 

insert into transactions (transaction_id, visitor_id, transaction_type, facility_id, start_time, num_of_days, num_adults, num_children, total_price, status)
values (seq_txn_id.nextval, vid, 2,fid, trunc(sdate)+ numtodsinterval (15, 'HOUR' ), daysnumber,   adultnumber,childnumber, totalPrice, 1) ;




select facility_name
into v_getFname
from facilities 
where facility_id=fid; 

-- insert if no conflict 
insertBody:= 'Thanks for reserving campsite ' || v_getFname || ' from  ' || sdate || ' for ' || daysnumber|| ' days. ' ; 
insert into message( message_id, visitor_id, message_time, message_body )
values (seq_message_id.NextVal, vid, systimestamp, insertBody);


end; 

/



-- Successful
EXEC featureSevens(2, 2, DATE '2026-02-15', 4, 3, 2);

-- Conflict Cases
EXEC featureSevens(1, 3, DATE '2026-03-05', 3, 2, 1);
EXEC featureSevens(1, 2, DATE '2026-04-18', 5, 4, 1);
EXEC featureSevens(2, 1, DATE '2026-05-22', 6, 5, 3);

-- Successful — No Conflict
EXEC featureSevens(2, 3, DATE '2027-08-10', 3, 2, 1);

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

    INSERT INTO message (message_id, visitor_id, message_time, message_body)
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

------------------------------------------
-- Feature 9 (Alex): Cancel a transaction
-- Input is transaction ID
------------------------------------------
create or replace procedure cancel_transaction(v_tid number)
as
    v_status number;    -- status of transaction
    v_vid    number;    -- visitor id
    v_fid    number;    -- facility id
    v_type   number;    -- transaction type(1=entry/other, 2=campsite reservation, 3=tour reservation)
    v_start_time timestamp; -- start time for transaction
    v_num_adults number;
    v_num_children number;
    v_available_spots number;   -- available spots for a tour
    v_tour_name varchar(100);   -- name of tour   
begin
   
   -- 1) check if a transaction exits
   begin
        select status, visitor_id, facility_id, start_time, num_adults, num_children, transaction_type
        into v_status, v_vid, v_fid, v_start_time, v_num_adults, v_num_children, v_type
        from transactions
        where transaction_id = v_tid;
    exception
        when no_data_found then
            dbms_output.put_line('Transaction not found');
            return;
    end;
    
    -- 2) check if the status of the transaction is already canceled
    if v_status = 3 then        -- status 3 = canceled
        dbms_output.put_line('This transaction already gets canceled');
        return;
    end if;
    
    -- 3) update the status to canceled if the transaction has not been canceled
    update transactions
    set status = 3
    where transaction_id = v_tid;
    
    -- 4) find the associated tour detail for a tour reservation
    -- update the availibility of the tour
if v_type = 3 then
    begin
        select f.facility_name, td.available_spots
        into v_tour_name, v_available_spots
        from tour_detail td, facilities f
        where f.facility_id = td.facility_id
        and td.facility_id = v_fid
        and td.start_time = v_start_time;
        
        -- increase the num of available spots by adding num of adults and children
        v_available_spots := v_available_spots + nvl(v_num_adults,0) + nvl(v_num_children,0);
        
        -- update the available spots to tour details
        update tour_detail
        set available_spots = v_available_spots
        where facility_id = v_fid and start_time = v_start_time;
        
        -- print the new tour details
        dbms_output.put_line('Tour ' || v_tour_name || ' starting at ' || v_start_time ||
        ' now has ' || v_available_spots || ' available spots');
        
        -- exception for tour detial that do not match tour reservation type 3
        exception 
            when no_data_found then
                dbms_output.put_line('There is no match in tour_detail');
        end;
end if;

    
    -- 5) insert a transaction message for the new canceled transaction
    insert into message(message_id, visitor_id, message_time, message_body)
    values (seq_message_id.nextval, v_vid, systimestamp, 
    'Your transaction ' || v_tid || ' has been canceled');
    
    commit;
end;
/

set serveroutput on;
 
-- Test Case 1: Regular Case
-- Canceling tour reservation
begin
    dbms_output.put_line('Test 1 cancel transaction');
    cancel_transaction(3);
end;
/

-- Test Case 2: Special Case
-- Canceling tour reservation that has already been canceled
begin
    dbms_output.put_line('Test 2 cancel tour that has already been canceled');
    cancel_transaction(3);   
end;
/

-- Test Case 3: Special Case
-- No transaction was found
begin
    dbms_output.put_line('Test 3 canceling transaction that does not exist');
    cancel_transaction(123);
end;
/

-- Test Case 4: Special Case
-- Canceling another tour type that is not tour reservartion (type 3)
-- other types: types 1 = entry and type 2 = campsite
begin
    dbms_output.put_line('Test 4 canceling other transaction type');
    cancel_transaction(2);
end;
/

--------------------------------------------------------------
-- Feature 10 (Udoka) — Print Statistics
--------------------------------------------------------------

CREATE OR REPLACE PROCEDURE print_statistics (
    p_start_date IN DATE,
    p_end_date   IN DATE
)
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== Feature 10: Statistics from '
                         || TO_CHAR(p_start_date, 'YYYY-MM-DD')
                         || ' to '
                         || TO_CHAR(p_end_date, 'YYYY-MM-DD')
                         || ' =====');

    ----------------------------------------------------------
    -- 1) Park name + total # uncanceled transactions + total $
    ----------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- (1) Transactions and Revenue per Park ---');

    FOR rec IN (
        SELECT p.park_name,
               COUNT(*) AS txn_count,
               NVL(SUM(t.total_price), 0) AS total_revenue
        FROM parks p
        JOIN facilities f
          ON f.park_id = p.park_id
        JOIN transactions t
          ON t.facility_id = f.facility_id
        WHERE t.status <> 3
          AND TRUNC(t.start_time) BETWEEN p_start_date AND p_end_date
        GROUP BY p.park_name
        ORDER BY p.park_name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Park: ' || rec.park_name ||
            ' | Transactions: ' || rec.txn_count ||
            ' | Total price: ' || rec.total_revenue
        );
    END LOOP;


    ----------------------------------------------------------
    -- 2) Name of each park + number of visitors (type 1)
    ----------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- (2) Number of Visitors per Park (type 1) ---');

    FOR rec IN (
        SELECT p.park_name,
               COUNT(*) AS num_visitors
        FROM parks p
        JOIN facilities f
          ON f.park_id = p.park_id
        JOIN transactions t
          ON t.facility_id = f.facility_id
        WHERE t.status <> 3
          AND t.transaction_type = 1
          AND TRUNC(t.start_time) BETWEEN p_start_date AND p_end_date
        GROUP BY p.park_name
        ORDER BY p.park_name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Park: ' || rec.park_name ||
            ' | Visitors (type 1 txns): ' || rec.num_visitors
        );
    END LOOP;


    ----------------------------------------------------------
    -- 3) For each park: campsite with most uncanceled reservations
    ----------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- (3) Top Campsite per Park (by reservations) ---');

    FOR rec IN (
        SELECT park_name,
               facility_name,
               reservation_count
        FROM (
            SELECT p.park_name,
                   f.facility_name,
                   COUNT(*) AS reservation_count,
                   ROW_NUMBER() OVER (
                       PARTITION BY p.park_id
                       ORDER BY COUNT(*) DESC, f.facility_name
                   ) AS rn
            FROM parks p
            JOIN facilities f
              ON f.park_id = p.park_id
            JOIN transactions t
              ON t.facility_id = f.facility_id
            WHERE f.facility_type = 'campsite'
              AND t.transaction_type = 2      -- campsite reservation
              AND t.status <> 3               -- not canceled
              AND TRUNC(t.start_time) BETWEEN p_start_date AND p_end_date
            GROUP BY p.park_id, p.park_name, f.facility_name
        )
        WHERE rn = 1
        ORDER BY park_name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Park: ' || rec.park_name ||
            ' | Top campsite: ' || rec.facility_name ||
            ' | Reservations: ' || rec.reservation_count
        );
    END LOOP;


    ----------------------------------------------------------
    -- 4) For each park: tour with most uncanceled reservations
    ----------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- (4) Top Tour per Park (by reservations) ---');

    FOR rec IN (
        SELECT park_name,
               facility_name,
               reservation_count
        FROM (
            SELECT p.park_name,
                   f.facility_name,
                   COUNT(*) AS reservation_count,
                   ROW_NUMBER() OVER (
                       PARTITION BY p.park_id
                       ORDER BY COUNT(*) DESC, f.facility_name
                   ) AS rn
            FROM parks p
            JOIN facilities f
              ON f.park_id = p.park_id
            JOIN transactions t
              ON t.facility_id = f.facility_id
            WHERE f.facility_type = 'tour'
              AND t.transaction_type = 3      -- tour reservation
              AND t.status <> 3               -- not canceled
              AND TRUNC(t.start_time) BETWEEN p_start_date AND p_end_date
            GROUP BY p.park_id, p.park_name, f.facility_name
        )
        WHERE rn = 1
        ORDER BY park_name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Park: ' || rec.park_name ||
            ' | Top tour: ' || rec.facility_name ||
            ' | Reservations: ' || rec.reservation_count
        );
    END LOOP;

END;
/
