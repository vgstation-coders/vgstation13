var/list/station_departments = list("Command", "Medical", "Engineering", "Science", "Security", "Cargo", "Civilian")

// The department the job belongs to.
/datum/job/var/department = null

// Whether this is a head position
/datum/job/var/head_position = 0

// Whether the head of this department is prioritized, due to his subordinates being prioritized
/datum/job/var/department_prioritized

// Link to the department head
/datum/job/var/department_head

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
/datum/job/qm/department_prioritized = FALSE

/datum/job/cargo_tech/department = "Cargo"
/datum/job/cargo_tech/department_head = /datum/job/qm

/datum/job/mining/department = "Cargo"
/datum/job/mining/department_head = /datum/job/qm

/datum/job/chief_engineer/department = "Engineering"
/datum/job/chief_engineer/head_position = 1
/datum/job/chief_engineer/department_prioritized = FALSE

/datum/job/engineer/department = "Engineering"
/datum/job/engineer/department_head = /datum/job/chief_engineer

/datum/job/atmos/department = "Engineering"
/datum/job/atmos/department_head = /datum/job/chief_engineer

/datum/job/mechanic/department = "Engineering"
/datum/job/mechanic/department_head = /datum/job/chief_engineer

/datum/job/cmo/department = "Medical"
/datum/job/cmo/head_position = 1
/datum/job/cmo/department_prioritized = FALSE

/datum/job/doctor/department = "Medical"
/datum/job/doctor/department_head = /datum/job/cmo

/datum/job/paramedic/department = "Medical"
/datum/job/paramedic/department_head = /datum/job/cmo

/datum/job/chemist/department = "Medical"
/datum/job/chemist/department_head = /datum/job/cmo

/datum/job/geneticist/department = "Medical"
/datum/job/geneticist/department_head = /datum/job/cmo

/datum/job/virologist/department = "Medical"
/datum/job/virologist/department_head = /datum/job/cmo

/datum/job/orderly/department = "Medical"
/datum/job/orderly/department_head = /datum/job/cmo

/datum/job/rd/department = "Science"
/datum/job/rd/head_position = 1
/datum/job/rd/department_prioritized = FALSE

/datum/job/scientist/department = "Science"
/datum/job/scientist/department_head = /datum/job/rd

/datum/job/roboticist/department = "Science"
/datum/job/roboticist/department_head = /datum/job/rd

/datum/job/xenobiologist/department  = "Science"
/datum/job/xenobiologist/department_head = /datum/job/rd

/datum/job/xenoarchaeologist/department =  = "Science"
/datum/job/xenoarchaeologist/department_head = /datum/job/rd


/datum/job/hos/department = "Security"
/datum/job/hos/head_position = 1
/datum/job/hos/department_prioritized = FALSE

/datum/job/warden/department = "Security"
/datum/job/warden/department_head = /datum/job/hos

/datum/job/detective/department = "Security"
/datum/job/detective/department_head = /datum/job/hos

/datum/job/officer/department = "Security"
/datum/job/officer/department_head = /datum/job/hos
