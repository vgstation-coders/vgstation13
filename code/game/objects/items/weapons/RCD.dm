/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	w_type = RECYK_ELECTRONIC
	origin_tech = "engineering=4;materials=2"
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0

	var/matter = 0
	var/max_matter = 30

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is using the deconstruct function on the [src.name] on \himself! It looks like \he's  trying to commit suicide!</b>"
		return (user.death(1))

	attack_self(mob/user)
		//Change the mode
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		switch(mode)
			if(1)
				mode = 2
				user << "<span class='notice'>Changed mode to 'Airlock'</span>"
				if(prob(20))
					src.effect_system.start()
				return
			if(2)
				mode = 3
				user << "<span class='notice'>Changed mode to 'Deconstruct'</span>"
				if(prob(20))
					src.effect_system.start()
				return
			if(3)
				mode = 1
				user << "<span class='notice'>Changed mode to 'Floor & Walls'</span>"
				if(prob(20))
					src.effect_system.start()
				return

	proc/activate()
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)


	afterattack(atom/A, mob/user)
		if(disabled && !isrobot(user))
			return 0
		if(get_dist(user,A)>1)
			return 0
		if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
			return 0
		if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return 0

		switch(mode)
			if(1)
				if(istype(A, /turf/space))
					if(useResource(1, user))
						user << "Building Floor..."
						activate()
						A:ChangeTurf(/turf/simulated/floor/plating)
						return 1
					return 0

				if(istype(A, /turf/simulated/floor))
					if(checkResource(3, user))
						user << "Building Wall ..."
						playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 20))
							if(!useResource(3, user)) return 0
							activate()
							A:ChangeTurf(/turf/simulated/wall)
							return 1
					return 0

			if(2)
				if(istype(A, /turf/simulated/floor))
					if(checkResource(10, user))
						user << "Building Airlock..."
						playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(10, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
							T.autoclose = 1
							return 1
						return 0
					return 0

			if(3)
				if(istype(A, /turf/simulated/wall))
					if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
						return 0
					if(checkResource(5, user))
						user << "Deconstructing Wall..."
						playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 40))
							if(!useResource(5, user)) return 0
							activate()
							A:ChangeTurf(/turf/simulated/floor/plating)
							return 1
					return 0

				if(istype(A, /turf/simulated/floor))
					if(checkResource(5, user))
						user << "Deconstructing Floor..."
						playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(5, user)) return 0
							activate()
							A:ChangeTurf(/turf/space)
							return 1
					return 0

				if(istype(A, /obj/machinery/door/airlock))
					if(checkResource(10, user))
						user << "Deconstructing Airlock..."
						playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(10, user)) return 0
							activate()
							del(A)
							return 1
					return	0
				return 0
			else
				user << "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin."
				return 0

/obj/item/weapon/rcd/New(loc)
	..(loc)
	src.effect_system = new/datum/effect/effect/system/spark_spread()
	src.effect_system.set_up(5, 0, src)
	src.effect_system.attach(src)

/obj/item/weapon/rcd/examine()
	set src in oview(0)
	..()
	usr << text("It currently holds []/[] matter-units.", matter, max_matter)

/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user)
	..()

	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/rcd_ammo = W

		if((src.matter + rcd_ammo.matter) > src.max_matter)
			user << "<span class='notice'>[src] device cannot hold any more matter-units.</span>"
			return

		playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
		src.matter += rcd_ammo.matter
		user << "<span class='notice'>[src] now holds [src.matter]/[src.max_matter] matter-units.</span>"
		user.drop_item()
		qdel(rcd_ammo)

/obj/item/weapon/rcd/proc/useResource(var/amount, var/mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	return 1

/obj/item/weapon/rcd/proc/checkResource(var/amount, var/mob/user)
	return matter >= amount

/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * max_matter)

/obj/item/weapon/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * max_matter)

/obj/item/weapon/rcd/borg/New(loc)
	..(loc)
	canRwall = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	m_amt = 30000
	g_amt = 15000
	w_type = RECYK_ELECTRONIC

	var/matter = 10
