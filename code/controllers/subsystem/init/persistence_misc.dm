var/datum/subsystem/persistence_misc/SSpersistence_misc

/datum/subsystem/persistence_misc
	name       = "Persistence - Misc"
	init_order = SS_INIT_PERSISTENCE_MISC
	flags      = SS_NO_FIRE

	var/const/round_count_file = "data/persistence/round_counts_per_year.json"
	var/list/round_count_list = list()


/datum/subsystem/persistence_misc/New()
	NEW_SS_GLOBAL(SSpersistence_misc)

/datum/subsystem/persistence_misc/Recover()
	round_count_list = SSpersistence_misc.round_count_list
	..()


/datum/subsystem/persistence_misc/Initialize(timeofday)
	read_round_count()
	..()

/datum/subsystem/persistence_misc/Shutdown()
	bump_round_count()
	write_round_count()
	..()

/datum/subsystem/persistence_misc/proc/read_round_count()
	if(fexists(round_count_file))
		round_count_list = json_decode(file2text(round_count_file))

/datum/subsystem/persistence_misc/proc/bump_round_count()
	var/itsthecurrentyear = time2text(world.realtime,"YY")
	if(!(itsthecurrentyear in round_count_list))
		round_count_list[itsthecurrentyear] = "0"
	round_count_list[itsthecurrentyear] = num2text(text2num(round_count_list[itsthecurrentyear]) + 1)

/datum/subsystem/persistence_misc/proc/write_round_count()
	var/writing = file(round_count_file)
	fdel(writing)
	writing << json_encode(round_count_list)
