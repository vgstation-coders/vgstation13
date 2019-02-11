//Totally not copypasted from its machinery version stop asking so many questions
#define PORTOSMELTER_MINIMUM_POWER_REQUIRED 100
#define PORTOSMELTER_POWER_DRAIN rand(50,100)

/obj/item/weapon/storage/bag/ore/furnace
	name = "portable ore processor"
	icon_state = "portsmelter"
	actions_types = list(/datum/action/item_action/toggle_furnace)
	var/datum/materials/ore
	var/list/recipes[0]
	var/on = FALSE
	var/sheets_per_tick = 100

/datum/action/item_action/toggle_furnace
	name = "Toggle Ore Furnace"

/datum/action/item_action/toggle_furnace/Trigger()
	var/obj/item/weapon/storage/bag/ore/furnace/F = target

	if(!istype(F) || !owner)
		return

	F.smelt_contents(owner)

/obj/item/weapon/storage/bag/ore/furnace/New()
	. = ..()
	ore = new
	for(var/recipe in subtypesof(/datum/smelting_recipe))
		recipes += new recipe
	update_icon()

/obj/item/weapon/storage/bag/ore/furnace/update_icon()
	icon_state = "portsmelter[on ? "2":"[contents.len ? "1" : "0"]"]" //Furnace on = portsmelter2 | Furnace loaded = portsmelter1 | Furnace empty = portsmelter0

/obj/item/weapon/storage/bag/ore/furnace/proc/smelt_contents(var/mob/user)
	var/sheets_this_tick = 0
	var/obj/item/weapon/cell/user_cell = null

	if(user)
		user_cell = user.get_cell() //Connected directly to the user's power source
		if(!user_cell)
			to_chat(user, "<span class='warning'>\The [name] can't be used without a compatible power source!</span>")
			return

	if(contents.len)
		on = TRUE
		update_icon()

		for(var/obj/item/I in contents)
			sheets_this_tick++

			if(sheets_this_tick >= sheets_per_tick)
				break

			if(user_cell.charge <= PORTOSMELTER_MINIMUM_POWER_REQUIRED)
				to_chat(user, "<span class='warning'>Not enough power available in \the [user_cell]!</span>")
				break

			if(!istype(I, /obj/item/stack/ore)) //Check if it's an ore
				I.forceMove(get_turf(loc))
				continue

			var/obj/item/stack/ore/O = I
			if(!O.material)
				continue

			ore.addAmount(O.material, O.amount)//1 per ore

			var/datum/material/mat = ore.getMaterial(O.material)
			if(!mat)
				continue

			qdel(O)
			user_cell.charge = max(user_cell.charge - PORTOSMELTER_POWER_DRAIN, 0)
			sleep(1) //Small delay between each ore so the animation plays and your immulshions don't get ruined.

		for(var/datum/smelting_recipe/R in recipes)
			while(R.checkIngredients(src)) //While we have materials for this
				for(var/ore_id in R.ingredients)
					ore.removeAmount(ore_id, 1)
					score["oremined"] += 1 //Count this ore piece as processed for the scoreboard

				getFromPool(R.yieldtype, get_turf(loc))
				sheets_this_tick++

				if(sheets_this_tick >= sheets_per_tick)
					break

			if(sheets_this_tick >= sheets_per_tick) //Second one is so it cancels the for loop when the while loop gets broken.
				break

		on = FALSE
		update_icon()
