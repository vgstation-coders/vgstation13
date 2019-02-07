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

	var/list/unlit_attack_verb = list("prods", "pokes")
	var/list/lit_attack_verb = list("burns", "singes")

	var/combustible = 120
	var/lit = FALSE
	var/flammable = TRUE


/obj/item/incense_stick/attack_self(var/mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] carefully puts out the ember on \the [name].</span>")
		lit = FALSE
		update_brightness()

/obj/item/incense_stick/proc/burn()
	flammable = FALSE
	while (!gcDestroyed && loc && lit)
		combustible--
		sleep(10)
	flammable = TRUE

/obj/item/incense_stick/update_icon()
	if (lit)
		icon_state = "incensestick"
		item_state = "incensestick_lit"
		damtype = BURN
		attack_verb = lit_attack_verb
	else
		icon_state = "incensestick"
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
	plural_descriptive_type = "sticks of ""
	storage_slots = 14
	can_only_hold = list("/obj/item/incense_stick")
	foldable = /obj/item/stack/sheet/wood
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_MISC)
	w_type=RECYK_WOOD
	siemens_coefficient = 0

/obj/item/weapon/storage/fancy/incensebox/update_icon()
	if (contents.len > 0)
		icon_state = "incensebox_[min(4,1+round(contents / 4))]"
	else
		icon_state = "incensebox_0"

/obj/item/weapon/storage/fancy/incensebox/empty
	empty = 1
	icon_state = "incensebox_0"

/obj/item/weapon/storage/fancy/incensebox/New()
	..()
	if (empty)
		return
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/incense_stick(src)

/obj/item/incense_oilbox
	name = "incense oil container"
	desc = "Filled with a blend of aromatic flowers, allows the initiate to alter the composition of incense sticks."
	icon = 'icons/obj/incense.dmi'
	icon_state = "incenseoilbox"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/incense.dmi', "right_hand" = 'icons/mob/in-hand/right/incense.dmi')
	item_state = "incenseoilbox"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	force = 2.5
	flags = FPRINT

/obj/item/weapon/thurible
	name = "thurible"
	desc = "A silver vessel made for burning incense, suspended by chains. Used by some chaplains during worship service."
	icon = 'icons/obj/incense.dmi'
	icon_state = "thurible"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/incense.dmi', "right_hand" = 'icons/mob/in-hand/right/incense.dmi')
	item_state = "thurible"
	hitsound = //TODO
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	attack_verb = list("bashes")

/obj/item/weapon/thurible/attack(var/mob/M, var/mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/role/vampire/V = isvampire(H)
		if(V)
			if(VAMP_MATURE in V.powers)
				V.smitecounter += 30 //Smithe the shit out of him. Four strikes and he's out

	if(M.mob_property_flags & MOB_UNDEAD)
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
