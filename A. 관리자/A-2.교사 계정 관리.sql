--이유미

--------------------------------------------------------------------------------
-- A-2. 교사 계정 관리
--  1) 교사 정보 관리(조회, 등록, 수정, 삭제)
--  2) 교사별 강의 가능 과목 관리(조회, 등록, 수정, 삭제)
--  3) 특정 교사 선택시 상세 정보 조회
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- A-2.1) 교사 정보 관리(tblTeacher)
--------------------------------------------------------------------------------
-- 1. 교사 정보 조회; 번호, 이름, 주민등록번호, 연락처 출력
--------------------------------------------------------------------------------
select 
    teacher_seq as "번호",
    teacher_name as "이름",
    teacher_ssn as "주민등록번호",
    teacher_tel as "연락처"
from tblTeacher
order by teacher_seq;


--------------------------------------------------------------------------------
-- 2. 교사 정보 등록; 이름, 주민등록번호, 연락처 입력
--------------------------------------------------------------------------------
begin
    procAddTeacher(이름, 주민등록번호, 연락처);
end;


    /* 교사 등록 프로시저 */
create or replace procedure procAddTeacher (
    pname varchar2,
    pssn varchar2,
    ptel varchar2
)
is
begin
    insert into tblTeacher (teacher_seq, teacher_name, teacher_ssn, teacher_tel) 
        values (teacher_seq.nextVal, pname, pssn, ptel);
        
    dbms_output.put_line('교사 등록 성공: No.' || teacher_seq.currtVal || ' ' || pname 
                            || '(주민등록번호: ' || substr(pssn, 1, 8) || '******' 
                            || ', tel: ' || ptel || ')');
exception
    when others then
        dbms_output.put_line('교사 등록 실패: No.' || teacher_seq.currVal || ' ' || pname 
                                || '(주민등록번호: ' || substr(pssn, 1, 8) || '******' 
                                || ', tel: ' || ptel || ')');
        dbms_output.put_line(sqlerrm);
end procAddTeacher;


--------------------------------------------------------------------------------
-- 3. 교사 정보 수정; 해당 번호의 이름, 주민등록번호, 연락처 수정
--------------------------------------------------------------------------------
begin
    procUpdateTeacher(번호, 이름, 주민등록번호, 연락처);
end;


    /*  교사 수정 프로시저 */
create or replace procedure procUpdateTeacher (
    pseq number,
    pname varchar2,
    pssn varchar2,
    ptel varchar2
)
is
begin
    update tblTeacher set teacher_name = pname,
                          teacher_ssn = pssn,
                          teacher_tel = ptel 
    where teacher_seq = pseq;
    
    dbms_output.put_line('교사 수정 성공: No.' || pseq || ' ' || pname 
                            || '(주민등록번호: ' || substr(pssn, 1, 8) || '******' 
                            || ', tel: ' || ptel || ')');
exception
    when others then
        dbms_output.put_line('교사 수정 실패: No.' || pseq || ' ' || pname 
                                || '(주민등록번호: ' || substr(pssn, 1, 8) || '******' 
                                || ', tel: ' || ptel || ')');
        dbms_output.put_line(sqlerrm);
end procUpdateTeacher;
end;


--------------------------------------------------------------------------------
-- 4. 교사 정보 삭제; 해당 교사 번호의 교사 정보 삭제
--------------------------------------------------------------------------------
declare
    vname tblTeacher.teacher_name%type;
    vssn tblTeacher.teacher_ssn%type;
    vtel tblTeacher.teacher_tel%type;
begin
    procDeleteTeacher(번호, vname, vssn, vtel);
end;


    /* 교사 삭제 프로시저 */
create or replace procedure procDeleteTeacher (
    pseq number,
    pname out varchar2,
    pssn out varchar2,
    ptel out varchar2
)
is
begin
    select teacher_name, teacher_ssn, teacher_tel
        into pname, pssn, ptel from tblTeacher
    where teacher_seq = pseq;
    delete from tblTeacher 
    where teacher_seq = pseq;
    
    dbms_output.put_line('교사 삭제 성공: No.' || pseq || ' ' || pname 
                            || '(주민등록번호: ' || substr(pssn, 1, 8) || '******' 
                            || ', tel: ' || ptel || ')');
exception
    when others then
        dbms_output.put_line('교사 삭제 실패: No.' || pseq || ' ' || pname 
                                || '(주민등록번호: ' || substr(pssn, 1, 8) || '******' 
                                || ', tel: ' || ptel || ')');
        dbms_output.put_line(sqlerrm);
end procDeleteTeacher;



--------------------------------------------------------------------------------
-- A-2.2) 교사별 강의 가능 과목 관리(tblSubjectTeacher)
--------------------------------------------------------------------------------
-- 1. 가능 과목 조회; 번호, 교사명(tblTeacher), 과목명(tblSubject) 출력
--------------------------------------------------------------------------------
select 
    st.st_seq as "번호",
    t.teacher_name as "교사명",
    s.subject_name as "과목명"
from tblSubjectTeacher st inner join tblTeacher t
    on (st.teacher_seq = t.teacher_seq) inner join tblSubject s
    on (st.subject_seq = s.subject_seq);
    

--------------------------------------------------------------------------------
-- 2. 가능 과목 등록; 번호, 과목번호, 교사번호 입력
--------------------------------------------------------------------------------
declare
    vsname tblSubject.subject_name%type;
    vtname tblTeacher.teacher_name%type;
begin
    procAddSubjectTeacher(과목_번호, 강사_번호, vsname, vtname);
end;


    /* 교사 가능 과목 등록 프로시저 */
create or replace procedure procAddSubjectTeacher (
    psseq number,
    ptseq number,
    psname out varchar2,
    ptname out varchar2
)
is
begin
    select subject_name 
        into psname from tblSubject
    where subject_seq = psseq;
    select teacher_name 
        into ptname from tblTeacher
    where teacher_seq = ptseq;
    insert into tblSubjectTeacher (st_seq, subject_seq, teacher_seq) 
        values (st_seq.nextVal, psseq, ptseq);
        
    dbms_output.put_line('강의 가능 교사 등록 성공: No.' || st_seq.currVal || ' ' 
                            || ptname || ' - ' || psname);
exception
    when others then
        dbms_output.put_line('강의 가능 교사 등록 실패: No.' || st_seq.currVal || ' ' 
                                || ptname || ' - ' || psname);
        dbms_output.put_line(sqlerrm);
end procAddSubjectTeacher;


--------------------------------------------------------------------------------
-- 3. 가능 과목 수정; 해당 번호의 과목번호, 교사번호 수정
--------------------------------------------------------------------------------
declare
    vsname tblSubject.subject_name%type;
    vtname tblTeacher.teacher_name%type;
begin
    procUpdateSubjectTeacher(번호, 과목_번호, 강사_번호, vsname, vtname);
end;


    /* 교사 가능 과목 수정 프로시저 */
create or replace procedure procUpdateSubjectTeacher (
    pseq number,
    psseq number,
    ptseq number,
    psname out varchar2,
    ptname out varchar2
)
is
begin
    select subject_name 
        into psname from tblSubject
    where subject_seq = psseq;
    select teacher_name 
        into ptname from tblTeacher
    where teacher_seq = ptseq;
    update tblSubjectTeacher set subject_seq = psseq,
                                 teacher_seq = ptseq
    where st_seq = pseq;
        
    dbms_output.put_line('강의 가능 교사 수정 성공: No.' || pseq || ' ' 
                            || ptname || ' - ' || psname);
exception
    when others then
        dbms_output.put_line('강의 가능 교사 수정 실패: No.' || pseq || ' ' 
                                || ptname || ' - ' || psname);
        dbms_output.put_line(sqlerrm);
end procUpdateSubjectTeacher;


--------------------------------------------------------------------------------
-- 4. 가능 과목 삭제; 해당 번호의 강의 가능 교사 정보 삭제
--------------------------------------------------------------------------------
declare
    vsname tblSubject.subject_name%type;
    vtname tblTeacher.teacher_name%type;
begin
    procDeleteSubjectTeacher(번호, 과목_번호, 강사_번호, vsname, vtname);
end;


    /* 교사 가능 과목 삭제 프로시저 */
create or replace procedure procDeleteSubjectTeacher (
    pseq number,
    psseq number,
    ptseq number,
    psname out varchar2,
    ptname out varchar2
)
is
begin
    select subject_name 
        into psname from tblSubject
    where subject_seq = psseq;
    select teacher_name 
        into ptname from tblTeacher
    where teacher_seq = ptseq;
    delete from tblSubjectTeacher 
    where st_seq = pseq;
        
    dbms_output.put_line('강의 가능 교사 삭제 성공: No.' || pseq || ' ' 
                            || ptname || ' - ' || psname);
exception
    when others then
        dbms_output.put_line('강의 가능 교사 삭제 실패: No.' || pseq || ' ' 
                                || ptname || ' - ' || psname);
        dbms_output.put_line(sqlerrm);
end procDeleteSubjectTeacher;



--------------------------------------------------------------------------------
-- A-2.3) 특정 교사 선택시 상세 정보 조회
--------------------------------------------------------------------------------
-- 1. 상세 정보 조회; 해당 교사의 개설 과정명, 과목명 및 기간, 교재, 강의실 출력
--------------------------------------------------------------------------------
select
    teacher_name as "교사명",
    course_seq as "과정명",
    oc_startdate as "과정 시작일",
    oc_enddate as "과정 종료일",
    subject_name as "과목명",
    os_startdate as "과목 시작일",
    os_enddate as "과목 종료일",
    book_name as "교재",
    room_name as "강의실"
from vwOpenCourseInfo
where teacher_seq = 교사_번호;


