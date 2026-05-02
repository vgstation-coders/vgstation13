
//Crew Score
/datum/persistence_task/crewscore
	execute = TRUE
	name = "Crew Score"
	file_path = "data/persistence/crewscore.json"

var/last_crewscore = 0

/datum/persistence_task/crewscore/on_init()
	last_crewscore = read_file()

/datum/persistence_task/crewscore/on_shutdown()
	write_file(score.crewscore)