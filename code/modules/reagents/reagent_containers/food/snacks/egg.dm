// Eat these

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"

	var/can_color = 1
	var/amount_grown = 0

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
	new/obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.reaction(hit_atom, TOUCH)
	src.visible_message("<span class='warning'>\The [src.name] has been squashed.</span>","<span class='warning'>You hear a smack.</span>")
	playsound(src.loc, 'sound/items/egg_squash.ogg', 50, 1)
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
			new /obj/item/weapon/reagent_containers/food/snacks/dough(src)
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
	new /mob/living/simple_animal/chick(get_turf(src))
	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/vox
	name = "green egg"
	desc = "Looks like it came from some genetically engineered chicken"
	icon_state = "egg-vox"
	can_color = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/vox/hatch()
	visible_message("[src] hatches with a quiet cracking sound.")
	new /mob/living/carbon/monkey/vox(get_turf(src))
	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice
	name = "cockatrice egg"
	desc = "A very hard egg. Its thick shell makes it safe to handle, as long as you don't break it and touch the embryo inside."
	icon_state = "egg-cockatrice"
	can_color = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice/hatch()
	visible_message("\The [src] hatches with a quiet cracking sound.")
	new /mob/living/simple_animal/hostile/retaliate/cockatrice/chick(get_turf(src))
	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice/On_Consume(mob/living/user, datum/reagents/reagentreference)
	if(user && user.held_items.Find(src))
		if(user.turn_into_statue(1))
			to_chat(user, "<span class='danger'>You've been turned to stone by \the [src].</span>")
		else
			to_chat(user, "<span class='info'>You feel very lucky.</span>")
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/egg/cockatrice/throw_impact(atom/hit_atom)
	.=..()

	if(isliving(hit_atom))
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			var/armor = H.getarmor(null, "bio") + H.getarmor(null, "melee")
			if(armor < rand(75,100))
				for(var/datum/disease/petrification/P in H.viruses) //If already petrifying, speed up the process!
					P.stage = P.max_stages
					P.stage_act()
					return 1

				var/datum/disease/D = new /datum/disease/petrification
				D.holder = H
				D.affected_mob = H
				H.viruses += D
				to_chat(H, "<span class='info'>You feel worried.</span>")
		else
			var/mob/living/L = hit_atom
			if(L.turn_into_statue(1)) //Statue forever
				L.visible_message("<span class='danger'>\The [L] has been turned to stone!</span>")
