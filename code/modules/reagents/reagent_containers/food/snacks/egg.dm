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
	reagents.add_reagent(NUTRIMENT, 4)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/egg/process()
	if(is_in_valid_nest(src)) //_macros.dm
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			hatch()
	else
		processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	if(isturf(hit_atom))
		new/obj/effect/decal/cleanable/egg_smudge(loc)
		splat_reagent_reaction(hit_atom)
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
	new hatch_type(get_turf(src))
	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/vox
	name = "green egg"
	desc = "Looks like it came from some genetically engineered chicken"
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
	playsound(src, 'sound/effects/phasein.ogg', 100, 1)
	visible_message("\The [src] cracks open, revealing a realm of the unknown within. From that realm, something emerges.")
	var/choice = pick(existing_typesof(/mob/living/simple_animal) - (boss_mobs + blacklisted_mobs))
	new choice(get_turf(src))
	processing_objects.Remove(src)
	qdel(src)
