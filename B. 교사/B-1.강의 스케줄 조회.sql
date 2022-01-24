--이유미

--------------------------------------------------------------------------------
-- B-1. 교사 강의 스케쥴 조회 
--  1) 현재 강의 스케줄 확인 
--  2) 강의 스케줄 상세 조회
--  3) 해당 과정의 교육생 정보 조회
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- B-1.1) 현재 강의 스케줄 확인
--------------------------------------------------------------------------------
-- 강의 스케줄 뷰
--------------------------------------------------------------------------------
create or replace view vwTeacherSchedule
as
select
    tt.teacher_seq as teacher_seq,
    tt.teacher_name as teacher_name,
    tc.course_name as course_name,
    toc.oc_startdate as oc_startdate,
    toc.oc_enddate as oc_enddate,
    case
        when toc.oc_startdate > sysdate then '예정'
        when toc.oc_enddate >= sysdate then '진행'
        when toc.oc_enddate < sysdate then '종료'
    end as state
from tblOpenCourse toc inner join tblCourse tc
    on (toc.course_seq = tc.course_seq) inner join tblTeacherManagement ttm
    on (ttm.oc_seq = toc.oc_seq) inner join tblTeacher tt
    on (tt.teacher_seq = ttm.teacher_seq) inner join (select max(tm_seq) as final
                                                    from tblTeacherManagement
                                                    group by oc_seq) ttmr
    on (ttm.tm_seq = ttmr.final) 
order by toc.oc_startdate desc;

--------------------------------------------------------------------------------
-- 강의 스케줄 저장 프로시저
--------------------------------------------------------------------------------
create or replace procedure procSetTeacherSchedule(
    presult out sys_refcursor,
    pseq number
)
is
    vc tblTeacher%rowtype;
begin
    select * 
        into vc 
    from tblTeacher
    where teacher_seq = pseq;
    
    dbms_output.put_line(chr(10) || '[ ' || vc.teacher_name || ' 선생님 강의 스케줄 조회 ]');
        dbms_output.put_line('------------------------------------------------------------');
        dbms_output.put_line('|' || lpad('과정명', 43) || lpad('|', 41) 
                            || lpad('기간', 17) || lpad('|', 13) 
                            || '상태|');
        dbms_output.put_line('------------------------------------------------------------');
    
    open presult
        for select * from vwTeacherSchedule
            where teacher_seq = pseq
            order by oc_startdate desc;
end procSetTeacherSchedule;

--------------------------------------------------------------------------------
-- 강의 스케줄 조회 프로시저
--------------------------------------------------------------------------------
create or replace procedure procGetTeacherSchedule(
    pseq number
)
is
    vresult sys_refcursor;
    vrow vwTeacherSchedule%rowtype;
    vname vwTeacherSchedule.course_name%type;
begin
    procSetTeacherSchedule(vresult, pseq);
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line('|' || chr(9) || vrow.course_name || chr(9)
                                || '|' || vrow.oc_startdate || '~' || vrow.oc_enddate 
                                || '|' || vrow.state || '|');
        dbms_output.put_line('------------------------------------------------------------');
    end loop;
end procGetTeacherSchedule;

--------------------------------------------------------------------------------
-- 해당 교사의 강의 스케줄 조회
--------------------------------------------------------------------------------
begin
    procGetTeacherSchedule(2);
end;


--------------------------------------------------------------------------------
-- B-1.2) 강의 스케줄 상세 조회
--------------------------------------------------------------------------------
-- 해당 과정 번호의 과정명, 과목명 및 기간, 교재, 강의실, 등록 인원 출력
--------------------------------------------------------------------------------
select
    course_name as "과정명",
    oc_startdate as "과정 시작일",
    oc_enddate as "과정 종료일",
    subject_name as "과목명",
    os_startdate as "과목 시작일",
    os_enddate as "과목 종료일",
    room_name as "강의실",
    book_name as "교재",
    (select count(*) from tblEnrollment 
     group by oc_seq having oc_seq = v.oc_seq) as "등록 인원"
from vwOpenCourse v
--where teacher_seq = 교사_번호
--    and oc_seq = 개설_과정_번호;
where teacher_seq = 1
    and oc_seq = 20;


--------------------------------------------------------------------------------
-- B-1.3) 해당 과정의 교육생 정보 조회
--------------------------------------------------------------------------------
-- 해당 개설 과정 번호의 교육생 정보(이름, 연락처, 상태) 출력
--------------------------------------------------------------------------------
select
    name as "이름",
    tel as "연락처",
    case
        when (select count(*) from tblAbandonment 
              where enrollment_seq = v.enrollment_seq) = 1 then '중도 탈락'
        when oc_startdate > sysdate then '예정'
        when oc_enddate >= sysdate then '진행 중'
        when oc_enddate < sysdate then '수료'
    end as "상태"
from vwStudentInfo v
where oc.seq = 개설_과정_번호
order by name;

