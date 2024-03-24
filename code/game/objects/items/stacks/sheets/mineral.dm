/*
Mineral Sheets
	Contains:
		- Sandstone
		- Brick
		- Diamond
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Clown
		- Plastic
	Others:
		- Adamantine
		- Mythril
		- Gingerbread
*/

/obj/item/stack/sheet/mineral
	w_type = RECYK_METAL

/*
 * Sandstone
 */
/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone bricks"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 4
	throw_range = 5
	origin_tech = Tc_MATERIALS + "=1"
	sheettype = "sandstone"
	melt_temperature = MELTPOINT_GLASS
	mat_type = MAT_GLASS
	perunit = CC_PER_SHEET_GLASS
	starting_materials = list(MAT_GLASS = CC_PER_SHEET_GLASS)

var/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/portable_atmospherics/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/machinery/door/mineral/sandstone, 10, one_per_turf = 1, on_floor = 1), \
/*	new/datum/stack_recipe("sandstone wall", ???), \
		new/datum/stack_recipe("sandstone floor", ???),\ */
	new/datum/stack_recipe("forge", /obj/structure/forge, 20, time = 10 SECONDS, one_per_turf = 1, on_floor = 1)
	)

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	recipes = sandstone_recipes
	..()

/*
 * Brick
 */
/obj/item/stack/sheet/mineral/brick
	name ="brick"
	singular_name = "brick"
	icon_state = "sheet-brick"
	force = 5.0
	throwforce = 5
	throw_range = 3
	throw_speed = 3
	w_class = W_CLASS_MEDIUM
	melt_temperature = 2473.15
	sheettype = "brick"
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL, MAT_GLASS = CC_PER_SHEET_GLASS)

var/list/datum/stack_recipe/brick_recipes = list ( \
	new/datum/stack_recipe("fireplace", /obj/machinery/space_heater/campfire/stove/fireplace, 15, time = 10 SECONDS, one_per_turf = 1, on_floor = 1)
	)

/obj/item/stack/sheet/mineral/brick/New(var/loc, var/amount=null)
	recipes = brick_recipes
	..()

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	singular_name = "diamond sheet"
	icon_state = "sheet-diamond"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=6"
	sheettype = "diamond"
	melt_temperature = 3820 // In a vacuum, but fuck dat
	perunit = CC_PER_SHEET_DIAMOND
	mat_type = MAT_DIAMOND
	starting_materials = list(MAT_DIAMOND = CC_PER_SHEET_DIAMOND)

var/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond floor tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20), \
	new/datum/stack_recipe("diamond door", /obj/machinery/door/mineral/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20, one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE)
	)

/obj/item/stack/sheet/mineral/diamond/New(var/loc, var/amount=null)
	recipes = diamond_recipes
	..()

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	singular_name = "uranium sheet"
	icon_state = "sheet-uranium"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	sheettype = "uranium"
	melt_temperature = 1132+T0C
	perunit = CC_PER_SHEET_URANIUM
	mat_type = MAT_URANIUM
	starting_materials = list(MAT_URANIUM = CC_PER_SHEET_URANIUM)

var/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium floor tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("uranium door", /obj/machinery/door/mineral/uranium, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20, one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	null,
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/uranium/New(var/loc, var/amount=null)
	recipes = uranium_recipes
	..()

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	singular_name = "plasma sheet"
	icon_state = "sheet-plasma"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_PLASMATECH + "=2;" + Tc_MATERIALS + "=2"
	sheettype = "plasma"
	melt_temperature = MELTPOINT_STEEL + 500
	perunit = CC_PER_SHEET_PLASMA
	mat_type = MAT_PLASMA
	starting_materials = list(MAT_PLASMA = CC_PER_SHEET_PLASMA)

var/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma floor tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("plasma door", /obj/machinery/door/mineral/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20, one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	null,
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/plasma/New(var/loc, var/amount=null)
	recipes = plasma_recipes

	..()

/obj/item/stack/sheet/mineral/plastic
	name = "plastic"
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=3"
	melt_temperature = MELTPOINT_PLASTIC
	autoignition_temperature = AUTOIGNITION_PLASTIC
	sheettype = "plastic"
	perunit = CC_PER_SHEET_PLASTIC
	mat_type = MAT_PLASTIC
	w_type = RECYK_PLASTIC
	starting_materials = list(MAT_PLASTIC = CC_PER_SHEET_PLASTIC)

var/list/datum/stack_recipe/plastic_recipes = list ( \
	new/datum/stack_recipe("plastic floor tile", /obj/item/stack/tile/mineral/plastic, 1, 4, 20), \
	new/datum/stack_recipe("plastic bucket", /obj/item/weapon/reagent_containers/glass/bucket, 3, time = 3 SECONDS, one_per_turf = 0, on_floor = 0), \
	new/datum/stack_recipe("plastic crate", /obj/structure/closet/pcrate, 10, one_per_turf = 1, on_floor = 1, one_per_turf = 1), \
	new/datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("lunch box", /obj/item/weapon/storage/lunchbox/plastic, 1, time = 2 SECONDS, one_per_turf = 0, on_floor = 0), \
	new/datum/stack_recipe("plastic fork", /obj/item/weapon/kitchen/utensil/fork/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spork", /obj/item/weapon/kitchen/utensil/spork/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spoon", /obj/item/weapon/kitchen/utensil/spoon/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic knife", /obj/item/weapon/kitchen/utensil/knife/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic bag", /obj/item/weapon/storage/bag/plasticbag, 3, on_floor = 1), \
	new/datum/stack_recipe("blood bag", /obj/item/weapon/reagent_containers/blood/empty, 3, on_floor = 1), \
	new/datum/stack_recipe("plastic coat", /obj/item/clothing/suit/raincoat, 5), \
	new/datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 10, one_per_turf = 1, on_floor = 1, start_unanchored = 1), \
	new/datum/stack_recipe("plastic chair", /obj/structure/bed/chair/plastic/plastic_chair, 3, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic table parts", /obj/item/weapon/table_parts/plastic, 5, on_floor = 1), \
	new/datum/stack_recipe("water-cooler", /obj/structure/reagent_dispensers/water_cooler, 4, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("warning cone", /obj/item/weapon/caution/cone, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe_list("curtains",list(
		new/datum/stack_recipe("white curtains", /obj/structure/curtain, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("black curtains", /obj/structure/curtain/black, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("medical curtains", /obj/structure/curtain/medical, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("bed curtains", /obj/structure/curtain/open/bed, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("privacy curtains", /obj/structure/curtain/open/privacy, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("shower curtains", /obj/structure/curtain/open/shower, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("engineering shower curtains", /obj/structure/curtain/open/shower/engineering, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("security shower curtains", /obj/structure/curtain/open/shower/security, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("medical shower curtains", /obj/structure/curtain/open/shower/medical, 4, one_per_turf = 1, on_floor = 1), \
		), 4),
	)

/obj/item/stack/sheet/mineral/plastic/New(var/loc, var/amount=null)
	recipes = plastic_recipes
	..()

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
	singular_name = "gold sheet"
	icon_state = "sheet-gold"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=4"
	melt_temperature = 1064+T0C
	sheettype = "gold"
	perunit = CC_PER_SHEET_GOLD
	mat_type = MAT_GOLD
	starting_materials = list(MAT_GOLD = CC_PER_SHEET_GOLD)

var/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden floor tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("alternate golden floor tile", /obj/item/stack/tile/mineral/gold/gold_old, 1, 4, 20), \
	new/datum/stack_recipe("golden door", /obj/machinery/door/mineral/gold, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("gold tooth", /obj/item/stack/teeth/gold, 1, 1, 20), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20,one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),\
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("chain", /obj/item/stack/chains, 2, 1, 20, 5, inherit_material = TRUE), \
	new/datum/stack_recipe("collection plate", /obj/item/weapon/storage/fancy/collection_plate, 2, 1, 1),
	null,
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/gold/New(var/loc, var/amount=null)
	recipes = gold_recipes
	..()

/*
 * Phazon
 */
var/list/datum/stack_recipe/phazon_recipes = list( \
	new/datum/stack_recipe("phazon floor tile", /obj/item/stack/tile/mineral/phazon, 1, 40, 20), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20,one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),\
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	null,
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/phazon
	name = "phazon"
	singular_name = "phazon sheet"
	desc = "Holy christ what is this?"
	icon_state = "sheet-phazon"
	item_state = "sheet-phazon"
	sheettype = "phazon"
	melt_temperature = MELTPOINT_PLASTIC
	throwforce = 15.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = Tc_MATERIALS + "=9"
	perunit = CC_PER_SHEET_PHAZON
	mat_type = MAT_PHAZON
	starting_materials = list(MAT_PHAZON = CC_PER_SHEET_PHAZON)

/obj/item/stack/sheet/mineral/phazon/New(var/loc, var/amount=null)
		recipes = phazon_recipes
		return ..()

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
	singular_name = "silver sheet"
	icon_state = "sheet-silver"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=3"
	sheettype = "silver"
	perunit = CC_PER_SHEET_SILVER
	mat_type = MAT_SILVER
	starting_materials = list(MAT_SILVER = CC_PER_SHEET_SILVER)

var/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver floor tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("alternate silver floor tile", /obj/item/stack/tile/mineral/silver/silver_old, 1, 4, 20), \
	new/datum/stack_recipe("silver door", /obj/machinery/door/mineral/silver, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20,one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),\
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("chain", /obj/item/stack/chains, 2, 1, 20, 5, inherit_material = TRUE),
	null,
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/silver/New(var/loc, var/amount=null)
	recipes = silver_recipes
	..()

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/clown
	name = "bananium"
	singular_name = "bananium sheet"
	icon_state = "sheet-clown"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=4"
	sheettype = "clown"
	perunit = CC_PER_SHEET_CLOWN
	mat_type = MAT_CLOWN
	starting_materials = list(MAT_CLOWN = CC_PER_SHEET_CLOWN)

var/list/datum/stack_recipe/clown_recipes = list ( \
	new/datum/stack_recipe("bananium floor tile", /obj/item/stack/tile/mineral/clown, 1, 40, 20), \
	new/datum/stack_recipe("clownnonball", /obj/item/cannonball/bananium, 20, time = 3 SECONDS, on_floor = 1), \
	new/datum/stack_recipe/dorf("dorf chair",/obj/structure/bed/chair, 20, one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE), \
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	12, time = 12,	on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	null,
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/clown/New(var/loc, var/amount=null)
	recipes = clown_recipes
	..()

/****************************** Others ****************************/
/*
 * Adamantine
 */
/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=4"
	perunit = 2000

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril shards"
	icon_state = "sheet-mythril"
	singular_name = "mythril shard"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=4"
	perunit = CC_PER_SHEET_MYTHRIL
	mat_type = MAT_MYTHRIL
	starting_materials = list(MAT_MYTHRIL = CC_PER_SHEET_MYTHRIL)

var/list/datum/stack_recipe/mythril_recipes = list ( \
	blacksmithing_recipes,
	)

/obj/item/stack/sheet/mineral/mythril/New(var/loc, var/amount=null)
	recipes = mythril_recipes
	..()


/obj/item/stack/sheet/mineral/pharosium
	name = "pharosium"
	icon_state = "sheet-pharosium"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_PHAROSIUM
	mat_type = MAT_PHAROSIUM
	starting_materials = list(MAT_PHAROSIUM = CC_PER_SHEET_PHAROSIUM)

/obj/item/stack/sheet/mineral/char
	name = "char"
	icon_state = "sheet-char"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_CHAR
	mat_type = MAT_CHAR
	starting_materials = list(MAT_CHAR = CC_PER_SHEET_CHAR)


/obj/item/stack/sheet/mineral/claretine
	name = "claretine"
	icon_state = "sheet-claretine"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_CLARETINE
	mat_type = MAT_CLARETINE
	starting_materials = list(MAT_CLARETINE = CC_PER_SHEET_CLARETINE)


/obj/item/stack/sheet/mineral/cobryl
	name = "cobryl"
	icon_state = "sheet-cobryl"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_COBRYL
	mat_type = MAT_COBRYL
	starting_materials = list(MAT_COBRYL = CC_PER_SHEET_COBRYL)


/obj/item/stack/sheet/mineral/bohrum
	name = "bohrum"
	icon_state = "sheet-bohrum"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_BOHRUM
	mat_type = MAT_BOHRUM
	starting_materials = list(MAT_BOHRUM = CC_PER_SHEET_BOHRUM)


/obj/item/stack/sheet/mineral/syreline
	name = "syreline"
	icon_state = "sheet-syreline"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_SYRELINE
	mat_type = MAT_SYRELINE
	starting_materials = list(MAT_SYRELINE = CC_PER_SHEET_SYRELINE)


/obj/item/stack/sheet/mineral/erebite
	name = "erebite"
	icon_state = "sheet-erebite"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_EREBITE
	mat_type = MAT_EREBITE
	starting_materials = list(MAT_EREBITE = CC_PER_SHEET_EREBITE)


/obj/item/stack/sheet/mineral/cerenkite
	name = "cerenkite"
	icon_state = "sheet-cerenkite"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_CERENKITE
	mat_type = MAT_CERENKITE
	starting_materials = list(MAT_CERENKITE = CC_PER_SHEET_CERENKITE)


/obj/item/stack/sheet/mineral/cytine
	name = "cytine"
	icon_state = "sheet-cytine"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_CYTINE
	mat_type = MAT_CYTINE
	starting_materials = list(MAT_CYTINE = CC_PER_SHEET_CYTINE)


/obj/item/stack/sheet/mineral/uqill
	name = "uqill"
	icon_state = "sheet-uqill"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_UQILL
	mat_type = MAT_UQILL
	starting_materials = list(MAT_UQILL = CC_PER_SHEET_UQILL)


/obj/item/stack/sheet/mineral/telecrystal
	name = "telecrystal"
	icon_state = "sheet-telecrystal"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_TELECRYSTAL
	mat_type = MAT_TELECRYSTAL
	starting_materials = list(MAT_TELECRYSTAL = CC_PER_SHEET_TELECRYSTAL)

/obj/item/stack/sheet/mineral/mauxite
	name = "mauxite"
	icon_state = "sheet-mauxite"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_MAUXITE
	mat_type = MAT_MAUXITE
	starting_materials = list(MAT_MAUXITE = CC_PER_SHEET_MAUXITE)


/obj/item/stack/sheet/mineral/molitz
	name = "molitz"
	icon_state = "sheet-molitz"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_MOLITZ
	mat_type = MAT_MOLITZ
	starting_materials = list(MAT_MOLITZ = CC_PER_SHEET_MOLITZ)

/obj/item/stack/sheet/mineral/gingerbread
	name = "gingerbread"
	icon_state = "sheet-gingerbread"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=5"
	perunit = CC_PER_SHEET_GINGERBREAD
	mat_type = MAT_GINGERBREAD
	starting_materials = list(MAT_GINGERBREAD = CC_PER_SHEET_GINGERBREAD)

var/list/datum/stack_recipe/gingerbread_recipes = list ( \
	new/datum/stack_recipe("gingerbread floor tile", /obj/item/stack/tile/mineral/gingerbread, 1, 4, 20), \
	new/datum/stack_recipe("wall mounted peppermint red",/obj/structure/bigpeppermint_red, 5, time = 10, on_floor = 1),\
	new/datum/stack_recipe("wall mounted peppermint green", /obj/structure/bigpeppermint_green,	5, time = 10,	on_floor = 1),\
	new/datum/stack_recipe("gingerbread wall", /turf/simulated/wall/mineral/gingerbread, 6, time = 40, one_per_turf = 1, on_floor = 1),\
	new/datum/stack_recipe("gingerbread door", /obj/machinery/door/mineral/gingerbread, 5, time = 30, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("gingerbread false wall", /obj/structure/falsewall/gingerbread, 6, time = 40, one_per_turf = 1, on_floor = 1),\
		)

/obj/item/stack/sheet/mineral/gingerbread/New(var/loc, var/amount=null)
	recipes = gingerbread_recipes
	..()
