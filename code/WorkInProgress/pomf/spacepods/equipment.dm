/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()


	if(my_atom.next_firetime > world.time)
		to_chat(usr, "<span class='warning'>Your weapons are recharging.</span>")
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		to_chat(usr, "<span class='warning'>Missing equipment or weapons.</span>")
		my_atom.verbs -= /obj/item/device/spacepod_equipment/weaponry/proc/fire_weapon_system
		return
	if(!my_atom.battery.use(shot_cost))
		to_chat(usr, "<span class='warning'>\The [my_atom]'s cell is too low on charge!</span>")
		return
	var/olddir
	dir = my_atom.dir
	for(var/i = 0; i < shots_per; i++)
		if(olddir != dir)
			switch(dir)
				if(NORTH)
					firstloc = get_turf(my_atom)
					firstloc = get_step(firstloc, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_turf(my_atom)
					firstloc = get_step(firstloc, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/obj/item/projectile/projone = new projectile_type(firstloc)
		var/obj/item/projectile/projtwo = new projectile_type(secondloc)
		projone.starting = get_turf(firstloc)
		projone.shot_from = my_atom
		projone.firer = usr
		projone.def_zone = LIMB_CHEST
		projtwo.starting = get_turf(secondloc)
		projtwo.shot_from = my_atom
		projtwo.firer = usr
		projtwo.def_zone = LIMB_CHEST
		spawn(0)
			playsound(my_atom, fire_sound, 50, 1)
			projone.dumbfire(dir)
		spawn(0)
			projtwo.dumbfire(dir)
		sleep(1)
	my_atom.next_firetime = world.time + fire_delay

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	//var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	//var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom
// base item for spacepod weapons

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 10
	var/verb_name = "What the fuck?"
	var/verb_desc = "How did you get this?"

/obj/item/device/spacepod_equipment/weaponry/taser
	name = "\improper taser system"
	desc = "A weak taser system for space pods, fires electrodes that shock upon impact."
	icon_state = "pod_taser"
	projectile_type = /obj/item/projectile/energy/electrode
	shot_cost = 10
	fire_sound = "sound/weapons/Taser.ogg"
	verb_name = "Fire Taser System"
	verb_desc = "Fire ze tasers!"

/obj/item/device/spacepod_equipment/weaponry/taser/burst
	name = "\improper burst taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "pod_b_taser"
	shot_cost = 35
	shots_per = 3
	fire_delay = 20
	verb_name = "Fire Burst Taser System"
	verb_desc = "Fire ze tasers!"

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "\improper laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy"
	icon_state = "pod_w_laser"
	projectile_type = /obj/item/projectile/beam
	shot_cost = 150
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 15
	verb_name = "Fire Laser System"
	verb_desc = "Fire ze lasers!"

/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapon_system()
	var/obj/spacepod/S = src
	var/obj/item/device/spacepod_equipment/weaponry/SPE = S.equipment_system.weapon_system
	set category = "Spacepod"
	//set name = SPE.verb_name
	//set desc = SPE.verb_desc
	set src = usr.loc

	SPE.fire_weapons()
