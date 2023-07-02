//copy pasta of the space piano, don't hurt me -Pete
/obj/item/device/instrument
	name = "generic instrument"
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "mid"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/musician.dmi', "right_hand" = 'icons/mob/in-hand/right/musician.dmi')
	icon = 'icons/obj/musician.dmi'
	force = 10
	var/requires_mouth = FALSE

	/* These two variables allow an admin to make an instrument dispense reagents in a certain range whenever an instrument is played. */
	var/datum/reagent/bard_reagent_id = null
	var/bard_reagent_amount = 0.3

/obj/item/device/instrument/New()
	..()
	song = new(instrumentId, src)
	song.instrumentExt = instrumentExt

/obj/item/device/instrument/Destroy()
	QDEL_NULL(song)
	..()

/obj/item/device/instrument/initialize()
	song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/item/device/instrument/attack_self(mob/user)
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	if(requires_mouth)
		var/mob/living/carbon/C = user
		if(istype(C) && !C.hasmouth())
			to_chat(user, "<span class='warning'>You need a mouth to play this instrument!</span>")
			return 1
	ui_interact(user)

/obj/item/device/instrument/drum/drum_makeshift/bongos/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/device/instrument/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null, var/force_open=NANOUI_FOCUS)
	if(!user)
		return

	if(user.incapacitated() || user.lying)
		return

	user.set_machine(src)
	song.ui_interact(user,ui_key,ui,force_open)

/obj/item/device/instrument/proc/OnPlayed(mob/user, mob/M)
	var/is_valid_id
	if(!bard_reagent_id)
		return
	if(!user || !M)
		return
	if(chemical_reagents_list[bard_reagent_id]) /* Check against global list of reagents to see if the ID is already valid */
		if(!istype(bard_reagent_id)) /* In case someone sets the variable to an existing reagents datum... for some reason... */
			is_valid_id = 1
	/* Cleaning up admin inputs before playing the sound */
	if(!is_valid_id && (istext(bard_reagent_id) || ispath(bard_reagent_id)))
		if(!ispath(bard_reagent_id))
			bard_reagent_id = text2path(bard_reagent_id)
		bard_reagent_id = reagent_type2id(bard_reagent_id)
	/* Sending reagent to affected player */
	if(user != M && M.reagents && !M.reagents.has_reagent(bard_reagent_id, 1))
		if(!M.reagents.add_reagent(bard_reagent_id, bard_reagent_amount)) /* Try to add the reagent, and give an error if it doesn't work. */
			log_debug("Error: Instrument ([src]), held by [ismob(loc) ? "[loc]" : "null"], called OnPlayed() with an invalid bard_reagent_id ([bard_reagent_id]). Please ensure you're using a reagent ID (ex. CHILLWAX) or reagent typepath (ex. /datum/reagent/honey/chillwax).")
			message_admins("Error: Instrument ([src]), held by [ismob(loc) ? "[loc]" : "null"], called OnPlayed() with an invalid bard_reagent_id ([bard_reagent_id]). Please ensure you're using a reagent ID (ex. CHILLWAX) or reagent typepath (ex. /datum/reagent/honey/chillwax).")
	
/obj/item/device/instrument/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] begins trying to play Faerie's Aire and Death Waltz with \the [src]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/effects/applause.ogg', 50, 1, -1)
	return SUICIDE_ACT_BRUTELOSS

/obj/item/device/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	attack_verb = list("smashed")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	instrumentId = "violin"

/obj/item/device/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar0"
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	instrumentId = "guitar"
	instrumentExt = "ogg"
	flags = TWOHANDABLE
	slot_flags = SLOT_BACK

/obj/item/device/instrument/guitar/update_wield(mob/user)
	..()
	item_state = "guitar[wielded ? 1 : 0]"
	if(user)
		user.update_inv_hands()

/obj/item/device/instrument/guitar/attack_self(mob/user as mob)
	if(wielded) //can only play if you're two handing it
		return ..()
	wield(user)

/obj/item/device/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	instrumentId = "glockenspiel"
	flags = TWOHANDABLE | MUSTTWOHAND

/obj/item/device/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	item_state = "accordion"
	instrumentId = "accordion"
	flags = TWOHANDABLE | MUSTTWOHAND

/obj/item/device/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	item_state = "saxophone"
	instrumentId = "saxophone"
	requires_mouth = TRUE

/obj/item/device/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	item_state = "trombone"
	instrumentId = "trombone"
	requires_mouth = TRUE

/obj/item/device/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	icon_state = "recorder"
	item_state = "recorder"
	instrumentId = "recorder"
	requires_mouth = TRUE

/obj/item/device/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	item_state = "harmonica"
	instrumentId = "harmonica"
	slot_flags = SLOT_MASK
	force = 5
	w_class = W_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)
	requires_mouth = TRUE

/obj/item/device/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	item_state = "bike_horn"

	attack_verb = list("beautifully honks")
	instrumentId = "bikehorn"
	instrumentExt = "ogg"
	w_class = W_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'


/obj/item/device/instrument/drum
	name = "drum"
	desc = "Are you ready to be the king of the Rhumba beat?"
	icon_state = "drum"
	item_state = "drum"
	force = 10
	attack_verb = list("drums", "beats", "smashes")
	instrumentId = "drum"
	flags = TWOHANDABLE | MUSTTWOHAND
	hitsound = 'sound/items/drumhit.ogg'

/obj/item/device/instrument/drum/drum_makeshift
	name = "makeshift drum"
	desc = "A crudely built drum that is, in essence, a wooden bowl with a leather sheet stretched taut over its surface. Despite its primitive design, you can extract a rather wide range of pitches and notes from this pile of trash."
	icon_state = "drum_makeshift"
	item_state = "drum_makeshift"
	w_class = W_CLASS_TINY
	force = 5
	flags = TWOHANDABLE
	instrumentId = "drum"
	var/decondrop = 1 //determines how many parts to drop if deconstructed

/obj/item/device/instrument/drum/drum_makeshift/bongos
	name = "bongos"
	desc = "Simple makeshift set of double drums that can be played by anyone with a pair of hands."
	icon_state = "drum_bongo"
	item_state = "drum_bongo"
	w_class = W_CLASS_LARGE
	flags = TWOHANDABLE | MUSTTWOHAND
	instrumentId = "drum"
	hitsound = 'sound/items/drumhit.ogg'
	decondrop = 2 //determines how many parts to drop if deconstructed

/obj/item/device/instrument/drum/drum_makeshift/attackby(obj/item/I,mob/user,params)
	if(I.is_wirecutter(user)) //wirecutters disassembles drums and bongos and gives you proper drops based on [decondrop] defined above
		I.playtoolsound(loc, 50)
		visible_message("<span class='notice'>[user] cuts the leather face off \the [src] with \the [I]. </span>")
		for (var/i = 1 to decondrop)
			new /obj/item/trash/bowl(get_turf(src))
			new /obj/item/stack/sheet/leather(get_turf(src))
		qdel(src)
	if (istype(I,/obj/item/device/instrument/drum/drum_makeshift)) //adding a drum to a drum makes bongos.
		visible_message("<span class='notice'>[user] combines the two drums to create a set of bongos.</span>")
		new /obj/item/device/instrument/drum/drum_makeshift/bongos(get_turf(src))
		qdel(src)
		qdel(I)
