--이유미

--------------------------------------------------------------------------------
-- A-3. 개설 과정 관리 
--  1) 개설 과정 정보 관리(조회, 등록, 수정, 삭제)
--  2) 과정 상세 정보 조회
--      -과정명, 기간, 강의실, 개설 과목 등록 여부, 교육생 등록 인원
--  3) 특정 개설 과정 선택시 개설 과목 정보 조회
--  4) 특정 개설 과정 선택시 등록된 교육생 정보 조회
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- A-3.1) 개설 과정 정보 관리(tblOpenCourse)
--------------------------------------------------------------------------------
-- 1. 개설 과정 조회
--------------------------------------------------------------------------------
-- 개설 과정 뷰
--------------------------------------------------------------------------------
create or replace view vwOpenCourse
as
select
    toc.oc_seq as oc_seq,
    tc.course_name as course_name,
    toc.oc_startdate as oc_startdate,
    toc.oc_enddate as oc_enddate,
    tr.room_seq as room_seq,
    tr.room_name as room_name,
    tr.room_capacity as room_capacity,
    case
        when (select count(*) from tblOpenSubject 
              group by oc_seq having oc_seq = toc.oc_seq) > 0 then 'Y'
        else 'N'
    end as regsub,
    (select 
         case count(*)
             when 1 then 0
             else count(*)
         end
     from tblEnrollment e full outer join tblOpenCourse oc
         on (e.oc_seq = oc.oc_seq)
     group by oc.oc_seq having oc.oc_seq = toc.oc_seq) as num
from tblOpenCourse toc inner join tblCourse tc
    on (toc.course_seq = tc.course_seq) inner join tblRoom tr
    on (toc.room_seq = tr.room_seq) 
order by toc.oc_startdate desc;

--------------------------------------------------------------------------------
-- 개설 과정 정보 저장 프로시저
--------------------------------------------------------------------------------
create or replace procedure procSetOpenCourse(
    presult out sys_refcursor
)
is
begin
    dbms_output.put_line(chr(10) || '[개설 과정 조회]');
    dbms_output.put_line('--------------------------------------------------------------------');
    dbms_output.put_line('|No.|' || lpad('과정명', 43) || lpad('|', 39) 
                            || lpad('기간', 17) || lpad('|', 13) 
                            || '  강의실|수용|');
    dbms_output.put_line('--------------------------------------------------------------------');
    open presult
        for select * from vwOpenCourse
            order by oc_seq;
end procSetOpenCourse;

--------------------------------------------------------------------------------
-- 개설 과정 조회 프로시저
--------------------------------------------------------------------------------
create or replace procedure procGetOpenCourse 
is
    vresult sys_refcursor;
    vrow vwOpenCourse%rowtype;
begin
    procSetOpenCourse(vresult);
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line('| ' || to_char(vrow.oc_seq, '00') || '|' || vrow.course_name || chr(9)
                                || '|' || vrow.oc_startdate || '~' || vrow.oc_enddate 
                                || '|' || vrow.room_name || '|' || vrow.room_capacity || '명|');
        dbms_output.put_line('--------------------------------------------------------------------');
    end loop;
end procGetOpenCourse;

--------------------------------------------------------------------------------
-- 개설 과정 조회 
--------------------------------------------------------------------------------
begin
    procGetOpenCourse;
end;


--------------------------------------------------------------------------------
-- 2. 개설 과정 등록
--------------------------------------------------------------------------------
-- 개설 가능한 날짜 함수
--------------------------------------------------------------------------------
create or replace function fnIsValidDate (
    pdate date
) return varchar2
is
    vcnt number;
    vcheck varchar2(1);
begin
    select count(*)
        into vcnt 
    from tblHoliday 
    where holiday_date = pdate;
    
    if to_char(pdate, 'd') in ('1', '7') 
        or pdate < sysdate 
        or vcnt > 0 then
        vcheck := 'N';
    else
        vcheck := 'Y';
    end if;
    
    return vcheck;
end fnIsValidDate;

--------------------------------------------------------------------------------
-- 개설 가능한 강의실 함수
--------------------------------------------------------------------------------
create or replace function fnIsValidRoom (
    pseq number,
    pstartdate date
) return varchar2
is
    vdate date;
    vcheck varchar2(1);
begin
    select max(oc_enddate)
        into vdate 
    from vwOpenCourse 
    where room_seq = pseq;
    
    if vdate > pstartdate then
        vcheck := 'N';
    else
        vcheck := 'Y';
    end if;
    
    return vcheck;
end fnIsValidRoom;

--------------------------------------------------------------------------------
-- 종료일 계산 함수
--------------------------------------------------------------------------------
create or replace function fnGetEnddate (
    pdate date,
    pseq number
) return date
is
    vperiod number;
begin
    select course_period
        into vperiod from tblCourse
    where course_seq = pseq;
    return add_months(pdate, vperiod);
end fnGetEnddate;

--------------------------------------------------------------------------------
-- 개설 과정 등록 프로시저
--------------------------------------------------------------------------------
create or replace procedure procAddOpenCourse (
    pseq number, 
    prseq number,
    pstartdate date
)
is
    venddate date;
begin
    venddate := fnIsEnddate(pstartdate, pseq);
    
    dbms_output.put_line(chr(10) || '[개설 과정 등록]' || chr(10) 
                            || 'No.' || oc_seq.nextVal || ' ' || fnGetCourseName(pseq)
                            || '(' || pstartdate || ' ~ ' || venddate 
                            || ', ' || fnGetRoomName(prseq) || ')' || chr(10));

    if fnIsValidDate(pstartdate) = 'N' then
        dbms_output.put_line('☞실패; 시작일 부적합');
    elsif fnIsValidDate(venddate) = 'N' then
        dbms_output.put_line('☞실패; 종료일 부적합');
    elsif fnIsValidRoom(prseq, pstartdate) = 'N' then
        dbms_output.put_line('☞실패; 강의실 부적합');
    else
        insert into tblOpenCourse (oc_seq, course_seq, oc_startdate, oc_enddate, room_seq) 
            values(oc_seq.currval, pseq, pstartdate, venddate, prseq);
            
        dbms_output.put_line('☞성공!');
    end if;
    
exception
    when others then
        dbms_output.put_line('☞실패; ' || sqlerrm);
end procAddOpenCourse;

--------------------------------------------------------------------------------
-- 개설 과정 등록
--------------------------------------------------------------------------------
begin
--    procAddOpenCourse(과정_번호, 강의실_번호, 시작일);
    procAddOpenCourse(2, 4, '21-12-23');
end;


--------------------------------------------------------------------------------
-- 3. 개설 과정 수정
--------------------------------------------------------------------------------
-- 개설 과정 수정 트리거
--------------------------------------------------------------------------------
create or replace trigger trgUpdateOpenCourse
    after
    update on tblOpenCourse
    for each row
begin 
    dbms_output.put_line('수정 전: No.' || :old.oc_seq || ' ' 
                            || fnGetCourseName(:old.course_seq)
                            || '(' || :old.oc_startdate || ' ~ ' || :old.oc_enddate 
                            || ', ' || fnGetRoomName(:old.room_seq) || ')');
    dbms_output.put_line('수정 후: No.' || :new.oc_seq || ' ' 
                            || fnGetCourseName(:new.course_seq)
                            || '(' || :new.oc_startdate || ' ~ ' || :new.oc_enddate 
                            || ', ' || fnGetRoomName(:new.room_seq) || ')');
end;

--------------------------------------------------------------------------------
-- 개설 과정 수정 프로시저
--------------------------------------------------------------------------------
create or replace procedure procUpdateOpenCourse (
    pseq number,
    pcseq number, 
    pstartdate date,
    penddate date,  
    prseq number
)
is
    vinfo varchar2(1000);
begin
    dbms_output.put_line(chr(10) || '[개설 과정 수정]');
    
    vinfo := 'No.' || pseq || ' ' || fnGetCourseName(pcseq)
                || '(' || pstartdate || ' ~ ' || penddate 
                || ', ' || fnGetRoomName(prseq) || ')' || chr(10) || chr(10); 
    
    if fnIsValidDate(pstartdate) = 'N' then
        dbms_output.put_line(vinfo || '☞실패; 시작일 부적합');
    elsif fnIsValidDate(penddate) = 'N' 
        or penddate < pstartdate then
        dbms_output.put_line(vinfo || '☞실패; 종료일 부적합');
    elsif fnIsValidRoom(prseq, pstartdate) = 'N' then
        dbms_output.put_line(vinfo || '☞실패; 강의실 부적합');
    else 
        dbms_output.put_line(vinfo || '☞성공!');
        
        update tblOpenCourse set course_seq = pcseq, 
                                 oc_startdate = pstartdate,
                                 oc_enddate = penddate,
                                 room_seq = prseq
        where oc_seq = pseq;
    end if;
    
exception
    when others then
        dbms_output.put_line(vinfo || '실패; ' || sqlerrm);
end procUpdateOpenCourse;

--------------------------------------------------------------------------------
-- 개설 과정 수정
--------------------------------------------------------------------------------
begin
--    procUpdateOpenCourse(번호, 과정_번호, 시작일, 종료일, 강의실_번호);
    procUpdateOpenCourse(24, 1, '21-12-23', '22-02-09', 1);
end;



--------------------------------------------------------------------------------
-- 4. 개설 과정 삭제
--------------------------------------------------------------------------------
-- 개설 과정 삭제 프로시저
--------------------------------------------------------------------------------
create or replace procedure procDeleteOpenCourse (
    pseq number
)
is
    voc tblOpenCourse%rowtype;
begin
    select * into voc from tblOpenCourse
    where oc_seq = pseq;
    
    dbms_output.put_line(chr(10) || '[개설 과정 삭제]' || chr(10) 
                            || 'No.' || pseq || ' ' || fnGetCourseName(voc.course_seq)
                            || '(' || voc.oc_startdate || ' ~ ' || voc.oc_enddate 
                            || ', ' || fnGetRoomName(voc.room_seq) || ')' || chr(10));
                            
    delete from tblOpenCourse
    where oc_seq = pseq;
    
    dbms_output.put_line('☞성공!');
exception
    when others then
        dbms_output.put_line('☞실패; ' || sqlerrm);
end procDeleteOpenCourse;

--------------------------------------------------------------------------------
-- 개설 과정 삭제
--------------------------------------------------------------------------------
begin
--    procDeleteOpenCourse(번호);
    procDeleteOpenCourse(3);
end;


--------------------------------------------------------------------------------
-- A-3.2) 개설 과정 상세 정보 조회
--------------------------------------------------------------------------------
-- 개설 과정 상세 정보 저장 프로시저
--------------------------------------------------------------------------------
create or replace procedure procSetOpenCourseInfo(
    presult out sys_refcursor
)
is
begin
    dbms_output.put_line(chr(10) || '[개설 과정 상세 조회]');
    dbms_output.put_line('----------------------------------------------------------------------------');
    dbms_output.put_line('|No.|' || lpad('과정명', 43) || lpad('|', 39) 
                            || lpad('기간', 17) || lpad('|', 13) 
                            || ' 강의실|  등록|과목 개설|');
    dbms_output.put_line('----------------------------------------------------------------------------');
    open presult
        for select * from vwOpenCourse
            order by oc_seq;
end procSetOpenCourseInfo;

--------------------------------------------------------------------------------
-- 개설 과정 상세 정보 조회 프로시저
--------------------------------------------------------------------------------
create or replace procedure procGetOpenCourseInfo
is
    vresult sys_refcursor;
    vrow vwOpenCourse%rowtype;
    vname vwOpenCourse.course_name%type;
begin
    procSetOpenCourseInfo(vresult);
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line('| ' || to_char(vrow.oc_seq, '00') || '|' || vrow.course_name || chr(9)
                                || '|' || vrow.oc_startdate || '~' || vrow.oc_enddate 
                                || '|' || vrow.room_name || '|' 
                                || to_char(vrow.num, '00') || '명|      '
                                || vrow.regsub || '     |');
        dbms_output.put_line('----------------------------------------------------------------------------');
    end loop;
end procGetOpenCourseInfo;

--------------------------------------------------------------------------------
-- 개설 과정 상세 조회
--------------------------------------------------------------------------------
begin
    procGetOpenCourseInfo;
end;



--------------------------------------------------------------------------------
-- A-3.3) 특정 개설 과정 선택시 개설 과목 정보 조회
--------------------------------------------------------------------------------
-- 개설 과목명, 기간 출력
--------------------------------------------------------------------------------
select
    distinct subject_name as "개설 과목명",
    os_startdate as "시작일",
    os_enddate as "종료일"
from vwOpenCourse
--where oc_seq = 개설_과정_번호
where oc_seq = 1
order by os_startdate desc;



--------------------------------------------------------------------------------
-- A-3.4) 특정 개설 과정 선택시 교육생 정보 조회
--------------------------------------------------------------------------------
-- 이름, 주민등록번호, 연락처 출력
--------------------------------------------------------------------------------
select
    name as "이름",
    ssn as "주민등록번호",
    tel as "연락처"
from vwStudentInfo
--where oc_seq = 개설_과정_번호
where oc_seq = 1
order by name;


