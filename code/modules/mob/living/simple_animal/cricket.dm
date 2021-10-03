/mob/living/simple_animal/cricket
	name = "space cricket"
	desc = "Much larger than its Earth cousin due to low gravity. Unlike in the case of bush crickets, Katy didn't."

	size = SIZE_TINY

	icon_state = "cricket"
	icon_living = "cricket"
	icon_dead = "cricket-dead"

	emote_hear = list("chirps")
	emote_sound = list("sound/effects/cricket_chirp.ogg")

	pass_flags = PASSTABLE | PASSGRILLE | PASSMACHINE

	speak_chance = 5

	maxHealth = 4
	health = 4

	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "stomps on"

	faction = "neutral"

	density = 0

	minbodytemp = 273.15		//Can't survive at below 0 C
	maxbodytemp = INFINITY

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	plane = HIDING_MOB_PLANE

	treadmill_speed = 0
	turns_per_move = 2 //2 life ticks / move

	size = SIZE_TINY
	stop_automated_movement_when_pulled = 0

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/cricket
	held_items = list()

/mob/living/simple_animal/cricket/New()
	..()

	pixel_x = rand(-20, 20) * PIXEL_MULTIPLIER
	pixel_y = rand(-20, 20) * PIXEL_MULTIPLIER

	maxHealth = rand(1,6)
	health = maxHealth
	global_cricket_population++

/mob/living/simple_animal/cricket/death(var/gore = 1)
	if(gore)

		var/obj/effect/decal/remains = new /obj/effect/decal/cleanable/cricket_remains(loc)
		remains.dir = dir
		remains.pixel_x = pixel_x
		remains.pixel_y = pixel_y
		remains.icon_state = "cricket_remains[pick(1,2)]"

		playsound(src, pick('sound/effects/gib1.ogg','sound/effects/gib2.ogg','sound/effects/gib3.ogg'), 40, 1) //Splat

		..()

		qdel(src)

	else

		return ..()

/mob/living/simple_animal/cricket/Crossed(mob/living/O)
	if(!istype(O))
		return
	if(O.a_intent == I_HELP)
		return //Must be on harm intent to stomp
	if(O.isUnconscious())
		return

	if(prob(15))
		death(gore = 1)

/mob/living/simple_animal/cricket/wander_move(turf/dest)
	..()
	var/godir = rand(-20,20)
	var/halfway = round((godir-pixel_x)/2)
	//- moving left. + moving right.
	flick("cricket-hop")
	animate(src, pixel_x = pixel_x - halfway, pixel_y = pixel_y + 4 * PIXEL_MULTIPLIER, 2, 1, ELASTIC_EASING)
	animate(src, pixel_x = pixel_x - halfway, pixel_y = pixel_y - 4 * PIXEL_MULTIPLIER, 3, 1, ELASTIC_EASING).

/mob/living/simple_animal/cricket/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()

	if(!flying)
		reset_plane_and_layer() //Since cucarachas can hide under trash (which modifies their layer), this is kinda necessary

/mob/living/simple_animal/cricket/proc/hop(var/anim = 1)
	if(isUnconscious())
		return

	speed = 1
	turns_since_move = 5 //Remove any delay

	icon_state = "cockroach_fly"

	flying = 1
	speak_chance = 5

	turns_per_move = 1

	response_help  = "attempts to pet"
	response_disarm = "tries to catch"
	response_harm   = "swats"

	plane = MOB_PLANE

	if(anim)



/mob/living/simple_animal/cricket/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/newspaper))
		user.visible_message("<span class='danger'>[user] swats \the [src] with \the [W]!</span>", "<span class='danger'>You swat \the [src] with \the [W].</span>")
		W.desc = "[initial(W.desc)] <span class='notice'>There is a splattered [src] on the back.</span>"

		adjustBruteLoss(5)
	else if(istype(W, /obj/item/weapon/plantspray/pests))
		var/obj/item/weapon/plantspray/pests/P = W
		if(P.use(1))
			to_chat(user, "You spray \the [src] with \the [P].")
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			death(gore = 0)
	else
		return ..()

/mob/living/simple_animal/cricket/reagent_act(id, method, volume)
	if(isDead())
		return

	.=..()

	switch(id)
		if(TOXIN, INSECTICIDE)
			if(method != INGEST)
				death(gore = 0)

/mob/living/simple_animal/cricket/bite_act(mob/living/carbon/human/H)
	if(size >= H.size)
		return

	playsound(H,'sound/items/eatfood.ogg', rand(10,50), 1)
	H.visible_message("<span class='notice'>[H] eats \the [src]!</span>", "<span class='notice'>You eat \the [src]!</span>")

	death(gore = 1)
	qdel(src)

	H.vomit()
