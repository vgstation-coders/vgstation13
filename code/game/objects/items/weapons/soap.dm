
/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = W_CLASS_TINY
	siemens_coefficient = 0 //no conduct
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | NO_ATTACK_MSG

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/nanotrasen/planned_obsolescence
	desc = "A cheap Nanotrasen brand bar of soap. Smells of planned obsolescence."
	icon_state = "soapnt"
	var/max_uses = 20

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of condoms."
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/weapon/soap/holo
	name = "UV sterilizer"
	desc = "This shouldn't exist."

/obj/item/weapon/soap/proc/on_successful_use(var/mob/user)
	return

/obj/item/weapon/soap/nanotrasen/planned_obsolescence/on_successful_use(var/mob/user)
	max_uses--
	if (max_uses <= 0 && prob(10 + (-max_uses * 5)))
		if (user)
			to_chat(user,"<span class='warning'>The bar of soap disintegrates between your fingers as you scrub the last of it.</span>")
		else
			visible_message("<span class='warning'>The bar of soap disintegrates.</span>")
		qdel(src)


/obj/item/weapon/soap/Crossed(var/atom/movable/AM)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(3, 2, 1))
			M.simple_message("<span class='notice'>You slipped on the [name]!</span>",
				"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")
			on_successful_use()

/obj/item/weapon/soap/afterattack(var/atom/target, var/mob/user)
	if(!user.Adjacent(target))
		return

	if(user.client && (target in user.client.screen) && !(user.is_holding_item(target)))
		user.simple_message("<span class='notice'>You need to take that [target.name] off before cleaning it.</span>",
			"<span class='notice'>You need to take that [target.name] off before destroying it.</span>")

	else if(istype(target,/obj/effect/decal/cleanable))
		user.simple_message("<span class='notice'>You scrub \the [target.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		qdel(target)
		on_successful_use(user)

	else if(istype(target,/turf/simulated))
		var/turf/simulated/T = target
		var/list/cleanables = list()

		for(var/obj/effect/decal/cleanable/CC in T)
			if(!istype(CC) || !CC)
				continue
			cleanables += CC

		for(var/obj/effect/decal/cleanable/CC in get_turf(user)) //Get all nearby decals drawn on this wall and erase them
			if(CC.on_wall == target)
				cleanables += CC

		if(!cleanables.len)
			user.simple_message("<span class='notice'>You fail to clean anything.</span>",
				"<span class='notice'>There is nothing for you to vandalize.</span>")
			return
		cleanables = shuffle(cleanables)
		var/obj/effect/decal/cleanable/C
		for(var/obj/effect/decal/cleanable/d in cleanables)
			if(d && istype(d))
				C = d
				break
		user.simple_message("<span class='notice'>You scrub \the [C.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		qdel(C)
		on_successful_use(user)
	else
		user.simple_message("<span class='notice'>You clean \the [target.name].</span>",
			"<span class='warning'>You [pick("deface","ruin","stain")] \the [target.name].</span>")
		target.clean_blood()
		on_successful_use(user)

/obj/item/weapon/soap/attack(var/mob/target, var/mob/user)
	if(target && user && ishuman(target) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()
