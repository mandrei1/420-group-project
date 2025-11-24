/*
CREATE TABLE tour_detail (
    tour_detail_id NUMBER(10)   PRIMARY KEY,
    facility_id    NUMBER(10)   NOT NULL,      -- FK to facilities(facility_type='tour')
    start_time     TIMESTAMP    NOT NULL,
    available_spots NUMBER(6)   NOT NULL,
    CONSTRAINT fk_tour_fac FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);
*/
--alter table tour_detail
--add tour_name varchar2(250); 
--alter table tour_detail
--add tour_date date; 


/*


UPDATE TOUR_DETAIL
SET TOUR_NAME = 'Tour A'
WHERE TOUR_DETAIL_ID = 1;
UPDATE TOUR_DETAIL
SET TOUR_NAME = 'Tour B'
WHERE TOUR_DETAIL_ID = 2;
UPDATE TOUR_DETAIL
SET TOUR_NAME = 'Tour C'
WHERE TOUR_DETAIL_ID = 3;
UPDATE TOUR_DETAIL
SET TOUR_DATE = TO_DATE('2025-10-20', 'YYYY-MM-DD')
WHERE TOUR_DETAIL_ID = 1;
UPDATE TOUR_DETAIL
SET TOUR_DATE = TO_DATE('2025-10-20', 'YYYY-MM-DD')
WHERE TOUR_DETAIL_ID = 2;
UPDATE TOUR_DETAIL
SET TOUR_DATE = TO_DATE('2025-10-21', 'YYYY-MM-DD')
WHERE TOUR_DETAIL_ID = 3;
commit ;

*/

set serveroutput on; 
create or replace procedure listTimeSpots ( tname in varchar2 , tdate in date ) 
is
checkCond number; 
begin 
select count(*)
into checkCond
from tour_detail
where tour_name=tname and tour_date=tdate; 
if checkCond=0 then
    dbms_output.put_line( 'No such tour' ) ; 
    return;
    end if; 
for allspots in (      
select start_time , available_spots 
from tour_detail
where tour_name=tname and tour_date=tdate
)
 loop
dbms_output.put_line('Start time: '|| allspots.start_time || ' Available Spots: ' || allspots.available_spots );
end loop;

end;
/ 
--EXEC listTimeSpots(  'Tour A' ,DATE '2025-10-20' );
--EXEC listTimeSpots(‘Tour D’ , DATE ‘2024-10-20’);
