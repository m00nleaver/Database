--이유미

--------------------------------------------------------------------------------
-- A-1. 기초 정보 관리
--  1) 과정 정보 관리(조회, 등록, 수정, 삭제)
--  2) 과목 정보 관리(조회, 등록, 수정, 삭제)
--  3) 강의실 정보 관리(조회, 등록, 수정, 삭제)
--  4) 교재 정보 관리(조회, 등록, 수정, 삭제)
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- A-1.1) 과정 정보 관리(tblCourse)
--------------------------------------------------------------------------------
-- 1. 과정 정보 조회
--------------------------------------------------------------------------------
-- 과정 정보 저장 프로시저
--------------------------------------------------------------------------------
create or replace procedure procSetCourse(
    presult out sys_refcursor
)
is
begin
    dbms_output.put_line(chr(10) || '[과정 정보 조회]');
    dbms_output.put_line('--------------------------------------------------');
    dbms_output.put_line('|No.|' || lpad('과정명', 43) || lpad('|', 39) || '   기간   |');
    dbms_output.put_line('--------------------------------------------------');
    open presult
        for select * from tblCourse order by course_seq;
end procSetCourse;

--------------------------------------------------------------------------------
-- 과정 정보 조회 프로시저
--------------------------------------------------------------------------------
create or replace procedure procGetCourse
is
    vresult sys_refcursor;
    vrow tblCourse%rowtype;
begin
    procSetCourse(vresult);
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line('| ' || to_char(vrow.course_seq, '00') || '|' || vrow.course_name || chr(9)
                                || '|' || to_char(vrow.course_period, '0.0') || '개월|');
        dbms_output.put_line('--------------------------------------------------');
    end loop;
end procGetCourse;

--------------------------------------------------------------------------------
-- 과정 정보 조회
--------------------------------------------------------------------------------
begin
    procGetCourse;
end;


--------------------------------------------------------------------------------
-- 2. 과정 정보 등록
--------------------------------------------------------------------------------
-- 과정 기간 확인 함수
--------------------------------------------------------------------------------
create or replace function fnIsValidPeriod (
    pperiod number
) return varchar2
is
    vcheck varchar2(1);
begin
    if pperiod in (5.5, 6, 7) then
        vcheck := 'Y';
    else 
        vcheck := 'N';
    end if;
    return vcheck;
end fnIsValidPeriod;

--------------------------------------------------------------------------------
-- 과정 등록 프로시저
--------------------------------------------------------------------------------
create or replace procedure procAddCourse (
    pname varchar2,
    pperiod number
)
is
begin
    dbms_output.put_line(chr(10) || '[과정 정보 등록]'  || chr(10)
                            || 'No.' || course_seq.nextVal || ' ' || pname 
                            || '(' || to_char(pperiod, '0.0') || '개월)' || chr(10));

    if fnIsValidPeriod(pperiod) = 'N' then
        dbms_output.put_line('☞실패; 기간 부적합');
    else 
        insert into tblCourse (course_seq, course_name, course_period) 
            values (course_seq.currVal, pname, pperiod);

        dbms_output.put_line('☞성공!');    
    end if;

exception
    when others then
        dbms_output.put_line('☞실패; ' || sqlerrm);
end procAddCourse;

--------------------------------------------------------------------------------
-- 과정 정보 등록
--------------------------------------------------------------------------------
begin
--    procAddCourse(과정명, 기간);
    procAddCourse('짱 쉬운 개발자 과정', 4);
--    procAddCourse('짱 쉬운 개발자 과정', 7);
end;


--------------------------------------------------------------------------------
-- 3. 과정 정보 수정
--------------------------------------------------------------------------------
-- 과정 수정 트리거
--------------------------------------------------------------------------------
create or replace trigger trgUpdateCourse
    after
    update on tblCourse
    for each row
begin 
    dbms_output.put_line('수정 전: No.' || :old.course_seq || ' ' 
                            || :old.course_name || '(' 
                            || to_char(:old.course_period, '0.0') || '개월)');

    dbms_output.put_line('수정 후: No.' || :new.course_seq || ' ' 
                            || :new.course_name || '(' 
                            || to_char(:new.course_period, '0.0') || '개월)');
end;

--------------------------------------------------------------------------------
-- 과정 수정 프로시저
--------------------------------------------------------------------------------
create or replace procedure procUpdateCourse (
    pseq number,
    pname varchar2,
    pperiod number    
)
is
    vinfo varchar2(1000);
begin
    dbms_output.put_line(chr(10) || '[과정 정보 수정]'); 
    
    vinfo := 'No.' || pseq || ' ' || pname 
                || '(' || to_char(pperiod, '0.0') || '개월)' || chr(10) || chr(10); 

    if fnIsValidPeriod(pperiod) = 'N' then
        dbms_output.put_line(vinfo || '☞실패; 기간 부적합');
    else 
        dbms_output.put_line(vinfo || '☞성공!');    

        update tblCourse set course_name = pname, 
                             course_period = pperiod
        where course_seq = pseq;
    end if;
    
exception
    when others then
        dbms_output.put_line(vinfo || '☞실패; ' || sqlerrm);
end procUpdateCourse;


--------------------------------------------------------------------------------
-- 과정 수정
--------------------------------------------------------------------------------
begin
--    procUpdateCourse(번호, 과정명, 기간);
    procUpdateCourse(11, '약간 어려운 개발자 개발자 과정', 4);
--    procUpdateCourse(11, '약간 어려운 개발자 개발자 과정', 7);
end;


--------------------------------------------------------------------------------
-- 4. 과정 정보 삭제
--------------------------------------------------------------------------------
-- 과정 삭제 프로시저
--------------------------------------------------------------------------------
create or replace procedure procDeleteCourse (
    pseq number
)
is
    vc tblCourse%rowtype;
begin
    select *
        into vc from tblCourse 
    where course_seq = pseq;
    
    dbms_output.put_line(chr(10) || '[과정 정보 삭제]' || chr(10) 
                            || 'No.' || pseq || ' ' || vc.course_name 
                            || '(' || vc.course_period || '개월)' || chr(10));  
                            
    delete from tblCourse 
    where course_seq = pseq;
    
    dbms_output.put_line('☞성공!');
exception
    when others then
        dbms_output.put_line('☞실패; ' || sqlerrm);
end procDeleteCourse;

--------------------------------------------------------------------------------
-- 과정 삭제 
--------------------------------------------------------------------------------
begin
--    procDeleteCourse(번호);
    procDeleteCourse(2);
end;



--------------------------------------------------------------------------------
-- A-1.2) 과목 정보 관리(tblSubject)
--------------------------------------------------------------------------------
-- 1. 과목 정보 조회; 번호, 이름, 기간 출력
--------------------------------------------------------------------------------
select 
    subject_seq as "번호",
    subject_name as "과정명",
    to_char(subject_period, '0.0') || '개월' as "기간"
from tblSubject
order by subject_seq;


--------------------------------------------------------------------------------
-- 2. 과목 정보 등록; 이름, 기간(0.5~4.5) 입력
--------------------------------------------------------------------------------
begin
    procAddSubject(과목명, 기간);
end;


    /* 과목 등록 프로시저 */
create or replace procedure procAddSubject (
    pname varchar2,
    pperiod number
)
is
begin
    insert into tblSubject (subject_seq, subject_name, subject_period)
        values (subject_seq.nextVal, pname, pperiod);
        
    dbms_output.put_line('과목 등록 성공: No.' || subject_seq.currVal || ' ' 
                            || pname || '(' || to_char(pperiod, '0.0') || '개월)');
exception
    when others then
        dbms_output.put_line('과목 등록 실패: No.' || subject_seq.currVal || ' ' 
                                || pname || '(' || to_char(pperiod, '0.0') || '개월)'); 
        dbms_output.put_line(sqlerrm);
end procAddSubject;


--------------------------------------------------------------------------------
-- 3. 과목 정보 수정; 해당 번호의 이름, 기간 수정
--------------------------------------------------------------------------------
begin
    procUpdateSubject(번호, 과목명, 기간);
end;


    /* 과목 수정 프로시저 */
create or replace procedure procUpdateSubject (
    pseq number,
    pname varchar2,
    pperiod number    
)
is
begin
    update tblSubject set subject_name = pname, 
                          subject_period = pperiod
    where subject_seq = pseq;
    
    dbms_output.put_line('과목 변경 성공: No.' || pseq || ' ' 
                            || pname || '(' || to_char(pperiod, '0.0') || '개월)');
exception
    when others then
        dbms_output.put_line('과목 변경 실패: No.' || pseq || ' '
                                || pname || '(' || to_char(pperiod, '0.0') || '개월)');
        dbms_output.put_line(sqlerrm);
end procUpdateSubject;

--------------------------------------------------------------------------------
-- 4. 과목 정보 삭제; 해당 과목 번호의 과목 삭제
--------------------------------------------------------------------------------
declare
    vname tblSubject.subject_name%type;
    vperiod number;   
begin
    procDeleteSubject(번호, vname, vperiod);
end;


    /* 과목 삭제 프로시저 */
create or replace procedure procDeleteSubject (
    pseq number,
    pname out varchar2,
    pperiod out number    
)
is
begin
    select subject_name, subject_period 
        into pname, pperiod from tblSubject 
    where subject_seq = pseq;
    delete from tblSubject 
    where subject_seq = pseq;
    
    dbms_output.put_line('과목 삭제 성공: No.' || pseq || ' ' 
                            || pname || '(' || to_char(pperiod, '0.0') || '개월)');
exception
    when others then
        dbms_output.put_line('과목 삭제 실패: No.' || pseq || ' '                
                                || pname || '(' ||to_char(pperiod, '0.0') || '개월)');
        dbms_output.put_line(sqlerrm);
end procDeleteSubject;


--------------------------------------------------------------------------------
-- A-1.3) 강의실 정보 관리(tblRoom)
--------------------------------------------------------------------------------
-- 1. 강의실 정보 조회; 번호, 이름, 수용 인원 출력
--------------------------------------------------------------------------------
select 
    room_seq as "번호",
    room_name as "이름",
    room_capacity || '명' as "수용 인원"
from tblRoom
order by room_seq;


--------------------------------------------------------------------------------
-- 2. 강의실 정보 등록; 이름, 수용 인원(26, 30) 입력
--------------------------------------------------------------------------------
begin
    procAddRoom(강의실명, 인원);
end;


    /* 강의실 등록 프로시저 */
create or replace procedure procAddRoom (
    pname varchar2,
    pcapacity number
)
is
begin
    insert into tblRoom (room_seq, room_name, room_capacity)
        values (room_seq.nextval , pname, pcapacity);
        
    dbms_output.put_line('강의실 등록 성공: No.' || room_seq.currVal || ' ' 
                            || pname || '(수용: ' || pcapacity || '명)');
exception
    when others then
        dbms_output.put_line('강의실 등록 실패: No.' || room_seq.currVal || ' ' 
                                || pname || '(수용: ' || pcapacity || '명)');
        dbms_output.put_line(sqlerrm);
end procAddRoom;


--------------------------------------------------------------------------------
-- 3. 강의실 정보 수정; 해당 강의실 번호의 이름, 수용인원 수정
--------------------------------------------------------------------------------
begin
    procUpdateRoom(번호, 강의실명, 인원);
end;


    /* 강의실 수정 프로시저 */
create or replace procedure procUpdateRoom (
    pseq number,
    pname varchar2,
    pcapacity number    
)
is
begin
    update tblRoom set room_name = pname, 
                       room_capacity = pcapacity
    where room_seq = pseq;
    
    dbms_output.put_line('강의실 변경 성공: No.' || pseq || ' ' 
                            || pname || '(수용: ' || pcapacity || '명)');
exception
    when others then
        dbms_output.put_line('강의실 변경 실패: No.' || pseq || ' '
                                || pname || '(수용: ' || pcapacity || '명)');
        dbms_output.put_line(sqlerrm);
end procUpdateRoom;


--------------------------------------------------------------------------------
-- 4. 강의실 정보 삭제; 해당 강의실 번호의 강의실 정보 삭제
--------------------------------------------------------------------------------
declare
    vname tblRoom.room_name%type;
    vcapacity number;   
begin
    procDeleteRoom(번호, vname, vcapacity);
end;


    /* 강의실 삭제 프로시저 */
create or replace procedure procDeleteRoom (
    pseq number,
    pname out varchar2,
    pcapacity out number 
)
is
begin
    select room_name, room_capacity
        into pname, pcapacity from tblRoom
    where room_seq = pseq;
    delete from tblRoom 
    where room_seq = pseq;
    
    dbms_output.put_line('강의실 삭제 성공: No.' || pseq || ' ' 
                            || pname || '(수용: ' || pcapacity || '명)');
exception
    when others then
        dbms_output.put_line('강의실 삭제 실패: No.' || pseq || ' ' 
                                || pname || '(수용: ' || pcapacity || '명)');
        dbms_output.put_line(sqlerrm);
end procDeleteRoom;


--------------------------------------------------------------------------------
-- A-1.4) 교재 정보 관리(tblBook)
-- 1. 교재 정보 조회; 번호, 교재명, 출판사, 가격, 과목 번호 출력
--------------------------------------------------------------------------------
select 
    b.book_seq as "번호",
    b.book_name as "이름",
    b.book_publisher as "출판사",
    b.book_price || '원 'as "가격",
    s.subject_name as "과목명"
from tblBook b inner join tblSubject s
    on (b.subject_seq = s.subject_seq)
order by b.book_seq;


--------------------------------------------------------------------------------
-- 2. 교재 정보 등록; 교재명, 출판사, 가격, 과목 번호 입력
--------------------------------------------------------------------------------
begin
    procAddBook(교재명, 출판사, 가격, 과목_번호);
end;


    /* 교재 등록 프로시저 */
create or replace procedure procAddBook (
    pname varchar2,
    ppublisher varchar2,
    pprice number,
    psseq number
)
is
begin
    insert into tblBook (book_seq, book_name, book_publisher, book_price, subject_seq)
        values (book_seq.nextVal, pname, ppublisher, pprice, psseq);
    
    dbms_output.put_line('교재 등록 성공: No.' || book_seq.currVal || ' ' || pname 
                            || '(출판사: ' || ppublisher 
                            || ', 가격: ' || pprice || '원)');
exception
    when others then
        dbms_output.put_line('교재 등록 성공: No.' || book_seq.currVal || ' ' || pname 
                                || '(출판사: ' || ppublisher 
                                || ', 가격: ' || pprice || '원)');
        dbms_output.put_line(sqlerrm);
end procAddBook;


--------------------------------------------------------------------------------
-- 3. 교재 정보 수정; 해당 교재 번호의 교재명, 출판사, 가격, 과목 번호 수정
--------------------------------------------------------------------------------
begin
    procUpdateBook(번호, 교재명, 출판사, 가격, 과목_번호);
end;


    /* 교재 수정 프로시저 */
create or replace procedure procUpdateBook (
    pseq number,
    pname varchar2,
    ppublisher varchar2,
    pprice number,
    psseq number 
)
is
begin
    update tblBook set book_name = pname, 
                       book_publisher = ppublisher,
                       book_price = pprice,
                       subject_seq = psseq
    where book_seq = pseq;
    
    dbms_output.put_line('교재 변경 성공: No.' || pseq || ' ' || pname 
                            || '(출판사: ' || ppublisher 
                            || ', 가격: ' || pprice || '원)');
exception
    when others then
        dbms_output.put_line('교재 변경 실패: No.' || pseq || ' ' || pname 
                                || '(출판사: ' || ppublisher 
                                || ', 가격: ' || pprice || '원)');
        dbms_output.put_line(sqlerrm);
end procUpdateBook;


--------------------------------------------------------------------------------
-- 4. 교재 정보 삭제; 해당 번호의 교재 정보 삭제
--------------------------------------------------------------------------------
declare
    vname tblBook.book_name%type;
    vpublisher tblBook.book_publisher%type;
    vprice number;
begin
    procDeleteBook(번호, vname, vpublisher, vprice);
end;


    /* 교재 삭제 프로시저 */
create or replace procedure procDeleteBook (
    pseq number,
    pname out varchar2,
    ppublisher out varchar2,
    pprice out number 
)
is
begin
    select book_name, book_publisher, book_price
        into pname, ppublisher, pprice from tblBook
    where book_seq = pseq;
    delete from tblBook 
    where book_seq = pseq;
    
    dbms_output.put_line('교재 삭제 성공: No.' || pseq || ' ' || pname 
                            || '(출판사: ' || ppublisher 
                            || ', 가격: ' || pprice || '원)');
exception
    when others then
        dbms_output.put_line('교재 삭제 실패: No.' || pseq || ' ' || pname 
                                || '(출판사: ' || ppublisher 
                                || ', 가격: ' || pprice || '원)');
        dbms_output.put_line(sqlerrm);
end procDeleteBook;



