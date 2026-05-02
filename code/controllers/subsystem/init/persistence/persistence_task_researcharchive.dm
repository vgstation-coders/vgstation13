
//Research Archive
/datum/persistence_task/researcharchive
	execute = TRUE
	name = "Research Archive"
	file_path = "data/persistence/researcharchive.json"

/datum/persistence_task/researcharchive/on_init()
	if(!research_archive_datum)
		research_archive_datum = new /datum/research()
	var/list/techs = read_file()
	//world.log << "DEBUG ARCHIVE: [json_encode(techs)]"
	var/skip_reporting = TRUE
	for(var/obj/machinery/computer/rdconsole/C in machines)
		for(var/element in techs)
			var/datum/tech/T = C.files.known_tech[element]
			if(!T)
				continue
			T.level = text2num(techs[element])
			if(skip_reporting && (T.level>1))
				skip_reporting = FALSE //If any level was increased, we want to report

	if(!skip_reporting)
		for(var/obj/machinery/computer/rdconsole/S in machines)
			var/obj/item/weapon/paper/P = new (S.loc)
			P.info = "Your station has benefitted from the research archive project."
			P.update_icon()

/datum/persistence_task/researcharchive/on_shutdown()
	var/list/to_archive = list()
	for(var/datum/tech/T in get_list_of_elements(research_archive_datum.known_tech))
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		to_archive[T.id] = T.level
	write_file(to_archive)
