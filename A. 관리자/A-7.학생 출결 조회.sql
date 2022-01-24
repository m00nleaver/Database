-- A-7. 관리자 -> 학생 출결 조회
-- 특정 과정, 특정 인원, 특정 기간에 대한 출결 조회

-- 프로시저(관리자 -> 학생 출결 조회)
create or replace procedure procAdminAttendance
(
    pcseq number, -- 과정 번호
    psseq number, -- 학생 번호
    pyear number, -- 년
    pmonth number, -- 월
    pday number, -- 일
    presult out sys_refcursor
)
is
begin

    -- 특정 과정 출결 조회
    if pcseq != 0 and psseq = 0 and pyear = 0 and pmonth = 0 and pday = 0 then
        open presult
            for select * from vwattendance where "과정번호" = pcseq and "교사명" = '조인규';
            
    -- 특정 과정, 특정 인원 출결 조회        
    elsif pcseq != 0 and psseq != 0 and pyear = 0 and pmonth = 0 and pday = 0 then
        open presult
            for select * from vwattendance where "과정번호" = pcseq and "학생번호" = psseq and "교사명" = '조인규';
            
    -- 특정 과정, 특정 인원, 특정 연도 출결 조회            
    elsif pcseq != 0 and psseq != 0 and pyear != 0 and pmonth = 0 and pday = 0 then
        open presult
            for select * from vwattendance where "과정번호" = pcseq and "학생번호" = psseq and to_char("출결일", 'YYYY') = to_char(pyear) and "교사명" = '조인규';
            
    -- 특정 과정, 특정 인원, 특정 연도, 특정월 출결 조회            
    elsif pcseq != 0 and psseq != 0 and pyear != 0 and pmonth != 0 and pday = 0 then
        open presult
            for select * from vwattendance where "과정번호" = pcseq and "학생번호" = psseq and to_char("출결일", 'YYYY') = to_char(pyear) and to_number(to_char("출결일", 'MM')) = pmonth and "교사명" = '조인규';
            
    -- 특정 과정, 특정 인원, 특정 연도, 특정월, 특정일 출결 조회             
    elsif pcseq != 0 and psseq != 0 and pyear != 0 and pmonth != 0 and pday != 0 then
        open presult
            for select * from vwattendance where "과정번호" = pcseq and "학생번호" = psseq and to_char("출결일", 'YYYY') = to_char(pyear) and to_number(to_char("출결일", 'MM')) = pmonth 
            and to_number(to_char("출결일", 'DD')) = pday and "교사명" = '조인규';
    end if;
    
exception
    when others then
        dbms_output.put_line('잘못된 값입니다');    

end procAdminAttendance;

select * from tblenrollment where oc_seq = 1;
select * from vwattendance where "학생번호" = 3 and "교사명" = '조인규';

-- 테스트(관리자 -> 학생 출결 조회)
declare
    vcseq number := 3; -- 과정 번호
    vsseq number := 3; -- 학생 번호
    vyear number := 2019; -- 년
    vmonth number := 2; -- 월
    vday number := 0; -- 일
    vresult sys_refcursor;
    vrow vwAttendance%rowtype;
begin
    procAdminAttendance(vcseq, vsseq, vyear, vmonth, vday, vresult);
    
    dbms_output.put_line(chr(10));
    dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    dbms_output.put_line(chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || '과정명' 
                                        || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || chr(9) || '출결일' || chr(9)|| chr(9) 
                                        || chr(9) || ' ' || '입실시간' || chr(9) || chr(9) || ' ' || '입실상태' || ' ' || chr(9) || chr(9) || ' ' || '퇴실시간' || chr(9) || chr(9) || ' ' || '퇴실상태');
    dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        
        dbms_output.put_line(vrow."과정명" || chr(9) || chr(9) || chr(9) || chr(9) || ' ' || vrow."출결일" || chr(9) || chr(9) || chr(9) || vrow."입실시간" || chr(9) || chr(9) || chr(9) || vrow."입실상태" 
        || chr(9) || chr(9) || ' ' || chr(9) || vrow."퇴실시간" || chr(9) || chr(9) || chr(9) || vrow."퇴실상태");
        dbms_output.put_line('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
        
    end loop;
    
exception
    when others then
        dbms_output.put_line('잘못된 값입니다');        
  
end;




