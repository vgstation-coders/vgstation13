// Vox feathers stack item
#define PIXEL_MULTIPLIER 1

/obj/item/stack/feather
	name = "feathers"
	singular_name = "feather"
	irregular_plural = "feathers"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "feather-single"
	amount = 1
	max_amount = 50
	w_class = W_CLASS_TINY
	w_type = RECYK_BIOLOGICAL
	throw_speed = 4
	throw_range = 10
	flammable = TRUE

	var/animal_type
	var/feather_color = null // Hexcode for feather color
	var/feather_color_name = null // Name of the feather color

/obj/item/stack/feather/update_icon()
	if(amount > 1)
		icon_state = "feather-stack"
		pixel_x = 0
		pixel_y = 0
	else
		icon_state = "feather-single"
		// Keep random offset for single feathers
		if(isnull(pixel_x) || isnull(pixel_y) || pixel_x == 0 && pixel_y == 0)
			pixel_x = rand(-8,8) * PIXEL_MULTIPLIER
			pixel_y = rand(-8,8) * PIXEL_MULTIPLIER
	if(feather_color)
		color = feather_color

/obj/item/stack/feather/New(loc, amount, color, color_name)
	. = ..()
	recipes = feather_recipes // Allow feather crafting from feather stacks
	pixel_x = rand(-8,8) * PIXEL_MULTIPLIER
	pixel_y = rand(-8,8) * PIXEL_MULTIPLIER
	if(color)
		feather_color = color
		color = feather_color // Set icon color
	if(color_name)
		feather_color_name = color_name
		name = "[feather_color_name] vox feathers"
		singular_name = "[feather_color_name] vox feather"
	update_icon()

/obj/item/stack/feather/can_stack_with(obj/item/other_stack)
	if(!istype(other_stack))
		return 0

	if(src.type == other_stack.type)
		var/obj/item/stack/feather/F = other_stack
		if(src.animal_type == F.animal_type && src.feather_color == F.feather_color && src.feather_color_name == F.feather_color_name)
			return 1
	return 0

/obj/item/stack/feather/proc/update_name(mob/parent)
	if(!parent)
		return

	if(isliving(parent))
		var/mob/living/L = parent
		var/mob/parent_species = L.species_type
		var/parent_species_name = initial(parent_species.name)

		if(ishuman(parent))
			var/mob/living/carbon/human/H = parent
			if(H.species)
				parent_species_name = lowertext(H.species.name)
			else
				parent_species_name = "human"
			if(parent_species_name == "vox")
				parent_species_name = "vox"

		name = "[parent_species_name] feathers"
		singular_name = "[parent_species_name] feather"
		animal_type = parent_species

/obj/item/stack/feather/proc/set_feather_color(hexcode)
	feather_color = hexcode
	color = feather_color
	update_icon()

/obj/item/stack/feather/proc/set_feather_color_name(name)
	feather_color_name = name
	if(feather_color_name)
		name = "[feather_color_name] vox feathers"
		singular_name = "[feather_color_name] vox feather"
	update_icon()

/obj/item/stack/feather/proc/add_amount(n)
	amount += n
	update_icon()

