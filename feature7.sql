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

-- use select statement and checkfacil

select count (*) 
into checkCamp
from facilities
where facility_type = 'campsite'  and facility_id=fid;

if checkCamp= 0 then 
    dbms_output.put_line('No Such Campsite  ') ; 
    return;
    end if; 

--use select statement and checkVisit

select count(*)
into checkVisit
from visitors
where visitor_id=vid;

if checkVisit= 0 then 
    dbms_output.put_line('No Such Visitor  ') ; 
    return; 
    end if; 
    
    
--Use select staterment and totalInput and capacity

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
and t.status !=3; 

if v_count > 0 then 
    select t.start_time , t.num_of_days
    into  v_stTime, v_numDays
    from transactions t
    where t.transaction_type = 2 and t.status!=3 and t.facility_id=fid
    and rownum=1;


v_CurEndCalc:= trunc(v_stTime)+ numtodsinterval(v_numDays,'day');
v_CurStCalc:=trunc(v_stTime);

v_newStCalc:= trunc(sDate);
v_newEndCalc:=  trunc(sDate ) + numtodsinterval(daysnumber,'day'); 

if v_newStCalc < v_CurEndCalc and v_CurStCalc < v_newEndCalc then 
 dbms_output.put_line ('The campsite is not available due to a conflict');
 return; 
 end if; 
end if;
 
select daily_price
into v_getDPrice
from facilities
where facility_id=fid;

totalPrice:= daysnumber*v_getDPrice; 

select max(transaction_id)
into findMaxFID
from transactions;



insert into transactions (transaction_id, visitor_id, transaction_type, facility_id, start_time, num_of_days, num_adults, num_children, total_price, status)
values (findMaxFID+1, vid, 2,fid, trunc(sdate)+ numtodsinterval (15, 'HOUR' ), daysnumber,   adultnumber,childnumber, totalPrice, 1) ;


select max(message_id)
into findMaxMID
from message;

select facility_name
into v_getFname
from facilities 
where facility_id=fid; 

insertBody:= 'Thanks for reserving campsite ' || v_getFname || ' from  ' || sdate || ' for ' || daysnumber|| ' days. ' ; 
insert into message( message_id, visitor_id, message_time, body )
values (findMaxMID+1, vid, systimestamp, insertBody) ; 


end; 

/

--EXEC featureSevens(1, 1, DATE '2025-10-25', 2, 2, 1);
--EXEC featureSevens(4, 2, DATE '2025-10-20', 3, 2, 0);
--EXEC featureSevens(1, 3, DATE '2025-12-10', 2, 2, 1);
--EXEC featureSevens(1, 33333, DATE '2025-12-10', 2, 2, 1);
---EXEC featureSevens(111111, 3, DATE '2025-12-10', 2, 2, 1);

--EXEC featureSevens(4, 3, DATE '2025-12-15', 4, 2, 1);

--EXEC featureSevens(4, 1, DATE '2025-10-22', 2, 1, 1);
