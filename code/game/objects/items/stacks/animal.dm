//"animal" stacks are actually things like bones and teeth, which are harvested from animals

/obj/item/stack/animal
	icon = 'icons/obj/butchering_products.dmi'

	var/animal_type

/obj/item/stack/animal/New(loc, amount)
	.=..()
	pixel_x = rand(-24,24)
	pixel_y = rand(-24,24)

/obj/item/stack/animal/can_stack_with(obj/item/other_stack)
	if(src.type == other_stack.type)
		var/obj/item/stack/animal/T = other_stack
		if(src.animal_type == T.animal_type)
			return 1
	return 0

/obj/item/stack/animal/copy_evidences(obj/item/stack/from as obj)
	.=..()
	if(istype(from, /obj/item/stack/animal))
		var/obj/item/stack/animal/original = from
		src.animal_type = original.animal_type
		src.name = original.name
		src.singular_name = original.singular_name

/obj/item/stack/animal/proc/update_name(mob/parent)
	if(!parent) return

	if(isliving(parent))
		var/mob/living/L = parent
		var/mob/parent_species = L.species_type
		var/parent_species_name = initial(parent_species.name)

		if(ishuman(parent))
			parent_species_name = "[parent]'s" //Like "Dick Johnson's"

		name = "[parent_species_name] [initial(name)]"
		singular_name = "[parent_species_name] [initial(singular_name)]"
		animal_type = parent_species
