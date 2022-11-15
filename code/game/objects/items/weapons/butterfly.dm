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
	force = 15
	throwforce = 8
	throw_speed = 3
	throw_range = 6
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=3"
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "cuts")
	var/open = FALSE
	var/knifetype = "plain"

/obj/item/weapon/butterflyknife/attack_self(mob/user)
	if(user.stat || user.restrained())
		return
	fold(user)

/obj/item/weapon/butterflyknife/proc/fold(mob/user)
	open = !open
	to_chat(user, "You flip \the [src] [open ? "open" : "closed"].")
	icon_state = "Bflyknife_[knifetype][open ? "_open" : ""]"
	item_state = open ? "smallknife" : initial(item_state)
	force = open ? initial(force) : 5
	sharpness = open ? initial(sharpness) : null
	sharpness_flags = open ? initial(sharpness_flags) : null
	hitsound = open ? initial(hitsound) : null
	attack_verb = open ? initial(attack_verb) : list("jabs", "pokes")
	after_fold(user)

/obj/item/weapon/butterflyknife/proc/after_fold(mob/user)
	playsound(src,'sound/items/zippo_open.ogg', 50, 1)

/obj/item/weapon/butterflyknife/viscerator
	desc = "A folding type knife that stores the blade between its two handles when flipped. It hums slightly."
	icon_state = "Bflyknife_red"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	mech_flags = MECH_SCAN_ILLEGAL
	knifetype = "red"
	var/last_spawned = 0
	var/bug = /mob/living/simple_animal/hostile/viscerator/butterfly

/obj/item/weapon/butterflyknife/viscerator/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/butterflyknife/viscerator/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/butterflyknife/viscerator/process()
	if(!bug && world.time >= 25 SECONDS + last_spawned)
		rearm()

/obj/item/weapon/butterflyknife/viscerator/proc/rearm()
	bug = initial(bug)
	playsound(src, 'sound/items/healthanalyzer.ogg', 10, 1)
	visible_message("<span class='notice'>\The [src] chimes.</span>")
	var/turf/T = get_turf(src)
	T.turf_animation('icons/effects/effects.dmi',"butterfly")

/obj/item/weapon/butterflyknife/viscerator/preattack(var/mob/living/target, mob/user) //"Putting away" a butterfly early.
	if(open && istype(target, /mob/living/simple_animal/hostile/viscerator/butterfly))
		qdel(target)
		rearm()
		to_chat(user, "You catch \the [target] and store it back into \the [src].")
		fold(user)
	else
		..()

/obj/item/weapon/butterflyknife/viscerator/after_fold(mob/user)
	if(open)
		if(bug)
			var/mob/living/simple_animal/hostile/viscerator/butterfly/B = new bug(get_turf(src))
			B.handle_faction(user)
			B.autodie = TRUE
			bug = null
			last_spawned = world.time
			playsound(src,'sound/items/butterflyknife.ogg', 50, 1)
			var/turf/T = get_turf(src)
			T.turf_animation('icons/effects/effects.dmi',"butterfly_out")
			return
	//if closed, or no bug made
	..()

/obj/item/weapon/butterflyknife/viscerator/magic
	name = "crystal butterfly knife"
	desc = "A folding type knife that stores the blade between its two handles when flipped. It's made of colored crystals and is engraved with the number 553."
	icon_state = "Bflyknife_wiz"
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ANOMALY + "=4"
	mech_flags = null
	bug = /mob/living/simple_animal/hostile/viscerator/butterfly/magic
	knifetype = "wiz"

/obj/item/weapon/butterflyknife/viscerator/bunny
	name = "mechanical toybox"
	desc = "A small box that rapidly assembles shaudy, barely working wind-up toys."
	icon = 'icons/obj/butterfly.dmi'
	icon_state = "Bflyknife_toy"
	hitsound = "trayhit"
	sharpness = 0
	sharpness_flags = 0
	w_class = W_CLASS_SMALL
	force = 1
	throwforce = 1
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ANOMALY + "=2"
	attack_verb = list("bops", "smacks", "whacks")
	mech_flags = null //I see no reason not to allow the station to be filled with 200 of these little guys
	knifetype = "toy"
	bug = /mob/living/simple_animal/hostile/bunnybot
