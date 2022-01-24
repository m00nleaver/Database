--a-8
----------------------------------------------------------------------------------------------------------------------
--A-8. 면접 관리 (관리자는 비회원의 면접을 관리)
----------------------------------------------------------------------------------------------------------------------
--A-8-1. 비회원의 면접 신청 정보를 조회한다.
----------------------------------------------------------------------------------------------------------------------
select 
        seq as "면접번호",
        name as "이름",
        tel as "전화번호",
        oc_seq as "희망과정",
        hopedate as "희망면접일",
        ensuredate as "확정면접일",
        result as "면접결과"
from vwinterviewinfo order by seq; --seq순 조회

select 
        seq as "면접번호",
        name as "이름",
        tel as "전화번호",
        oc_seq as "희망과정",
        hopedate as "희망면접일",
        ensuredate as "확정면접일",
        result as "면접결과"
from vwinterviewinfo 
    where hopedate between to_date('19-01-01', 'yy-mm-dd') and to_date('19-12-31', 'yy-mm-dd')--년도별 조회
order by seq, hopedate;

----------------------------------------------------------------------------------------------------------------------
-- A-8-2.면접 신청 일자와 가능일자를 비교하여 면접 확정일을 입력한다.
----------------------------------------------------------------------------------------------------------------------

--면접 일자 없는 것만 뽑아오기
select * from vwInterviewNull;


--이번 달 희망 면접일//면접 가능일자 확인하기
--vwThisMonthHopeDate로 확인
select 
        v.regdate, 
        v.interviewer_name,
        v.interviewer_seq 
from vwThisMonthHopeDate v 
    left outer join tblinterview i 
        on v.interviewer_seq = i.interviewer_seq;
 --업그레이드
 
----------------------------------------------------------------------------------------------------------------------
--이번 달 전체 면접 신청 일자 확인
----------------------------------------------------------------------------------------------------------------------
set serverout on;

DECLARE
vregdate date;
vname varchar2(50);
vseq number;

CURSOR EX_CUR --커서 선언
IS
SELECT
v.regdate as regdate, 
v.interviewer_name as name,
v.interviewer_seq as seq
FROM
vwThisMonthHopeDate v 
            left outer join tblinterview i on v.interviewer_seq = i.interviewer_seq;

BEGIN
OPEN EX_CUR;-- 2. 명시적 커서 오픈
dbms_output.put_line(chr(10)  ||chr(10)||  chr(10));   
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');

DBMS_OUTPUT.PUT_LINE(chr(9) ||chr(9) ||chr(9) ||chr(9) ||chr(9) ||'이번 달 면접 신청자 현황');
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
DBMS_OUTPUT.PUT_LINE(chr(9)||'날짜'||chr(9) ||chr(9) ||chr(9) ||'면접 가능'||chr(9) ||'신청자 번호');
LOOP
FETCH EX_CUR INTO vregdate, vname, vseq; --커서에서 데이터 가져오기
EXIT WHEN EX_CUR %NOTFOUND; --커서가 없을 경우 종료
DBMS_OUTPUT.PUT_LINE(chr(9)||vregdate||chr(9)||vname||chr(9)||chr(9) ||chr(9) ||vseq);
END LOOP;

CLOSE EX_CUR; --커서 닫기
END;


 
 --희망면접일이 공휴일이 아니라 면접이 가능한 학생 번호 
 select tm.regdate, n."면접번호" from vwthismonthhopedate tm left join  vwinterviewnull n on tm.interviewer_seq = n."면접번호"
where n."확정 면접일" is null and instr(tm.interviewer_name,'*')=0;


--면접일이 공휴일+주말이라 안되는 신청자
select tm.regdate, n."면접번호" from vwthismonthhopedate tm inner join  vwinterviewnull n on tm.interviewer_seq = n."면접번호"
where n."확정 면접일" is null and instr(tm.interviewer_name,'*')>0;

--업그레이드
DECLARE
vregdate date;
vname varchar2(30);
vseq number;

CURSOR EX_CUR --커서 선언
IS
select 
        tm.regdate, 
        n."이름",
        n."면접번호" 
        
from vwthismonthhopedate tm 
    inner join  vwinterviewnull n 
        on tm.interviewer_seq = n."면접번호"
            where n."확정 면접일" is null and instr(tm.interviewer_name,'*')>0;

BEGIN
OPEN EX_CUR;-- 2. 명시적 커서 오픈
dbms_output.put_line(chr(10)  ||chr(10)||  chr(10));   
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');

DBMS_OUTPUT.PUT_LINE(chr(9) ||chr(9) ||chr(9) ||chr(9) ||chr(9) ||'주말 * 공휴일 면접 신청자');
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------'||  chr(10));
DBMS_OUTPUT.PUT_LINE(chr(9)||'날짜'||chr(9) ||chr(9) ||chr(9) ||'면접자 이름'||chr(9) ||'신청자 번호'||  chr(10));
LOOP
FETCH EX_CUR INTO vregdate, vname, vseq; --커서에서 데이터 가져오기
EXIT WHEN EX_CUR %NOTFOUND; --커서가 없을 경우 종료
DBMS_OUTPUT.PUT_LINE(chr(9)||vregdate||chr(9)||vname||chr(9)||chr(9) ||chr(9) ||vseq);
END LOOP;

CLOSE EX_CUR; --커서 닫기
END;


select 
        v.regdate, 
        v.interviewer_name,
        v.interviewer_seq 
from vwThisMonthHopeDate v 
    left outer join tblinterview i 
        on v.interviewer_seq = i.interviewer_seq where v.interviewer_name is null;
        

--면접 확정일자 입력
insert into tblInterview(interviewer_seq, interview_date, interview_result) 
    values(803, 
    --'2019-01-06', --임의 입력
    (select interviewer_date from tblInterviewer where interviewer_seq = 803),--희망날짜 = 면접날짜
    null);

----------------------------------------------------------------------------------------------------------------------
--주말 * 공휴일 면접 신청자 임의 입력해주기
----------------------------------------------------------------------------------------------------------------------
--1. 평일 중 신청자가 없는 날짜 확인하기

DECLARE
vregdate date;

CURSOR EX_CUR --커서 선언
IS
select 
        v.regdate        
from vwThisMonthHopeDate v 
    left outer join tblinterview i 
        on v.interviewer_seq = i.interviewer_seq where v.interviewer_name is null;

BEGIN
OPEN EX_CUR;-- 2. 명시적 커서 오픈
dbms_output.put_line(chr(10)  ||chr(10)||  chr(10));   
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');

DBMS_OUTPUT.PUT_LINE(chr(9) ||chr(9) ||chr(9) ||chr(9) ||chr(9) ||'신청자가 없는 일자');
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------'||  chr(10));
DBMS_OUTPUT.PUT_LINE(chr(9)||'날짜'||  chr(10));
LOOP
FETCH EX_CUR INTO vregdate; --커서에서 데이터 가져오기
EXIT WHEN EX_CUR %NOTFOUND; --커서가 없을 경우 종료
DBMS_OUTPUT.PUT_LINE(chr(9)||vregdate);
END LOOP;

CLOSE EX_CUR; --커서 닫기
END;


------------------------------
--2-0. 등록 프로시저
create or replace procedure procAddInterview (
    pseq number,
    pdate date
)
is
begin
    insert into tblInterview(interviewer_seq, interview_date, interview_result) 
        values (pseq, pdate, null);
     DBMS_OUTPUT.PUT_LINE('------------------------------');   
    dbms_output.put_line('면접일 등록: ' || pdate || '로 등록되었습니다.');
    DBMS_OUTPUT.PUT_LINE('------------------------------');   
exception
    when others then
        DBMS_OUTPUT.PUT_LINE('------------------------------');   
        dbms_output.put_line('면접일 실패: No.' || pdate || '로 등록 실패했습니다.');
        DBMS_OUTPUT.PUT_LINE('------------------------------');   
        dbms_output.put_line(sqlerrm);
end procAddInterview;



------------------------------
--2-1. 신민석
begin
--    procAddInterview(면접자 번호, 확정면접일);
    procAddInterview(301, to_date('21/12/20','yy/mm/dd'));
end;
------------------------------
--2-2. 정경림
begin
--    procAddInterview(면접자 번호, 확정면접일);
    procAddInterview(309, to_date('21/12/21','yy/mm/dd'));
end;

------------------------------
--3. 확인해보기
DECLARE
vregdate date;
vname varchar2(30);
vseq number;

CURSOR EX_CUR --커서 선언
IS
select 
        tm.regdate, 
        n."이름",
        n."면접번호" 
        
from vwthismonthhopedate tm 
    inner join  vwinterviewnull n 
        on tm.interviewer_seq = n."면접번호"
            where n."확정 면접일" is null and instr(tm.interviewer_name,'*')>0;

BEGIN
OPEN EX_CUR;-- 2. 명시적 커서 오픈
dbms_output.put_line(chr(10)  ||chr(10)||  chr(10));   
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');

DBMS_OUTPUT.PUT_LINE(chr(9) ||chr(9) ||chr(9) ||chr(9) ||chr(9) ||'주말 * 공휴일 면접 신청자');
DBMS_OUTPUT.PUT_LINE('---------------------------------------------------'||  chr(10));
DBMS_OUTPUT.PUT_LINE(chr(9)||'날짜'||chr(9) ||chr(9) ||chr(9) ||'면접자 이름'||chr(9) ||'신청자 번호'||  chr(10));
LOOP
FETCH EX_CUR INTO vregdate, vname, vseq; --커서에서 데이터 가져오기
EXIT WHEN EX_CUR %NOTFOUND; --커서가 없을 경우 종료
DBMS_OUTPUT.PUT_LINE(chr(9)||vregdate||chr(9)||vname||chr(9)||chr(9) ||chr(9) ||vseq);
END LOOP;

CLOSE EX_CUR; --커서 닫기
END;


--평일인 경우 확정일자 반복해서 입력
--프로시저 loop 이용
DECLARE
      V_CNT NUMBER(2) := 0;    --초기값
      vcount number :=0;
BEGIN
    select count(*) into vcount from vwthismonthhopedate tm inner join  vwinterviewnull n on tm.interviewer_seq = n."면접번호"
where n."확정 면접일" is null and instr(tm.interviewer_name,'*')=0;
    LOOP
    EXIT WHEN V_CNT = vcount;
    V_CNT := V_CNT + 1;   
      insert into tblinterview(interviewer_seq, interview_date, interview_result) 
    values((select tm.interviewer_seq from vwthismonthhopedate tm inner join  vwinterviewnull n on tm.interviewer_seq = n."면접번호" where n."확정 면접일" is null
    and instr(tm.interviewer_name,'*')=0 and rownum =1),
    (select tm.regdate from vwthismonthhopedate tm inner join  vwinterviewnull n on tm.interviewer_seq = n."면접번호" where n."확정 면접일" is null
    and instr(tm.interviewer_name,'*')=0 and rownum =1),
    null);
    END LOOP;
END;


--업그레이드
Declare
    vseq number;
    vname varchar2(30);
    vdate date;
    
Cursor cu1 is 
 select 
 tm.interviewer_seq,
 tm.interviewer_name,
 tm.regdate
 from 
 vwthismonthhopedate tm 
    inner join  vwinterviewnull n 
        on tm.interviewer_seq = n."면접번호" where n."확정 면접일" is null
    and instr(tm.interviewer_name,'*')=0; 
 
 begin
     open cu1;
     
     
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------'||  chr(10));
     loop
        fetch cu1 into vseq,vname, vdate;      --fetch 커서에서 값을 꺼내오는 것
        exit when cu1%NotFound; --커서에 있는 데이터를 fatch하여 넣어주는데
                                                   --더이상 변수에 할당할 레코드가 없을 때 빠져나간다
        insert into tblinterview(interviewer_seq, interview_date, interview_result) 
        values (vseq, vdate,null);
        DBMS_OUTPUT.PUT_LINE(vname||chr(9)||'면접일 입력 성공');
        end loop;
        close cu1;
        end;


----------------------------------------------------------------------------------------------------------------------
-- A-8-3. 면접 응시 완료자들은 면접 합격 여부를 입력한다.
----------------------------------------------------------------------------------------------------------------------
UPDATE tblInterview 
    SET interview_result = 'Y' 
    --SET interview_result = 'N' 불합격 
    WHERE to_char(interview_date) =to_char(sysdate, 'yy/mm/dd')--오늘 날짜
    --WHERE to_char(interview_date) =to_char('21/10/30', 'yy/mm/dd')-- 날짜 선택
    and interviewer_seq = 802;--면접자 번호
    --관리자면 관리자 seq입력하면 됨




----------------------------------------------------------------------------------------------------------------------
-- A-8-4.면접 합격자의 수강 과정은 희망 과정을 참고하며, 변경할 수 있다.
----------------------------------------------------------------------------------------------------------------------
--0-1. 면접 결과 입력 확인하기
select 
seq as "면접 번호",
name as "면접자명",
ensuredate as "면접 일자",
oc_seq as "희망과정번호",
result as "면접 결과"
from vwinterviewinfo
    where seq = 304;



--면접 합격자 교육생에 넣기 (희망과정에 정원이 있을 경우)
--뷰 사용
--현재 개설예정 강의
select * from vwcourseinfo where oc_startdate>sysdate ;

select 
    o.oc_seq, s.ccourse_name , count(*) as cnt
from vwstudentinfo s 
    left join tblenrollment e
        on s.eseq = e.enrollment_seq
            inner join tblopencourse o
                on e.oc_seq = o.oc_seq
where o.oc_startdate>sysdate
group by o.oc_seq, s.ccourse_name order by count(*) desc;

--업그레이드
declare
    vcnt number;
begin
    select count(*) as cnt
     into vcnt
from vwstudentinfo s 
    inner join tblenrollment e
        on s.eseq = e.enrollment_seq
            inner join tblopencourse o
                on e.oc_seq = o.oc_seq
                    where o.oc_startdate> sysdate and o.oc_seq =22; --희망과정 번호

     if vcnt <= 25 then
        insert into tblStudent (student_seq, student_name, student_ssn, student_tel, student_coursenum)
        values (student_seq.nextval, 
        (select name from vwinterviewinfo where result = 'Y' and seq = 304),--면접자 번호 수기 입력
        '951219-1000001',--수기 입력
        (select tel from vwinterviewinfo where result = 'Y' and seq = 304),--면접자 번호 수기 입력
        (select oc_seq from vwinterviewinfo where result = 'Y' and seq = 304)--면접자 번호 수기 입력
                );
        dbms_output.put_line('합격한 면접자 교육생으로 입력 완료되었습니다 ^0^');  
        elsif vcnt >25 and vcnt<=29 then
        dbms_output.put_line('수강 인원 확인 후 입력해주세요 :0');  
        else 
        DBMS_OUTPUT.PUT_LINE('다른 개설과정으로 입력하세요 :(');
    end if;
end;


--개설 예정 과정이 정원 초과인지 아닌지 확인하기
--프로시저 이용
declare
    vcnt number;
begin
    select count(*) as cnt
     into vcnt
from vwstudentinfo s 
    inner join tblenrollment e
        on s.enrollment_seq = e.enrollment_seq
            inner join tblopencourse o
                on e.oc_seq = o.oc_seq
                    where o.oc_startdate> sysdate;

     if vcnt <= 26 then
        insert into tblStudent (student_seq, student_name, student_ssn, student_tel, student_coursenum)
        values (student_seq.nextval, 
        (select name from vwinterviewinfo where result = 'Y' and seq = 302),--면접자 번호 수기 입력
        '951219-0000001',--수기 입력
        (select tel from vwinterviewinfo where result = 'Y' and seq = 302),--면접자 번호 수기 입력
        (select oc_seq from vwinterviewinfo where result = 'Y' and seq = 302)--면접자 번호 수기 입력
                );
        dbms_output.put_line('입력 완료');  
        elsif vcnt >= 27 and vcnt<=30 then
        dbms_output.put_line('수강 인원 확인 후 입력해주세요');  
        else 
        DBMS_OUTPUT.PUT_LINE('다른 개설과정으로 입력하세요.');
    end if;
end;





--과정 수기 입력
--뷰사용
insert into tblStudent (student_seq, student_name, student_ssn, student_tel, student_coursenum) 
     values (student_seq.nextVal,
        (select name from vwinterviewinfo where result = 'Y' and seq = 300),--면접자 번호 수기 입력
        '951219-0000001',--수기 입력
        (select tel from vwinterviewinfo where result = 'Y' and seq = 300),--면접자 번호 수기 입력
         42--면접자 번호 수기 입력
                );



--면접 합격자 수강신청에 넣기 
insert into tblEnrollment (enrollment_seq, oc_seq, student_seq) 
    values (enrollment_seq.nextVal,과정번호,학생번호);