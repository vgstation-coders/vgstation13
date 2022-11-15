/obj/item/weapon/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter pre-programmed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = W_CLASS_SMALL

	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_ENGINEERING + "=1"

	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

	var/obj/item/device/toner/ink = null

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/weapon/airlock_painter/proc/use(mob/user as mob)
	if(can_use(user))
		ink.charges--
		playsound(src, 'sound/effects/spray2.ogg', 50, 1)
		return 1
	else
		return 0

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/weapon/airlock_painter/proc/can_use(mob/user as mob)
	if(!ink)
		to_chat(user, "<span class='notice'>There is no toner cardridge installed installed in \the [name]!</span>")
		return 0
	else if(ink.charges < 1)
		to_chat(user, "<span class='notice'>\The [name] is out of ink!</span>")
		return 0
	else
		return 1

/obj/item/weapon/airlock_painter/examine(mob/user)
	..()
	if(!ink)
		to_chat(user, "<span class='info'>It doesn't have a toner cardridge installed.</span>")
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	to_chat(user, "<span class='info'>Its ink levels look [ink_level].</span>")

/obj/item/weapon/airlock_painter/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/device/toner))
		if(ink)
			to_chat(user, "<span class='notice'>\the [name] already contains \a [ink].</span>")
			return
		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You install \the [W] into \the [name].</span>")
			ink = W
			playsound(src, 'sound/machines/click.ogg', 50, 1)

/obj/item/weapon/airlock_painter/attack_self(mob/user)
	if(ink)
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		ink.forceMove(user.loc)
		user.put_in_hands(ink)
		to_chat(user, "<span class='notice'>You remove \the [ink] from \the [name].</span>")
		ink = null

/obj/item/weapon/airlock_painter/New()
	. = ..()
	ink = new /obj/item/device/toner(src)
