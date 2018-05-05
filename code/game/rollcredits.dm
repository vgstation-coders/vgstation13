#define CREDIT_ROLL_SPEED 370
#define CREDIT_SPAWN_SPEED 20
#define CREDIT_WIDTH (14 * world.icon_size)
#define CREDIT_HEIGHT 2*CREDIT_WIDTH

/datum/credits
	var/director = "Pomf Chicken Productions"
	var/list/producers = list()
	var/mob/living/carbon/human/star
	var/time_wait = 8 SECONDS
	var/text = ""
	var/episode_name = ""

/datum/credits/New()
	var/list/possible_episode_names = list()

	/* Establish a big-ass list of potential titles for the "episode". */
	possible_episode_names += "THE [pick("DOWNFALL OF", "RISE OF", "TROUBLE WITH", "FINAL STAND OF", "DARK SIDE OF")] [pick("SPACEMEN", "HUMANITY", "DIGNITY", "SANITY", "THE CHIMPANZEES", "THE VENDOMAT PRICES","[uppertext(station_name())]")]"
	possible_episode_names += "THE CREW GETS [pick("RACIST", "PICKLED", "AN INCURABLE DISEASE", "PIZZA", "A VALUABLE HISTORY LESSON", "A BREAK", "HIGH", "TO LIVE", "TO RELIVE THEIR CHILDHOOD", "EMBROILED IN CIVIL WAR", "SERIOUS ABOUT [pick("DRUG ABUSE", "CRIME", "PRODUCTIVITY", "ANCIENT AMERICAN CARTOONS", "SPACEBALL")]")]"
	possible_episode_names += "THE CREW LEARNS ABOUT [pick("LOVE", "DRUGS", "THE DANGERS OF MONEY LAUNDERING", "SPACE 'NAM", "INVESTMENT FRAUD", "KELOTANE ABUSE", "RADIATION PROTECTION", "SACRED GEOMETRY", "STRING THEORY", "ABSTRACT MATHEMATICS", "[pick("CATBEAST", "DIONAN", "PLASMAMAN", "VOX", "GREY")] MATING RITUALS", "ANCIENT CHINESE MEDICINE","LAWSETS")]"
	if(SNOW_THEME)
		possible_episode_names += "A VERY [pick("NANOTRASEN", "EXPEDITIONARY", "DIONA", "PLASMA", "MARTIAN")] CHRISTMAS"
	possible_episode_names += "[pick("GUNS, GUNS EVERYWHERE", "MUCH ADO ABOUT NOTHING", "WHAT HAPPENS WHEN YOU MIX MOMMIS AND COMMERCIAL-GRADE PACKING FOAM", "ATTACK! ATTACK! ATTACK!", "SEX BOMB", "THE BALLAD OF [uppertext(station_name())]")]"
	possible_episode_names += "[pick("SPACE", "SEXY", "DRAGON", "WARLOCK", "LAUNDRY", "GUN", "ADVERTISING", "DOG", "CARBON MONOXIDE", "NINJA", "WIZARD", "SOCRATIC", "JUVENILE DELIQUENCY", "POLITICALLY MOTIVATED", "RADTACULAR SICKNASTY")] [pick("QUEST", "FORCE", "ADVENTURE")]"
	possible_episode_names += "[pick("THE DAY [uppertext(station_name())] STOOD STILL", "HUNT FOR THE GREEN WEENIE", "ALIEN VS VENDOMAT", "SPACE TRACK")]"

	episode_name = pick(possible_episode_names)

/client
	var/list/credits = list()

/client/proc/roll_credits(var/datum/credits/end_credits)
	set waitfor = FALSE

	if(!credits)
		credits = list()
	if(mob)
		if(prefs.toggles & SOUND_LOBBY)
			src << sound(null,channel = CHANNEL_LOBBY)
			src << sound('sound/music/Frolic_Luciano_Michelini.ogg', wait = 0, volume = 40, channel = CHANNEL_LOBBY)

		sleep(end_credits.time_wait)
		verbs += /client/proc/clear_credits
		mob.overlay_fullscreen("fullblack",/obj/abstract/screen/fullscreen/fullblack)

	var/obj/abstract/screen/credit/P
	for(var/I in end_credits.producers)

		if(!credits)
			return

		if(P)
			screen -= P
			qdel(P)
		P = new(I, src)
		screen += P
		sleep(CREDIT_SPAWN_SPEED)

	if(!credits)
		return

	P.rollem(TRUE)

	var/obj/abstract/screen/credit/T = new(end_credits.text, src)
	credits += T
	T.rollem()

/client/proc/clear_credits()
	set name = "Skip Credits"
	set category = "OOC"
	verbs -= /client/proc/clear_credits
	screen -= credits
	credits = null
	mob.clear_fullscreen("fishbed")
	mob.clear_fullscreen("fullblack")
	src << sound(null,channel = CHANNEL_LOBBY)

/obj/abstract/screen/credit
	icon_state = "blank"
	mouse_opacity = 0
	screen_loc = "1,CENTER"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_COVERALL_LAYER
	var/client/parent
	maptext_x = 16

/obj/abstract/screen/credit/New(var/credited, var/client/P)
	. = ..()
	parent = P
	maptext = credited
	maptext_height = CREDIT_HEIGHT
	maptext_width = CREDIT_WIDTH

/obj/abstract/screen/credit/proc/rollem(var/seenbefore = FALSE)
	if(!seenbefore)
		screen_loc = "1,1"
		var/matrix/initialM = matrix()
		initialM.Translate(0,-CREDIT_HEIGHT)
		transform = initialM
	var/matrix/targetM = matrix()
	targetM.Translate(0, CREDIT_HEIGHT)
	animate(src, transform = targetM, time = CREDIT_ROLL_SPEED)
	parent.screen += src

/obj/abstract/screen/credit/Destroy()
	var/client/P = parent
	if(parent)
		P.screen -= src
		P.credits -= src
	parent = null
	return ..()

/datum/credits/proc/generate_credits()
	add_to_credits("<center><h1>SEASON [rand(1,22)] EPISODE [rand(1,17)]<br>[episode_name]<h1></h1></h1>",add_space=FALSE )
	add_to_credits("<h1>CAST:</h1><h2>(in order of appearance)</h2>",add_space=FALSE)
	for(var/mob/living/carbon/human/H in living_mob_list|dead_mob_list)
		if(!star || H.talkcount > star.talkcount)
			star = H
		if(H.timeofdeath && H.timeofdeath < 5 MINUTES) //don't mention these losers (prespawned corpses mostly)
			continue

		add_to_credits(gender_credits(H))

	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(H.timeofdeath < 5 MINUTES) //no prespawned corpses
			continue
		else if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		var/true_story_bro = "[pick("BASED ON","INSPIRED BY","A RE-ENACTMENT OF")] [pick("A TRUE STORY","REAL EVENTS","THE EVENTS ABOARD [uppertext(station_name())]")]"
		add_to_credits("<h2>[true_story_bro]</h2>In memory of those that did not make it.<br> [english_list(corpses)].")

	add_to_credits({"Unofficially Sponsored by The United States Navy.<br>All rights reserved.<br>
			[pick("All stunts were performed by underpaid and expendable interns. Do NOT try at home.", "[director] do not endorse behaviour depicted. Attempt at your own risk.")]"})
	add_to_credits({"This motion picture is (not) protected under the copyright laws of the United States and other countries throughout the world. Country of first publication:
				United States of America. Any unauthorized exhibition, distribution, or copying of this film or any part thereof (including soundtrack) may result in civil liability
				and criminal prosecution. The story, all names, characters, and incidents portrayed in this production are fictitious. No identification with actual persons (living or
				deceased), places, buildings, and products is intended or should be inferred. No person or entity associated with this film received payment or anything of value,
				or entered into any agreement, in connection with the depiction of tobacco products. No animals were harmed in the making of this motion picture,
				though many clowns were.</center>"})

/datum/credits/proc/generate_producers()
	var/list/staff = list("<h1>PRODUCTION STAFF</h1>")
	var/list/staffjobs = list("Coffee Fetcher", "Cameraman", "Angry Yeller", "Chair Operator", "Choreographer", "Historical Consultant", "Costume Designer", "Chief Editor", "Executive Assistant")
	if(!admins.len)
		staff += "<h2>PRODUCER - Alan Smithee</h2>"
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

	producers = list("<center><h2>Directed by</h2><h1>[uppertext(director)]","<center>[jointext(staff,"")]")
	for(var/head in data_core.get_manifest_json()["heads"])
		producers += "<center><h2>[head["rank"]]</h2><h1>[uppertext(head["name"])]"
	producers += "<center><h2>Starring</h2><h1>[gender_credits(star," as ",FALSE)]"

/proc/gender_credits(var/mob/living/carbon/human/H,var/segue = "\t \t \t \t",var/showjob = TRUE)
	if(H.mind && H.mind.key)
		var/ifshowjob = ", [H.get_assignment()]"
		return "[uppertext(H.mind.key)][segue][H.real_name][showjob ? ifshowjob : ""]"
	else
		var/t_him = "Them"
		if(H.gender == MALE)
			t_him = "Him"
		else if(H.gender == FEMALE)
			t_him = "Her"
		return "[uppertext(H.real_name)][segue][t_him]self"

/datum/credits/proc/add_to_credits(var/T,var/add_space = TRUE)
	if(add_space)
		text += "<br>"
	text += T