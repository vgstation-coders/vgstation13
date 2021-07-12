/datum/smelting_recipe
	var/name= ""
	var/list/ingredients[0]
	var/yieldtype = null

// Note: Returns -1 if not enough ore!
/datum/smelting_recipe/proc/checkIngredients(var/datum/materials/ore)
	for(var/ore_id in ore.storage)
		var/min_ore_required = ingredients[ore_id]

		if(ore.getAmount(ore_id) < min_ore_required)
			return 0

	. = 1

// RECIPES BEEP BOOP
/datum/smelting_recipe/glass
	name = "Glass"
	ingredients=list(
		MAT_GLASS = CC_PER_SHEET_GLASS
	)
	yieldtype = /obj/item/stack/sheet/glass/glass


/datum/smelting_recipe/rglass
	name = "Reinforced Glass"
	ingredients=list(
		MAT_GLASS = CC_PER_SHEET_GLASS,
		MAT_IRON = CC_PER_SHEET_METAL/2
	)
	yieldtype = /obj/item/stack/sheet/glass/rglass

/datum/smelting_recipe/gold
	name = "Gold"
	ingredients=list(
		MAT_GOLD = CC_PER_SHEET_GOLD
	)
	yieldtype = /obj/item/stack/sheet/mineral/gold

/datum/smelting_recipe/silver
	name = "Silver"
	ingredients=list(
		MAT_SILVER = CC_PER_SHEET_SILVER
	)
	yieldtype = /obj/item/stack/sheet/mineral/silver

/datum/smelting_recipe/diamond
	name = "Diamond"
	ingredients=list(
		MAT_DIAMOND = CC_PER_SHEET_DIAMOND
	)
	yieldtype = /obj/item/stack/sheet/mineral/diamond

/datum/smelting_recipe/plasma
	name = "Plasma"
	ingredients=list(
		MAT_PLASMA = CC_PER_SHEET_PLASMA
	)
	yieldtype = /obj/item/stack/sheet/mineral/plasma

/datum/smelting_recipe/uranium
	name = "Uranium"
	ingredients=list(
		MAT_URANIUM = CC_PER_SHEET_URANIUM
	)
	yieldtype = /obj/item/stack/sheet/mineral/uranium

/datum/smelting_recipe/metal
	name = "Metal"
	ingredients=list(
		MAT_IRON = CC_PER_SHEET_METAL
	)
	yieldtype = /obj/item/stack/sheet/metal

/datum/smelting_recipe/plasteel
	name = "Plasteel"
	ingredients=list(
		MAT_IRON = CC_PER_SHEET_METAL,
		MAT_PLASMA = CC_PER_SHEET_PLASMA
	)
	yieldtype = /obj/item/stack/sheet/plasteel

/datum/smelting_recipe/brick
	name = "Brick"
	ingredients=list(
		MAT_IRON = CC_PER_SHEET_METAL,
		MAT_GLASS = CC_PER_SHEET_GLASS
	)
	yieldtype = /obj/item/stack/sheet/mineral/brick

/datum/smelting_recipe/clown
	name = "Bananium"
	ingredients=list(
		MAT_CLOWN = CC_PER_SHEET_CLOWN
	)
	yieldtype = /obj/item/stack/sheet/mineral/clown

/datum/smelting_recipe/plasma_glass
	name = "Plasma Glass"
	ingredients=list(
		MAT_PLASMA = CC_PER_SHEET_PLASMA,
		MAT_GLASS = CC_PER_SHEET_GLASS
	)
	yieldtype = /obj/item/stack/sheet/glass/plasmaglass

/datum/smelting_recipe/plasma_rglass
	name="Reinforced Plasma Glass"
	ingredients=list(
		MAT_PLASMA = CC_PER_SHEET_PLASMA,
		MAT_GLASS = CC_PER_SHEET_GLASS,
		MAT_IRON = CC_PER_SHEET_METAL/2
	)
	yieldtype=/obj/item/stack/sheet/glass/plasmarglass

/datum/smelting_recipe/phazon
	name = "phazon"
	ingredients=list(
		MAT_PHAZON = CC_PER_SHEET_PHAZON
	)
	yieldtype = /obj/item/stack/sheet/mineral/phazon

/datum/smelting_recipe/plastic
	name = "Plastic"
	ingredients=list(
		MAT_PLASTIC = CC_PER_SHEET_PLASTIC
	)
	yieldtype = /obj/item/stack/sheet/mineral/plastic

/datum/smelting_recipe/cardboard
	name = "Cardboard"
	ingredients=list(
		MAT_CARDBOARD = CC_PER_SHEET_CARDBOARD
	)
	yieldtype = /obj/item/stack/sheet/cardboard

/datum/smelting_recipe/mythril
	name = "Mythril"
	ingredients=list(
		MAT_MYTHRIL = CC_PER_SHEET_MYTHRIL
	)
	yieldtype = /obj/item/stack/sheet/mineral/mythril

/datum/smelting_recipe/telecrystal
	name="Telecrystal"
	ingredients=list(
		MAT_TELECRYSTAL = CC_PER_SHEET_TELECRYSTAL
	)
	yieldtype=/obj/item/bluespace_crystal
