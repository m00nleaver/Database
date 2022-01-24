----------------------------------------------------------------------------------------------------------------------
--C-5 사후 처리 입력
----------------------------------------------------------------------------------------------------------------------
--C-5-1 취업 상황(분야/취업일/고용보험 여부)을 기재
--C-5-2 취업 알선 희망 여부 등록
----------------------------------------------------------------------------------------------------------------------
--사후관리 종강 후 인지 확인하기
--프로시저 사용
set serverout on;

declare
    vdate date;
begin
    select max(enddate) into vdate from vwStudentInfo where sseq=291;
     if vdate <= to_date(sysdate,'yy/mm/dd') then
       insert into tblPostManagement (pm_seq,enrollment_seq,pm_employee,pm_jobseeker) 
        values (
        pm_seq.nextVal, --사후관리번호
        1,--수강신청번호
        'N',--취업여부
        'Y');--취업 알선 희망 여부
        dbms_output.put_line('입력 완료');  
        else
        DBMS_OUTPUT.PUT_LINE('조기취업자인 경우 수기 입력해주세요');
    end if;
end;

--사후관리 수기입력
insert into tblPostManagement (pm_seq,enrollment_seq,pm_employee,pm_jobseeker) 
    values (
    pm_seq.nextVal, --사후관리번호
    1,--수강신청번호
    'N',--취업여부
    'Y');--취업 알선 희망 여부



--취업 입력
insert into tblEmployee (pm_seq,rc_seq,employee_hiredate,employee_insurance,employee_salary) 
     values (
     pm_seq,--사후번호
     7,--취업분야
     to_date('19/06/16', --취업일
     'rr/mm/dd'),
     'Y',--고용보험여부
     2700);--연봉

----------------------------------------------------------------------------------------------------------------------
--C-5-3 알선 희망시 연봉, 근무지, 분야 기재 
----------------------------------------------------------------------------------------------------------------------

insert into tblJobSeeker (pm_seq,js_salary,area_seq,rc_seq)
    values (11, --사후관리번호
    3200,--희망 연봉
    (select area_seq from tblArea where instr(area_name, '종로구') >0),--근무지
    (select rc_seq from tblrecruitcategory where instr(rc_name, 'game_designer') >0));--분야




