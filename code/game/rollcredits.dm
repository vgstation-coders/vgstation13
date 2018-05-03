#define CREDIT_ROLL_SPEED 185
#define CREDIT_SPAWN_SPEED 20
#define CREDIT_ANIMATE_HEIGHT (14 * world.icon_size)
#define CREDIT_EASE_DURATION 22

/datum/credits
	var/host = "POMF CHICKEN PRODUCTIONS"
	var/list/producers = list()
	var/list/end_titles = list()
	var/mob/living/carbon/human/star
	var/time_wait = 8 SECONDS

var/global/datum/credits/end_credits = new()

/client
	var/list/credits = list()

/client/proc/RollCredits()
	set waitfor = FALSE

	if(!end_credits.end_titles.len)
		end_credits.generate_titles()

	if(mob)
		if(prefs.toggles & SOUND_LOBBY)
			src << sound(null,channel = CHANNEL_LOBBY)
			src << sound('sound/music/Frolic_Luciano_Michelini.ogg', wait = 0, volume = 40, channel = CHANNEL_LOBBY)

		sleep(end_credits.time_wait)

		mob.overlay_fullscreen("fullblack",/obj/abstract/screen/fullscreen/fullblack)

	var/obj/abstract/screen/credit/P
	for(var/I in end_credits.producers)
		if(P)
			screen -= P
			qdel(P)
		P = new(I, src)
		screen += P
		sleep(CREDIT_SPAWN_SPEED)
	P.rollem(TRUE)

	for(var/I in end_credits.end_titles)
		var/obj/abstract/screen/credit/T = new(I, src)
		credits += T
		T.rollem()
		sleep(CREDIT_SPAWN_SPEED)
	sleep(CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)

	ClearCredits()

/client/proc/ClearCredits()
	screen -= credits
	credits.Cut()
	mob.clear_fullscreen("fishbed")
	mob.clear_fullscreen("fullblack")
	mob.clear_fullscreen("scanline")
	src << sound(null,channel = CHANNEL_LOBBY)

/obj/abstract/screen/credit
	icon_state = "blank"
	mouse_opacity = 0
	screen_loc = "1,CENTER"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_COVERALL_LAYER
	var/client/parent
	var/matrix/target
	maptext_x = 16

/obj/abstract/screen/credit/New(var/credited, var/client/P)
	. = ..()
	parent = P
	maptext = credited
	maptext_height = world.icon_size * 14
	maptext_width = world.icon_size * 14

/obj/abstract/screen/credit/proc/rollem(var/seenbefore = FALSE)
	var/target_alpha = 0
	if(!seenbefore)
		alpha = 0
		screen_loc = "1,1"
		target_alpha = 255
	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	if(seenbefore)
		sleep(CREDIT_EASE_DURATION)
	animate(src, alpha = target_alpha, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	spawn(CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)
		if(src && !gcDestroyed)
			animate(src, alpha = 0, transform = target, time = CREDIT_EASE_DURATION)
			sleep(CREDIT_EASE_DURATION)
			qdel(src)
	parent.screen += src

/obj/abstract/screen/credit/Destroy()
	var/client/P = parent
	if(parent)
		P.screen -= src
		P.credits -= src
	parent = null
	return ..()

/datum/credits/proc/generate_titles()
	var/list/titles = list()
	var/list/cast = list()
	var/chunk = "<center>"
	var/list/possible_titles = list()
	var/chunksize = 0

	/* Establish a big-ass list of potential titles for the "episode". */
	possible_titles += "THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES","[uppertext(station_name())]")]"
	possible_titles += "THE CREW GETS [pick("RACIST", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]")]"
	possible_titles += "THE CREW LEARNS ABOUT [pick("LOVE", "DRUGS", "THE DANGERS OF MONEY LAUNDERING", "SPACE 'NAM", "INVESTMENT FRAUD", "KELOTANE ABUSE", "RADIATION PROTECTION", "SACRED GEOMETRY", "STRING THEORY", "ABSTRACT MATHEMATICS", "[pick("CATBEAST", "DIONAN", "PLASMAMAN", "VOX", "GREY")] MATING RITUALS", "ANCIENT CHINESE MEDICINE")]"
	if(SNOW_THEME)
		possible_titles += "A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "DIONA", "PLASMA", "MARTIAN")] CHRISTMAS"
	possible_titles += "[pick("GUNS, GUNS EVERYWHERE", "MUCH ADO ABOUT NOTHING", "WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "ATTACK! ATTACK! ATTACK!", "SEX BOMB", "THE BALLAD OF [uppertext(station_name())]")]"
	possible_titles += "[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]"
	possible_titles += "[pick("THE DAY [uppertext(station_name())] STOOD STILL", "HUNT FOR THE GREEN WEENIE", "ALIEN VS VENDOMAT", "SPACE TRACK")]"
	titles += "<center><h1>SEASON [rand(1,22)] EPISODE [rand(1,17)]<br>[pick(possible_titles)]<h1></h1></h1></center>"
	titles += "<center><h1>CAST:</h1><h2>(in order of appearance)"
	for(var/mob/living/carbon/human/H in living_mob_list|dead_mob_list)
		if(!star || H.talkcount > star.talkcount)
			star = H
		if(H.timeofdeath && H.timeofdeath < 5 MINUTES) //don't mention these losers (prespawned corpses mostly)
			continue

		chunk += gender_credits(H)
		chunksize++
		if(chunksize == 5)
			cast += chunk
			chunk = "<center>"
			chunksize = 0
	titles += cast
	if(chunksize)
		titles += chunk

	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(H.timeofdeath < 5 MINUTES) //no prespawned corpses
			continue
		else if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		titles += "<center>BASED ON REAL EVENTS<br>In memory of [english_list(corpses)].</center>"

	var/list/staff = list("<h1>PRODUCTION STAFF</h1>")
	var/list/staffjobs = list("Coffee Fetcher", "Cameraman", "Angry Yeller", "Chair Operator", "Choreographer", "Historical Consultant", "Costume Designer", "Chief Editor", "Executive Assistant")
	if(!admins.len)
		staff += "<h2>DIRECTOR - Alan Smithee</h2>"
	for(var/client/C in admins)
		if(!C.holder)
			continue
		if(C.holder.rights & (R_DEBUG|R_ADMIN))
			var/observername = ""
			if(C.mob && istype(C.mob,/mob/dead/observer))
				var/mob/dead/observer/O = C.mob
				if(O.started_as_observer)
					observername = "[O.real_name] a.k.a. "
			staff += "<h2>[uppertext(pick(staffjobs))] - [observername]'[C.key]'</h2>"

	var/disclaimer = "Unofficially Sponsored by The United States Navy.<br>All rights reserved.<br>"
	disclaimer += pick("All stunts were performed by underpaid and expendable interns. Do NOT try at home.", "Nanotrasen does not endorse behaviour depicted. Attempt at your own risk.<br>")
	titles += "<center>[disclaimer]</center>"
	titles += "<center>This motion picture is (not) protected under the copyright laws of the United States and other countries throughout the world. Country of first publication: United States of America. Any unauthorized exhibition, distribution, or copying of this film or any part thereof (including soundtrack) may result in civil liability</center>"
	titles += "<center>and criminal prosecution. The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual persons (living or deceased), places, buildings, and products is intended or should be inferred. No person or entity associated with this film received payment or anything of value, or entered into any agreement, in connection with the depiction of tobacco products. No animals were harmed in the making of this motion picture, though many clowns were.</center>"
	producers = list("<center><h2>Directed by</h2><h1>[host]","<center>[jointext(staff,"")]")
	for(var/head in data_core.get_manifest_json()["heads"])
		producers += "<center><h2>[head["rank"]]</h2><h1>[uppertext(head["name"])]"
	end_titles = titles
	producers += "<center><h2>Starring</h2><h1>[gender_credits(star," as ",FALSE)]"

/proc/gender_credits(var/mob/living/carbon/human/H,var/segue = "\t \t \t \t",var/showjob = TRUE)
	if(H.mind && H.mind.key)
		var/ifshowjob = ", [H.get_assignment()]<br>"
		return "[uppertext(H.mind.key)][segue][H.real_name][showjob ? ifshowjob : ""]"
	else
		var/t_him = "Them"
		if(H.gender == MALE)
			t_him = "Him"
		else if(H.gender == FEMALE)
			t_him = "Her"
		return "[uppertext(H.real_name)][segue][t_him]self"