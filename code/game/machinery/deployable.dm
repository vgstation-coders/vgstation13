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


//Barricades, maybe there will be a metal one later...
/obj/structure/barricade/wooden
	name = "\improper wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	anchored = 1.0
	density = 1.0
	var/health = 100.0
	var/maxhealth = 100.0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/stack/sheet/wood))
			if (src.health < src.maxhealth)
				user.visible_message("<span class='warning'>[user] begins to repair [src]!", "<span class='notice'>You begin to repair [src].</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 60, 1)
				spawn(rand(3,7))
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 40, 1)
				spawn(rand(3,7))
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1) //No seriously, that's how I do repairing sounds
				if(do_after(user,50))
					src.health = src.maxhealth
					W:use(1)
					user.visible_message("<span class='warning'>[user] repairs [src]!", "<span class='notice'>You repair [src].</span>")
					return
			else
				return
			return
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 1
				if("brute")
					src.health -= W.force * 0.75
				else
			if (src.health <= 0)
				visible_message("<span class='danger'>[src] is smashed apart!</span>")
				new /obj/item/stack/sheet/wood(get_turf(src, 5))
				del(src)
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("<span class='danger'>[src] is blown apart!</span>")
				qdel(src)
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					visible_message("<span class='danger'>[src] is blown apart!</span>")
					new /obj/item/stack/sheet/wood(get_turf(src))
					new /obj/item/stack/sheet/wood(get_turf(src))
					new /obj/item/stack/sheet/wood(get_turf(src))
					qdel(src)
				return

	meteorhit()
		visible_message("<span class='danger'>[src] is smashed apart!</span>")
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		del(src)
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			visible_message("<span class='danger'>The blob eats through [src]!</span>")
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

/obj/structure/barricade/wooden/door //Used by the barricade kit when it is placed on doors

	icon = 'icons/policetape.dmi'
	icon_state = "wood_door"
	anchored = 1
	density = 1
	health = 50 //Can take a few hits
	maxhealth = 50

//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "\improper deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "\improper deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 100.0
	var/maxhealth = 100.0
	var/locked = 0.0

	New()
		..()

		src.icon_state = "barrier[src.locked]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/card/id/))
			if (src.allowed(user))
				if	(src.emagged < 2.0)
					src.locked = !src.locked
					src.anchored = !src.anchored
					src.icon_state = "barrier[src.locked]"
					if ((src.locked == 1.0) && (src.emagged < 2.0))
						user.visible_message("<span class='warning'>[user] toggles [src] on!", "<span class='notice'>You toggle [src] on.</span>")
						return
					else if ((src.locked == 0.0) && (src.emagged < 2.0))
						user.visible_message("<span class='warning'>[user] toggles [src] off!", "<span class='notice'>You toggle [src] off.</span>")
						return
				else
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, src)
					s.start()
					visible_message("<span class='warning'>[src] sparks violently.</span>")
					return
			return
		else if (istype(W, /obj/item/weapon/card/emag))
			if (src.emagged == 0)
				src.emagged = 1
				src.req_access = null
				user << "<span class='notice'>You break the ID authentication lock on [src].</span>"
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("<span class='warning'>[src] sparks violently.</span>")
				return
			else if (src.emagged == 1)
				src.emagged = 2
				user << "<span class='notice'>You short out the anchoring mechanism on [src].</span>"
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("<span class='warning'>[src] sparks violently.</span>")
				return
		else if (istype(W, /obj/item/weapon/wrench))
			if (src.health < src.maxhealth)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("<span class='warning'>[user] starts repairing [src]!", "<span class='notice'>You start repairing [src]!</span>", "<span class='notice'>You hear a ratchet.</span>")
				if(do_after(user,50))
					src.health = src.maxhealth
					src.emagged = 0
					src.req_access = list(access_security)
					user.visible_message("<span class='warning'>[user] repairs [src]!", "<span class='notice'>You repair [src]!</span>")
					return
			else if (src.emagged > 0)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("<span class='warning'>[user] starts repairing [src]!", "<span class='notice'>You start repairing [src]!</span>", "<span class='notice'>You hear a ratchet.</span>")
				if(do_after(user,50))
					src.emagged = 0
					src.req_access = list(access_security)
					user.visible_message("<span class='warning'>[user] repairs [src]!", "<span class='notice'>You repair [src]!</span>")
					return
			return
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 0.75
				if("brute")
					src.health -= W.force * 0.5
				else
			if (src.health <= 0)
				src.explode()
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.explode()
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					src.explode()
				return
	emp_act(severity)
		if(stat & (BROKEN|NOPOWER))
			return
		if(prob(50/severity))
			locked = !locked
			anchored = !anchored
			icon_state = "barrier[src.locked]"

	meteorhit()
		src.explode()
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			src.explode()
		return

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

	proc/explode()

		visible_message("<span class='danger'>[src] blows apart!</span>")
		var/turf/Tsec = get_turf(src)

	/*	var/obj/item/stack/rods/ =*/
		new /obj/item/stack/rods(Tsec)

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		explosion(src.loc,-1,-1,0)
		if(src)
			qdel(src)
