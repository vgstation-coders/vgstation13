//Inheritance Monkey (Not a real rig)//

/obj/item/clothing/suit/space/rig/grey
	name = "grey pressure suit"
	desc = "Placeholder description."
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/head/helmet/space/rig/grey
	name = "grey pressure helmet"
	desc = "Placeholder description."
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED)

//Worker//

/obj/item/clothing/suit/space/rig/grey/worker
	name = "worker pressure suit"
	desc = "A pressure suit mass-produced for the spacefaring laborers of the Grey Democratic Republic. It has radiation shielding and insulation against extreme heat."
	icon_state = "rig_grey_worker"
	item_state = "rig_grey_worker"
	armor = list(melee = 40, bullet = 5, laser = 20, energy = 5, bomb = 35, bio = 100, rad = 50)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/worker
	initial_modules = list(/obj/item/rig_module/rad_shield)

/obj/item/clothing/suit/space/rig/grey/dissolvable()
	return WATER

/obj/item/clothing/head/helmet/space/rig/grey/worker
	name = "worker pressure helmet"
	desc = " A grey laborer's pressure helmet. It protects the cranium from common work hazards in vacuum. Safety first!"
	icon_state = "rig0-grey_worker_dome_up"
	item_state = "rig0-grey_worker_dome_up"
	_color = "grey_worker_dome"
	armor = list(melee = 40, bullet = 5, laser = 20, energy = 5, bomb = 35, bio = 100, rad = 50)
	actions_types = list(/datum/action/item_action/toggle_helmet)
	eyeprot = 1
	var/up = 1

/obj/item/clothing/head/helmet/space/rig/grey/worker/attack_self()
	toggle()

/obj/item/clothing/head/helmet/space/rig/grey/worker/proc/toggle()
	var/mob/C = usr
	if(!usr)
		if(!ismob(loc))
			return
		C = loc
	if(!C.incapacitated())
		if(src.up)
			src.up = !src.up
			eyeprot = 3
			to_chat(C, "You activate the [src]'s welding visor.")
		else
			src.up = !src.up
			eyeprot = 1
			to_chat(C, "You deactivate the [src]'s welding visor.")

		update_icon()
		usr.update_inv_head()

/obj/item/clothing/head/helmet/space/rig/grey/worker/update_icon()
	icon_state = "rig[on]-grey_worker_dome[up ? "_up" : ""]"
	item_state = "rig[on]-grey_worker_dome[up ? "_up" : ""]"


/obj/item/clothing/head/helmet/space/rig/grey/worker/dissolvable()
	return WATER

//Researcher//

/obj/item/clothing/suit/space/rig/grey/researcher
	name = "researcher pressure suit"
	desc = "A pressure suit intended for use by the scientific elite of the Grey Democratic Republic. It offers some protection from explosions and exotic particles."
	icon_state = "rig_grey_researcher"
	item_state = "rig_grey_researcher"
	armor = list(melee = 40, bullet = 5, laser = 25, energy = 5, bomb = 50, bio = 100, rad = 35)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/researcher

/obj/item/clothing/suit/space/rig/grey/researcher/dissolvable()
	return WATER

/obj/item/clothing/head/helmet/space/rig/grey/researcher
	name = "researcher pressure helmet"
	desc = "A grey researcher's pressure helmet. The brightest minds will lead the way!"
	icon_state = "rig0-grey_researcher_dome"
	item_state = "rig0-grey_researcher_dome"
	_color = "grey_researcher_dome"
	armor = list(melee = 40, bullet = 5, laser = 25, energy = 5, bomb = 50, bio = 100, rad = 35)

/obj/item/clothing/head/helmet/space/rig/grey/researcher/dissolvable()
	return WATER

//Soldier//

/obj/item/clothing/suit/space/rig/grey/soldier
	name = "soldier pressure suit"
	desc = "A reinforced pressure suit issued to the defense forces of the Grey Democratic Republic. It provides moderate protection from melee attacks and laser-based weaponry."
	icon_state = "rig_grey_soldier"
	item_state = "rig_grey_soldier"
	slowdown = HARDSUIT_SLOWDOWN_HIGH
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/handcuffs, /obj/item/weapon/gun/energy/smalldisintegrator, /obj/item/weapon/gun/energy/heavydisintegrator)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/soldier

/obj/item/clothing/suit/space/rig/grey/soldier/dissolvable()
	return WATER

/obj/item/clothing/head/helmet/space/rig/grey/soldier
	name = "soldier pressure helmet"
	desc = "A grey soldier's pressure helmet. All enemies of the mothership must be disintegrated!"
	icon_state = "rig0-grey_soldier_dome"
	item_state = "rig0-grey_soldier_dome"
	_color = "grey_soldier_dome"
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 15, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/rig/grey/soldier/dissolvable()
	return WATER

//Leader//

/obj/item/clothing/suit/space/rig/grey/leader
	name = "Administrator Pressure Suit"	//Not an admin item. Just a thematic name. It's capitalized unlike the others because it's important! And also because it looks better on the reflect message.
	desc = "A pressure suit for high ranking officials in the Grey Democratic Republic. It provides much better protection than a standard soldier suit."
	icon_state = "rig_grey_leader"
	item_state = "rig_grey_leader"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 60, bullet = 30, laser = 70, energy = 25, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/gun/energy/smalldisintegrator, /obj/item/weapon/gun/energy/heavydisintegrator, /obj/item/weapon/gun/energy/advdisintegrator)
	cell_type = /obj/item/weapon/cell/super
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/leader
	clothing_flags = PLASMAGUARD

/obj/item/clothing/suit/space/rig/grey/leader/equipped(mob/living/carbon/human/H, equipped_slot)
	if(equipped_slot == slot_wear_suit)
		if(isgrey(H))
			to_chat(H,"<span class='notice'>The [src] forms a perfect seal around your body. You hear it hum as it adjusts its components.</span>")
		else
			to_chat(H,"<span class='warning'>The [src] is barely able to form a seal around your body and flashes a warning: Overweight user detected!</span>") // If a human equips it, it will complain a bit. Doesn't affect the stats, however
	..()

/obj/item/clothing/suit/space/rig/grey/leader/dissolvable() // A grey leader's suit melted by acid? I imagine maybe it happened once and they vowed to never let it happen again
	return FALSE

/obj/item/clothing/head/helmet/space/rig/grey/leader
	name = "Administrator Pressure Helmet"
	desc = "A grey Administrator's pressure helmet. Glory to the mothership, and all hail the Chairman!"
	icon_state = "rig0-grey_leader_dome"
	item_state = "rig0-grey_leader_dome"
	_color = "grey_leader_dome"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 60, bullet = 30, laser = 70, energy = 25, bomb = 50, bio = 100, rad = 50)
	clothing_flags = PLASMAGUARD

/obj/item/clothing/head/helmet/space/rig/grey/leader/dissolvable() // A grey leader's suit melted by acid? I imagine maybe it happened once and they vowed to never let it happen again
	return FALSE
