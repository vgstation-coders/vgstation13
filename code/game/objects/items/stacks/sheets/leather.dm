/obj/item/stack/sheet/animalhide
	icon = 'icons/obj/butchering_products.dmi'
	var/source_string

/obj/item/stack/sheet/animalhide/can_stack_with(var/obj/item/other_stack)
	if(istype(other_stack, /obj/item/stack/sheet/animalhide))
		var/obj/item/stack/sheet/animalhide/other = other_stack
		if(other.source_string != source_string)
			return 0
		return 1
	return ..()

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of humanoid farming."
	singular_name = "human skin piece"
	icon_state = "sheet-human"
	source_string = "human"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"
	source_string = "corgi"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"
	source_string = "cat"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"
	source_string = "monkey"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"
	source_string = "lizard"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"
	source_string = "alien"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/deer
	name = "deer hide"
	desc = "The skin of a deer."
	singular_name = "deer hide piece"
	icon_state = "sheet-deer"
	source_string = "deer"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/gondola
	name = "gondola skin"
	desc = "It's all quiet now."
	singular_name = "gondola skin piece"
	icon_state = "sheet-gondola"
	source_string = "gondola"
	origin_tech = ""

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "chitin"
	origin_tech = ""

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "claw"
	origin_tech = ""

/obj/item/xenos_claw/attackby(obj/item/W, mob/user)
	.=..()

	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W

		if(C.use(5))
			user.drop_item(src, force_drop = 1)

			var/obj/item/clothing/mask/necklace/xeno_claw/X = new(get_turf(src))
			user.put_in_active_hand(X)
			to_chat(user, "<span class='info'>You create a necklace out of \the [src] and \the [C].</span>")

			qdel(src)
		else
			to_chat(user, "<span class='info'>You need at least 5 lengths of cable to do this!</span>")

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"
	origin_tech = ""

/obj/item/deer_head
	name = "deer head"
	desc = "Not something you want to find in your bed in the morning."
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "deer-head"
	origin_tech = ""

/obj/item/deer_head/attackby(obj/item/W, mob/user)
	.=..()

	if(W.sharpness_flags & SHARP_BLADE)
		user.visible_message("<span class='notice'>[user] finishes butchering \the [src].</span>", \
		"<span class='notice'>You slice the antlers off \the [src].</span>", drugged_message = "<span class='notice'>[user] gives \the [src] a nice haircut.</span>")
		new /obj/item/antlers(get_turf(src))
		new /obj/effect/gibspawner/generic(get_turf(src))
		qdel(src)

/obj/item/antlers
	name = "deer antlers"
	desc = "A bit horny."
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "antlers"

/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of it's hair, but still needs tanning."
	singular_name = "hairless hide piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "sheet-hairlesshide"
	var/source_string
	origin_tech = ""

/obj/item/stack/sheet/hairlesshide/can_stack_with(var/obj/item/other_stack)
	if(istype(other_stack, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/other = other_stack
		if(other.source_string != source_string)
			return 0
		return 1
	return ..()

/obj/item/stack/sheet/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "sheet-wetleather"
	var/source_string
	origin_tech = ""
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = T0C + 40

/obj/item/stack/sheet/wetleather/can_stack_with(var/obj/item/other_stack)
	if(istype(other_stack, /obj/item/stack/sheet/wetleather))
		var/obj/item/stack/sheet/wetleather/other = other_stack
		if(other.source_string != source_string)
			return 0
		return 1
	return ..()

/obj/item/stack/sheet/wetleather/New()
	..()
	processing_objects.Add(src)

/obj/item/stack/sheet/wetleather/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "sheet-leather"
	var/source_string
	origin_tech = Tc_MATERIALS + "=2"

/obj/item/stack/sheet/leather/can_stack_with(var/obj/item/other_stack)
	if(istype(other_stack, /obj/item/stack/sheet/leather))
		var/obj/item/stack/sheet/leather/other = other_stack
		if(other.source_string != source_string)
			return 0
		return 1
	return ..()

/obj/item/stack/sheet/leather/New(var/loc, var/amount=null)
	recipes = leather_recipes
	return ..()



//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_sharp() >= 1.2 && W.sharpness_flags & SHARP_BLADE)

		//visible message on mobs is defined as visible_message(var/message, var/self_message, var/blind_message)
		user.visible_message("<span class='notice'>\the [usr] starts cutting hair off \the [src]</span>", "<span class='notice'>You start cutting the hair off \the [src]</span>", "You hear the sound of a knife rubbing against flesh")

		spawn()
			if(do_after(user, src, 50))
				to_chat(user, "<span class='notice'>You cut the hair from this [src.singular_name]</span>")

				if(src.use(1))
					var/obj/item/stack/sheet/hairlesshide/H = drop_stack(/obj/item/stack/sheet/hairlesshide, user.loc, 1, user)
					H.source_string = source_string
					H.name = source_string ? "hairless [source_string] hide" : "hairless hide"
		return 1
	else
		..()


//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/sheet/wetleather/process()
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/datum/gas_mixture/environment = location.return_air()
	if(environment.temperature >= drying_threshold_temperature)
		wetness--
		if(wetness <= 0)
			if(amount)
				var/obj/item/stack/sheet/leather/L = drop_stack(/obj/item/stack/sheet/leather, loc, amount)
				L.source_string = source_string
				L.name = source_string ? "[source_string] leather": "leather"
				use(amount)


/obj/item/stack/leather_strip
	name = "strip of leather"
	desc = "For more precise leather work."
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "strip-leather"
	singular_name = "strip of leather"
	irregular_plural = "strips of leather"
	max_amount = 20