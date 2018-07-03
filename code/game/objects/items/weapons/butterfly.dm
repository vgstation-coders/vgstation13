/obj/item/weapon/butterflyknife
	name = "butterfly knife"
	desc = "A folding type knife that stores the blade between its two handles when flipped."
	icon = 'icons/obj/butterfly.dmi'
	icon_state = "Bflyknife_plain"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	item_state = null
	hitsound = "sound/weapons/bladeslice.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1.2
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	w_class = W_CLASS_TINY
	force = 20
	throwforce = 8
	throw_speed = 3
	throw_range = 6
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=3"
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "cuts")
	var/open = FALSE
	var/bug = null
	var/knifetype = "plain"
	var/counting

/obj/item/weapon/butterflyknife/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/butterflyknife/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/butterflyknife/process()
	if(counting)
		if(world.time - counting >= 250)
			rearm()

/obj/item/weapon/butterflyknife/attack_self(var/mob/living/L = null)
	if(!open)
		unfold()
		to_chat(L, "You flip \the [src] open.")
	else
		fold()
		to_chat(L, "You flip \the [src] closed.")
		if(bug)
			var/mob/living/simple_animal/X = new bug(get_turf(src))
			if(istype(L))
				handle_faction(X,L)
			if(istype(X, /mob/living/simple_animal/hostile/viscerator/butterfly))
				var/mob/living/simple_animal/hostile/viscerator/butterfly/B = X
				B.autodie = TRUE
			bug = null
			counting = world.time
	playsound(src,'sound/items/zippo_open.ogg', 50, 1)

/obj/item/weapon/butterflyknife/preattack(var/mob/living/target, mob/user) //"Putting away" a butterfly early.
	if((istype(target, /mob/living/simple_animal/hostile/viscerator/butterfly)) && (knifetype != "plain"))
		qdel(target)
		rearm()
		to_chat(user, "You catch \the [target] and store it back into \the [src].")
		if(open)
			unfold()
		else
			fold()

/obj/item/weapon/butterflyknife/proc/rearm()
	counting = null
	bug = initial(bug)
	playsound(src, 'sound/items/healthanalyzer.ogg', 10, 1)
	visible_message("<span class='notice'>\The [src] chimes.</span>")

/obj/item/weapon/butterflyknife/proc/unfold()
	open = TRUE
	icon_state = "Bflyknife_[knifetype]_open"
	item_state = "smallknife"
	force = initial(force)
	sharpness = initial(sharpness)
	sharpness_flags = initial(sharpness_flags)
	hitsound = initial(hitsound)
	attack_verb = initial(attack_verb)
	if(!bug)
		force = 15

/obj/item/weapon/butterflyknife/proc/fold()
	open = FALSE
	icon_state = "Bflyknife_[knifetype]"
	item_state = initial(item_state)
	force = 5
	sharpness = null
	sharpness_flags = null
	hitsound = null
	attack_verb = list("jabs", "pokes")

/obj/item/weapon/butterflyknife/proc/handle_faction(var/mob/living/spawned, var/mob/living/L)
	if(!spawned || !L)
		return
	if(!isnukeop(L) || !iswizard(L)) //If you're an op(syndicate) or wizard your faction already matches the faction of the respective viscerator.
		spawned.faction = "\ref[L]"


/obj/item/weapon/butterflyknife/viscerator
	desc = "A folding type knife that stores the blade between its two handles when flipped. It hums slightly."
	icon_state = "Bflyknife_red"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	mech_flags = MECH_SCAN_ILLEGAL
	bug = /mob/living/simple_animal/hostile/viscerator/butterfly
	knifetype = "red"


/obj/item/weapon/butterflyknife/viscerator/magic
	name = "crystal butterfly knife"
	desc = "A folding type knife that stores the blade between its two handles when flipped. It's made of colored crystals and is engraved with the number 553."
	icon_state = "Bflyknife_wiz"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ANOMALY + "=4"
	mech_flags = null
	bug = /mob/living/simple_animal/hostile/viscerator/butterfly/magic
	knifetype = "wiz"
