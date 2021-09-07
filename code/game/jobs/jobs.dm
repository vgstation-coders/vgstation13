var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)

var/list/engineering_positions = list(
	"Chief Engineer",
	"Station Engineer",
	"Atmospheric Technician",
	"Mechanic"
)

var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Virologist",
//	"Psychiatrist",
	"Paramedic",
	"Chemist",
	"Orderly"
)

var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Xenoarchaeologist",
	"Xenobiologist",
	"Geneticist",	//Part of both medical and science
	"Roboticist",
	"Mechanic"
)

//BS12 EDIT
var/list/civilian_positions = list(
	"Head of Personnel",
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Internal Affairs Agent",
	"Chaplain",
	"Clown",
	"Mime",
	"Assistant"
)

var/list/service_positions = list(
	"Bartender",
	"Botanist",
	"Chef",
)

var/list/cargo_positions = list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner"
)

var/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer"
)

var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI",
	"Mobile MMI"
)

var/list/misc_positions = list(
	"Trader",
)

var/list/all_jobs_txt = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
	"Station Engineer",
	"Atmospheric Technician",
	"Mechanic",
	"Medical Doctor",
	"Geneticist",
	"Virologist",
//	"Psychiatrist",
	"Paramedic",
	"Chemist",
	"Orderly",
	"Research Director",
	"Scientist",
	"Roboticist",
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Internal Affairs Agent",
	"Chaplain",
	"Clown",
	"Mime",
	"Assistant",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Warden",
	"Detective",
	"Security Officer",
)

var/list/departement_list = list(
	"Command",
	"Security",
	"Cargo",
	"Engineering",
	"Medical",
	"Science",
	"Civilian",
)

/proc/guest_jobbans(var/job)
	return ((job in command_positions) || (job in nonhuman_positions) || (job in security_positions))

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)
			continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(!J)
			continue
		if(J.title == job)
			titles = J.alt_titles

	return titles
