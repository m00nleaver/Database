-- C-2. 학생 -> 학생 출결 조회
-- 학생이 수강한 과정의 출결 조회


insert into tblCourse(course_seq, course_name, course_period) values(course_seq.nextval, 'Github 기반의 스프링을 활용한 프레임워크 구축 개발자', 6);

-- 프로시저(학생 -> 학생 출결 조회)
create or replace procedure procStudentAttendance
(
    pseq number, -- 학생 번호
    pyear number, -- 년
    pmonth number, -- 월
    pday number, -- 일
    presult out sys_refcursor
)
is
begin
    
    -- 특정 학생 전체 출결 조회
    if pseq != 0 and pyear = 0 and pmonth = 0 and pday = 0 then
        open presult
            for select * from vwstudentattendance where "학생번호" = pseq;
            
    -- 특정 학생, 특정 연도 출결 조회            
    elsif pseq != 0 and pyear != 0 and pmonth = 0 and pday = 0 then
        open presult
            for select * from vwstudentattendance where "학생번호" = pseq and to_char("출결일", 'YYYY') = to_char(pyear);
            
    -- 특정 학생, 특정 연도, 특정월 출결 조회               
    elsif pseq != 0 and pyear != 0 and pmonth != 0 and pday = 0 then
        open presult
            for select * from vwstudentattendance where "학생번호" = pseq and to_char("출결일", 'YYYY') = to_char(pyear) and to_number(to_char("출결일", 'MM')) = pmonth;
            
    -- 특정 학생, 특정 연도, 특정월, 특정일 출결 조회               
    elsif pseq != 0 and pyear != 0 and pmonth != 0 and pday != 0 then
        open presult
            for select * from vwstudentattendance where "학생번호" = pseq and to_char("출결일", 'YYYY') = to_char(pyear) and to_number(to_char("출결일", 'MM')) = pmonth and to_number(to_char("출결일", 'DD')) = pday;
    end if;
    
exception
    when others then
        dbms_output.put_line('잘못된 값입니다');

end procStudentAttendance;

-- #테스트(학생 -> 학생 출결 조회)
declare
    vseq number := 3; -- 학생 번호
    vyear number := 2019; -- 년
    vmonth number := 2; -- 월
    vday number := 0; -- 일
    vresult sys_refcursor;
    vrow vwstudentattendance%rowtype;
begin
    
    procstudentattendance(vseq, vyear, vmonth, vday, vresult);
    
    dbms_output.put_line(chr(10));
    dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    dbms_output.put_line(chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || '과정명' 
                                        || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || '출결일' || chr(9)|| chr(9) 
                                        || chr(9) || ' ' || '입실시간' || chr(9) || chr(9) || ' ' || '입실상태' || ' ' || chr(9) || chr(9) || ' ' || '퇴실시간' || chr(9) || chr(9) || ' ' || '퇴실상태');
    dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        
        dbms_output.put_line(vrow."과정명" || chr(9) || chr(9) || chr(9) || ' ' || vrow."출결일" || chr(9) || chr(9) || chr(9) || vrow."입실시간" || chr(9) || chr(9) || chr(9) || vrow."입실상태" 
        || chr(9) || chr(9) || ' ' || chr(9) || vrow."퇴실시간" || chr(9) || chr(9) || chr(9) || vrow."퇴실상태");
        dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
        
    end loop;
    
exception
    when others then
        dbms_output.put_line('잘못된 값입니다');
  
end;


