//Worker//

/obj/item/clothing/suit/space/rig/grey
	name = "worker pressure suit"
	desc = "A pressure suit mass-produced for the spacefaring laborers of the Grey Democratic Republic. It has radiation shielding and insulation against extreme heat."
	icon_state = "rig_grey_worker"
	item_state = "rig_grey_worker"
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED)
	armor = list(melee = 30, bullet = 5, laser = 20, energy = 5, bomb = 25, bio = 100, rad = 50)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey

/obj/item/clothing/head/helmet/space/rig/grey
	name = "worker pressure helmet"
	desc = " A Grey laborer's pressure helmet. It protects the cranium from common work hazards in vacuum. Safety first!"
	icon_state = "rig0_grey_worker_dome"
	item_state = "rig0_grey_worker_dome"
	_color = "grey_worker_dome"
	armor = list(melee = 30, bullet = 5, laser = 20, energy = 5, bomb = 25, bio = 100, rad = 50)
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED)


//Researcher//

/obj/item/clothing/suit/space/rig/grey/researcher
	name = "researcher pressure suit"
	desc = "A pressure suit intended for use by the scientific elite of the Grey Democratic Republic. It offers some protection from explosions and exotic particles."
	icon_state = "rig_grey_researcher"
	item_state = "rig_grey_researcher"
	armor = list(melee = 30, bullet = 5, laser = 20, energy = 5, bomb = 40, bio = 100, rad = 40)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/researcher

/obj/item/clothing/head/helmet/space/rig/grey/researcher
	name = "researcher pressure helmet"
	desc = "A Grey researcher's pressure helmet. The brightest minds will lead the way!"
	icon_state = "rig0_grey_researcher_dome"
	item_state = "rig0_grey_researcher_dome"
	_color = "grey_researcher_dome"
	armor = list(melee = 30, bullet = 5, laser = 20, energy = 5, bomb = 40, bio = 100, rad = 40)

//Soldier//

/obj/item/clothing/suit/space/rig/grey/soldier
	name = "soldier pressure suit"
	desc = "A reinforced pressure suit issued to the defense forces of the Grey Democratic Republic. It provides moderate protection from melee attacks and laser-based weaponry."
	icon_state = "rig_grey_soldier"
	item_state = "rig_grey_soldier"
	slowdown = HARDSUIT_SLOWDOWN_MED
	armor = list(melee = 40, bullet = 15, laser = 50, energy = 30, bomb = 30, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/gun/energy/laser)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/soldier

/obj/item/clothing/head/helmet/space/rig/grey/soldier
	name = "soldier pressure helmet"
	desc = "A Grey soldier's pressure helmet. All enemies of the mothership must be disintegrated!"
	icon_state = "rig0_grey_soldier_dome"
	item_state = "rig0_grey_soldier_dome"
	_color = "grey_soldier_dome"
	armor = list(melee = 40, bullet = 15, laser = 50, energy = 15, bomb = 30, bio = 100, rad = 20)

//Leader//

/obj/item/clothing/suit/space/rig/grey/leader
	name = "administrator pressure suit"	//Not an admin item. Just a thematic name.
	desc = "A pressure suit for high ranking officials in the Grey Democratic Republic. It provides much better protection than a standard soldier suit."
	icon_state = "rig_grey_leader"
	item_state = "rig_grey_leader"
	armor = list(melee = 50, bullet = 25, laser = 60, energy = 25, bomb = 40, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/gun/energy/laser, /obj/item/weapon/handcuffs)
	head_type = /obj/item/clothing/head/helmet/space/rig/grey/leader


/obj/item/clothing/head/helmet/space/rig/grey/leader
	name = "administrator pressure helmet"
	desc = "A Grey Administrator's pressure helmet. Glory to the mothership, and all hail the Chairman!"
	icon_state = "rig0_grey_leader_dome"
	item_state = "rig0_grey_leader_dome"
	_color = "grey_leader_dome"
	armor = list(melee = 50, bullet = 25, laser = 60, energy = 25, bomb = 40, bio = 100, rad = 50)
