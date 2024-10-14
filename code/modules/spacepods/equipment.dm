/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()


	if(my_atom.next_firetime > world.time)
		to_chat(usr, "<span class='warning'>Your weapons are recharging.</span>")
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.ES || !my_atom.ES.weapon_system)
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
	var/movement_charge = 2
	var/weapons_allowed = 1
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	//var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	//var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system
	var/obj/item/device/spacepod_equipment/locking/locking_system // locking system
	var/obj/item/device/spacepod_equipment/cargo/cargo_system // cargo bay system

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
	desc = "You shouldn't be seeing this."
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
	desc = "A weak laser system for space pods that fires concentrated bursts of energy."
	icon_state = "pod_w_laser"
	projectile_type = /obj/item/projectile/beam
	shot_cost = 150
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 15
	verb_name = "Fire Laser System"
	verb_desc = "Fire ze lasers!"

/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapon_system()
	var/obj/spacepod/S = src
	var/obj/item/device/spacepod_equipment/weaponry/SPE = S.ES.weapon_system
	set category = "Spacepod"
	//set name = SPE.verb_name
	//set desc = SPE.verb_desc
	set src = usr.loc

	var/list/passengers = S.get_passengers()
	if(passengers.Find(usr) && !S.passenger_fire)
		to_chat(usr, "<span class = 'warning'>Passenger gunner system disabled.</span>")
		return
	SPE.fire_weapons()

/obj/item/device/spacepod_equipment/locking
	icon = 'icons/pods/ship.dmi'
	icon_state = "locking"

/obj/item/device/spacepod_equipment/locking/proc/toggle_lock()
	my_atom.locked = !my_atom.locked
	my_atom.visible_message("<span class = 'notice'>\The [my_atom] beeps!</span>")

/obj/item/device/spacepod_equipment/locking/lock
	name = "spacepod physical lock system"
	desc = "Use a remote key to lock and unlock the pod."
	var/code

/obj/item/device/spacepod_equipment/locking/lock/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/pod_key))
		var/obj/item/device/pod_key/P = I
		if(!P.code)
			if(!code)
				code = rand(11111,99999)
			to_chat(user, "<span class = 'notice'>You pair \the [P] with \the [src].</span>")
			P.code = code
		else
			to_chat(user, "<span class = 'warning'>\The [P] is already codelocked.</span>")
		return
	..()

/obj/item/device/pod_key
	name = "pod key"
	desc = "Used in tandem with a pod locking system. Authenticate the key with the lock via colliding the two."
	icon = 'icons/pods/ship.dmi'
	icon_state = "key"
	w_class = W_CLASS_SMALL
	var/code

/obj/item/device/pod_key/attack_self(mob/user)
	for(var/obj/spacepod/P in view(7, user))
		if(P.ES.locking_system && istype(P.ES.locking_system, /obj/item/device/spacepod_equipment/locking/lock))
			var/obj/item/device/spacepod_equipment/locking/lock/L = P.ES.locking_system
			if(L.code == code)
				L.toggle_lock()

/obj/item/device/pod_key/attackby(var/obj/item/O, mob/user)
	if(O.is_multitool(user))
		code = input(user,"Enter a number:","Key Code",code) as num
		return
	.=..()

/obj/item/device/pod_key/afterattack(var/atom/A, mob/user, proximity_flag)
	if(!proximity_flag)
		return

	if(istype(A, /obj/spacepod))
		var/obj/spacepod/SP = A
		if(SP.ES.locking_system && istype(SP.ES.locking_system, /obj/item/device/spacepod_equipment/locking/lock))
			var/obj/item/device/spacepod_equipment/locking/lock/L = SP.ES.locking_system
			if(code == L.code)
				L.toggle_lock()
				return
			var/list/our_code = string2charlist(num2text(code))
			var/list/their_code = string2charlist(num2text(L.code))
			var/found_values = 0
			var/correct_positions = 0
			for(var/i=1 to our_code.len)
				var/char = our_code[i]
				if(their_code.Find(char))
					found_values++
				if(i < their_code.len && char == their_code[i])
					correct_positions++
			to_chat(user, "<span class = 'notice'>[found_values] correct values, [correct_positions] correct positions.</span>")

/obj/item/device/spacepod_equipment/cargo
	name = "pod cargo system"
	desc = "You shouldn't be seeing this."
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/list/allowed_types
	var/atom/movable/stored

/obj/item/device/spacepod_equipment/cargo/crate
	name = "pod cargo system"
	desc = "A pod system that allows a space pod to hold a single crate."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shelf_base"
	allowed_types = list( /obj/structure/closet/crate)
