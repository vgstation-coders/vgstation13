/datum/faction/spider_clan
	name = "Spider Clan"
	desc = "For honor, for revengeance, or just to train by ruining someone's day."
	ID = SPIDERCLAN
	required_pref = NINJA
	initial_role = NINJA
	late_role = NINJA
	roletype = /datum/role/ninja
	initroletype = /datum/role/ninja
	default_admin_voice = "Spider Clan"
	admin_voice_style = "bold"
	logo_state = "ninja-logo"
	hud_icons = list("ninja-logo")

/datum/faction/spider_clan/New()
	..()
	load_dungeon(/datum/map_element/dungeon/ninja_dojo)


/datum/faction/spider_clan/forgeObjectives()
	return //nothing logical to put here just yet


/datum/map_element/dungeon/ninja_dojo //small room for the ninja to get oriented
	file_path = "maps/misc/dojo.dmm"
	unique = TRUE

/obj/structure/button/ninja
	activate_id = "0"
	global_search = 0
	reset_name = 0

/obj/structure/button/ninja/attack_hand(mob/user)

	visible_message("<span class='info'>[user] presses \the [src].</span>")
	activate(user)

/obj/structure/button/ninja/launcher
	name = "launcher button"
	desc = "Pressing this button will activate your space protection and launch you to the target station from a random direction."

/obj/structure/button/ninja/launcher/activate(mob/user)
	var/mob/living/carbon/human/spaceninja = user
	if(spaceninja.get_item_by_slot(slot_wear_suit))
		var/obj/item/clothing/suit/space/ninja/apprentice/ninja_suit = spaceninja.get_item_by_slot(slot_wear_suit)
		ninja_suit.pressurize()
	if(spaceninja.get_item_by_slot(slot_shoes))
		var/obj/item/clothing/shoes/ninja/apprentice/ninja_shoes = spaceninja.get_item_by_slot(slot_shoes)
		ninja_shoes.activateMagnets()
	spaceninja.ThrowAtStation()

/obj/structure/button/ninja/teleporter
	name = "teleporter button"
	desc = "Pressing this button will teleport you into a dark secluded place on the target station."

/obj/structure/button/ninja/teleporter/activate(mob/user)
	usr.spawn_rand_maintenance()

/obj/effect/decal/ninjaporter
	name = "ninja teleporter"
	desc = "Teleports you at the press of a button!"
	icon = 'icons/mecha/mecha_equipment.dmi' //placeholder until someone sprites something better
	icon_state = "mecha_teleport"  // much like the acoustic floors instead of tatami mats

/obj/effect/decal/arrow
	name = "arrow"
	desc = "Points at something."
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrows"

/obj/structure/sign/ninjaglove
	name = "Glove Draining Practice"
	desc = "This sign indicates you can practice power glove draining here."
	icon_state = "NJ_glove"
