set serverout on;

-- A-5 교육생 관리
-- A-5-1 교육생 추가

-- 트리거(교육생 추가)
create or replace trigger trgAddStudent
after insert on tblStudent
for each row
begin
    if inserting then
        dbms_output.put_line('교육생이 추가되었습니다');
    end if;
end;

-- 프로시저(교육생 추가)
create or replace procedure procAddStudent
(
    pname varchar2, -- 교육생 이름
    pssn varchar2, -- 교육생 주민등록번호
    ptel varchar2, -- 교육생 전화번호
    pseq number, -- 교육생 수강횟수
    presult out sys_refcursor
)
is
begin

    insert into tblstudent values(student_seq.nextval, pname, pssn, ptel, pseq);

    open presult
        for select * from tblstudent order by student_seq;
        
exception
    when no_data_found then
        dbms_output.put_line('존재하지 않는 값입니다');
    when others then
        dbms_output.put_line('잘못된 값입니다');            
    
end procAddStudent;

-- #합격자 조회
select ir.interviewer_name as 합격자 from tblinterviewer ir inner join tblinterview i on i.interviewer_seq = ir.interviewer_seq where upper(i.interview_result) = upper('Y') order by ir.interviewer_seq desc; 

-- #테스트(교육생 추가)
declare
    vname varchar2(20) := '탁연아'; -- 교육생 이름
    vssn varchar2(14) := '991207-2222222'; -- 교육생 주민등록번호
    vtel varchar2(13) := '010-9292-5959'; -- 교육생 전화번호
    vseq number := 0; -- 교육생 수강횟수
    vresult sys_refcursor;
    vname2 varchar2(20); -- 비교할 이름
    vrow tblstudent%rowtype;
begin
    
    -- 면접이 합격한 사람만 교육생 추가 가능
    select ir.interviewer_name into vname2 
    from tblinterviewer ir 
        inner join tblinterview i 
            on i.interviewer_seq = ir.interviewer_seq 
    where instr(ir.interviewer_name, vname) != 0 and upper(i.interview_result) = upper('Y');  
    
    -- 추가할 이름과 합격한 면접자의 이름이 같으면 교육생 정보 추가  
    if(vname = vname2) 
        then procAddStudent(vname, vssn, vtel, vseq, vresult);
    end if;
    
    dbms_output.put_line(chr(10));
    dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    dbms_output.put_line('학생번호' || chr(9) || chr(9) || ' ' || '학생명' || chr(9)|| chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || '주민등록번호' || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || '연락처' || chr(9) || chr(9) || chr(9) || chr(9) || '  ' || '수강횟수');
    dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;    
        
        dbms_output.put_line(chr(9) || lpad(vrow.student_seq, 3, ' ') || chr(9) || chr(9) || chr(9) || lpad(vrow.student_name, 8, ' ') || ' ' || chr(9) || chr(9) || chr(9) || chr(9) || lpad(vrow.student_ssn, 14, ' ') || chr(9) || chr(9) || chr(9) || vrow.student_tel || chr(9) || chr(9) || chr(9) || chr(9) || vrow.student_coursenum);
        dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    end loop;
    
exception
    when no_data_found then
        dbms_output.put_line('존재하지 않는 값입니다');
    when others then 
        dbms_output.put_line('잘못된 값입니다');
    
end;




-- 교육생 수정
begin
update tblstudent
set
    student_seq = 3,
    student_name = '김경아',
    student_tel = '010-1234-5678',
    student_coursenum = 2
where student_seq = 3;

exception
    when dup_val_on_index then
        dbms_output.put_line('이미 존재하는 값입니다');
    when data_no_found then
        dbms_output.put_line('존재하지 않는 값입니다');
    when others then
        dbms_output.put_line('잘못된 값입니다');
end;

-- 교육생 삭제

delete tblstudent where student_name = '탁연아';

-- A-5-2 전체 교육생 조회
-- 전체 교육생 조회
select distinct "학생번호", "학생명", substr("학생 주민등록번호", 8) as "학생 주민등록번호", "학생 연락처", "학생 수강횟수" from vwstudent order by "학생번호";



-- A-5-3 특정 교육생 조회
-- #특정 교육생(3번 교육생) 조회
select 
    "학생명", 
    "과정명" , 
    "과정시작일", 
    "과정종료일", 
    "과정기간" || '개월' as 과정기간, 
    "강의실명",
    case 
        when "탈락일" is not null
            then '탈락'
        else '수료'
    end as "수료 여부",
    case 
        when "탈락일" is null then "수료일"
        else "탈락일"
    end as "수료/탈락일"
from vwstudent where "학생번호" = 3;

-- #특정 과정(3번 과정) 조회
select 
    distinct "학생명", 
    "과정명" , 
    "과정시작일", 
    "과정종료일", 
    "과정기간" || '개월' as 과정기간, 
    "강의실명",
    case 
        when "탈락일" is not null
            then '탈락'
        else '수료'
    end as "수료 여부",
    case 
        when "탈락일" is null then "수료일"
        else "탈락일"
    end as "수료/탈락일"
from vwstudent where "과정번호" = 3
order by "과정시작일";



-- A-5-4 교육생 중도탈락 처리
-- 교육생 중도탈락 처리

-- 테스트 - EX) 2019년 5월 1일에 3번 교육생이 중도 탈락
insert into tblabandonment(abandonment_seq, enrollment_seq, abandonment_date) values (abandonment_seq.nextval, 3, '19-05-01');

-- 테스트 - 3번 교육생의 중도 탈락 정보 확인
select "학생번호", "학생명", "과정명", "과정시작일", "과정종료일", "탈락일" from vwstudent where "학생 수강신청 번호" = 3;




 