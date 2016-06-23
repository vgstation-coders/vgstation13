/*
CONTAINS:

Deployable items
Barricades

for reference:

	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_genetics = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	access_court = 42
	access_clown = 43
	access_mime = 44

*/

//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 140.0
	var/maxhealth = 140.0
	var/locked = 0.0
//	req_access = list(access_maint_tunnels)

	machine_flags = EMAGGABLE

/obj/machinery/deployable/barrier/New()
	..()

	icon_state = "barrier[locked]"

/obj/machinery/deployable/barrier/emag(mob/user)
	if (emagged == 0)
		emagged = 1
		req_access = 0
		to_chat(user, "You break the ID authentication lock on the [src].")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		desc = "A deployable barrier. Swipe your ID card to lock/unlock it. Seems like it's malfunctioning"
		return

/obj/machinery/deployable/barrier/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id/))
		if (allowed(user))
			locked = !locked
			anchored = !anchored
			icon_state = "barrier[locked]"
			if (locked == 1.0)
				to_chat(user, "Barrier lock toggled on.")
				return
			else if (locked == 0.0)
				to_chat(user, "Barrier lock toggled off.")
				return
		return
	else
		visible_message("<span class='danger'>[src] has been hit by [user] with [W]</span>") //I have to put this because atom/proc/attackby is not triggering. No idea why
		user.delayNextAttack(10)
		switch(W.damtype)
			if("fire")
				health -= W.force * 1
			if("brute")
				health -= W.force * 0.75
		if (health <= 0)
			explode()
		..()

/obj/machinery/deployable/barrier/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
			return
		if(2.0)
			health -= 25
			if (health <= 0)
				explode()
			return

/obj/machinery/deployable/barrier/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(prob(50/severity))
		locked = !locked
		anchored = !anchored
		icon_state = "barrier[locked]"

/obj/machinery/deployable/barrier/blob_act()
	health -= 25
	if (health <= 0)
		explode()
	return

/obj/machinery/deployable/barrier/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/deployable/barrier/proc/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>")

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	explosion(loc,-1,-1,0)
	if(src)
		qdel(src)
