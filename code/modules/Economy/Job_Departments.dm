var/list/station_departments = list("Command", "Medical", "Engineering", "Science", "Security", "Cargo", "Civilian")
var/list/department_head = list("Engineering" = /datum/job/chief_engineer, "Medical" = /datum/job/cmo, "Science" = /datum/job/rd, "Security" = /datum/job/hos, "Cargo" = /datum/job/qm)

// The department the job belongs to.
/datum/job/var/department = null

// Whether this is a head position
/datum/job/var/head_position = 0

/datum/job/captain/department = "Command"
/datum/job/captain/head_position = 1

/datum/job/hop/department = "Civilian"
/datum/job/hop/head_position = 1

/datum/job/assistant/department = "Civilian"

/datum/job/bartender/department = "Civilian"

/datum/job/chef/department = "Civilian"

/datum/job/hydro/department = "Civilian"

/datum/job/janitor/department = "Civilian"

/datum/job/librarian/department = "Civilian"

/datum/job/lawyer/department = "Civilian"

/datum/job/chaplain/department = "Civilian"

/datum/job/clown/department = "Civilian"

/datum/job/mime/department = "Civilian"

/datum/job/qm/department = "Cargo"
/datum/job/qm/head_position = 1
/datum/job/qm/department_prioritized = 0

/datum/job/cargo_tech/department = "Cargo"

/datum/job/mining/department = "Cargo"

/datum/job/chief_engineer/department = "Engineering"
/datum/job/chief_engineer/head_position = 1
/datum/job/chief_engineer/department_prioritized = 0

/datum/job/engineer/department = "Engineering"

/datum/job/atmos/department = "Engineering"

/datum/job/cmo/department = "Medical"
/datum/job/cmo/head_position = 1
/datum/job/cmo/department_prioritized = 0

/datum/job/doctor/department = "Medical"

/datum/job/chemist/department = "Medical"

/datum/job/geneticist/department = "Medical"

/datum/job/rd/department = "Science"
/datum/job/rd/head_position = 1
/datum/job/rd/department_prioritized = 0

/datum/job/scientist/department = "Science"

/datum/job/roboticist/department = "Science"

/datum/job/hos/department = "Security"
/datum/job/hos/head_position = 1
/datum/job/hos/department_prioritized = 0

/datum/job/warden/department = "Security"

/datum/job/detective/department = "Security"

/datum/job/officer/department = "Security"
