/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap."
	gender = PLURAL
	icon = 'icons/obj/soap.dmi'
	icon_state = "soap"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	var/remaining = 100

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap."
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap."
	icon_state = "soapsyndie"

/obj/item/weapon/soap/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(3)
		M.Weaken(2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob)
	if(user.client && (target in user.client.screen))
		user << "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user << "<span class='notice'>You scrub \the [target.name] out.</span>"
		use(user)
		del(target)
	else if(istype(target,/turf/simulated))
		var/turf/simulated/T = target
		var/list/cleanables = list()
		for(var/obj/effect/decal/cleanable/CC in T)
			if(!istype(CC) || !CC)
				continue
			cleanables += CC
		if(!cleanables.len)
			user << "<span class='notice'>You fail to clean anything.</span>"
			return
		cleanables = shuffle(cleanables)
		var/obj/effect/decal/cleanable/C
		for(var/obj/effect/decal/cleanable/d in cleanables)
			if(d && istype(d))
				C = d
				break
		user << "<span class='notice'>You scrub \the [C.name] out.</span>"
		use(user)
		del(C)
	else
		user << "<span class='notice'>You clean \the [target.name].</span>"
		use(user)
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("\red \the [user] washes \the [target]'s mouth out with soap!")
		use(user)
		return
	..()

/obj/item/weapon/soap/proc/use(mob/user)
	remaining = remaining - max(0, rand(2, 6))
	update_icon()
	if(remaining <= 0)
		user << "<span class='notice'>You have used up the soap.</span>"
		user.drop_item()
		del(src)

/obj/item/weapon/soap/update_icon()
	if(remaining <= 33)
		icon_state = "[initial(icon_state)]33"
		return
	if(remaining <= 66 )
		icon_state = "[initial(icon_state)]66"
		return

/obj/item/weapon/soap/examine()
	set src in view(1)
	..()
	if(remaining != 100)
		usr <<"<span class='notice'>It is [remaining]% of its original size.</span>"