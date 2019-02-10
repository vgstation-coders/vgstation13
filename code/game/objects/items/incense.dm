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

	var/fragrance = INCENSE_HAREBELLS
	var/adjective = "holy"
	var/list/breathed_at_least_once = list()

/obj/item/incense_stick/harebells
	fragrance = INCENSE_HAREBELLS
	adjective = "holy"

/obj/item/incense_stick/poppies
	fragrance = INCENSE_POPPIES
	adjective = "calming"

/obj/item/incense_stick/sunflowers
	fragrance = INCENSE_SUNFLOWERS
	adjective = "pleasant"

/obj/item/incense_stick/moonflowers
	fragrance = INCENSE_MOONFLOWERS
	adjective = "disturbing"

/obj/item/incense_stick/novaflowers
	fragrance = INCENSE_NOVAFLOWERS
	adjective = "stimulating"

/obj/item/incense_stick/examine(mob/user)

	..()
	to_chat(user, "\The [src] is [lit ? "":"un"]lit.")

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
	update_icon()
	set_light(0)
	if (istype(loc,/obj/item/weapon/thurible))
		var/obj/item/weapon/thurible/T = loc
		T.update_icon()

/obj/item/incense_stick/proc/burn()
	if (!flammable)
		return
	flammable = FALSE
	lit = TRUE
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
						for (var/mob/living/carbon/C in T.contents)
							if (get_dist(location, C) <= 7)//are they relatively close?
								if (!ishuman(C))
									potential_breathers |= C
								else
									var/mob/living/carbon/human/H = C
									if(H.species && H.species.flags & NO_BREATHE)//can they breath?
										continue
									if(H.internal)//are their internals off?
										continue
									potential_breathers |= C

					for (var/mob/living/carbon/C in potential_breathers)
						C.reagents.add_reagent(fragrance,0.5)
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
		damtype = BURN
		attack_verb = lit_attack_verb
	else
		icon_state = "incensestick_[length]"
		item_state = "incensestick"
		damtype = BRUTE
		attack_verb = unlit_attack_verb

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()



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

/obj/item/weapon/storage/fancy/incensebox/harebells/New()
	..()
	for(var/obj/item/incense_stick/S in contents)
		S.fragrance = INCENSE_HAREBELLS

/obj/item/weapon/storage/fancy/incensebox/poppies/New()
	..()
	for(var/obj/item/incense_stick/S in contents)
		S.fragrance = INCENSE_POPPIES

/obj/item/weapon/storage/fancy/incensebox/sunflowers/New()
	..()
	for(var/obj/item/incense_stick/S in contents)
		S.fragrance = INCENSE_SUNFLOWERS

/obj/item/weapon/storage/fancy/incensebox/moonflowers/New()
	..()
	for(var/obj/item/incense_stick/S in contents)
		S.fragrance = INCENSE_MOONFLOWERS

/obj/item/weapon/storage/fancy/incensebox/novaflowers/New()
	..()
	for(var/obj/item/incense_stick/S in contents)
		S.fragrance = INCENSE_NOVAFLOWERS

/obj/item/weapon/storage/fancy/incensebox/New()
	..()
	if (empty)
		return
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/incense_stick(src)


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
	var/fragrance = INCENSE_HAREBELLS

/obj/item/incense_oilbox/harebells
	fragrance = INCENSE_HAREBELLS

/obj/item/incense_oilbox/poppies
	fragrance = INCENSE_POPPIES

/obj/item/incense_oilbox/sunflowers
	fragrance = INCENSE_SUNFLOWERS

/obj/item/incense_oilbox/moonflowers
	fragrance = INCENSE_MOONFLOWERS

/obj/item/incense_oilbox/novaflowers
	fragrance = INCENSE_NOVAFLOWERS

/obj/item/incense_oilbox/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype (W, /obj/item/incense_stick))
		var/obj/item/incense_stick/S = W
		S.fragrance = fragrance
		to_chat(user, "<span class='notice'>You dip the stick in the container, carefully applying the oils on it.</span>")
		return
	if (istype (W,/obj/item/weapon/reagent_containers/food/snacks/grown/harebell))
		user.drop_item(W, force_drop = 1)
		qdel(W)
		fragrance = INCENSE_HAREBELLS
		to_chat(user, "<span class='notice'>The oils in the box are now blended with harebell petals, producing an holy fragrance.</span>")
		return
	if (istype (W,/obj/item/weapon/reagent_containers/food/snacks/grown/poppy))
		user.drop_item(W, force_drop = 1)
		qdel(W)
		fragrance = INCENSE_POPPIES
		to_chat(user, "<span class='notice'>The oils in the box are now blended with poppy petals, producing a calming fragrance.</span>")
		return
	if (istype (W,/obj/item/weapon/grown/sunflower))
		user.drop_item(W, force_drop = 1)
		qdel(W)
		fragrance = INCENSE_SUNFLOWERS
		to_chat(user, "<span class='notice'>The oils in the box are now blended with sunflower petals, producing a pleasant fragrance.</span>")
		return
	if (istype (W,/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower))
		user.drop_item(W, force_drop = 1)
		qdel(W)
		fragrance = INCENSE_MOONFLOWERS
		to_chat(user, "<span class='notice'>The oils in the box are now blended with moonflower petals, producing a disturbing fragrance.</span>")
		return
	if (istype (W,/obj/item/weapon/grown/novaflower))
		user.drop_item(W, force_drop = 1)
		qdel(W)
		fragrance = INCENSE_NOVAFLOWERS
		to_chat(user, "<span class='notice'>The oils in the box are now blended with novaflower petals, producing a stimulating fragrance.</span>")
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
			if(VAMP_MATURE in V.powers)
				V.smitecounter += 30 //Smithe the shit out of him. Four strikes and he's out

	if(istype(M,/mob/living/simple_animal))
		var/mob/living/simple_animal/SA = M
		if (SA.mob_property_flags & MOB_UNDEAD)
			force = 50
	..()
	force = 10

/obj/item/weapon/thurible/pickup(var/mob/living/user)
	if(user.mind)
		if(ishuman(user))
			var/datum/role/vampire/V = isvampire(user)
			if(V && !(VAMP_UNDYING in V.powers))
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
			incense.burn()
			to_chat(user,"<span class='warning'>You flick the built-in lighter, and the small flame lights up \the [incense].</span>")
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
