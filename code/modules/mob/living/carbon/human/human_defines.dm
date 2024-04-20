/mob/living/carbon/human
	//Hair colour and style are in apperance.dm

	var/multicolor_skin_r = 0	//Only used when the human has a species datum with the MULTICOLOR anatomical flag
	var/multicolor_skin_g = 0
	var/multicolor_skin_b = 0

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/eye_style = null
	var/face_style = null

	mob_bump_flag = HUMAN
	mob_push_flags = ALLMOBS
	mob_swap_flags = ALLMOBS

	flags = HEAR_ALWAYS | PROXMOVE

	var/age = 30		//Player's age (pure fluff)
	//var/b_type = "A+"	//Player's bloodtype //NOW HANDLED IN THEIR DNA

	var/underwear = 1	//Which underwear the player wants
	var/backbag = 2		//Which backpack type the player has chosen. Nothing, Satchel or Backpack.

	//Equipment slots
	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/shoes = null
	var/obj/item/belt = null
	var/obj/item/gloves = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/head = null
	var/obj/item/ears = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null
	var/obj/item/l_ear	 = null
	var/obj/item/r_ear	 = null

	//Special attacks (bite, kicks, ...)
	var/attack_type = NORMAL_ATTACK

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = null

	var/icon/stand_icon = null
	var/icon/lying_icon = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/last_dam = -1	//Used for determining if we need to process all organs or just some or even none.
	var/list/bad_external_organs = list()// organs we check until they are good.

	var/xylophone = 0 //For the spoooooooky xylophone cooldown
	var/lastpuke = 0

	var/mob/remoteview_target = null

	var/meatleft = 3 //For chef item

	var/check_mutations=0 // Check mutations on next life tick

	var/last_shush = 0 // disarm intent shushing cooldown
	var/lastFart = 0 // Toxic fart cooldown.
	var/lastDeathgasp = 0	// Deathgasp cooldown (only for clown trombones atm)
	var/lastDab = 0 //Dab cooldown.
	var/lastAnemia = 0 //Anemia rest cooldown
	var/last_emote_sound = 0 // Prevent scream spam in some situations

	/// To keep track of a decapitated head, for debug and soulstone purposes.
	/// (obj/item/organ/external/head)
	var/datum/weakref/decapitated

	fire_dmi = 'icons/mob/OnFire.dmi'
	fire_sprite = "Standing"
	plane = HUMAN_PLANE

	var/show_client_status_on_examine = TRUE //If false, don't display catatonic/braindead messages to non-admins

	var/become_zombie = FALSE
	var/calorie_burn_rate = HUNGER_FACTOR
	var/time_last_speech = 0 //When was the last time we talked?
	var/manual_emote_sound_override = 0 //If toggled on, allows humans to make audible emotes
