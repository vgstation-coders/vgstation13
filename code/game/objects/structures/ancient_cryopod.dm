/obj/machinery/cryopod
	name = "ancient cryogenic pod"
	desc = "An ancient looking cryogenic stasis pod. You can faintly see a human figure inside..."
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "ancientpod_idle"
	mech_flags = MECH_SCAN_FAIL
	var/datum/recruiter/recruiter = null
	var/thawing = FALSE
	density = 1
	var/datum/cryorole/role
	var/possible_roles = list(
		/datum/cryorole/cowboy,
		/datum/cryorole/pirate,
		/datum/cryorole/samurai,
		/datum/cryorole/prisoner,
		/datum/cryorole/roman,
		/datum/cryorole/tourist,
		/datum/cryorole/cosmonaut,
		/datum/cryorole/gangster,
		/datum/cryorole/pizzaman,
		/datum/cryorole/sportsfan)

/obj/machinery/cryopod/attack_hand(mob/user as mob)
	if(thawing)
		return
	message_admins("[key_name_admin(user)] has activated an ancient cryopod.")
	log_game("[key_name(user)] has activated an ancient cryopod.")
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/pressure = environment.return_pressure()
	if(((pressure < WARNING_HIGH_PRESSURE) && pressure > WARNING_LOW_PRESSURE))
		thawing = TRUE
		visible_message("<span class='notice'>\The [name] beeps and clicks, then flickers to life, displaying the text 'Attempting to revive occupant...'.</span>")
		if(!recruiter)
			recruiter = new(src)
			recruiter.display_name = name
			recruiter.role = ROLE_MINOR
		// Role set to Yes or Always
		recruiter.player_volunteering = new /callback(src, nameof(src::recruiter_recruiting()))
		// Role set to No or Never
		recruiter.player_not_volunteering = new /callback(src, nameof(src::recruiter_not_recruiting()))

		recruiter.recruited = new /callback(src, nameof(src::recruiter_recruited()))
		recruiter.request_player()
	else
		visible_message("<span class='notice'>\The [name] flickers to life and displays an error message: 'Unable to revive occupant, enviromental pressure inadequate for sustaining human life.'</span>")

/obj/machinery/cryopod/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\The [name] has been activated. You have been added to the list of potential ghosts. ([controls])</span>")

/obj/machinery/cryopod/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\The [src] has been activated. ([controls])</span>")

/obj/machinery/cryopod/proc/recruiter_recruited(mob/dead/observer/player, controls)
	if(player)
		QDEL_NULL(recruiter)
		visible_message("<span class='notice'>\The [name] opens with a hiss of frigid air!</span>")
		playsound(src, 'sound/machines/pressurehiss.ogg', 30, 1)
		icon_state = "ancientpod_used"
		desc = "An ancient looking cryogenic stasis pod. Its lights are off and its occupant is nowhere to be found."
		new /obj/effect/smoke(get_turf(src))
		var/mob/living/carbon/human/S = new(get_turf(src))
		var/roll = pick(possible_roles)
		role = new roll
		S.ckey = player.ckey
		S.randomise_appearance_for()
		role.gear_occupant(S)
		role.special_behavior(S)
	else
		thawing = FALSE
		visible_message("<span class='notice'>\The [name] quietly beeps and displays an error message. Try again later.</span>")

/datum/cryorole/proc/gear_occupant(var/mob/living/carbon/human/M)
	var/datum/outfit/roleoutfit = new outfit_datum
	roleoutfit.equip(M)

	to_chat(M, "<b>You are the [title].</b>")
	to_chat(M, "You remember being frozen in a cryogenic stasis pod. How long has it been, decades, centuries?")
	to_chat(M, "You are dazed and disoriented when you awake to the bright lights and monotonous hum of a station in deep space.")
	to_chat(M, "You know nothing about this station or the people on it. Maybe they can help you get your bearings.")
	to_chat(M, "<b>You do not belong to the crew, but you are not an antagonist either. Your goal is to make a story for yourself and survive.</b>")

	M.bodytemperature = 305.15 //chilly
	M.jitteriness = 15
	M.confused = 5
	M.eye_blurry = 15

	if(getrandomname)
		M.generate_name()
	else
		M.fully_replace_character_name(null,pick(preset_names))

	mob_rename_self(M,title,"Pick your name")

	message_admins("[key_name_admin(M)] has spawned as a [title] from an ancient cryopod.")
	log_game("[key_name(M)] has spawned as a [title] from an ancient cryopod.")

// TO ADD ROLES: create cryorole datum below, add role to possible_roles list in cryopod definition above

/datum/cryorole
	var/title
	var/outfit_datum
	var/preset_names
	var/getrandomname = FALSE

/datum/cryorole/proc/special_behavior(var/mob/living/carbon/human/M) //for special behavior like giving roles genetic mutations
	return

/datum/cryorole/cowboy
	title = "cowboy"
	outfit_datum = /datum/outfit/special/cowboy
	preset_names = list(
		"Deadwood Cassidy",
		"Rick O'Shea",
		"Loan Ranger",
		"Quick-Draw Billy"
	)

/datum/cryorole/pirate
	title = "pirate"
	outfit_datum = /datum/outfit/special/piratealt
	preset_names = list(
		"Scurvy Sam",
		"One-Eyed Johnny",
		"Barnacle Doubloons",
		"Gary the Pirate"
	)

/datum/cryorole/samurai
	title = "samurai"
	outfit_datum = /datum/outfit/special/samurai
	preset_names = list(
		"Udon Ramenatsu",
		"Onigiri Wasabishi",
		"Honda Subaru",
		"Musashi"
	)

/datum/cryorole/prisoner
	title = "prisoner"
	outfit_datum = /datum/outfit/special/prisoneralt
	preset_names = list(
		"Tiny",
		"King Cocaine",
		"Slim Pickle",
		"Stranglin' Steve"
	)

/datum/cryorole/roman
	title = "roman legionare"
	outfit_datum = /datum/outfit/special/roman
	preset_names = list(
		"Naughtius Maximus",
		"Biggus Dickus",
		"Marcus Cocceius Firmus",
		"Incontinentia Buttocks"
	)

/datum/cryorole/tourist
	title = "tourist"
	outfit_datum = /datum/outfit/special/tourist
	getrandomname = TRUE

/datum/cryorole/cosmonaut
	title = "cosmonaut"
	outfit_datum = /datum/outfit/special/cosmonaut
	preset_names = list(
		"Pilot Gagarin",
		"Commander Laika",
		"Officer Chernushka",
		"Pilot Leonov"
	)

/datum/cryorole/gangster
	title = "gangster"
	outfit_datum = /datum/outfit/special/gangster
	preset_names = list(
		"Tony Ravioli",
		"Fabrizio Marinara",
		"Giovanni Tortellini",
		"Johnny Shanks",
		"Jackie Pott"
	)

/datum/cryorole/pizzaman
	title = "pizza delivery guy"
	outfit_datum = /datum/outfit/special/pizzaman
	getrandomname = TRUE

/datum/cryorole/sportsfan
	title = "sports fan"
	outfit_datum = /datum/outfit/special/sports
	getrandomname = TRUE

/datum/cryorole/sportsfan/special_behavior(var/mob/living/carbon/human/M)
	if(prob(50))
		M.mutations += M_FAT
		M.overeatduration = 600
		M.update_mutantrace()
		M.update_mutations()
		M.regenerate_icons()
	return
