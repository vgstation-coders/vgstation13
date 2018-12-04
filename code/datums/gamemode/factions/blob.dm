//________________________________________________

#define BLOB_PRELUDE 0
#define BLOB_OUTBREAK 1
#define BLOB_DELTA 2

#define WAIT_TIME_PHASE1 60 SECONDS
#define WAIT_TIME_PHASE2 200 SECONDS

#define STATION_TAKEOVER 1
#define STATION_WAS_NUKED 2
#define BLOB_IS_DED 3

#define CREW_VICTORY 0
#define AI_VICTORY 1 // Station was nuked.
#define BLOB_VICTORY 2

/datum/faction/blob_conglomerate
	name = BLOBCONGLOMERATE
	ID = BLOBCONGLOMERATE
	logo_state = "blob-logo"
	roletype = /datum/role/blob_overmind
	initroletype = /datum/role/blob_overmind

	var/datum/station_state/start

	var/list/pre_escapees = list()
	var/declared = FALSE
	var/win = FALSE

// -- Victory procs --

/datum/faction/blob_conglomerate/check_win()
	if (!declared)//No blobs have been spawned yet
		return 0
	if (map.blobwincount <= blobs.len)//Blob took over
		return win(STATION_TAKEOVER)
	if(ticker.station_was_nuked)//Nuke went off
		return win(STATION_WAS_NUKED)
	for (var/datum/role/R in members)
		if (!(R.antag.current.isDead()))
			return 0
	return win(BLOB_IS_DED)

/datum/faction/blob_conglomerate/process()
	. = ..()
	if (0.66*map.blobwincount <= blobs.len) // Blob almost won !
		stage(BLOB_DELTA)

/datum/faction/blob_conglomerate/OnPostSetup()
	spawn()
		start = new()
		start.count()

		sleep(rand(WAIT_TIME_PHASE1,2*WAIT_TIME_PHASE1))
		stage(BLOB_PRELUDE)

		sleep(rand(WAIT_TIME_PHASE2,2*WAIT_TIME_PHASE2))
		stage(BLOB_OUTBREAK)

/datum/faction/blob_conglomerate/proc/win(var/result)
	. = 1
	win = result
	switch (result)
		if (STATION_TAKEOVER)
			to_chat(world, {"<FONT size = 5><B>Blob victory victory!</B></FONT><br>
<B>The station was nuked before the blob could completly take over.</B>"})
		if (STATION_WAS_NUKED)
			to_chat(world, {"<FONT size = 5><B>Crew minor victory!</B></FONT><br>
<B>The station was nuked before the blob could completly take over.</B>"})
		if (BLOB_IS_DED)
			to_chat(world, {"<FONT size = 5><B>Crew major victory!</B></FONT><br>
<B>The blob was stopped.</B>"})

// -- Fluff & warnings --

/datum/faction/blob_conglomerate/proc/stage(var/stage)
	switch(stage)
		if (BLOB_PRELUDE)
			biohazard_alert()
			return

		if (BLOB_OUTBREAK)
			command_alert(/datum/command_alert/biohazard_station_lockdown)
			for(var/mob/M in player_list)
				var/T = M.loc
				if((istype(T, /turf/space)) || ((istype(T, /turf)) && (M.z!=1)))
					pre_escapees += M.real_name
			send_intercept(BLOB_OUTBREAK)
			research_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice." //LOCKDOWN THESE SHUTTLES
			mining_shuttle.lockdown = "Under directive 7-10, [station_name()] is quarantined until further notice."

		if (BLOB_DELTA)
			command_alert(/datum/command_alert/biohazard_station_nuke)
			for(var/mob/camera/blob/B in player_list)
				to_chat(B, "<span class='blob'>The beings intend to eliminate you with a final suicidal attack, you must stop them quickly or consume the station before this occurs!</span>")
			send_intercept(BLOB_DELTA)

/datum/faction/blob_conglomerate/proc/send_intercept(var/report = BLOB_OUTBREAK)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(report)
		if(BLOB_OUTBREAK)
			interceptname = "Biohazard Alert"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.
Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.
Nanotrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.
Orders for all [station_name()] personnel follows:
<ol>
	<li>Do not leave the quarantine area.</li>
	<li>Locate any outbreaks of the organism on the station.</li>
	<li>If found, use any neccesary means to contain the organism.</li>
	<li>Avoid damage to the capital infrastructure of the station.</li>
</ol>
Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.
Message ends."}
			for (var/mob/living/silicon/ai/aiPlayer in player_list)
				var/law = "The station is under quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving."
				aiPlayer.set_zeroth_law(law)
				to_chat(aiPlayer, "Laws Updated: [law]")
		if(BLOB_DELTA)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in machines)
				if(bomb && bomb.r_code)
					if(bomb.z == map.zMainStation)
						nukecode = bomb.r_code
			interceptname = "Directive 7-12"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Directive 7-12 has been issued for [station_name()].
The biohazard has grown out of control and will soon reach critical mass.
Your orders are as follows:
<ol>
	<li>Secure the Nuclear Authentication Disk.</li>
	<li>Detonate the Nuke located in the Station's Vault.</li>
</ol>
<b>Nuclear Authentication Code:</b> [nukecode]
Message ends."}
			for (var/mob/living/silicon/ai/aiPlayer in player_list)
				var/law = "Directive 7-12 has been authorized. Allow no sentient being to escape the purge. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
				aiPlayer.set_zeroth_law(law)
				to_chat(aiPlayer, "Laws Updated: [law]")

	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext

			comm.messagetitle.Add("[interceptname]")
			comm.messagetext.Add(intercepttext)
	return

// -- Scoreboard --

/datum/faction/blob_conglomerate/GetScoreboard()
	var/list/results = list()
	results += ..()
	results += "<br/>"
	switch (win)
		if (STATION_TAKEOVER)
			results += "<b>Blob victory!</b>"
		if (STATION_WAS_NUKED)
			results += "<b>Crew minor victory!</b>"
		if (BLOB_IS_DED)
			results += "<b>Crew victory!</b>"
	results += "<br />"
	var/datum/station_state/end = new
	end.count()
	results += "<b>Percentage of station taken: [end.score(start)]</b>"
	results += "<br/>"
	results += "<b>Quarantaine status:</b><br/>"
	var/list/result = check_quarantaine()
	results += "Dead humans: <b>[result["numDead"]]</b><br/>"
	results += "Alive humans still on board: <b>[result["numAlive"]]</b><br/>"
	results += "Humans in space: <b>[result["numSpace"]]</b><br/>"
	results += "Humans off-station: <b>[result["numOffStation"]]</b><br/>"
	results += "Pre-escapes: <b>[pre_escapees.len]</b>"
	if (result["numOffStation"] + result["numSpace"])
		results += "<span class='danger'>The AI has failed to enforce the quarantaine.</span>"
	else
		results += "<span class='notice'>The AI has managed to enforce the quarantaine.</span>"

/datum/faction/blob_conglomerate/proc/check_quarantaine()
	var/list/result = list()
	result["numDead"] = 0
	result["numSpace"] = 0
	result["numAlive"] = 0
	result["numOffStation"] = 0
	for(var/mob/living/carbon/human/M in player_list)
		if (M.isDead())
			result["numDead"]++
		else if(M.real_name in pre_escapees)
			continue
		else
			var/T = M.loc
			if (istype(T, /turf/space))
				result["numSpace"]++
			else if(istype(T, /turf))
				if (M.z!=1)
					result["numOffStation"]++
				else
					result["numAlive"]++
	return result

// -- Station states --

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0


/datum/station_state/proc/count()
	for(var/atom/A in world)
		CHECK_TICK // So that we don't lag too much.
		if (isturf(A))
			var/turf/T = A
			if(T.z != map.zMainStation)
				continue

			if(istype(T,/turf/simulated/floor))
				if(!(T:burnt))
					src.floor += 12
				else
					src.floor += 1

			if(istype(T, /turf/simulated/wall))
				if(T:intact)
					src.wall += 2
				else
					src.wall += 1

			if(istype(T, /turf/simulated/wall/r_wall))
				if(T:intact)
					src.r_wall += 2
				else
					src.r_wall += 1

		if (isobj(A))
			var/obj/O = A
			if(O.z != map.zMainStation)
				continue

			if(istype(O, /obj/structure/window))
				src.window += 1

			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/G = O
				if(!G.broken)
					src.grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(istype(O, /obj/machinery))
				src.mach += 1

	return


/datum/station_state/proc/score(var/datum/station_state/result)
	if(!result)
		return 0
	var/output = 0
	output += (result.floor / max(floor,1))
	output += (result.r_wall/ max(r_wall,1))
	output += (result.wall / max(wall,1))
	output += (result.window / max(window,1))
	output += (result.door / max(door,1))
	output += (result.grille / max(grille,1))
	output += (result.mach / max(mach,1))
	return (output/7)

/proc/getBlobs()
	to_chat(world, "Blobs are : [blobs.len]")

/proc/getBlobWinCount()
	to_chat(world, "Blobwin is : [map.blobwincount]")