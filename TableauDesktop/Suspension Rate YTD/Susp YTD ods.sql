--		School	Student ID	Disposition	Date	Code	School1	Tag	Column1
SELECT di.SchoolId, edorg.NameOfInstitution, s.StudentUsi, s.StudentUniqueId, d.CodeValue Disposition, di.IncidentIdentifier, di.IncidentDate, behaviorDescriptor.CodeValue BehaviorCode, ssa.SchoolYear
--di.IncidentIdentifier, dib.SchoolId, dadi.StudentUSI, di.IncidentDate,
--  behaviorDescriptor.CodeValue Behavior, dt.CodeValue DisciplineType, d.CodeValue DisciplineDescriptor  
  --di.IncidentDescription, dib.BehaviorDetailedDescription,
FROM edfi.DisciplineIncident di
LEFT JOIN edfi.EducationOrganization edorg on di.SchoolId = edorg.EducationOrganizationId
LEFT JOIN edfi.DisciplineIncidentBehavior dib on di.IncidentIdentifier = dib.IncidentIdentifier and di.SchoolId=dib.SchoolId
LEFT JOIN edfi.Descriptor behaviorDescriptor on dib.BehaviorDescriptorId = behaviorDescriptor.DescriptorId
LEFT JOIN edfi.DisciplineActionDisciplineIncident dadi on di.IncidentIdentifier = dadi.IncidentIdentifier and di.SchoolId = dadi.SchoolId
LEFT JOIN edfi.DisciplineAction da on dadi.DisciplineActionIdentifier=da.DisciplineActionIdentifier and dadi.StudentUSI=da.StudentUSI and dadi.DisciplineDate=da.DisciplineDate
LEFT JOIN edfi.DisciplineActionDiscipline dad on da.DisciplineActionIdentifier = dad.DisciplineActionIdentifier and da.StudentUSI = dad.StudentUSI and da.DisciplineDate= dad.DisciplineDate
LEFT JOIN edfi.DisciplineDescriptor dd on dad.DisciplineDescriptorId = dd.DisciplineDescriptorId
LEFT JOIN edfi.DisciplineType dt on dd.DisciplineTypeId = dt.DisciplineTypeId
LEFT JOIN edfi.Descriptor d on dd.DisciplineDescriptorId = d.DescriptorId
LEFT JOIN edfi.Student s on da.StudentUsi = s.StudentUsi
LEFT JOIN edfi.StudentSchoolAssociation ssa on s.StudentUsi = ssa.StudentUSI and di.IncidentDate>=ssa.EntryDate and (ssa.ExitWithdrawDate is null or di.IncidentDate<=ssa.ExitWithdrawDate)
WHERE d.CodeValue is not null and d.CodeValue not in ('Other') -- and ssa.SchoolYear = 2020
--and s.StudentUsi = 1144
ORDER By di.IncidentIdentifier, dadi.StudentUSI;

-- This Query is to debug enrollment of the student. We have cases where there is a discipline incident when student is not enrolled.
--SELECT StudentUsi, SchoolId, EntryDate, ExitWithdrawDate FROM edfi.StudentSchoolAssociation where StudentUsi=17060
--SELECT * FROM edfi.StudentDisciplineIncidentAssociation Where StudentUSI=1144 and incidentIdentifier=181531