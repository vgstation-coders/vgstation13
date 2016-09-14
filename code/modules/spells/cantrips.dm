//cantrips: cheap fun spells

//summon food: creates bread or a common fruit at target location
/spell/aoe_turf/conjure/summon_food
	name = "Feed The Multitude"
	desc = "Creates a loaf of bread or a common fruit at the targeted location."

	price = 0.2 * Sp_BASE_PRICE //1 point

	spell_flags = WAIT_FOR_CLICK
	school = "conjuration"
	charge_max = 20 SECONDS
	cooldown_min = 5 SECONDS

	invocation = "Pascenium!"
	invocation_type = SpI_WHISPER
	range = 7

	summon_type = list(
	/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread,
	/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread,
	/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread,
	/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread,
	/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread,
	/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/berries,
	/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
	/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
	/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
	/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
	/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	)

	hud_state = "food"

//spark: summon sparks. that's it
/spell/sparks
	name = "Spark"
	desc = "Dubbed by many wizards as the Poor Man's Lightning, this spell summons 5 harmless sparks."

	price = 0.2 * Sp_BASE_PRICE //1 point

	school = "conjuration"
	charge_max = 10 SECONDS
	cooldown_min = 2 SECONDS

	invocation = "Ignaz!"
	invocation_type = SpI_WHISPER

/spell/sparks/before_cast(list/targets, user)
	return targets

/spell/sparks/choose_targets(mob/user)
	return list(user)

/spell/sparks/cast(list/targets, mob/user)
	..()

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, user)
	s.start()

//light: summon a light. light may be colored (right click to change the color)
/spell/aoe_turf/light
	name = "Lighting"
	desc = "Create a light at the chosen location. The light lasts for 30 seconds."

	school = "divination"

	price = 0.4 * Sp_BASE_PRICE //2 points
	charge_max = 30 SECONDS
	cooldown_min = 5 SECONDS

	invocation = "Lumos!"
	invocation_type = SpI_WHISPER

	spell_flags = WAIT_FOR_CLICK
	range = 7

	duration = 30 SECONDS
	hud_state = "wiz_light"
	var/light_range = 6
	var/light_power = 2
	var/light_color = "#FFFFFF"

/spell/aoe_turf/light/on_learn(mob/user)
	..()
	to_chat(user, "<span class='info'><strong>Middle-click on the spell icon to set the spell's color.</strong></span>")

/spell/aoe_turf/light/cast(list/targets, mob/user)
	var/turf/T = locate(/turf) in targets

	if(!istype(T))
		return

	var/obj/effect/light/L = new /obj/effect/light(T)
	process_light_effect(L)

	spawn(duration)
		qdel(L)

/spell/aoe_turf/light/on_right_click(mob/user)
	spawn()
		var/new_color = input(user, "Select the spell's color.", "Lighting", light_color) as color

		if(connected_button)

			//Update overlay colors
			for(var/image/I in connected_button.overlays)
				connected_button.overlays.Remove(I)
				I.color = new_color
				connected_button.overlays.Add(I)

		light_color = new_color

	return TRUE

/spell/aoe_turf/light/proc/process_light_effect(obj/effect/light/L)
	L.light_color = src.light_color
	L.set_light(light_range, light_power)
	return

/obj/effect/light
	anchored = TRUE
	invisibility = 101

//