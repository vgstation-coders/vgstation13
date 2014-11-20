/datum/smelting_recipe
	var/name=""
	var/list/ingredients=list() // phazon=1, iron=1
	var/yieldtype=null

// Note: Returns -1 if not enough ore!
/datum/smelting_recipe/proc/checkIngredients(var/datum/materials/materials, var/list/selected, var/multiplier=1)
	var/sufficient_ore=1
	var/matching_ingredient_count=0
	for(var/ore_id in materials.storage)
		var/datum/material/po=materials.getMaterial(ore_id)
		var/required=(ore_id in ingredients)
		var/is_selected=(ore_id in selected)

		// Selected but not in ingredients
		if(is_selected && !required)
			return 0

		// Unselected but in ingredients
		if(!is_selected && required)
			return 0

		var/min_ore_required=ingredients[ore_id] * multiplier

		// Selected, in ingredients, but not enough in stock.
		if(is_selected && required)
			if(po.stored < min_ore_required)
				sufficient_ore=0
				continue

			matching_ingredient_count++

	if(!sufficient_ore)
		return -1 // -1 means not enough ore. NOT A TYPO.

	return matching_ingredient_count == ingredients.len

/**
 * Get the maximum number of batches possible, given the available materials.
 * @return num
 */
/datum/smelting_recipe/proc/getMaxBatches(var/datum/materials/materials, var/maxbatches=50)
	var/batches=maxbatches
	for(var/ore_id in ingredients)
		var/datum/material/po=materials.getMaterial(ore_id)

		batches = min(batches, round(po.stored/ingredients[ore_id]))

	return batches

/**
 * Actually smelt the raw materials into product.
 * @param output Where to plop the product.
 * @param materials Materials to use.
 * @param batches Number of batches to make.
 */
/datum/smelting_recipe/proc/smelt(var/turf/output, var/datum/materials/materials, var/batches=1)
	// Take ingredients
	for(var/ore_id in ingredients)
		materials.removeAmount(ore_id, ingredients[ore_id] * batches)

	// Spawn yield
	var/obj/item/stack/sheet/S = new yieldtype(output)
	S.amount=batches

/////////////////////////////////
// RECIPES BEEP BOOP
/////////////////////////////////

/datum/smelting_recipe/glass
	name="Glass"
	ingredients=list(
		"glass"=1
	)
	yieldtype=/obj/item/stack/sheet/glass

/datum/smelting_recipe/rglass
	name="Reinforced Glass"
	ingredients=list(
		"glass"=1,
		"iron"=1
	)
	yieldtype=/obj/item/stack/sheet/rglass

/datum/smelting_recipe/gold
	name="Gold"
	ingredients=list(
		"gold"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/gold

/datum/smelting_recipe/silver
	name="Silver"
	ingredients=list(
		"silver"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/silver

/datum/smelting_recipe/diamond
	name="Diamond"
	ingredients=list(
		"diamond"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/diamond

/datum/smelting_recipe/plasma
	name="Plasma"
	ingredients=list(
		"plasma"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/plasma

/datum/smelting_recipe/uranium
	name="Uranium"
	ingredients=list(
		"uranium"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/uranium

/datum/smelting_recipe/metal
	name="Metal"
	ingredients=list(
		"iron"=1
	)
	yieldtype=/obj/item/stack/sheet/metal

/datum/smelting_recipe/plasteel
	name="Plasteel"
	ingredients=list(
		"iron"=1,
		"plasma"=1
	)
	yieldtype=/obj/item/stack/sheet/plasteel

/datum/smelting_recipe/clown
	name="Bananium"
	ingredients=list(
		"clown"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/clown

/datum/smelting_recipe/plasma_glass
	name="Plasma Glass"
	ingredients=list(
		"plasma"=1,
		"glass"=1
	)
	yieldtype=/obj/item/stack/sheet/glass/plasmaglass

/datum/smelting_recipe/plasma_rglass
	name="Reinforced Plasma Glass"
	ingredients=list(
		"plasma"=1,
		"glass"=1,
		"iron"=1
	)
	yieldtype=/obj/item/stack/sheet/glass/plasmarglass

/datum/smelting_recipe/phazon
	name="phazon"
	ingredients=list(
		"phazon"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/phazon

/datum/smelting_recipe/plastic
	name="plastic"
	ingredients=list(
		"plastic"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/plastic

/datum/smelting_recipe/pharosium
	name="pharosium"
	ingredients=list(
		"pharosium"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/pharosium

/datum/smelting_recipe/char
	name="char"
	ingredients=list(
		"char"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/char

/datum/smelting_recipe/claretine
	name="claretine"
	ingredients=list(
		"claretine"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/claretine

/datum/smelting_recipe/bohrum
	name="bohrum"
	ingredients=list(
		"bohrum"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/bohrum

/datum/smelting_recipe/syreline
	name="syreline"
	ingredients=list(
		"syreline"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/syreline

/datum/smelting_recipe/erebite
	name="erebite"
	ingredients=list(
		"erebite"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/erebite

/datum/smelting_recipe/cytine
	name="cytine"
	ingredients=list(
		"cytine"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/cytine

/datum/smelting_recipe/telecrystal
	name="telecrystal"
	ingredients=list(
		"telecrystal"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/telecrystal

/datum/smelting_recipe/mauxite
	name="mauxite"
	ingredients=list(
		"mauxite"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/mauxite

/datum/smelting_recipe/cobryl
	name="cobryl"
	ingredients=list(
		"cobryl"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/cobryl

/datum/smelting_recipe/cerenkite
	name="cerenkite"
	ingredients=list(
		"cerenkite"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/cerenkite

/datum/smelting_recipe/molitz
	name="molitz"
	ingredients=list(
		"molitz"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/molitz

/datum/smelting_recipe/uqill
	name="uqill"
	ingredients=list(
		"uqill"=1
	)
	yieldtype=/obj/item/stack/sheet/mineral/uqill
