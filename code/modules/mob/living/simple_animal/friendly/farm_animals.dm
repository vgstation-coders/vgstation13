//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = "goat"
	attacktext = "kicks"
	health = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	size = SIZE_BIG

	var/datum/reagents/udder = null

/mob/living/simple_animal/hostile/retaliate/goat/New()
	udder = new(50)
	udder.my_atom = src
	..()

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	if(timestopped) return 0 //under effects of time magick
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			enemies = list()
			LoseTarget()
			src.visible_message("<span class='notice'>[src] calms down.</span>")

		if(stat == CONSCIOUS)
			if(udder && prob(5))
				udder.add_reagent(MILK, rand(5, 10))

		if(locate(/obj/effect/plantsegment) in loc)
			var/obj/effect/plantsegment/SV = locate(/obj/effect/plantsegment) in loc
			SV.die_off()
			if(prob(10))
				say("Nom")

		if(!pulledby)
			for(var/direction in shuffle(alldirs))
				var/step = get_step(src, direction)
				if(step)
					if(locate(/obj/effect/plantsegment) in step)
						Move(step)

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	if(!stat)
		..()
		src.visible_message("<span class='warning'>[src] gets an evil-looking gleam in \his eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	..()
	if(!stat)
		if(locate(/obj/effect/plantsegment) in loc)
			var/obj/effect/plantsegment/SV = locate(/obj/effect/plantsegment) in loc
			SV.die_off()
			if(prob(10))
				say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, MILK, rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>[O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()
//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 50

	size = SIZE_BIG
	holder_type = /obj/item/weapon/holder/animal/cow

	var/datum/reagents/udder = null

/mob/living/simple_animal/cow/New()
	udder = new(50)
	udder.my_atom = src
	..()

/mob/living/simple_animal/cow/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, MILK, rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>[O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()

/mob/living/simple_animal/cow/Life()
	if(timestopped) return 0 //under effects of time magick
	. = ..()
	if(stat == CONSCIOUS)
		if(udder && prob(5))
			udder.add_reagent(MILK, rand(5, 10))

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M as mob)
	if(!stat && M.a_intent == I_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Weaken(30)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				var/list/responses = list(	"[src] looks at you imploringly.",
											"[src] looks at you pleadingly",
											"[src] looks at you with a resigned expression.",
											"[src] seems resigned to its fate.")
				to_chat(M, pick(responses))
	else
		..()

/mob/living/simple_animal/chick
	name = "chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	speak_chance = 2
	turns_per_move = 2
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	species_type = /mob/living/simple_animal/chicken
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 1
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE
	size = SIZE_TINY

/mob/living/simple_animal/chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life()
	if(timestopped) return 0 //under effects of time magick
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)

/mob/living/simple_animal/chicken
	name = "chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken"
	icon_living = "chicken"
	icon_dead = "chicken_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	speak_chance = 2
	turns_per_move = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 10
	var/eggsleft = 0
	var/body_color
	pass_flags = PASSTABLE
	size = SIZE_SMALL

/mob/living/simple_animal/chicken/New()
	if(prob(5))
		name = "Pomf chicken"
		body_color = "white"

	if(!body_color)
		body_color = pick( list("brown","black","white") )
	icon_state = "chicken_[body_color]"
	icon_living = "chicken_[body_color]"
	icon_dead = "chicken_[body_color]_dead"
	..() //call this after icons to generate the proper static overlays
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chicken/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat)) //feedin' dem chickens
		if(!stat && eggsleft < 8)
			if(!user.drop_item(O))
				user << "<span class='notice'>You can't let go of \the [O]!</span>"
				return

			user.visible_message("<span class='notice'>[user] feeds [O] to [name]! It clucks happily.</span>","<span class='notice'>You feed [O] to [name]! It clucks happily.</span>")
			qdel(O)
			eggsleft += rand(1, 4)
//			to_chat(world, eggsleft)
		else
			to_chat(user, "<span class='notice'>[name] doesn't seem hungry!</span>")
	else if(istype(O, /obj/item/weapon/dnainjector))
		var/obj/item/weapon/dnainjector/I = O
		I.inject(src, user)
	else
		..()

/mob/living/simple_animal/chicken/Life()
	if(timestopped) return 0 //under effects of time magick
	. =..()
	if(!.)
		return
	if(!stat && prob(3) && eggsleft > 0)
		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
		eggsleft--
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = new(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(animal_count[src.type] < ANIMAL_CHILD_CAP && prob(10))
			processing_objects.Add(E)

#define BOX_GROWTH_BAR 200
/mob/living/simple_animal/hostile/retaliate/box
	name = "box"
	desc = "A distant descendent of the common domesticated Earth pig, corrupted by generations of splicing and genetic decay."
	icon_state = "box_2"
	icon_living = "box_2"
	icon_dead = "box_2_dead"
	speak = list("SQUEEEEE!","Oink...","Oink, oink", "Oink, oink, oink", "Oink!", "Oiiink.")
	emote_hear = list("squeals hauntingly")
	emote_see = list("roots about","squeals hauntingly")
	speak_chance = 1
	turns_per_move = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/box
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 60
	melee_damage_lower = 10
	melee_damage_upper = 12 //Those tusk will maul you!
	size = SIZE_SMALL
	min_oxy = 0
	max_oxy = 1
	min_n2 = 5
	max_n2 = 0
	treadmill_speed = 1.5
	var/fat = 0

/mob/living/simple_animal/hostile/retaliate/box/proc/updatefat()
	if(size<SIZE_BIG)
		size++
		fat = 0
	update_icon()

/mob/living/simple_animal/hostile/retaliate/box/update_icon()
	icon_state = "box_[size]"
	icon_living = "box_[size]"
	icon_dead = "box_[size]_dead"

/mob/living/simple_animal/hostile/retaliate/box/examine(mob/user)
	..()
	switch(size)
		if(SIZE_SMALL)
			to_chat(user, "<span class='info'>It's a box baby.</span>")
		if(SIZE_NORMAL)
			to_chat(user, "<span class='info'>It's a respectable size.</span>")
		if(SIZE_BIG)
			to_chat(user, "<span class='info'>It's huge - a prize winning porker!</span>")

/mob/living/simple_animal/hostile/retaliate/box/CanAttack(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(isvox(H)) return 0 //Won't attack Vox
	else ..()

/mob/living/simple_animal/hostile/retaliate/box/Life()
	. = ..()
	if(size<SIZE_BIG)
		fat += rand(2)
	if(fat>BOX_GROWTH_BAR)
		updatefat()

/mob/living/simple_animal/hostile/retaliate/box/death()
	..()
	playsound(src, 'sound/effects/box_scream.ogg', 100, 1)

/mob/living/simple_animal/hostile/retaliate/box/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom)) //Pigs like mushrooms
		if(!stat && size < SIZE_BIG)
			if(!user.drop_item(O))
				user << "<span class='notice'>You can't let go of \the [O]!</span>"
				return

			user.visible_message("<span class='notice'>[user] feeds [O] to [name].</span>","<span class='notice'>You feed [O] to [name].</span>")
			qdel(O)
			fat += rand(15,25)
	else ..()
