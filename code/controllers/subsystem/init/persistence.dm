var/datum/subsystem/persistence/SSpersistence

/datum/subsystem/persistence
	name       = "Persistence"
	init_order = SS_INIT_PERSISTENCE
	flags      = SS_NO_FIRE

	var/const/round_count_file = "data/persistence/round_counts_per_year.json"
	var/list/round_count_list = list()


/datum/subsystem/persistence/New()
	NEW_SS_GLOBAL(SSpersistence)

/datum/subsystem/persistence/Recover()
	round_count_list = SSpersistence.round_count_list
	..()


/datum/subsystem/persistence/Initialize(timeofday)
	read_round_count()
	..()

/datum/subsystem/persistence/Shutdown()
	bump_round_count()
	write_round_count()
	..()

/datum/subsystem/persistence/proc/read_round_count()
	if(fexists(round_count_file))
		round_count_list = json_decode(file2text(round_count_file))

/datum/subsystem/persistence/proc/bump_round_count()
	var/itsthecurrentyear = time2text(world.realtime,"YY")
	if(!(itsthecurrentyear in round_count_list))
		round_count_list[itsthecurrentyear] = "0"
	round_count_list[itsthecurrentyear] = num2text(text2num(round_count_list[itsthecurrentyear]) + 1)

/datum/subsystem/persistence/proc/write_round_count()
	var/writing = file(round_count_file)
	fdel(writing)
	writing << json_encode(round_count_list)
