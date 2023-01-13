// Eat these

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	var/amount_grown = 0
	var/can_color = TRUE
	var/hatch_type = /mob/living/simple_animal/chick

/obj/item/weapon/reagent_containers/food/snacks/egg/New()
	..()
	reagents.add_reagent(EGG_YOLK, 4)
	reagents.add_reagent(CALCIUMCARBONATE, 1)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/egg/process()
	if(is_in_valid_nest(src)) //_macros.dm
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			hatch()
	else
		processing_objects.Remove(src)


/obj/item/weapon/reagent_containers/food/snacks/egg/afterattack(atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	var/static/list/allowed_targets = list(/obj/item/weapon/reagent_containers, /obj/structure/reagent_dispensers/cauldron)
	if(!adjacency_flag || !is_type_in_list(target, allowed_targets) || !target.is_open_container())
		return

	if(target.reagents.is_full())
		to_chat(user, "<span class='notice'>\The [target] is full!</span>")
		return

	new /obj/item/trash/egg(get_turf(target))
	playsound(loc, 'sound/items/egg_cracking.ogg', 50, 1)
	reagents.del_reagent(CALCIUMCARBONATE)
	reagents.trans_to(target, reagents.total_volume, log_transfer = TRUE, whodunnit = user)

	user.visible_message("<span class='warning'>[user] cracks open an egg into \the [target].</span>", \
		self_message = "<span class='notice'>You crack open \the [src] into \the [target].[target.reagents.is_full()? " It is now full." : ""]</span>", range = 2)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(!..() && isturf(hit_atom))
		new/obj/effect/decal/cleanable/egg_smudge(loc)
		new/obj/item/trash/egg(loc)
		splat_reagent_reaction(hit_atom,user)
		visible_message("<span class='warning'>\The [src] has been squashed.</span>","<span class='warning'>You hear a smack.</span>")
		playsound(loc, 'sound/items/egg_squash.ogg', 50, 1)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	_color = "blue"

/obj/item/weapon/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	_color = "green"

/obj/item/weapon/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	_color = "mime"

/obj/item/weapon/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	_color = "orange"

/obj/item/weapon/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	_color = "purple"

/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	_color = "rainbow"

/obj/item/weapon/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	_color = "red"

/obj/item/weapon/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	_color = "yellow"

/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(W.reagents.amount_cache.len == 1 && W.reagents.has_reagent(FLOUR, 5))
			W.reagents.remove_reagent(FLOUR,5)
			new /obj/item/trash/egg(loc)
			new /obj/item/weapon/reagent_containers/food/snacks/dough(get_turf(src))
			to_chat(user, "You make some dough.")
			qdel(src)
			return 1
	else if (istype(W, /obj/item/toy/crayon) && can_color)

		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(user, "<span class='notice'>[src] refuses to take on this colour!</span>")
			return

		to_chat(user, "<span class='notice'>You colour [src] [clr].</span>")
		icon_state = "egg-[clr]"
		_color = clr
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/egg/proc/hatch()
	visible_message("[src] hatches with a quiet cracking sound.")
	new/obj/item/trash/egg(loc)
	new hatch_type(get_turf(src))
	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/vox
	name = "green egg"
	desc = "Looks like it came from some genetically engineered chicken."
	icon_state = "egg-vox"
	can_color = FALSE
	hatch_type = /mob/living/carbon/monkey/vox

/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice
	name = "cockatrice egg"
	desc = "On the first glance this cockatrice egg looks like a rock. It is safe to handle, although it may still contain some poison."
	icon_state = "egg-cockatrice"
	can_color = FALSE
	hatch_type = /mob/living/simple_animal/hostile/retaliate/cockatrice/chick

/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice/New()
	..()

	reagents.add_reagent(PETRITRICIN, rand(5,15)/10)

/obj/item/weapon/reagent_containers/food/snacks/egg/bigroach
	name = "mutated cockroach eggs"
	desc = "A bunch of strange-looking, weirdly glowing eggs."
	icon_state = "egg-bigroach"
	can_color = FALSE
	hatch_type = /mob/living/simple_animal/hostile/bigroach

/obj/item/weapon/reagent_containers/food/snacks/egg/bigroach/New()
	..()

	reagents.add_reagent(TOXIN, rand(5,15))
	reagents.add_reagent(RADIUM, rand(1,5))

/obj/item/weapon/reagent_containers/food/snacks/egg/parrot
	name = "parrot egg"
	desc = "This doesn't seem realistic. Its texture feels like that of a cracker, and is faceted in microscopic shards of plasma."
	icon_state = "egg-rainbow"
	can_color = FALSE
	hatch_type = /mob/living/simple_animal/parrot

/obj/item/weapon/reagent_containers/food/snacks/egg/chaos
	name = "chaos egg"
	desc = "Contents: Unknown. Origin: Unknown. Intent: Unknown. Potential: Unknown. Status: Scrambled."
	icon_state = "egg-chaos"
	can_color = FALSE

/obj/item/weapon/reagent_containers/food/snacks/egg/chaos/hatch()
	var/turf/T = get_turf(src)
	if(T)
		playsound(src, 'sound/effects/phasein.ogg', 100, 1)
		visible_message("\The [src] cracks open, revealing a realm of the unknown within. From that realm, something emerges.")
		var/choice = pick(existing_typesof(/mob/living/simple_animal) - (boss_mobs + blacklisted_mobs))
		new choice(T)
	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/chaos/instahatch/New()
	..()
	var/time = rand(3,10)
	spawn(time)
		if(!gcDestroyed)
			hatch()

var/snail_egg_count = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/snail
	name = "snail egg"
	desc = "Proud and arrogant, even before birth."
	icon_state = "egg-snail"
	can_color = FALSE
	hatch_type = /mob/living/simple_animal/snail

/obj/item/weapon/reagent_containers/food/snacks/egg/snail/New()
	processing_objects.Add(src)
	snail_egg_count++
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/egg/snail/Destroy()
	snail_egg_count--
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/egg/pomf
	name = "pomf egg"
	desc = "An ordinary egg. Yep. Definitely. But where's that voice coming from?"
	icon_state = "egg"
	hatch_type = /mob/living/simple_animal/chicken/pomf

/obj/item/weapon/reagent_containers/food/snacks/egg/pomf/examine(var/mob/user)
	..()
	spawn(30)
		var/list/egg_speak = list(
			"let me out",
			"it's cramped in here",
			"throw it",
			"fulfill your destiny",
			)
		to_chat(user,"<span class='sinister'>...[pick(egg_speak)]...</span>")

/obj/item/weapon/reagent_containers/food/snacks/egg/pomf/throw_impact(atom/hit_atom)
	new hatch_type(loc)
	playsound(loc, 'sound/items/egg_squash.ogg', 50, 1)
	playsound(loc, 'sound/voice/chicken.ogg', 50, 1)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/pomf/can_consume(mob/living/carbon/eater, mob/user)
	to_chat(user,"<span class='warning'>The shell is too hard for your teeth. Is that really an egg?</span>")
	return FALSE
