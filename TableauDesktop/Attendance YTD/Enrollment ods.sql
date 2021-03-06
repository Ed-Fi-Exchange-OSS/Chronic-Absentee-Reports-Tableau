SELECT ssa.[StudentUSI],
       s.StudentUniqueId,
        [SchoolId],
        NameOfInstitution
       ,[EntryDate]
	   ,[ExitWithdrawDate]
       ,[SchoolYear]
       , egld.CodeValue as EntryGradeLevelDescriptor
	  ,(CASE 
			WHEN egld.CodeValue='Kindergarten'   then '0'
			WHEN egld.CodeValue='First grade'    then '1'
			WHEN egld.CodeValue='Second grade'   then '2'
			WHEN egld.CodeValue='Third grade'    then '3'
			WHEN egld.CodeValue='Fourth grade'   then '4'
			WHEN egld.CodeValue='Fifth grade'    then '5'
			WHEN egld.CodeValue='Sixth grade'    then '6'
			WHEN egld.CodeValue='Seventh grade'  then '7'
			WHEN egld.CodeValue='Eighth grade'   then '8'
			WHEN egld.CodeValue='Ninth grade'    then '9'
			WHEN egld.CodeValue='Tenth grade'    then '10'
			WHEN egld.CodeValue='Eleventh grade' then '11'
			WHEN egld.CodeValue='Twelfth grade'  then '12'
			ELSE NULL
	    END) Grade
FROM [edfi].[StudentSchoolAssociation] ssa
INNER JOIN edfi.EducationOrganization edorg on ssa.SchoolId = edorg.EducationOrganizationId
INNER JOIN edfi.Student s on ssa.StudentUSI=s.StudentUsi
INNER JOIN edfi.Descriptor egld on ssa.EntryGradeLevelDescriptorId = egld.DescriptorId
Where ssa.SchoolId in (255901001,255901044,255901107) and ExitWithdrawDate is null -- and Schoolyear = 2020 
;
