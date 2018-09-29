
/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	density = 1
	anchored = 1
	var/broken = 0
	var/processing = 0
	var/opened = 0.0

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	var/time_coeff = 1

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/processor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/processor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/processor/RefreshParts()
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
	time_coeff = 2/manipcount

/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	proc/process(loc, what)
		if (src.output && loc)
			new src.output(loc)
		if (what)
			qdel(what)
			what = null

	/* objs */

	poison
		input = null
		output = null
		process(loc, atom/movable/what)
			if(loc && istype(what,/obj/item/weapon/reagent_containers/food/snacks/meat))
				var/obj/item/weapon/reagent_containers/food/snacks/meat/M = what
				if(M.poisonsacs)
					M.poisonsacs.forceMove(loc)
					M.poisonsacs = null
					M.desc = "An excellent [M.name]!"
					M.reagents.del_reagent(TOXIN)
					M.reagents.del_reagent(CARPOTOXIN)
				what.forceMove(loc)

	poison/spiderleg
		input = /obj/item/weapon/reagent_containers/food/snacks/meat/spiderleg

	poison/spidermeat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat

	poison/carpmeat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat

	meat
		input = /obj/item/weapon/reagent_containers/food/snacks/meat
		output = /obj/item/weapon/reagent_containers/food/snacks/faggot

	potato
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
		output = /obj/item/weapon/reagent_containers/food/snacks/fries

	carrot
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
		output = /obj/item/weapon/reagent_containers/food/snacks/carrotfries

	soybeans
		input = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
		output = /obj/item/weapon/reagent_containers/food/snacks/soydope

	/* mobs */
	mob
		process(loc, what)
			..()


		slime

			process(loc, what)

				var/mob/living/carbon/slime/S = what
				var/C = S.cores
				if(S.stat != DEAD)
					S.forceMove(loc)
					S.visible_message("<span class='notice'>[C] crawls free of the processor!</span>")
					return
				for(var/i = 1, i <= C, i++)
					new S.coretype(loc)
					feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
				..()
			input = /mob/living/carbon/slime
			output = null

		monkey
			process(loc, what)
				var/mob/living/carbon/monkey/O = what
				if (O.client) //grief-proof
					O.forceMove(loc)
					O.visible_message("<span class='notice'>[O] suddenly jumps out of [src]!</span>", \
							"You jump out from the processor", \
							"You hear a slimy sound")
					return
				var/obj/item/weapon/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
				O.take_blood(bucket_of_blood, 70)
				..()

			input = /mob/living/carbon/monkey
			output = null

		chicken
			process(loc, what)
				playsound(loc, 'sound/machines/ya_dun_clucked.ogg', 50, 1)
				..()
			input = /mob/living/simple_animal/chicken
			output = /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets

		chick
			process(loc, what)
				playsound(loc, 'sound/machines/ya_dun_clucked.ogg', 50, 1)
				..()
			input = /mob/living/simple_animal/chick
			output = /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets

		human
			process(loc, what)
				var/mob/living/carbon/human/target = what
				if (istype(target.wear_suit,/obj/item/clothing/suit/chickensuit) && istype(target.head,/obj/item/clothing/head/chicken))
					target.visible_message("<span class='danger'>Bwak! Bwak! Bwak!</span>")
					playsound(loc, 'sound/machines/ya_dun_clucked.ogg', 50, 1)
					target.canmove = 0
					target.icon = null
					target.invisibility = 101
					target.setDensity(FALSE)
					var/throwzone = list()
					for(var/turf/T in orange(loc,4))
						throwzone += T
					for(var/obj/I in target.contents)
						I.forceMove(loc)
						I.throw_at(pick(throwzone),rand(2,5),0)
					hgibs(loc, target.viruses, target.dna, target.species.flesh_color, target.species.blood_color)
					qdel(target)
					target = null
					for(var/i = 1;i<=6;i++)
						new /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets(loc)
						sleep(2)
					..()
				else
					target.forceMove(loc)
					target.visible_message("<span class='danger'>The processor's safety protocols won't allow it to cut something that looks human!</span>")
			input = /mob/living/carbon/human
			output = null

/obj/machinery/processor/proc/select_recipe(var/X)
	for (var/Type in typesof(/datum/food_processor_process) - /datum/food_processor_process - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/crowbarDestroy(mob/user)
	if(contents.len)
		to_chat(user, "You can't do that while something is loaded in \the [src].")
		return -1
	return ..()

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.processing)
		to_chat(user, "<span class='warning'>[src] is already processing!</span>")
		return 1

	if(..())
		return 1
	if(src.contents.len > 0) //TODO: several items at once? several different items?
		to_chat(user, "<span class='warning'>Something is already in [src]</span>.")
		return 1
	var/atom/movable/what = O
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)
	if (!P)
		to_chat(user, "<span class='warning'>This probably won't blend.</span>")
		return 1
	user.visible_message("<span class='notice'>[user] puts [what] into [src].</span>", \
		"You put [what] into the [src].")
	if(what == user.get_active_hand())
		user.drop_item(what, src)
	else
		if(O.loc == user)
			user.drop_item(O)
		what.forceMove(src)
	return

/obj/machinery/processor/attack_hand(var/mob/user as mob)
	if (src.stat != 0) //NOPOWER etc
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
		return
	if(src.processing)
		to_chat(user, "<span class='warning'>[src] is already processing!</span>")
		return 1
	if(src.contents.len == 0)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor is not suitable. How did you put it in?") //-rastaf0
			continue
		src.processing = 1
		user.visible_message("<span class='notice'>[user] turns on [src]</span>.", \
			"You turn on \a [src].", \
			"You hear [src] start")
		playsound(src, 'sound/machines/blender.ogg', 50, 1)
		use_power(500)
		sleep(P.time*time_coeff)
		P.process(src.loc, O)
		src.processing = 0
	src.visible_message("<span class='notice'>[src] is done.</span>", \
		"You hear [src] stop.")

/obj/machinery/processor/attack_ghost(mob/user as mob)
	user.examination(src)

/obj/machinery/processor/MouseDropTo(atom/movable/O, mob/user)
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O))
		return
	if(user.incapacitated() || user.lying)
		return
	if(O.anchored || !Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src))
		return
	if(!ishigherbeing(user) && !isrobot(user))
		return
	attackby(O,user)
