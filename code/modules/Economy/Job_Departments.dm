var/list/station_departments = list("Command", "Medical", "Engineering", "Science", "Security", "Cargo", "Civilian")

/datum/job
	var/department = null		// The department the job belongs to.
	var/head_position = 0		// Whether this is a head position
	var/department_prioritized	// Whether the head of this department is prioritized, due to his subordinates being prioritized
	var/department_head			// Link to the department head

/datum/job/captain
	department = "Command"
	head_position = 1


/* Civilian */

/datum/job/hop
	department = "Civilian"
	head_position = 1
	department_prioritized = FALSE

/datum/job/assistant
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/bartender
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/chef
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/hydro
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/janitor
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/librarian
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/lawyer
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/chaplain
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/clown
	department = "Civilian"
	department_head = /datum/job/hop

/datum/job/mime
	department = "Civilian"
	department_head = /datum/job/hop


/* Cargo */

/datum/job/qm
	department = "Cargo"
	head_position = 1
	department_prioritized = FALSE

/datum/job/cargo_tech
	department = "Cargo"
	department_head = /datum/job/qm

/datum/job/mining
	department = "Cargo"
	department_head = /datum/job/qm


/* Engineering */

/datum/job/chief_engineer
	department = "Engineering"
	head_position = 1
	department_prioritized = FALSE

/datum/job/engineer
	department = "Engineering"
	department_head = /datum/job/chief_engineer

/datum/job/atmos
	department = "Engineering"
	department_head = /datum/job/chief_engineer

/datum/job/mechanic
	department = "Engineering"
	department_head = /datum/job/chief_engineer


/* Medical */

/datum/job/cmo
	department = "Medical"
	head_position = 1
	department_prioritized = FALSE

/datum/job/doctor
	department = "Medical"
	department_head = /datum/job/cmo

/datum/job/paramedic
	department = "Medical"
	department_head = /datum/job/cmo

/datum/job/chemist
	department = "Medical"
	department_head = /datum/job/cmo

/datum/job/geneticist
	department = "Medical"
	department_head = /datum/job/cmo

/datum/job/virologist
	department = "Medical"
	department_head = /datum/job/cmo

/datum/job/orderly
	department = "Medical"
	department_head = /datum/job/cmo


/* Science */

/datum/job/rd
	department = "Science"
	head_position = 1
	department_prioritized = FALSE

/datum/job/scientist
	department = "Science"
	department_head = /datum/job/rd

/datum/job/roboticist
	department = "Science"
	department_head = /datum/job/rd

/datum/job/xenobiologist
	department  = "Science"
	department_head = /datum/job/rd

/datum/job/xenoarchaeologist	
	department = "Science"
	department_head = /datum/job/rd


/* Security */

/datum/job/hos
	department = "Security"
	head_position = 1
	department_prioritized = FALSE

/datum/job/warden/
	department = "Security"
	department_head = /datum/job/hos

/datum/job/detective
	department = "Security"
	department_head = /datum/job/hos

/datum/job/officer
	department = "Security"
	department_head = /datum/job/hos
