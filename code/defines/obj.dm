/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		switch(alert("Travel back to ss13?",,"Yes","No"))
			if("Yes")
				if(user.z != src.z)
					return
				user.loc.loc.Exited(user)
				user.forceMove(pick(latejoin))
			if("No")
				return

/obj/effect/mark
	var/mark = ""
	icon = 'icons/misc/mark.dmi'
	icon_state = "blank"
	anchored = 1
	mouse_opacity = 0

/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0

/*
 * This item is completely unused, but removing it will break something in R&D and Radio code causing PDA and Ninja code to fail on compile
 */

// Holy shit someone make this a datum already
/obj/effect/datacore
	name = "datacore"
	var/medical[] = list()
	var/general[] = list()
	var/security[] = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()

// Finds a record in 'general' based on the name, then finds a record in 'which' based on the ID
// Returns the record if it finds one, null otherwise
/obj/effect/datacore/proc/find_record_by_name(var/target_name, var/list/which)
	for (var/datum/data/record/E in general)
		if (E.fields["name"] == target_name)
			for (var/datum/data/record/R in which)
				if (R.fields["id"] == E.fields["id"])
					return R
	return null

/obj/effect/datacore/proc/find_record_by_dna(var/target_dna, var/list/which)
	for (var/datum/data/record/E in which)
		if (E.fields["b_dna"] == target_dna)
			return E
	return null

/obj/effect/datacore/proc/find_general_record_by_name(var/target_name)
	for(var/datum/data/record/E in general)
		if(E.fields["name"] == target_name)
			return E
	return null

/obj/effect/datacore/proc/find_medical_record_by_name(var/target_name)
	return find_record_by_name(target_name, medical)

/obj/effect/datacore/proc/find_medical_record_by_dna(var/target_dna)
	return find_record_by_dna(target_dna, medical)

/obj/effect/datacore/proc/find_security_record_by_name(var/target_name)
	return find_record_by_name(target_name, security)

/obj/effect/datacore/proc/get_manifest(monochrome, OOC)
	var/list/heads = new()
	var/list/sec = new()
	var/list/eng = new()
	var/list/med = new()
	var/list/sci = new()
	var/list/cgo = new()
	var/list/civ = new()
	var/list/bot = new()
	var/list/misc = new()
	var/list/isactive = new()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Activity</th></tr>
	"}
	var/even = 0
	// sort mobs
	for(var/datum/data/record/t in sortRecord(data_core.general))
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]
		if(OOC)
			var/active = 0
			var/SSD = 0
			for(var/mob/M in player_list)
				if(M.real_name == name)
					if(!M.client)
						SSD = 1
						break
					if(M.client && M.client.inactivity <= 10 * 60 * 10)
						active = 1
						break
			isactive[name] = (SSD ? "SSD" : (active ? "Active" : "Inactive"))
		else
			isactive[name] = t.fields["p_stat"]
//			to_chat(world, "[name]: [rank]")
			//cael - to prevent multiple appearances of a player/job combination, add a continue after each line
		var/department = 0
		if(real_rank in command_positions)
			heads[name] = rank
			department = 1
		if(real_rank in security_positions)
			sec[name] = rank
			department = 1
		if(real_rank in engineering_positions)
			eng[name] = rank
			department = 1
		if(real_rank in medical_positions)
			med[name] = rank
			department = 1
		if(real_rank in science_positions)
			sci[name] = rank
			department = 1
		if(real_rank in cargo_positions)
			cgo[name] = rank
			department = 1
		if(real_rank in civilian_positions)
			civ[name] = rank
			department = 1
		if(real_rank in nonhuman_positions)
			bot[name] = rank
			department = 1
		if(!department && !(name in heads))
			misc[name] = rank
	if(heads.len > 0)
		dat += "<tr><th colspan=3>Heads</th></tr>"
		for(name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	if(sec.len > 0)
		dat += "<tr><th colspan=3>Security</th></tr>"
		for(name in sec)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sec[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	if(eng.len > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	if(med.len > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	if(sci.len > 0)
		dat += "<tr><th colspan=3>Science</th></tr>"
		for(name in sci)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sci[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	if(cgo.len > 0)
		dat += "<tr><th colspan=3>Cargo</th></tr>"
		for(name in cgo)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[cgo[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	if(civ.len > 0)
		dat += "<tr><th colspan=3>Civilian</th></tr>"
		for(name in civ)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[civ[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	// in case somebody is insane and added them to the manifest, why not
	if(bot.len > 0)
		dat += "<tr><th colspan=3>Silicon</th></tr>"
		for(name in bot)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[bot[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	// misc guys
	if(misc.len > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat

/* Predicting the manifest is much less intense than building a real one.
We don't care about names, DNA, accounts, activity, any of that. We're just gonna loop through high job prefs.*/

/datum/controller/occupations/proc/display_prediction()
	predict_manifest()
	if(!crystal_ball.len)
		return "No prediction has been made!" //This only gets shown the first time ever. If everyone unreadies it's blank.
	var/dat = {"
	<head><style>
	{border-collapse:collapse;}
	td, th {border:1px solid "#DEF; background-color:white; color:black"; padding:.25em}
	th {height: 2em; "background-color: #48C; color:white";}
	tr.head th {"background-color: #488";}
	tr.alt td {"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Rank</th><th>Quantity</th></tr>
	"}

	var/color = 0
	for(var/job in crystal_ball)
		if(!crystal_ball[job])
			continue //If 0, skip
		dat += "<tr[color ? " class='alt'" : ""]><td>[job]</td><td>[crystal_ball[job]]</td></tr>"
		color = !color

	return dat

/datum/controller/occupations/proc/predict_manifest()
	crystal_ball = list("AI" = 0, "Cyborg" = 0, "Captain" = 0, "Head of Personnel" = 0, "Head of Security" = 0, "Chief Engineer" = 0, "Chief Medical Officer" = 0, "Research Director" = 0)
	//We always want to list these first, the rest can be random for all we care.
	for(var/mob/new_player/player in player_list)
		if(!player.ready)
			continue
		//Prefs are only stored as a bitflag, so we have to look up the job name.
		//Only one of these should have a value

		var/J = null
		if(player.client.prefs.job_engsec_high)
			J = flags_to_job(player.client.prefs.job_engsec_high,ENGSEC)
		else if(player.client.prefs.job_medsci_high)
			J = flags_to_job(player.client.prefs.job_medsci_high,MEDSCI)
		else if(player.client.prefs.job_civilian_high)
			J = flags_to_job(player.client.prefs.job_civilian_high,CIVILIAN)
		else
			continue //They don't have a high pref!

		if(!J)
			continue //sanity
		crystal_ball[J] += 1

/datum/controller/occupations/proc/flags_to_job(var/flags, var/department)
	var/list/searchable_jobs = typesof(/datum/job) - /datum/job
	for(var/path in searchable_jobs)
		var/datum/job/J = path
		if(initial(J.department_flag) != department)
			continue
		if(initial(J.flag) != flags)
			continue
		return initial(J.title)
	return null //Still nothing? Null it is

/*
We can't just insert in HTML into the nanoUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /obj/effect/datacore/proc/manifest_inject( ), or manifest_insert( )
*/

var/global/list/PDA_Manifest = list()

/obj/effect/datacore/proc/get_manifest_json()
	if(PDA_Manifest.len)
		return PDA_Manifest
	var/heads[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/cgo[0]
	var/civ[0]
	var/bot[0]
	var/misc[0]
	for(var/datum/data/record/t in data_core.general)
		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]
		var/isactive = t.fields["p_stat"]
		var/department = 0
		var/depthead = 0 			// Department Heads will be placed at the top of their lists. Too bad all the procs that get the manifest call get_manifest(), which can't do this without a rewrite.
		if(real_rank in command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			depthead = 1
			if(rank=="Captain" && heads.len != 1)
				heads.Swap(1,heads.len)

		if(real_rank in security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sec.len != 1)
				sec.Swap(1,sec.len)

		if(real_rank in engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && eng.len != 1)
				eng.Swap(1,eng.len)

		if(real_rank in medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && med.len != 1)
				med.Swap(1,med.len)

		if(real_rank in science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sci.len != 1)
				sci.Swap(1,sci.len)

		if(real_rank in cargo_positions)
			cgo[++cgo.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && cgo.len != 1)
				cgo.Swap(1,cgo.len)

		if(real_rank in civilian_positions)
			civ[++civ.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && civ.len != 1)
				civ.Swap(1,civ.len)

		if(real_rank in nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive)


	PDA_Manifest = list(\
		"heads" = heads,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"cgo" = cgo,\
		"civ" = civ,\
		"bot" = bot,\
		"misc" = misc\
		)
	return PDA_Manifest



/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0


/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/machinery/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	machine_flags = WRENCHMOVE

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/weapon/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = W_CLASS_TINY
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/weapon/beach_ball/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if(user.drop_item(src))
		src.throw_at(target, throw_range, throw_speed)

/obj/effect/stop
	var/victim = null
	icon_state = "empty"
	name = "Geas"
	desc = "You can't resist."
	// name = ""

/obj/effect/stop/Uncross(atom/movable/mover)
	if(victim == mover)
		return 0
	return 1

/obj/effect/stop/sleeping
	var/sleeptime
	icon_state = "empty"
	name = "Sleepy time"
	var/datum/mind/owner
	var/spell/aoe_turf/fall/ourspell
	invisibility = 100
	var/theworld
	ignoreinvert = 1

/obj/effect/stop/sleeping/New(loc, ourtime, mind, var/spell/aoe_turf/fall/F, theworld)
	..()
	sleeptime = ourtime
	owner = mind
	ourspell = F
	src.theworld = theworld

/obj/effect/stop/sleeping/Crossed(atom/movable/A)
	if(!(A.flags & TIMELESS) && sleeptime > world.time)
		if(ismob(A))
			var/mob/living/L = A
			if(L.mind != owner)
				if(L.client)
					L.client.move_delayer.next_allowed = sleeptime //So we don't need to check timestopped in client/move
				if(!L.stat)
					L.playsound_local(src, theworld == 1 ? 'sound/effects/theworld2.ogg' : 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)
				//L.Paralyse(round(((sleeptime - world.time)/10)/2, 1))
				//L.update_canmove()
				if(!(L in ourspell.affected))
					invertcolor(L)
					ourspell.affected += L
					ourspell.recursive_timestop(L)
		else
			if(!(A in ourspell.affected))
				invertcolor(A)
				ourspell.affected += A
				ourspell.recursive_timestop(A)


/obj/effect/spawner
	name = "object spawner"
