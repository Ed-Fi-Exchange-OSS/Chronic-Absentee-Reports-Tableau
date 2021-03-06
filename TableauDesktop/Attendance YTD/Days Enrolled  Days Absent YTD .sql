/* Student Days Enrolled and Days Absent as of today*/
SELECT   
         ssa.SchoolId,
		 stu.StudentUniqueId, 
		 case 
		  when egld.CodeValue = 'Kindergarten' then  '0'
		  when egld.CodeValue = 'First Grade' then  '1'
		  when egld.CodeValue = 'Second Grade' then  '2'
		  when egld.CodeValue = 'Third Grade' then  '3'
		  when egld.CodeValue = 'Fourth Grade' then  '4'
		  when egld.CodeValue = 'Fifth grade' then  '5'
		  when egld.CodeValue = 'Sixth Grade' then  '6'
		  when egld.CodeValue = 'Seventh Grade' then  '7'
		  when egld.CodeValue = 'Eighth Grade' then  '8'
		  when egld.CodeValue = 'Ninth Grade' Then '9'
		  when egld.CodeValue = 'Tenth Grade' then  '10'
		  when egld.CodeValue = 'Eleventh Grade' then  '11'
		  when egld.CodeValue = 'Twelfth Grade' then  '12'
		   when egld.CodeValue = 'Transitional Kindergarten' then  'other'
		    when egld.CodeValue = 'Preschool' then  'other'
		  when egld.CodeValue = '22' then  'other'
		   else 'unknown'
						 end as [EntryGradeLevel],

		--gld.CodeValue   as [GradeLevel] , 
         ssa.SchoolYEar,
        -- syt.SchoolYear,
        -- ses.SchoolYear, 
	     ses.SessionName,
		 ssa.StudentUSI
		-- ses.BeginDate sesBeginDate, 
		-- ses.EndDate sesEndDate

	--, Min(cda.Date) CalendarBeginDate, Max(cda.Date) CalendarEndDate
    , count(*) DaysPresentAndEnrolledAsOfToday
	, ( SELECT count(*) 
	    FROM edfi.StudentSchoolAttendanceEvent ssae 
		INNER JOIN edfi.Descriptor d on ssae.AttendanceEventCategoryDescriptorId = d.DescriptorId
		WHERE ssae.StudentUSI=ssa.StudentUSI  and ssae.SchoolId = ssa.SchoolId  
			  and d.CodeValue not in ('In Attendance', '223', '222') -- *NOTE: We need to ask about this. 223 is 'Ind. Study Incomplete' and 222 is 'Ind. Study Incomplete'
			  and ses.BeginDate<= ssae.EventDate and ses.EndDate>=ssae.EventDate
	  ) DaysAbsent
FROM edfi.Student stu 
INNER JOIN edfi.StudentSchoolAssociation ssa on stu.StudentUSI = ssa.StudentUSI
INNER JOIN edfi.Descriptor egld on ssa.EntryGradeLevelDescriptorId = egld.DescriptorId
-- NOTE: SchoolYear was commented out because in the v26_PopulatedTemplate there is no schoolyear in StudentSchoolAssociation
INNER JOIN edfi.Session ses on ssa.SchoolId = ses.SchoolId --and ssa.SchoolYear=ses.SchoolYear --and ses.SessionName like '%Semester%'
INNER JOIN edfi.SchoolYearType syt on ses.SchoolYear = syt.SchoolYear --and syt.SchoolYear=2020 --syt.CurrentSchoolYear=1 -- Current School Year
INNER JOIN edfi.CalendarDate cda on ses.SchoolId=cda.SchoolId and ses.BeginDate<=cda.Date and ses.EndDate>=cda.Date
INNER JOIN edfi.CalendarDateCalendarEvent cdce on cda.Date=cdce.Date and cda.SchoolId=cdce.SchoolId
INNER JOIN edfi.Descriptor cdet on cdce.CalendarEventDescriptorId = cdet.DescriptorId and cdet.CodeValue='Instructional day' -- ONLY Instructional days
where cdce.Date >= ssa.EntryDate -- Start from the students enrollment day
	  and cdce.Date <= GETDATE() -- Given today	 
and ( (ssa.ExitWithdrawDate is null) or (ssa.ExitWithdrawDate is not null and cdce.Date<=ssa.ExitWithdrawDate) )
--and ssa.SchoolId in (12,13,16,18,20,21,23,24,25,26,27,28)
-- For debugging purposes: narrow down to a specific student.
--and ssa.StudentUSI in (1809)
--and stu.StudentUniqueId = 64490
group by ssa.StudentUSI,stu.StudentUniqueId, ssa.SchoolId,egld.CodeValue,  ssa.SchoolYEar, syt.SchoolYear, ses.SchoolYear, ses.SessionName, ses.BeginDate, ses.EndDate--, --, ssa.EntryDate, ssa.ExitWithdrawDate
order by  entrygradelevel, StudentUSI
;

-- QUERIES to debug:
-- ENROLLMENT
-- SELECT * FROM edfi.StudentSchoolAssociation where studentUsi=1706
-- Attendance Events
--SELECT ssae.StudentUSI, EventDate, d.CodeValue, d.Description 
--FROM edfi.StudentSchoolAttendanceEvent ssae 
--INNER JOIN edfi.Descriptor d on ssae.AttendanceEventCategoryDescriptorId = d.DescriptorId
--WHERE d.CodeValue not in ('In Attendance', '223', '222') and studentUsi=1706
--Order by EventDate desc

-- SCHOOL CALENDAR INSTRUCTIONAL DAYS
--SELECT ses.SchoolId, ses.SessionName, cda.Date, cdet.CodeValue FROM edfi.Session ses 
--INNER JOIN edfi.SchoolYearType syt on ses.SchoolYear = syt.SchoolYear and syt.SchoolYear=2020 --syt.CurrentSchoolYear=1 -- Current School Year
--INNER JOIN edfi.CalendarDate cda on ses.SchoolId=cda.SchoolId and ses.BeginDate<=cda.Date and ses.EndDate>=cda.Date
--INNER JOIN edfi.CalendarDateCalendarEvent cdce on cda.Date=cdce.Date and cda.SchoolId=cdce.SchoolId
--INNER JOIN edfi.Descriptor cdet on cdce.CalendarEventDescriptorId = cdet.DescriptorId and cdet.CodeValue='Instructional day' -- ONLY Instructional days
--WHERE ses.SessionName like '%Fall Semester%' and ses.SchoolId=1

--DESCRIPTORS
--SELECT * FROM edfi.Descriptor where Namespace like '%Exit%'