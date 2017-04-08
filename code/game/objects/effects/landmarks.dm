var/list/landmarks_list = list() //list of all landmarks
var/list/landmarks_by_type = list() //list of landmark types associated with turf lists

//Returns a list of all landmark turfs or an empty list
/proc/get_landmarks(input_type, readonly = TRUE)
	var/list/L = landmarks_by_type[input_type]
	return L ? (readonly ? L : L.Copy()) : list()

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

	var/destroy_on_creation = TRUE

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

/obj/effect/landmark/endgame_exit
	name = "endgame exit"
	desc = "In the event of a supermatter cascade, the portal to safety teleports you here."

/obj/effect/landmark/xeno_spawn
	name = "xeno spawn"
	desc = "Random events may spawn xenomorphs here."

/obj/effect/landmark/latejoin
	name = "latejoin"
	desc = "Late arrivals spawn here."

/obj/effect/landmark/assistant_latejoin
	name = "assistant latejoin"
	desc = "Late arrivals that are also assistants spawn here."

/obj/effect/landmark/wizardstart
	name = "wizard spawn"
	desc = "Wizards spawn here"

/obj/effect/landmark/newplayer_start
	name = "newplayer start"
	desc = "The title screen that is shown to players when they connect to the server."

/obj/effect/landmark/prisonwarp
	name = "prisonwarp"
	desc = "A prison in central command used by admins."

/obj/effect/landmark/blobstart
	name = "blobstart"
	desc = "A spawn location for blobs and some other minor events."

/obj/effect/landmark/holdingfacility
	name = "holding facility"
	desc = "Captured people go here." //Unused currently

/obj/effect/landmark/thunderdome/green
	name = "thunderdome 1"
	desc = "Team Green"

/obj/effect/landmark/thunderdome/red
	name = "thunderdome 2"
	desc = "Team Red"

/obj/effect/landmark/thunderdome/admin
	name = "thunderdome admin area"

/obj/effect/landmark/thunderdome/observe
	name = "thunderdome spectators"

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
