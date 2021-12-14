//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
MATCHBOXES ARE ALSO IN FANCY.DM
*/

///////////
//MATCHES//
///////////

/obj/item/weapon/match
	name = "match"
	desc = "A budget match stick, used to start fires easily, preferably at the end of a smoke."
	icon = 'icons/obj/cigarettes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cigs_lighters.dmi', "right_hand" = 'icons/mob/in-hand/right/cigs_lighters.dmi')
	icon_state = "match"
	item_state = "match"
	var/lit = 0
	var/smoketime = 10
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	autoignition_temperature = AUTOIGNITION_PAPER
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=1"
	var/list/unlit_attack_verb = list("prods", "pokes")
	var/list/lit_attack_verb = list("burns", "singes")
	attack_verb = list("prods", "pokes")

	light_range = 1
	light_color = LIGHT_COLOR_FIRE
	lighting_flags = MOVABLE_LIGHT
	light_type = LIGHT_SOFT_FLICKER

	var/base_name = "match"
	var/base_icon = "match"

/obj/item/weapon/match/New()
	..()
	update_brightness() //Useful if you want to spawn burnt matches, or burning ones you maniac

/obj/item/weapon/match/Destroy()
	. = ..()

	processing_objects -= src

/obj/item/weapon/match/is_hot()
	if(lit==1)
		return source_temperature
	return 0

/obj/item/weapon/match/ignite(temperature)
	. = ..()
	light()

/obj/item/weapon/match/proc/light()
	lit = 1
	update_brightness()

/obj/item/weapon/match/examine(mob/user)
	..()
	switch(lit)
		if(1)
			to_chat(user, "The match is lit.")
		if(0)
			to_chat(user, "The match is unlit and ready to be used.")
		if(-1)
			to_chat(user, "The match is burnt.")

//Also updates the name, the damage and item_state for good measure
/obj/item/weapon/match/update_icon()
	switch(lit)
		if(1)
			name = "lit [base_name]"
			icon_state = "[base_icon]_lit"
			item_state = icon_state
			damtype = BURN
			attack_verb = lit_attack_verb
		if(0)
			name = "[base_name]"
			icon_state = "[base_icon]_unlit"
			item_state = icon_state
			damtype = BRUTE
			attack_verb = unlit_attack_verb
		if(-1)
			name = "burnt [base_name]"
			icon_state = "[base_icon]_burnt"
			item_state = icon_state
			damtype = BRUTE
			attack_verb = unlit_attack_verb
	if (istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_wear_mask()
		M.update_inv_hands()

/obj/item/weapon/match/proc/update_brightness()
	if(lit == 1) //I wish I didn't need the == 1 part, but Dreamkamer is a dumb puppy
		processing_objects.Add(src)
		set_light()
	else
		processing_objects.Remove(src)
		kill_light()
	update_icon()

/obj/item/weapon/match/process()
	var/mob/living/M = get_holder_of_type(src,/mob/living)
	var/turf/location = get_turf(src)
	smoketime--
	var/datum/gas_mixture/env = location.return_air()
	if(smoketime <= 0)
		lit = -1
		update_brightness()
		return
	if(env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		lit = -1
		update_brightness()
		if(M)
			to_chat(M, "The flame on \the [src] suddenly goes out in a weak fashion.")
	if(location)
		location.hotspot_expose(source_temperature, 5, surfaces = istype(loc, /turf))
		return

/obj/item/weapon/match/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit == 1)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds \the [name] out for [M], and lights \his [cig.name].</span>")
	else
		return ..()

/obj/item/weapon/match/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_hot() >= autoignition_temperature)
		light()
		user.visible_message("[user] lights \the [src] with \the [W].", \
		"You light \the [src] with \the [W].")
	..()

/obj/item/weapon/match/strike_anywhere
	name = "strike-anywhere match"
	desc = "An improved match stick, used to start fires easily, preferably at the end of a smoke. Can be lit against any surface."

/obj/item/weapon/match/strike_anywhere/afterattack(atom/target, mob/user, prox_flags)
	if(!prox_flags == 1)
		return

	if(!(get_turf(src) == get_turf(user)))
		return

	if(lit)
		return

	if(istype(target, /obj) || istype(target, /turf))
		light()
		user.visible_message("[user] strikes \the [src] on \the [target].", \
		"You strike \the [src] on \the [target].")

//////////////////
//FINE SMOKABLES//
//////////////////

//Doubles as a mask entity, aka can be put to your mouth like a real cigarette
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine. Not the best thing to have on your face in the event of a plasma flood."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cigs_lighters.dmi', "right_hand" = 'icons/mob/in-hand/right/cigs_lighters.dmi')
	icon_state = "cig"
	item_state = null
	species_fit = list(INSECT_SHAPED, GREY_SHAPED, VOX_SHAPED)
	w_class = W_CLASS_TINY
	body_parts_covered = 0
	var/list/unlit_attack_verb = list("prods", "pokes")
	var/list/lit_attack_verb = list("burns", "singes")
	attack_verb = list("prods", "pokes")
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	light_color = LIGHT_COLOR_FIRE
	slot_flags = SLOT_MASK|SLOT_EARS
	var/lit = 0
	var/overlay_on = "ciglit" //Apparently not used
	var/type_butt = /obj/item/trash/cigbutt
	var/lastHolder = null

	light_range = 1
	light_color = LIGHT_COLOR_FIRE
	lighting_flags = MOVABLE_LIGHT
	light_type = LIGHT_SOFT_FLICKER

	var/smoketime = 300
	var/chem_volume = 20
	var/inside_item = 0 //For whether the cigarette is contained inside another item.
	var/filling = null //To alter the name if it's a special kind of cigarette
	var/base_name = "cigarette"
	var/base_icon = "cig"
	var/burn_on_end = FALSE

/obj/item/clothing/mask/cigarette/New()
	..()
	base_name = name
	base_icon = icon_state
	flags |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15
	if(Holiday == APRIL_FOOLS_DAY)
		reagents.add_reagent(DANBACCO, 5)
	else
		reagents.add_reagent(TOBACCO, 5)
	update_brightness()

/obj/item/clothing/mask/cigarette/Destroy()
	. = ..()

	processing_objects -= src

/obj/item/clothing/mask/cigarette/examine(mob/user)

	..()
	to_chat(user, "\The [src] is [lit ? "":"un"]lit.")//Shared with all cigarette sub-types

//Also updates the name, the damage and item_state for good measure
/obj/item/clothing/mask/cigarette/update_icon()

	switch(lit)
		if(1)
			name = filling ? "lit [filling] [base_name]" : "lit [base_name]"
			item_state = "[base_icon]on"
			icon_state = "[base_icon]on"
			damtype = BURN
			attack_verb = lit_attack_verb
		if(0)
			name = filling ? "[filling] [base_name]" : "[base_name]"
			item_state = "[base_icon]off"
			icon_state = "[base_icon]off"
			damtype = BRUTE
			attack_verb = unlit_attack_verb
	if (istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_wear_mask()
		M.update_inv_hands()

/obj/item/clothing/mask/cigarette/proc/update_brightness()
	if(lit)
		processing_objects.Add(src)
		set_light()
	else
		processing_objects.Remove(src)
		kill_light()
	update_icon()

/obj/item/clothing/mask/cigarette/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(lit)
		return
	light("<span class='danger'>The raging fire sets \the [src] alight.</span>")

/obj/item/clothing/mask/cigarette/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/clothing/mask/cigarette/attackby(var/obj/item/weapon/W, var/mob/living/user)
	..()
	if (!isliving(user))
		return

	if(lit) //The cigarette is already lit
		to_chat(user, "<span class='warning'>\The [src] is already lit.</span>")
		return //Don't bother

	//Items with special messages go first
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.is_hot()) //Badasses dont get blinded while lighting their cig with a welding tool
			light("<span class='notice'>[user] casually lights \his [name] with \the [W], what a badass.</span>")

	else if(istype(W, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = W
		if(Z.is_hot())
			if (clumsy_check(user) && (prob(50)))
				light("<span class='rose'>With a single flick of their wrist, [user] smoothly lights \his [name] </span><span class='danger'>as well as themselves</span><span class='rose'> with \the [W]. Damn, that's cool.</span>")
				user.adjust_fire_stacks(0.5)
				user.on_fire = 1
				user.update_icon = 1
				playsound(user.loc, 'sound/effects/bamf.ogg', 50, 0)
			else
				light("<span class='rose'>With a single flick of their wrist, [user] smoothly lights \his [name] with \the [W]. Damn, that's cool.</span>")

	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.is_hot())
			light("<span class='notice'>After some fiddling, [user] manages to light \his [name] with \the [W].</span>")

	else if(istype(W, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/sword/S = W
		if(S.is_hot())
			light("<span class='warning'>[user] raises \his [W.name], lighting \the [src]. Holy fucking shit.</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		var/obj/item/device/assembly/igniter/I = W
		if(I.is_hot())
			light("<span class='notice'>[user] fiddles with \his [W.name], and manages to light their [name].</span>")

	//All other items are included here, any item that is hot can light the cigarette
	else if(W.is_hot() || W.sharpness_flags & (HOT_EDGE))
		light("<span class='notice'>[user] lights \his [name] with \the [W].</span>")
	return

/obj/item/clothing/mask/cigarette/afterattack(obj/reagentholder, mob/user as mob)
	..()
	if(reagentholder.is_open_container() && !ismob(reagentholder) && reagentholder.reagents)
		if(reagentholder.reagents.has_reagent(SACID) || reagentholder.reagents.has_reagent(PACID)) //Dumping into acid, a dumb idea
			var/atom/new_butt = new type_butt(get_turf(reagentholder))
			transfer_fingerprints_to(new_butt)
			processing_objects.Remove(src)
			to_chat(user, "<span class='warning'>Half of \the [src] dissolves with a nasty fizzle as you dip it into \the [reagentholder].</span>")
			user.drop_item(src, force_drop = 1)
			qdel(src)
			return
		if(reagentholder.reagents.has_reagent(WATER) && lit) //Dumping a lit cigarette into water, the result is obvious
			var/atom/new_butt = new type_butt(get_turf(reagentholder))
			transfer_fingerprints_to(new_butt)
			processing_objects.Remove(src)
			to_chat(user, "<span class='warning'>\The [src] fizzles as you dip it into \the [reagentholder].</span>")
			user.drop_item(src, force_drop = 1)
			qdel(src)
			return
		var/transfered = reagentholder.reagents.trans_to(src, chem_volume)
		if(transfered)	//If reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [reagentholder].</span>")
		else	//If not, either the beaker was empty, or the cigarette was full
			if(!reagentholder.reagents.total_volume) //Only show an explicit message if the beaker was empty, you can't tell a cigarette is "full"
				to_chat(user, "<span class='warning'>\The [reagentholder] is empty.</span>")
				return

/obj/item/clothing/mask/cigarette/proc/light(var/flavor_text = "[usr] lights \the [src].")
	if(lit) //Failsafe
		return //"Normal" situations were already handled in attackby, don't show a message

	if(reagents.get_reagent_amount(WATER)) //The cigarette was dipped into water, it's useless now
		to_chat(usr, "<span class='warning'>You fail to light \the [src]. It appears to be wet.</span>")
		return

	if(reagents.get_reagent_amount(PLASMA)) //Plasma explodes when exposed to fire
		var/datum/effect/system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(PLASMA)/2.5, 1), get_turf(src), 0, 0, whodunnit = usr)
		e.start()
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)
		qdel(src)
		return

	if(reagents.get_reagent_amount(FUEL)) //Fuel explodes, too, but much less violently
		var/datum/effect/system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(FUEL)/5, 1), get_turf(src), 0, 0, whodunnit = usr)
		e.start()
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)
		qdel(src)
		return

	lit = 1 //All checks that could have stopped the cigarette are done, let us begin
	score["tobacco"]++

	flags &= ~NOREACT //Allow reagents to react after being lit
	clothing_flags |= (MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT)

	reagents.handle_reactions()
	//This ain't ready yet.
	//overlays.len = 0
	//overlays += image('icons/mob/mask.dmi', overlay_on, ABOVE_LIGHTING_LAYER)
	var/turf/T = get_turf(src)
	T.visible_message(flavor_text)

	update_brightness()

	//can't think of any other way to update the overlays :< //Gee, thanks
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_mask(0)
		M.update_inv_ears(0)
		M.update_inv_hands()

/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
	var/mob/living/M = get_holder_of_type(src,/mob/living)
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if (smoketime == 5 && ismob(loc))
		to_chat(M, "<span class='warning'>Your [name] is about to go out.</span>")
	var/datum/gas_mixture/env = location.return_air()
	if(smoketime <= 0 || env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		if(smoketime > 0 && ishuman(loc))
			var/mob/living/carbon/human/mysmoker = loc
			if(mysmoker.internal?.air_contents.partial_pressure(GAS_OXYGEN) > 0)
				return //if there's oxygen in the tank, let my cig live freely
		if(!inside_item)
			var/atom/new_butt = new type_butt(location) //Spawn the cigarette butt
			transfer_fingerprints_to(new_butt)
		lit = 0 //Actually unlight the cigarette so that the lighting can update correctly
		update_brightness()
		if(ismob(loc))
			if (burn_on_end)
				if (M.get_item_by_slot(slot_wear_mask) == src)
					to_chat(M, "<span class='danger'>Ow! The [name] burns the tip of your lips as it goes out.</span>")
					M.apply_damage(1, BURN, LIMB_HEAD)
				else
					var/hand_index = M.held_items.Find(src)
					switch(hand_index)
						if (GRASP_RIGHT_HAND)
							to_chat(M, "<span class='danger'>Ow! The [name] burns your fingers as it goes out.</span>")
							M.apply_damage(1, BURN, LIMB_RIGHT_HAND)
						if (GRASP_LEFT_HAND)
							to_chat(M, "<span class='danger'>Ow! The [name] burns your fingers as it goes out.</span>")
							M.apply_damage(1, BURN, LIMB_LEFT_HAND)
			else if(env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
				to_chat(M, "<span class='notice'>\The [src] suddenly goes out in a weak fashion.</span>")
			else
				to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
			M.u_equip(src, 0)	//Un-equip it so the overlays can update
		qdel(src)
		return
	if(location)
		location.hotspot_expose(source_temperature, 5, surfaces = istype(loc, /turf))
	//Oddly specific and snowflakey reagent transfer system below
	if(reagents && reagents.total_volume)	//Check if it has any reagents at all
		if(iscarbon(M) && ((src == M.wear_mask) || (loc == M.wear_mask))) //If it's in the human/monkey mouth, transfer reagents to the mob
			if(M.reagents.has_any_reagents(LEXORINS) || (M_NO_BREATH in M.mutations) || istype(M.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				reagents.remove_any(REAGENTS_METABOLISM)
			else
				if(prob(25)) //So it's not an instarape in case of acid
					reagents.reaction(M, INGEST)
				reagents.trans_to(M, 1)
		else //Else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	return

/obj/item/clothing/mask/cigarette/attack_self(mob/user as mob)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [name], putting it out.</span>")
		var/turf/T = get_turf(src)
		var/atom/new_butt = new type_butt(T)
		transfer_fingerprints_to(new_butt)
		lit = 0 //Needed for proper update
		update_brightness()
		qdel(src)

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(!lit && M.on_fire) //Hit burning mobs with cigarettes to light it up.
		if(M == user)
			light("<span class='notice'>[user] uses \his burning body to light \the [src]. Smooth.</span>")
			return
		else
			light("<span class='notice'>[user] uses the flames on [M] to light \the [src]. How rude.</span>")
			return

	//Using another cigarette to light yours
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds \his [name] out for [M], and lights \the [cig].</span>")

	else
		return ..()

//////////////
//FANCY CIGS//
//////////////

/obj/item/clothing/mask/cigarette/bidi
	name = "Bidi"
	desc = "An acrid, loosely-rolled tobacco leaf, stuffed with herbs and spices and bound with twine."
	icon_state = "bidi"
	overlay_on = "bidilit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/bidibutt
	burn_on_end = TRUE

/obj/item/clothing/mask/cigarette/goldencarp
	name = "Golden Carp cigarette"
	desc = "A cigarette made from light, fine paper, with a thin gold band above the filter."
	icon_state = "goldencarp"
	overlay_on = "goldencarplit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/goldencarpbutt

/obj/item/clothing/mask/cigarette/starlight
	name = "Starlight cigarette"
	desc = "A nicely-rolled smoke. Above the filter are a red and yellow band."
	icon_state = "starlight"
	overlay_on = "starlightlit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/starlightbutt

/obj/item/clothing/mask/cigarette/lucky
	name = "Lucky Strike cigarette"
	desc = "Plain and unfiltered, just how great-great-grandad used to like them."
	icon_state = "lucky"
	overlay_on = "luckylit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/luckybutt

/obj/item/clothing/mask/cigarette/redsuit
	name = "Redsuit cigarette"
	desc = "Slim and refined. A mild smoke for a serious smoker."
	icon_state = "redsuit"
	overlay_on = "redsuitlit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/redsuitbutt

/obj/item/clothing/mask/cigarette/ntstandard
	name = "NT Standard cigarette"
	desc = "Matte grey with a blue band. Corporate loyalty with every puff."
	icon_state = "ntstandard"
	overlay_on = "ntstandardlit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/ntstandardbutt

/obj/item/clothing/mask/cigarette/spaceport
	name = "Spaceport cigarette"
	desc = "The dull gold band wrapped around this cig does nothing to hide its cheap origins."
	icon_state = "spaceport"
	overlay_on = "spaceportlit"
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/spaceportbutt



////////////
// CIGARS //
////////////

/obj/item/clothing/mask/cigarette/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	var/mob/living/carbon/C = M
	if(!istype(C) || !C.hasmouth())
		to_chat(C, "<span class='warning'>You have no mouth.</span>")
		return CANNOT_EQUIP
	. = ..()

/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A large roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar"
	overlay_on = "cigarlit"
	flags = FPRINT
	slot_flags = SLOT_MASK
	type_butt = /obj/item/trash/cigbutt/cigarbutt
	smoketime = 1500
	chem_volume = 25
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2"
	overlay_on = "cigar2lit"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2"
	overlay_on = "cigar2lit"
	smoketime = 7200
	chem_volume = 30
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/trash/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = W_CLASS_TINY
	throwforce = 1
	autoignition_temperature = 0 //The filter doesn't burn

/obj/item/trash/cigbutt/bidibutt
	name = "bidi butt"
	desc = "An acrid bidi stub."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "bidibutt"
	w_class = W_CLASS_TINY

/obj/item/trash/cigbutt/goldencarpbutt
	name = "cigarette butt"
	desc = "Leftovers of a fancy smoke."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "goldencarpbutt"

/obj/item/trash/cigbutt/starlightbutt
	name = "cigarette butt"
	desc = "A slick-looking cig butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "starlightbutt"

/obj/item/trash/cigbutt/luckybutt
	name = "cigarette butt"
	desc = "An unfiltered cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "luckybutt"

/obj/item/trash/cigbutt/redsuitbutt
	name = "cigarette butt"
	desc = "A discarded butt, with an ominous red band."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "redsuitbutt"

/obj/item/trash/cigbutt/spaceportbutt
	name = "cigarette butt"
	desc = "A discarded butt, with a tacky gold band in the middle."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "spaceportbutt"

/obj/item/trash/cigbutt/ntstandardbutt
	name = "cigarette butt"
	desc = "A butt bearing the logo of the corp wrapped above the filter."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "ntstandardbutt"

/obj/item/trash/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/*
//I'll light my cigar with an energy sword if I want to, thanks
/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		to_chat(user, "<span class='notice'>\The [src] straight out REFUSES to be lit by such uncivilized means.</span>")
*/

///////////////////
//AMBROSIA BLUNTS//
///////////////////

/obj/item/clothing/mask/cigarette/blunt
	name = "blunt"
	desc = "A special homemade cigar. Light it up and pass it around."
	icon_state = "blunt"
	overlay_on = "bluntlit"
	type_butt = /obj/item/trash/cigbutt/bluntbutt
	slot_flags = SLOT_MASK
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

	lit_attack_verb = list("burns", "singes", "blunts")
	smoketime = 420
	chem_volume = 100 //It's a fat blunt, a really fat blunt

	burn_on_end = TRUE

/obj/item/clothing/mask/cigarette/blunt/rolled //grown.dm handles reagents for these

/obj/item/clothing/mask/cigarette/blunt/cruciatus

/*/obj/item/clothing/mask/cigarette/blunt/cruciatus/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(SPACE_DRUGS, 7)
	reagents.add_reagent(KELOTANE, 7)
	reagents.add_reagent(BICARIDINE, 5)
	reagents.add_reagent(TOXIN, 5)
	reagents.add_reagent(SPIRITBREAKER, 10)
	update_brightness()*/

/obj/item/clothing/mask/cigarette/blunt/cruciatus/rolled

/obj/item/clothing/mask/cigarette/blunt/deus
	name = "godblunt"
	desc = "A fat ambrosia deus cigar. Smoke weed every day."
	icon_state = "dblunt"
	overlay_on = "dbluntlit"

/*/obj/item/clothing/mask/cigarette/blunt/deus/New()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(BICARIDINE, 7)
	reagents.add_reagent(SYNAPTIZINE, 7)
	reagents.add_reagent(HYPERZINE, 5)
	reagents.add_reagent(SPACE_DRUGS, 5)
	update_brightness()*/

/obj/item/clothing/mask/cigarette/blunt/deus/rolled

/obj/item/trash/cigbutt/bluntbutt
	name = "blunt butt"
	desc = "A manky old blunt butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "bluntbutt"
	w_class = W_CLASS_TINY
	throwforce = 1

/////////////////
//SMOKING PIPES//
/////////////////

/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	flags = FPRINT
	icon_state = "pipe"
	slot_flags = SLOT_MASK
	overlay_on = "pipelit"
	species_fit = list(GREY_SHAPED)
	smoketime = 100

/obj/item/clothing/mask/cigarette/pipe/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		lit = 1
		score["tobacco"]++
		damtype = BURN
		update_brightness()
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		if(istype(loc,/mob))
			var/mob/M = loc
			if(M.wear_mask == src)
				M.update_inv_wear_mask(0)
		clothing_flags |= (MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if (smoketime == 5 && ismob(loc))
		var/mob/M = loc
		to_chat(M, "<span class='warning'>Your [name] is about to go out.</span>")
	if(smoketime <= 0)
		new /obj/effect/decal/cleanable/ash(location)
		lit = 0
		if(ismob(loc))
			var/mob/living/M = loc
			M.visible_message("<span class='notice'>[M]'s [name] goes out.</span>", \
			"<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
			if(M.wear_mask == src)
				M.update_inv_wear_mask(0)
		update_brightness()
		return
	if(location)
		location.hotspot_expose(source_temperature, 5, surfaces = istype(loc, /turf))
	return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something. //Later meaning never
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out \the [src].</span>", \
							"<span class='notice'>You put out \the [src].</span>")
		lit = 0
		clothing_flags &= ~(MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT)
		update_brightness()
		return
	if(smoketime < initial(smoketime)) //Warrants a refill
		user.visible_message("<span class='notice'>[user] refills \the [src].</span>", \
							"<span class='notice'>You refill \the [src].</span>")
		smoketime = initial(smoketime)
	return

/*
//Ditto above, only a ruffian would refuse to light his pipe with an energy sword
/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		to_chat(user, "<span class='notice'>\The [src] straight out REFUSES to be lit by such means.</span>")
*/

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipe"
	smoketime = 400

/////////////////
//CHEAP LIGHTER//
/////////////////

/obj/item/weapon/lighter
	name = "cheap lighter"
	var/initial_name	//a lighter that gets renamed for flavor needs to keep its name
	desc = "A budget lighter. More likely lit more fingers than it did light smokes."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cigs_lighters.dmi', "right_hand" = 'icons/mob/in-hand/right/cigs_lighters.dmi')
	item_state = null
	w_class = W_CLASS_TINY
	throwforce = 4
	flags = null
	siemens_coefficient = 1
	var/color_suffix = "-g" // Determines the sprite used
	var/lightersound = list('sound/items/lighter1.ogg','sound/items/lighter2.ogg')
	var/fuel = 20
	var/fueltime
	heat_production = 1500
	source_temperature = TEMPERATURE_FLAME
	slot_flags = SLOT_BELT
	var/list/unlit_attack_verb = list("prods", "pokes")
	var/list/lit_attack_verb = list("burns", "singes")
	attack_verb = list("prods", "pokes")

	light_range = 2
	light_color = LIGHT_COLOR_FIRE
	lighting_flags = MOVABLE_LIGHT
	light_type = LIGHT_SOFT_FLICKER

	var/lit = 0
	var/base_icon = "lighter"

/obj/item/weapon/lighter/New()
	..()
	base_icon = icon_state
	update_icon()

/obj/item/weapon/lighter/Destroy()
	. = ..()

	processing_objects -= src

/obj/item/weapon/lighter/red
	color_suffix = "-r"
/obj/item/weapon/lighter/cyan
	color_suffix = "-c"
/obj/item/weapon/lighter/yellow
	color_suffix = "-y"
/obj/item/weapon/lighter/green
	color_suffix = "-g"
/obj/item/weapon/lighter/NT
	desc = "A limited edition, super-exclusive Nanotrasen-colored cheap lighter. You're not thrilled."
	color_suffix = "-nt"

/obj/item/weapon/lighter/random/New()
	color_suffix = "-[pick("r","c","y","g")]"
	..()

/obj/item/weapon/lighter/examine(mob/user)
	..()
	to_chat(user, "The lighter is [lit ? "":"un"]lit")

//Also updates the name, the damage and item_state for good measure
/obj/item/weapon/lighter/update_icon()
	switch(lit)
		if(1)
			initial_name = name
			name = "lit [initial_name]"
			icon_state = "[base_icon][color_suffix]-on"
			item_state = icon_state
			damtype = BURN
			attack_verb = lit_attack_verb
		if(0)
			if(!initial_name)
				initial_name = name
			name = "[initial_name]"
			icon_state = "[base_icon][color_suffix]"
			item_state = icon_state
			damtype = BRUTE
			attack_verb = unlit_attack_verb
	if (istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_wear_mask()
		M.update_inv_hands()

/obj/item/weapon/lighter/proc/update_brightness()
	if(lit)
		processing_objects.Add(src)
		set_light()
	else
		processing_objects.Remove(src)
		kill_light()
	update_icon()

/obj/item/weapon/lighter/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return 0
	if(istype(O, /obj/structure/reagent_dispensers/fueltank))
		fuel += O.reagents.remove_any(initial(fuel) - fuel)
		user.visible_message("<span class='notice'>[user] refuels \the [src].</span>", \
		"<span class='notice'>You refuel \the [src].</span>")
		playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
		return

/obj/item/weapon/lighter/attack_self(mob/living/user)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	user.delayNextAttack(5) //Hold on there cowboy
	if(!fuel || env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		user.visible_message("<span class='rose'>[user] attempts to light \the [src] to no avail.</span>", \
		"<span class='notice'>You try to light \the [src], but no flame appears.</span>")
		return
	if(!lit) //Lighting the lighter
		playsound(src, pick(lightersound), 50, 1)
		if(fuel >= initial(fuel) - 5 || prob(100 * (fuel/initial(fuel)))) //Strike, but fail to light it
			user.visible_message("<span class='notice'>[user] manages to light \the [src].</span>", \
			"<span class='notice'>You manage to light \the [src].</span>")
			lit = !lit
			update_brightness()
			--fuel
			return
		else //Failure
			user.visible_message("<span class='notice'>[user] tries to light \the [src].</span>", \
			"<span class='notice'>You try to light \the [src].</span>")
			return
	else
		fueltime = null
		lit = !lit
		user.visible_message("<span class='notice'>[user] quietly shuts off \the [src].</span>", \
		"<span class='notice'>You quietly shut off \the [src].</span>")
		update_brightness()

/obj/item/weapon/lighter/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/weapon/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/weapon/lighter/zippo))
				cig.light("<span class='rose'>[user] whips \his [name] out and holds it for [M]. Their arm is as steady as the unflickering flame they light \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds \his [name] out for [M] and lights \the [cig].</span>")
	else
		return ..()

/obj/item/weapon/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(source_temperature, 5, surfaces = istype(loc, /turf))
	if(!fueltime)
		fueltime = world.time + 100
	if(world.time > fueltime)
		fueltime = world.time + 100
		--fuel
		if(!fuel)
			lit = 0
			update_brightness()
			visible_message("<span class='warning'>Without warning, \the [src] suddenly shuts off.</span>")
			fueltime = null
	var/datum/gas_mixture/env = location.return_air()
	if(env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		lit = 0
		update_brightness()
		visible_message("<span class='warning'>Without warning, the flame on \the [src] suddenly goes out in a weak fashion.</span>")

/////////
//ZIPPO//
/////////

/obj/item/weapon/lighter/zippo
	name = "Zippo lighter"
	desc = "The Zippo lighter. Need to light a smoke? Zippo!"
	icon_state = "zippo"
	color_suffix = null
	var/open_sound = list('sound/items/zippo_open.ogg')
	var/close_sound = list('sound/items/zippo_close.ogg')
	fuel = 100 //Zippos da bes

/obj/item/weapon/lighter/zippo/attack_self(mob/living/user)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	user.delayNextAttack(5) //Hold on there cowboy
	if(!fuel || env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		user.visible_message("<span class='rose'>[user] attempts to light \the [src] to no avail.</span>", \
		"<span class='notice'>You try to light \the [src], but no flame appears.</span>")
		return
	lit = !lit
	if(lit) //Was lit
		playsound(src, pick(open_sound), 50, 1)
		user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights \the [src] in one smooth movement.</span>", \
		"<span class='rose'>Without even breaking stride, you flip open and light \the [src] in one smooth movement.</span>")
		--fuel
	else //Was shut off
		fueltime = null
		playsound(src, pick(close_sound), 50, 1)
		user.visible_message("<span class='rose'>You hear a quiet click as [user] shuts off \the [src] without even looking at what they're doing. Wow.</span>", \
		"<span class='rose'>You hear a quiet click as you shut off \the [src] without even looking at what you are doing.</span>")
	update_brightness()
