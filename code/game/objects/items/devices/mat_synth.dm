/**
 * Matter Reconstitutor
 *
 * Basically, a mobile recycler.
 */

/obj/item/device/material_synth
	name = "matter reconstitutor"
	desc = "A device capable of recycling debris and trash into valuable raw materials."
	icon = 'icons/obj/device.dmi'
	//icon_state = "mat_synthoff"
	icon_state = "mat_synthon"

	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 3.0
	origin_tech = "engineering=4;materials=5;power=3"

	var/emagged = 0

	var/datum/smelting_recipe/active_recipe = null

	var/datum/materials/materials
	var/datum/smelting_manager/smelter

	// material => CC per tick.
	var/list/material_regen = list()

	// How much volume this has (in CC)
	var/max_volume = CC_PER_SHEET_METAL * 50

	var/const/CHARGE_DEPLETION_MULTIPLIER = 50

	var/const/MAT_COST_COMMON = 1
	var/const/MAT_COST_MEDIUM = 5
	var/const/MAT_COST_RARE   = 15

	var/list/available_recipes=list()

/obj/item/device/material_synth/cyborg
	material_regen = list(
		"metal" = CC_PER_SHEET_METAL / 2, // One sheet every two ticks
		"glass" = CC_PER_SHEET_GLASS / 2, // One sheet every two ticks
	)

	max_volume = CC_PER_SHEET_METAL * 30

/obj/item/device/material_synth/New()
	..()

	// Get ticks from MC.
	processing_objects.Add(src)

	// Initialize materials.
	materials = new (max_volume)

	// Load up recipes.
	smelter = new (materials)

/obj/item/device/material_synth/Destroy()
	// Stop ticking us.
	processing_objects.Remove(src)
	..()

/obj/item/device/material_synth/process()
	if(material_regen.len == 0)
		return PROCESS_KILL // Stop processing

	// Regenerate materials.
	var/changed=0
	for(var/mat_id in material_regen)
		var/amount = material_regen[mat_id]
		var/c_amount = materials.getAmount(mat_id)
		if(c_amount >= 10 * CC_PER_SHEET_METAL)
			continue
		if(materials.addAmount(mat_id, amount))
			changed=1
	if(changed)
		recalc_recipes()

/obj/item/device/material_synth/examine()
	..()

	var/list/bits=list()
	for(var/mat_id in materials.storage)
		var/datum/material/mat=materials.getMaterial(mat_id)
		if(mat.stored > 0)
			bits.Add("[mat.stored/mat.cc_per_sheet]U of [mat.processed_name]")

	if(bits.len>0)
		usr << "<span class=\"info\">It contains:</span>"
		for(var/line in bits)
			usr << "<span class=\"info\">  [line]</span>"
	else
		usr << "<span class=\"warning\">It's empty.</span>"

/obj/item/device/material_synth/update_icon()
	//icon_state = "mat_synth[mode ? "on" : "off"]"

/obj/item/device/material_synth/proc/recalc_recipes()
	// Recalculate available recipes.
	available_recipes = smelter.getAvailableRecipes()

/obj/item/device/material_synth/afterattack(var/obj/target, var/mob/user)
	if(!in_range(target,user))
		return
	if(loc != user)
		return
	if(!isrobot(user) && !ishuman(user))
		return 0
	//message_admins("This fired with [target.type]")
	var/datum/materials/recykMats=new
	if(istype(target) && target.recycle(recykMats))
		if(do_after(user, 10))
			materials.removeFrom(recykMats)
			if(recykMats.getVolume()>0)
				user << "<span class='warning'>The matter recycling beam melts \the [target], but fails to completely consume it.  Maybe it's full?</span>"
				var/obj/effect/decal/slag/slag = new (target.loc)
				slag.mats=recykMats
				slag.melt()
			else
				user << "<span class='info'>\The [src] fires a beam at \the [target], disintegrating it and then sucking it into the device's matter storage bin.</span>"
			qdel(target)
			user << "[available_recipes.len] recipes available."
			recalc_recipes()
			return 1
	else
		user << "<span class='warning'>The matter recycling beam is scattered by \the [target].</span>"
	return ..()

/obj/item/device/material_synth/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/weapon/card/emag))
		if(!emagged)
			emagged = 1
			var/matter_rng = rand(5, 25)
			if(materials.getAmount("iron") >= matter_rng)
				var/obj/item/device/spawn_item = pick(typesof(/obj/item/device) - /obj/item/device) //we make any kind of device. It's a surprise!
				user.visible_message("<span class='rose'>\The [src] in [user]'s hands appears to be trying to synthesize... \a [initial(spawn_item.name)]?</span>",
									 "You hear a loud popping noise.")
				user <<"<span class='warning'>\The [src] pops and fizzles in your hands, before creating... \a [initial(spawn_item.name)]?</span>"
				sleep(10)
				new spawn_item(get_turf(src))
				materials.removeAmount("iron",matter_rng)
				return 1
			else
				user<<"<span class='danger'>The lack of matter in \the [src] shorts out the device!</span>"
				explosion(src.loc, 0,0,1,2) //traitors - fuck them, am I right?
				qdel(src)
		else
			user<<"You don't think you can do that again..."
			return
	return ..()

/obj/item/device/material_synth/proc/getModifier()
	var/obj/item/stack/sheet/S = active_recipe.yieldtype
	if(initial(S.perunit) < 3750)
		return MAT_COST_MEDIUM
	if(initial(S.perunit) < 2000)
		return MAT_COST_RARE
	return MAT_COST_COMMON

/obj/item/device/material_synth/attack_self(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/r_user = user
		if(!r_user.cell || !r_user.cell.charge)
			// no cell, no service
			return
	if(available_recipes.len)
		var/recipe_name = input("Select the material you'd like to synthesize", "Change Material Type") in available_recipes|null
		if(!recipe_name)
			return
		var/datum/smelting_recipe/recipe=available_recipes[recipe_name]
		active_recipe = recipe
		user << "<span class='notice'>You configure \the [src] to synthesize [recipe.name].</span>"

		var/max_batches = active_recipe.getMaxBatches(materials)
		var/amount = Clamp(round(input("How many sheets of [recipe.name] do you want to synthesize? (0 - [max_batches])") as num), 0, max_batches)
		if(amount==0)
			return

		// TODO: Determine if this is even necessary, given that it's going to be a PITA enough to get the materials.
		if(isrobot(user))
			var/mob/living/silicon/robot/r_user = user
			if(!r_user.cell.use(amount*getModifier()*CHARGE_DEPLETION_MULTIPLIER))
				user <<"<span class='warning'>You can't make that much [recipe.name] without shutting down!</span>"
				return

		active_recipe.smelt(get_turf(src), materials, amount)