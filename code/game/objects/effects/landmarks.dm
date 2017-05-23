var/list/landmarks_list = list() //list of all landmarks
var/list/landmarks_by_type = list() //list of landmark types associated with turf lists

//Returns a list of all landmark turfs or an empty list
//If readonly is false, it returns a COPY of the list, which can be changed without affecting the original list
/proc/get_landmarks(input_type, readonly = TRUE)
	var/list/L = landmarks_by_type[input_type] || list()
	if(!readonly)
		L = L.Copy()

	return L

/proc/pick_landmark(input_type, backup_type = /obj/effect/landmark/latejoin)
	var/list/L = get_landmarks(input_type)
	if(!L.len && (backup_type != input_type))
		L = get_landmarks(backup_type)
	if(!L.len)
		return null

	return pick(L)

/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	w_type=NOT_RECYCLABLE

	var/destroy_on_creation = FALSE

/obj/effect/landmark/New()
	. = ..()
	tag = text("landmark*[]", name)
	invisibility = 101

	if(!islist(landmarks_by_type[src.type]))
		landmarks_by_type[src.type] = list()

	var/list/L = landmarks_by_type[src.type]
	L.Add(loc)

	landmarks_list += src

	if(destroy_on_creation)
		qdel(src)

/obj/effect/landmark/Destroy()
	landmarks_list -= src

	if(!destroy_on_creation)
		var/list/L = landmarks_by_type[src.type]
		if(L)
			L.Remove(loc)

	..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	invisibility = 101

	return 1

/obj/effect/landmark/bluespacerift
	name = "bluespace rift"
	desc = "In the event of a supermatter cascade, the portal to safety spawns here."
	destroy_on_creation = TRUE

/obj/effect/landmark/endgame_exit
	name = "endgame exit"
	desc = "In the event of a supermatter cascade, the portal to safety teleports you here."
	destroy_on_creation = TRUE

/obj/effect/landmark/xeno_spawn
	name = "xeno spawn"
	desc = "Random events may spawn xenomorphs here."
	destroy_on_creation = TRUE

/obj/effect/landmark/latejoin
	name = "latejoin"
	desc = "Late arrivals spawn here."
	destroy_on_creation = TRUE

/obj/effect/landmark/assistant_latejoin
	name = "assistant latejoin"
	desc = "Late arrivals that are also assistants spawn here."
	destroy_on_creation = TRUE

/obj/effect/landmark/wizardstart
	name = "wizard spawn"
	desc = "Wizards spawn here"
	destroy_on_creation = TRUE

/obj/effect/landmark/newplayer_start
	name = "newplayer start"
	desc = "The title screen that is shown to players when they connect to the server."
	destroy_on_creation = TRUE

/obj/effect/landmark/prisonwarp
	name = "prisonwarp"
	desc = "A prison in central command used by admins."
	destroy_on_creation = TRUE

/obj/effect/landmark/blobstart
	name = "blobstart"
	desc = "A spawn location for blobs and some other minor events."


/obj/effect/landmark/holdingfacility
	name = "holding facility"
	desc = "Captured people go here." //Unused currently
	destroy_on_creation = TRUE

/obj/effect/landmark/thunderdome/green
	name = "thunderdome 1"
	desc = "Team Green"
	destroy_on_creation = TRUE

/obj/effect/landmark/thunderdome/red
	name = "thunderdome 2"
	desc = "Team Red"
	destroy_on_creation = TRUE

/obj/effect/landmark/thunderdome/admin
	name = "thunderdome admin area"
	destroy_on_creation = TRUE

/obj/effect/landmark/thunderdome/observe
	name = "thunderdome spectators"
	destroy_on_creation = TRUE

/obj/effect/landmark/carpspawn
	name = "carp spawn"
	desc = "Random event spawns carps here."

/obj/effect/landmark/nukeops/nuke_spawn
	name = "Nuclear-Bomb"
	desc = "Nuke spawns here."

/obj/effect/landmark/nukeops/gear_closet
	name = "gear closet"
	desc = "Gear closet spawns here."

/obj/effect/landmark/nukeops/uplink
	name = "uplink"
	desc = "Uplink spawns here"

/obj/effect/landmark/nukeops/bomb
	name = "bomb"
	desc = "A bomb spawns here."

/obj/effect/landmark/nukeops/syndicate_spawn
	name = "syndicate spawn"
	desc = "Operatives spawn here."

/obj/effect/landmark/syndicate_commando/bomb
	name = "Syndicate-Commando-Bomb"

/obj/effect/landmark/syndicate_commando/commando_spawn
	name = "Syndicate-Commando"

/obj/effect/landmark/commando/commando_spawn
	name = "Commando"

/obj/effect/landmark/commando/bomb
	name = "Commando-Bomb"

/obj/effect/landmark/commando/manual
	name = "Commando_Manual"

/obj/effect/landmark/marauder/entry
	name = "Marauder Entry"

/obj/effect/landmark/marauder/exit
	name = "Marauder Exit"

/obj/effect/landmark/ert/ert_spawn
	name = "ERT"

/obj/effect/landmark/lightsout
	name = "lightsout"
	desc = "Lights in this area may break from a random event."

/obj/effect/landmark/observer_start
	name = "Observer-Start"

/obj/effect/landmark/syndicate_uplink
	name = "Syndicate-Uplink"

/obj/effect/landmark/holodeck_atmos
	name = "Atmospheric Test Start"

/obj/effect/landmark/holodeck_holocarp
	name = "Holocarp Spawn"

/obj/effect/landmark/tripai
	name = "tripai"
	desc = "AI spawn locations when there's more than one"

/obj/effect/landmark/voxstart
	name = "voxstart"
	desc = "Vox raiders"

/obj/effect/narration
	name = "narrator"
	icon_state = "megaphone"

	var/msg
	var/play_sound
	var/list/saw_ckeys = list() //List of ckeys which have seen the message

/obj/effect/narration/New()
	..()

	invisibility = 101

/obj/effect/narration/Crossed(mob/living/O)
	if(istype(O))
		if(!saw_ckeys.Find(O.ckey))
			saw_ckeys.Add(O.ckey)

			display(O)

	return ..()

/obj/effect/narration/proc/display(mob/living/L)
	if(msg)
		to_chat(L, msg)

	if(play_sound)
		L << play_sound
