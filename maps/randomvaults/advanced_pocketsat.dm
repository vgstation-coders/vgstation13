
/datum/map_element/vault/advanced_pocketsat
	name = "Advanced pocket satellite"
	file_path = "maps/randomvaults/advanced_pocketsat.dmm"

/area/vault/advanced_pocketsat
	requires_power = FALSE
	dynamic_lighting = FALSE

/obj/machinery/door/airlock/external/adv_pocketsat_entrance
	desc = "It opens and closes. It appears to have a microphone and speaker attached."
	locked = 1
	flags = FPRINT | HEAR
	var/list/codewords = list()
	var/last_saytime = 0

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/New()
	..()
	var/static/list/potential_codewords = list("love","hate","anger","peace","pride","sympathy","bravery","loyalty","honesty","integrity","compassion",
										"charity","success","courage","deceit","skill","beauty","brilliance","pain","misery","beliefs","dreams",
										"justice","truth","faith","liberty","knowledge","thought","information","culture","trust","dedication",
										"progress","education","hospitality","leisure","trouble","friendships", "relaxation",
										"vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea",
										"margarita","Irish coffee"," manly dwarf","Irish cream","doctor's delight","Beepsky Smash","tequila sunrise",
										"brave bull","gargle blaster","bloody mary","whiskey cola","white Russian","vodka martini","martini",
										"Cuba libre","kahlua","vodka","wine","moonshine")
	for(var/i in 1 to 3)
		codewords += list(pick_n_take(potential_codewords))
	update_icon()

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/hitby(atom/movable/AM)
	if(!locked)
		..()
	else if(!check_for_access_item(AM))
		say_phrase()

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/attack_hand(mob/user)
	if(!locked)
		..()
	else if(!check_for_access_item(user))
		say_phrase()

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/Bumped(atom/AM)
	if(!locked)
		..()
	else if(!check_for_access_item(AM))
		say_phrase()

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/proc/check_for_access_item(var/mob/user)
	if((stat & (BROKEN|NOPOWER)) || !locked || !istype(user))
		return FALSE
	if(locate(/obj/item/toy/syndicateballoon) in user.held_items)
		grant_access()
		return TRUE
	var/obj/item/ID = user.get_item_by_slot(slot_wear_id)
	ID = ID.GetID()
	if(istype(ID),/obj/item/weapon/card/id/syndicate)
		grant_access()
		return TRUE
	return FALSE

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/proc/say_phrase()
	if((stat & (BROKEN|NOPOWER)) || !locked)
		return
	if(last_saytime + (10 SECONDS) < world.time)
		say(pick(codewords))
		last_saytime = world.time

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/Hear(var/datum/speech/speech, var/rendered_speech="")
	if((stat & (BROKEN|NOPOWER)) || !locked)
		return
	if(speech.speaker && !speech.frequency)
		for(var/phrase in syndicate_code_response)
			if(findtext(speech.message, phrase))
				grant_access(TRUE)
				break

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/proc/grant_access(var/from_speech = FALSE)
	var/turrets_were_on = FALSE
	var/area/control_area = get_area(src)
	for(var/obj/machinery/turret/aTurret in control_area.contents)
		turrets_were_on |= aTurret.enabled
		aTurret.setState(0, 1)
	say("[from_speech ? "Response phrase accepted. " : "Identity authenticated. "]Welcome, Agent.[turrets_were_on ? " Turrets disabled." : ""]")
	locked = 0
	playsound(src, "sound/machines/door_unbolt.ogg", 50, 1, -1)
	for(var/mob/M in range(1, src))
		to_chat(M, "You hear a metallic clunk from the bottom of the door.")
	update_icon()

/obj/machinery/computer/arcade/syndicate/New()
	. = ..()
	emag_act()

/obj/abstract/map/spawner/safe/syndicate
	name = "syndicate balloon"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	chance = 1
	to_spawn = list(
		/obj/item/weapon/gun/gatling,
		/obj/item/weapon/gun/energy/gatling,
		/obj/item/weapon/gun/projectile/rocketlauncher/nikita,
		/obj/item/weapon/gun/projectile/hecate
		)
