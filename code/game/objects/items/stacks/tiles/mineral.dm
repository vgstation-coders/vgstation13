/obj/item/stack/tile/mineral

/obj/item/stack/tile/mineral/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "A tile made out of highly flammable plasma. This can only end well."
	icon_state = "tile_plasma"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "plasma"
	starting_materials = list(MAT_PLASMA = CC_PER_SHEET_PLASMA / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "A tile made out of uranium. You feel a bit woozy."
	icon_state = "tile_uranium"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "uranium"
	starting_materials = list(MAT_URANIUM = CC_PER_SHEET_URANIUM / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/uranium/safe
	name = "isolated uranium tile"
	singular_name = "isolated uranium floor tile"
	desc = "A tile made out of uranium, with an added layer of reinforced glass on top of it."
	icon_state = "tile_uraniumsafe"

	material = "uranium_safe"
	starting_materials = list(// Recipe requires 1 uranium sheet per 4 tiles, and 1 reinforced glass sheet per tile
		MAT_URANIUM = CC_PER_SHEET_URANIUM / 4,
		MAT_GLASS = CC_PER_SHEET_GLASS,
		MAT_METAL = CC_PER_SHEET_METAL / 2)
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/uranium/safe/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You pry off the layer of reinforced glass from [src].")

		if(use(1))
			drop_stack(/obj/item/stack/tile/mineral/uranium, user.loc, 1, user)
		return

/obj/item/stack/tile/mineral/uranium/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/sheet/glass/rglass))
		var/obj/item/stack/sheet/glass/rglass/G = W
		to_chat(user, "You add a layer of reinforced glass to [src].")
		G.use(1)
		src.use(1)

		drop_stack(/obj/item/stack/tile/mineral/uranium/safe, user.loc, 1, user)
		return

/obj/item/stack/tile/mineral/gold
	name = "gold tile"
	singular_name = "gold floor tile"
	desc = "A tile made out of gold, the swag seems strong here."
	icon_state = "tile_gold"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "gold"
	starting_materials = list(MAT_GOLD = CC_PER_SHEET_GOLD / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/silver
	name = "silver tile"
	singular_name = "silver floor tile"
	desc = "A tile made out of silver, the light shining from it is blinding."
	icon_state = "tile_silver"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "silver"
	starting_materials = list(MAT_SILVER = CC_PER_SHEET_SILVER / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/diamond
	name = "diamond tile"
	singular_name = "diamond floor tile"
	desc = "A tile made out of diamond. Wow, just, wow."
	icon_state = "tile_diamond"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "diamond"
	starting_materials = list(MAT_DIAMOND = CC_PER_SHEET_DIAMOND / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/clown
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "A tile made out of bananium, HOOOOOOOOONK!"
	icon_state = "tile_clown"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "bananium"
	starting_materials = list(MAT_CLOWN = CC_PER_SHEET_CLOWN / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL
	var/spam_flag = 0

/obj/item/stack/tile/mineral/plastic
	name = "plastic tile"
	singular_name = "plastic floor tile"
	desc = "A tile made of tiny plastic blocks."
	icon_state = "tile_plastic"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	starting_materials = list(MAT_PLASTIC = CC_PER_SHEET_PLASTIC / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_PLASTIC
	autoignition_temperature = AUTOIGNITION_PLASTIC

	material = "plastic"

/obj/item/stack/tile/mineral/phazon
	name = "phazon tile"
	singular_name = "phazon floor tile"
	desc = "A floor tile made out of phazon. It's very light and brittle."
	icon_state = "tile_phazon"
	w_class = W_CLASS_TINY
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	max_amount = 60
	origin_tech = Tc_MATERIALS + "=9"

	material = "phazon"
	starting_materials = list(MAT_PHAZON = CC_PER_SHEET_PHAZON / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/phazon/adjust_slowdown(mob/living/L, current_slowdown)
	current_slowdown *= 0.75
	return ..()

/obj/item/stack/tile/mineral/brass
	name = "brass tile"
	singular_name = "brass floor tile"
	desc = "A floor tile made out of brass. Shiny."
	icon_state = "tile_brass"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material = "brass"
	starting_materials = list(MAT_BRASS = CC_PER_SHEET_BRASS / 4) // Recipe requires 1 sheet for 4 tiles
	w_type = RECYK_METAL

/obj/item/stack/tile/mineral/gingerbread
	name = "gingerbread tile"
	singular_name ="gingerbread floor tile"
	desc = "gingerbread architecture is more complicated than just baking some cookies and sticking them together. There are other processes involved."
	icon_state = "tile-gingerbread"
	w_class = W_CLASS_MEDIUM
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60

	material  = "gingerbread"
	autoignition_temperature = AUTOIGNITION_ORGANIC


