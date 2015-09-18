/obj/item/skull
	name = "skull"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "skull"

	var/broken = 0
	var/animal_type

/obj/item/skull/New()
	..()
	pixel_x = rand(-12,12)
	pixel_y = rand(-12,12)

/obj/item/skull/attackby(obj/item/O, mob/living/user)
	if(broken)
		user << "<span class='notice'>This skull is too broken to work with.</span>"
	if(istype(O, /obj/item/weapon/chisel))
		user.visible_message("<span class='info'>[user] starts carving into \the [src].</span>", "<span class='info'>You start carving \the [src] into a helmet.</span>")

		if(!do_after(user, src, 150) || ((M_CLUMSY in user.mutations) && prob(65))) //15 seconds to finish. If clumsy, 65% chance to fuck up
			user << "<span class='notice'>ACK! Your hand slips and \the [src] cracks.</span>"
			broken = 1
			update_icon()
			return

		if(ishuman(src.loc))
			var/mob/living/L = src.loc
			L.drop_item(src)

		user.visible_message("<span class='info'>[user] finishes carving \the [src] into a helmet.</span>", "<span class='info'>You create a helmet out of \the [src].</span>")
		var/obj/item/clothing/head/helmet/skull/S = new(get_turf(src))
		S.name = "[src.name] helmet" //"corgi skull helmet", or "dick johnson's skull helmet"
		qdel(src)

/obj/item/skull/update_icon()
	..()

	if(broken)
		icon_state = "skull_broken"
	else
		icon_state = "skull"

/obj/item/skull/proc/update_name(mob/parent)
	if(!parent) return

	if(isliving(parent))
		var/mob/living/L = parent
		var/mob/parent_species = L.species_type
		var/parent_species_name = initial(parent_species.name)

		if(ishuman(parent))
			parent_species_name = "[parent]'s" //Like "Dick Johnson's"

		name = "[parent_species_name] [initial(name)]"
		animal_type = parent_species
