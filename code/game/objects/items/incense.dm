/* Incense stuff
 * Contains:
 *		stick of incense
 *		box of incense
 *		incense oil container
 * 		thurible
 */

/obj/item/incense_stick
	name = "stick of incense"
	desc = "Made of an aromatic material that releases fragrant smoke when burned. Usually soothing."
	icon = 'icons/obj/incense.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/incense.dmi', "right_hand" = 'icons/mob/in-hand/right/incense.dmi')
	icon_state = "incensestick"
	item_state = "incensestick"
	w_class = W_CLASS_TINY
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	light_color = LIGHT_COLOR_FIRE
	siemens_coefficient = 0
	vending_cat = "incense material"

	var/list/unlit_attack_verb = list("prods", "pokes")
	var/list/lit_attack_verb = list("burns", "singes")

	var/combustible = 1200
	var/maxCombustible = 1200
	var/lit = FALSE
	var/flammable = TRUE

	var/fragrance = null
	var/adjective = null
	var/list/breathed_at_least_once = list()

/obj/item/incense_stick/New()
	..()
	create_reagents(1)

/obj/item/incense_stick/harebells
	fragrance = INCENSE_HAREBELLS
	adjective = "holy"
	color = "#ffffff"

/obj/item/incense_stick/poppies
	fragrance = INCENSE_POPPIES
	adjective = "calming"
	color = "#660000"

/obj/item/incense_stick/sunflowers
	fragrance = INCENSE_SUNFLOWERS
	adjective = "pleasant"
	color = "#ffff99"

/obj/item/incense_stick/moonflowers
	fragrance = INCENSE_MOONFLOWERS
	adjective = "disturbing"
	color = "#6f20b5"

/obj/item/incense_stick/novaflowers
	fragrance = INCENSE_NOVAFLOWERS
	adjective = "stimulating"
	color = "#ffa500"

/obj/item/incense_stick/banana
	fragrance = INCENSE_BANANA
	adjective = "slippery"
	color = "#ffff00"

/obj/item/incense_stick/cabbage
	fragrance = INCENSE_LEAFY
	adjective = "fresh"
	color = "#33cc33"

/obj/item/incense_stick/booze
	fragrance = INCENSE_BOOZE
	adjective = "alcoholic"
	color = "#b35900"

/obj/item/incense_stick/vapor
	fragrance = INCENSE_VAPOR
	adjective = "clean"
	color = "#3399ff"

/obj/item/incense_stick/dense
	fragrance = INCENSE_DENSE
	adjective = "foul"
	color = "#333333"

/obj/item/incense_stick/vale
	fragrance = INCENSE_CRAVE
	adjective = "craving-inducing"
	color = "#ffccff"

/obj/item/incense_stick/cornoil
	fragrance = INCENSE_CORNOIL
	adjective = "hunger-inducing"
	color = "#361b11"

/obj/item/incense_stick/examine(mob/user)
	..()
	to_chat(user, "\The [src] is [lit ? "":"un"]lit.")
	to_chat(user,"<span class='info'>This one [adjective ? "smells [adjective]" : "is unscented"].</span>")

/obj/item/incense_stick/attack_self(var/mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] carefully puts out the ember on \the [name].</span>")
		exting()

/obj/item/incense_stick/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(lit)
		return
	burn()

/obj/item/incense_stick/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/incense_stick/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(lit)
		to_chat(user, "<span class='warning'>\The [src] is already lit.</span>")
		return
	else if (!flammable)
		to_chat(user,"<span class='warning'>The incense was recently put out, you must wait a few seconds before lighting it up again.</span>")
		return
	else if(W.is_hot() || W.sharpness_flags & (HOT_EDGE))
		user.visible_message("<span class='notice'>\The [user] lights \a [name] with \the [W].</span>")
		burn()

/obj/item/incense_stick/afterattack(var/obj/reagentholder, var/mob/user)
	..()
	if(reagentholder.is_open_container() && !ismob(reagentholder) && reagentholder.reagents)
		if(reagentholder.reagents.has_reagent(WATER) && lit)
			to_chat(user, "<span class='warning'>\The [src] fizzles as you dip it into \the [reagentholder].</span>")
			exting()
			return
		else
			if(!reagentholder.reagents.total_volume)
				to_chat(user, "<span class='warning'>\The [reagentholder] is empty.</span>")
				return

/obj/item/incense_stick/proc/exting()
	lit = FALSE
	damtype = BRUTE
	breathed_at_least_once.Cut()
	attack_verb = unlit_attack_verb
	update_icon()
	kill_light()
	if (istype(loc,/obj/item/weapon/thurible))
		var/obj/item/weapon/thurible/T = loc
		T.update_icon()

/obj/item/incense_stick/proc/burn()
	if (!flammable)
		return
	flammable = FALSE
	lit = TRUE
	damtype = BURN
	attack_verb = lit_attack_verb
	update_icon()
	set_light(1)
	if (istype(loc,/obj/item/weapon/thurible))
		var/obj/item/weapon/thurible/T = loc
		T.update_icon()
	while (!gcDestroyed && loc && lit)
		if (istype(loc,/obj/item/weapon/thurible))
			combustible -= 3
		else
			combustible -= 5
		var/turf/simulated/location = get_turf(src)

		//are we on a turf? or held by a mob that's on a turf? or in a thurible (that's on the ground or held by a mob?)
		if (istype(location) && (isturf(loc) || (ismob(loc) && isturf(loc.loc)) || (istype(loc,/obj/item/weapon/thurible) && (isturf(loc.loc) || (ismob(loc.loc) && isturf(loc.loc.loc))))))//I'm sorry
			if (location)
				location.hotspot_expose(source_temperature, 5, surfaces = istype(loc, /turf))
				anim(target = location, a_icon = 'icons/effects/160x160.dmi', flick_anim = "incense", offX = -WORLD_ICON_SIZE*2+pixel_x, offY = -WORLD_ICON_SIZE*2+pixel_y)
				if (location.zone)//is there a simulated atmosphere where we are?

					var/list/potential_breathers = list()
					for(var/turf/simulated/T in location.zone.contents)//are they in that same atmospheric zone?
						for (var/mob/living/C in T)
							if(!iscarbon(C) && !isanimal(C))
								continue
							if (get_dist(location, C) <= 7)//are they relatively close?
								if (!ishuman(C))
									potential_breathers += C
								else
									var/mob/living/carbon/human/H = C
									if(H.species && H.species.flags & NO_BREATHE)//can they breath?
										continue
									if(H.wear_mask && H.wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
										continue
									if(H.glasses && H.glasses.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
										continue
									if(H.head && H.head.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
										continue
									if(H.internal)//are their internals off?
										continue
									potential_breathers += C

					var/datum/reagent/incense/D = chemical_reagents_list[fragrance]
					if(D)
						D.OnDisperse(location)
					for (var/mob/living/C in potential_breathers)
						reagents.clear_reagents()
						reagents.add_reagent(fragrance,0.5) //Create a new fragrance inside, then move it to the target.
						reagents.trans_to(C,0.5)
						if (!(C in breathed_at_least_once))
							breathed_at_least_once += C
							to_chat(C,"\A [adjective] fragrance fills the air.[((fragrance == INCENSE_HAREBELLS)&&(iscultist(C)||isvampire(C))) ? "..<span class='danger'>and gives you a splitting headache!</span>" : ""]")

		update_icon()
		if (combustible <= 0)
			exting()
			new /obj/effect/decal/cleanable/ash(location)
			if (istype(loc,/obj/item/weapon/thurible))
				var/obj/item/weapon/thurible/T = loc
				T.incense = null
			qdel(src)
			return
		sleep(50)
	flammable = TRUE

/obj/item/incense_stick/update_icon()
	var/length = round((maxCombustible - combustible) / 260)
	if (lit)
		icon_state = "incensestick_[length]_lit"
		item_state = "incensestick_lit"
	else
		icon_state = "incensestick_[length]"
		item_state = "incensestick"

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/incense_stick/proc/set_fragrance(var/newfrag)
	if(fragrance == newfrag)
		return FALSE
	fragrance = newfrag
	for(var/path in typesof(/obj/item/incense_stick))
		var/obj/item/incense_stick/IS = new path
		if(fragrance == IS.fragrance)
			adjective = IS.adjective
			color = IS.color
	return TRUE


/obj/item/weapon/storage/fancy/incensebox
	name = "box of incense"
	desc = "A wooden box used to store aromatic incense sticks."
	icon = 'icons/obj/incense.dmi'
	icon_state = "incensebox"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/incense.dmi', "right_hand" = 'icons/mob/in-hand/right/incense.dmi')
	item_state = "incensebox"
	icon_type = "incense"
	plural_type = ""
	descriptive_type = "stick of "
	plural_descriptive_type = "sticks of "
	storage_slots = 14
	can_only_hold = list("/obj/item/incense_stick")
	foldable = /obj/item/stack/sheet/wood
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_MISC)
	w_type=RECYK_WOOD
	siemens_coefficient = 0
	vending_cat = "incense material"
	var/fragrance = null

/obj/item/weapon/storage/fancy/incensebox/fire_act(var/datum/gas_mixture/air, var/exposed_temperature, var/exposed_volume)
	for (var/obj/item/incense_stick/S in contents)
		if(S.lit)
			return
		S.burn()//mwahaha

/obj/item/weapon/storage/fancy/incensebox/update_icon()
	if (contents.len > 0)
		icon_state = "incensebox_[min(4,1+round(contents.len / 4))]"
	else
		icon_state = "incensebox_0"

/obj/item/weapon/storage/fancy/incensebox/empty
	empty = 1
	icon_state = "incensebox_0"

/obj/item/weapon/storage/fancy/incensebox/harebells
	fragrance = INCENSE_HAREBELLS

/obj/item/weapon/storage/fancy/incensebox/poppies
	fragrance = INCENSE_POPPIES

/obj/item/weapon/storage/fancy/incensebox/sunflowers
	fragrance = INCENSE_SUNFLOWERS

/obj/item/weapon/storage/fancy/incensebox/moonflowers
	fragrance = INCENSE_MOONFLOWERS

/obj/item/weapon/storage/fancy/incensebox/novaflowers
	fragrance = INCENSE_NOVAFLOWERS

/obj/item/weapon/storage/fancy/incensebox/banana
	fragrance = INCENSE_BANANA

/obj/item/weapon/storage/fancy/incensebox/leafy
	fragrance = INCENSE_LEAFY

/obj/item/weapon/storage/fancy/incensebox/booze
	fragrance = INCENSE_BOOZE

/obj/item/weapon/storage/fancy/incensebox/vapor
	fragrance = INCENSE_VAPOR

/obj/item/weapon/storage/fancy/incensebox/dense
	fragrance = INCENSE_DENSE

/obj/item/weapon/storage/fancy/incensebox/vale
	fragrance = INCENSE_CRAVE

/obj/item/weapon/storage/fancy/incensebox/cornoil
	fragrance = INCENSE_CORNOIL


/obj/item/weapon/storage/fancy/incensebox/New()
	..()
	if (empty)
		return
	if(fragrance)
		for(var/i=1; i <= storage_slots; i++)
			var/obj/item/incense_stick/IS = new(src)
			IS.set_fragrance(fragrance)

/obj/item/weapon/storage/fancy/incensebox/variety/New()
	..()
	new /obj/item/incense_stick/harebells(src)
	new /obj/item/incense_stick/poppies(src)
	new /obj/item/incense_stick/sunflowers(src)
	new /obj/item/incense_stick/novaflowers(src)
	new /obj/item/incense_stick/moonflowers(src)
	new /obj/item/incense_stick/dense(src)
	new /obj/item/incense_stick/vapor(src)
	new /obj/item/incense_stick/booze(src)
	new /obj/item/incense_stick/banana(src)
	new /obj/item/incense_stick/cabbage(src)
	new /obj/item/incense_stick/vale(src)
	new /obj/item/incense_stick/cornoil(src)

/obj/item/incense_oilbox
	name = "incense oil container"
	desc = "Filled with a blend of aromatic flowers, allows the initiate to alter the composition of incense sticks. Other flowers may be blended in this box to replace the fragrance."
	icon = 'icons/obj/incense.dmi'
	icon_state = "incenseoilbox"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/incense.dmi', "right_hand" = 'icons/mob/in-hand/right/incense.dmi')
	item_state = "incenseoilbox"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	force = 2.5
	flags = FPRINT
	vending_cat = "incense material"
	var/fragrance = null
	var/adjective = null

/obj/item/incense_oilbox/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>It [adjective ? "smells [adjective]" : "is unscented"].</span>")

/obj/item/incense_oilbox/harebells
	fragrance = INCENSE_HAREBELLS
	adjective = "holy"

/obj/item/incense_oilbox/poppies
	fragrance = INCENSE_POPPIES
	adjective = "calming"

/obj/item/incense_oilbox/sunflowers
	fragrance = INCENSE_SUNFLOWERS
	adjective = "pleasant"

/obj/item/incense_oilbox/moonflowers
	fragrance = INCENSE_MOONFLOWERS
	adjective = "disturbing"

/obj/item/incense_oilbox/novaflowers
	fragrance = INCENSE_NOVAFLOWERS
	adjective = "stimulating"

/obj/item/incense_oilbox/banana
	fragrance = INCENSE_BANANA
	adjective = "slippery"

/obj/item/incense_oilbox/cabbage
	fragrance = INCENSE_LEAFY
	adjective = "fresh"

/obj/item/incense_oilbox/booze
	fragrance = INCENSE_BOOZE
	adjective = "alcoholic"

/obj/item/incense_oilbox/vapor
	fragrance = INCENSE_VAPOR
	adjective = "clean"

/obj/item/incense_oilbox/dense
	fragrance = INCENSE_DENSE
	adjective = "foul"

/obj/item/incense_oilbox/vale
	fragrance = INCENSE_CRAVE
	adjective = "craving-inducing"

/obj/item/incense_oilbox/cornoil
	fragrance = INCENSE_CORNOIL
	adjective = "hunger-inducing"

/obj/item/incense_oilbox/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype (W, /obj/item/incense_stick))
		if(!fragrance)
			to_chat(user, "<span class='warning'>A floral product must be blended inside first!</span>")
			return
		var/obj/item/incense_stick/S = W
		if(S.set_fragrance(fragrance))
			to_chat(user, "<span class='notice'>You dip the stick in the container, carefully applying the [adjective] oils on it.</span>")
		return
	if (istype (W,/obj/item/weapon/reagent_containers/food/snacks/grown) || istype(W,/obj/item/weapon/grown))
		if(W:fragrance) //for both types this is null by default, so it's "safe" to use the trusted operator
			user.drop_item(W, force_drop = 1)
			qdel(W)
			fragrance = W:fragrance
			for(var/path in typesof(/obj/item/incense_oilbox))
				var/obj/item/incense_oilbox/IO = new path
				if(fragrance == IO.fragrance)
					adjective = IO.adjective
					break
			to_chat(user, "<span class='notice'>The oils in the box are now blended with \the [W]... it smells [adjective]!</span>")
			return
	..()


/obj/item/weapon/thurible
	name = "thurible"
	desc = "A silver vessel made for burning incense, suspended by chains. Used by some chaplains during worship service."
	icon = 'icons/obj/incense.dmi'
	icon_state = "thurible"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/incense.dmi', "right_hand" = 'icons/mob/in-hand/right/incense.dmi')
	item_state = "thurible"
	hitsound = 'sound/weapons/toolbox.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	//slot_flags = SLOT_BELT once I get assed to do the belt sprites
	damtype = BRUTE
	force = 10
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	attack_verb = list("bashes", "batters")
	vending_cat = "incense material"
	var/obj/item/incense_stick/incense = null


/obj/item/weapon/thurible/Destroy()
	if (incense)
		qdel(incense)
		incense = null
	..()

/obj/item/weapon/thurible/examine(mob/user)
	..()
	if(incense && incense.lit)
		to_chat(user,"<span class='info'>A [incense.adjective] fragrance wafts from within!</span>")

/obj/item/weapon/thurible/update_icon()
	if (incense && incense.lit)
		icon_state = "thurible_lit"
		item_state = "thurible_lit"
		damtype = BURN
	else
		icon_state = "thurible"
		item_state = "thurible"
		damtype = BRUTE

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/weapon/thurible/attack(var/mob/M, var/mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/role/vampire/V = isvampire(H)
		if(V)
			if(locate(/datum/power/vampire/mature) in V.current_powers)
				V.smitecounter += 30 //Smithe the shit out of him. Four strikes and he's out

	if(istype(M,/mob/living/simple_animal))
		var/mob/living/simple_animal/SA = M
		if (SA.mob_property_flags & MOB_UNDEAD)
			force = 50
	. = ..()
	force = 10

/obj/item/weapon/thurible/pickup(var/mob/living/user)
	if(user.mind)
		if(ishuman(user))
			var/datum/role/vampire/V = isvampire(user)
			if(V && !(locate(/datum/power/vampire/undying) in V.current_powers))
				V.smitecounter += 60
				to_chat(user, "<span class='danger'>\The [src] sears your hand!</span>")

/obj/item/weapon/thurible/attack_self(var/mob/user)
	if(incense)
		if (incense.lit)
			incense.exting()
			user.visible_message("<span class='notice'>[user] carefully puts out the ember on \the [incense] after removing it from \the [src].</span>")
			user.put_in_hands(incense)
			incense = null
		else if (!incense.flammable)
			to_chat(user,"<span class='warning'>The incense was recently put out, you must wait a few seconds before lighting it up again.</span>")
			return
		else
			to_chat(user,"<span class='warning'>You flick the built-in lighter, and the small flame lights up \the [incense].</span>")
			incense.burn()
	else
		to_chat(user,"<span class='warning'>Put some incense in there first.</span>")

/obj/item/weapon/thurible/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype (W, /obj/item/incense_stick))
		if (incense)
			to_chat(user,"<span class='warning'>There's already some incense in there.</span>")
			return
		user.drop_item(W, force_drop = 1)
		W.forceMove(src)
		incense = W
		update_icon()
		return

	if(incense && (W.is_hot() || W.sharpness_flags & (HOT_EDGE)))
		user.visible_message("<span class='notice'>\The [user] lights \the [incense] inside \the [src] with \the [W].</span>")
		incense.burn()
		update_icon()
		return
	..()
