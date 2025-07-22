
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
	id_tag = "APS"
	var/list/codewords = list()
	var/last_saytime = 0

/obj/machinery/door/airlock/external/adv_pocketsat_entrance/New()
	..()
	codewords = generate_code_phrase()
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
	if(istype(ID,/obj/item/weapon/card/id/syndicate))
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
	for(var/obj/machinery/turretid/controller in control_area.contents)
		turrets_were_on |= controller.enabled
		controller.enabled = 0
		controller.updateTurrets()
	say("[from_speech ? "Response phrase accepted. " : "Identity authenticated. "]Welcome, Agent.[turrets_were_on ? " Turrets disabled." : ""]")
	locked = 0
	playsound(src, "sound/machines/door_unbolt.ogg", 50, 1, -1)
	for(var/mob/M in range(1, src))
		M.show_message("You hear a metallic clunk from the bottom of the door.", 2)
	update_icon()

/obj/machinery/computer/arcade/syndicate/New()
	. = ..()
	emag_act()

/obj/structure/safe/floor/advanced_pocketsat
	name = "secret satellite stash"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Gorlex Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and Nanotrasen resistant. Contains roughly 160 telecrystals worth of syndicate equipment.\""
	color = "#ff0000"

/obj/structure/safe/floor/advanced_pocketsat/New()
	..()
	for(var/i in 1 to 8)
		if(i == 7 && prob(1))
			var/to_spawn = pick(list(
				/obj/item/weapon/gun/gatling,
				/obj/item/weapon/gun/energy/gatling,
				/obj/effect/spawner/newbomb/timer,
				/obj/item/weapon/gun/projectile/rocketlauncher/nikita,
				/obj/item/weapon/gun/projectile/hecate,
				))
			new to_spawn(src)
			return
		else
			new /obj/item/toy/syndicateballoon(src)
