----------------------------------------------------------------------------------------------------------------------
--A-9. 사후 처리
--(교육생에 대한 취업 지원 및 고용보험 가입(취업) 확인)
----------------------------------------------------------------------------------------------------------------------
-- 교육생 정보와 취업 여부, 취업지원 희망 여부를 입력 및 조회한다.
----------------------------------------------------------------------------------------------------------------------

  --사후 처리 기재된 전체 교육생
  select 
          p.pm_seq as "사후관리 여부",
          v.sname as " 학생명", 
          v.stel as "전화번호", 
          p.pm_employee as "취업여부", 
          p.pm_jobseeker as "취업지원 희망 여부" 
  from vwstudentinfo v 
    inner join tblpostmanagement p
        on v.eseq = p.enrollment_seq
            inner join tbljobseeker j
                on p.pm_seq = j.pm_seq;

--그 중 취업한 사람
  select 
          p.pm_seq as "사후관리 여부",
          v.sname as " 학생명", 
          v.stel as "전화번호", 
          p.pm_employee as "취업여부", 
          p.pm_jobseeker as "취업지원 희망 여부" 
  from vwstudentinfo v 
    inner join tblpostmanagement p
        on v.eseq = p.enrollment_seq
            inner join tbljobseeker j
                on p.pm_seq = j.pm_seq
                where p.pm_employee = 'Y'
                ;


----------------------------------------------------------------------------------------------------------------------
--A-9-2 취업자의 경우 취업분야, 취업일, 고용보험 가입 여부 확인 가능
----------------------------------------------------------------------------------------------------------------------
 select 
          v.sname as " 학생명", 
          v.stel as "전화번호", 
          --p.pm_employee as "취업여부",
          e.employee_hiredate as "취업일",
          e.employee_insurance as"고용 보험 가입 여부",
          rc.rc_name as "취업 분야"
  from vwstudentinfo v 
    inner join tblpostmanagement p
        on v.eseq = p.enrollment_seq
            inner join tblemployee e
                on p.pm_seq = e.pm_seq
                    inner join tblrecruitcategory rc
                        on rc.rc_seq = e.rc_seq
                        where p.pm_employee = 'Y';

----------------------------------------------------------------------------------------------------------------------
-- 취업 지원 희망자의 경우 희망 연봉, 근무지, 희망 분야를 확인 
----------------------------------------------------------------------------------------------------------------------

select 
          p.pm_seq as "사후관리 여부",
          v.sname as " 학생명", 
          v.stel as "전화번호", 
          j.js_salary as "희망연봉",
          a.area_name as "희망근무지",
          rc.rc_name as "희망취업분야",
          --p.pm_jobseeker as "취업지원 희망 여부",
          p.pm_employee as "취업여부"
           
  from vwstudentinfo v 
    inner join tblpostmanagement p
        on v.eseq = p.enrollment_seq
            inner join tblemployee e
                on p.pm_seq = e.pm_seq
                    inner join tblrecruitcategory rc
                        on rc.rc_seq = e.rc_seq
                            inner join tbljobseeker j
                                on p.pm_seq = j.pm_seq
                                    inner join tblarea a
                                        on j.area_seq = a.area_seq
                                where p.pm_jobseeker ='Y';



----------------------------------------------------------------------------------------------------------------------
-- 알선하는 기업의 희망 근무자와 일치하는 교육생에게 연결한다. >B.7
----------------------------------------------------------------------------------------------------------------------
select 
        s.sname as "학생명", 
        s.stel as "학생번호",
        a.area_name as "지역명",
        c.company_name as "회사명",
        c.company_tel as "회사번호"
from tblRecruitInfo r
    inner join tblJobSeeker j
        on j.rc_seq = r.rc_seq
        and r.ri_salary = j.js_salary --연봉
                inner join tblcompany c
                    on r.company_seq = c.company_seq
                        inner join tblarea a
                            on c.area_seq = a.area_seq
                                inner join tblpostmanagement p
                                    on p.pm_seq = j.pm_seq 
                                        inner join vwstudentinfo s
                                            on p.enrollment_seq =s.eseq;