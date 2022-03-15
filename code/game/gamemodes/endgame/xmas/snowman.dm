/obj/structure/snowman
	name = "snowman"
	desc = "Just an inanimate facsimile of a human. It looks like it could use a nose and a hat."
	icon_state = "snowman"
	icon='icons/mob/snowman.dmi'
	anchored = TRUE
	density = TRUE
	var/obj/item/clothing/head/hat = null
	var/obj/item/carrot = null
	var/health = 40

/obj/structure/snowman/Destroy()
	qdel(hat)
	hat = null
	qdel(carrot)
	carrot = null
	..()

/obj/structure/snowman/attackby(obj/item/weapon/W, mob/user)
	if(!carrot && istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/carrot))
		if(user.drop_item(W, src))
			carrot = W
			overlays += image(icon = icon, icon_state = "snowman_carrot")
			come_to_life()
	else if(!hat && istype(W,/obj/item/clothing/head/))
		if(user.drop_item(W, src))
			hat = W
			overlays += image('icons/mob/head.dmi', hat.icon_state)
			come_to_life()
	else if(isshovel(W))
		for(var/i = 1 to 5)
			new /obj/item/stack/sheet/snow(loc, 4)
		dropall()
		playsound(loc, 'sound/items/shovel.ogg', 50, 1)
		qdel(src)
	else
		visible_message("<span class='danger'>[user] hits \the [src] with \a [W].</span>")
		user.delayNextAttack(8)
		user.do_attack_animation(src, W)
		if (W.hitsound)
			playsound(src, W.hitsound, 50, 1, -1)
		takedamage(W.force)

/obj/structure/snowman/bullet_act(var/obj/item/projectile/Proj)
	takedamage(Proj.damage)
	return ..()

/obj/structure/snowman/proc/takedamage(var/dam)
	health -= dam
	if(health<=0)
		dropall()
		new /obj/item/stack/sheet/snow(loc, 4)
		qdel(src)

/obj/structure/snowman/proc/dropall()
	if(carrot)
		carrot.forceMove(loc)
		carrot = null
	if(hat)
		hat.forceMove(loc)
		hat = null

/obj/structure/snowman/proc/come_to_life()
	if(hat && hat.wizard_garb && carrot)
		say(pick("Happy birthday! Hey... I said my first words!","I can make words, I can move!","Could... could I really be alive?"))
		if(!hat.gave_out_gifts)
			hat.gave_out_gifts = TRUE
			for(var/i = 1 to 6)
				call(/obj/item/weapon/winter_gift/proc/pick_a_gift)(loc)
		new /mob/living/simple_animal/hostile/retaliate/snowman(loc, hat)
		hat = null //to avoid deletion
		qdel(src)

/mob/living/simple_animal/hostile/retaliate/snowman
	name = "snowman"
	desc = "It's alive! There must have been some magic in that hat the crew found."
	icon_state = "snowman-full"
	icon_living = "snowman-full"
	icon_dead = ""
	icon='icons/mob/snowman.dmi'
	speak = list("Good day sir.","Cold day, isn't it?","What a pleasant weather.")
	speak_emote = list("says")
	emote_hear = list("says")
	emote_see = list("hums")
	speak_chance = 2.5
	turns_per_move = 3
	response_help  = "hugs"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	friendly = "hugs"
	faction = "snow"
	health = 40
	ranged = 1
	retreat_distance = 5
	minimum_distance = 3
	projectilesound = 'sound/weapons/punchmiss.ogg'
	projectiletype = /obj/item/projectile/snowball
	environment_smash_flags = 0

	can_butcher = 0

	minbodytemp = 0
	maxbodytemp = MELTPOINT_SNOW
	heat_damage_per_tick = 5
	bodytemperature = 270

	var/obj/item/hat = null

/mob/living/simple_animal/hostile/retaliate/snowman/New(loc,nhat)
	..()
	hat = nhat
	if(hat)
		hat.forceMove(src)
	else
		for(var/obj/item/clothing/head/H in loc)
			hat = H
			H.forceMove(src)
			break
	if(hat)
		overlays += image('icons/mob/head.dmi', hat.icon_state)

/mob/living/simple_animal/hostile/retaliate/snowman/Destroy()
	if(hat)
		hat.forceMove(get_turf(src))
		hat = null
	overlays.Cut()
	..()

/mob/living/simple_animal/hostile/retaliate/snowman/Life()
	if(timestopped)
		return 0 //under effects of time magick

	..()

	if(stat)
		death(1)

	if(enemies.len && prob(5))
		enemies = list()
		LoseTarget()
		say("Whatever.")

	if(fire_alert)
		say(pick("Oh god the heat...","I'm meltiiinggg...","Someone turn off the heater!"))

	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/snowman/death(gibbed)
	visible_message("<span class='game say'><span class='name'>[name]</span> murmurs, \"[pick("Oh my snowballs...","I will...be back...")]\"</span>")
	visible_message("\the [src] collapses in a pile of snow.")
	var/turf/T = get_turf(src)
	new /obj/item/stack/sheet/snow(T, 1)
	new /obj/item/stack/sheet/snow(T, 1)
	new /obj/item/stack/sheet/snow(T, 1)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(T)
	animal_count[src.type]--
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/snowman/Retaliate()
	..()
	if(!stat)
		src.say(pick("You, come fight me!","I say!","Coward!"))

/obj/item/projectile/snowball
	name = "flying snowball"
	desc = "Think fast!"
	icon = 'icons/obj/items.dmi'
	icon_state = "snow"
	nodamage = 1
	stun = 1
	weaken = 1
	stutter = 1

/obj/item/projectile/snowball/to_bump(atom/A as mob|obj|turf|area)
	.=..()
	if(.)
		playsound(A.loc, "swing_hit", 50, 1)
		if(istype(A,/mob/living/carbon/))
			var/mob/living/carbon/C = A
			if (M_RESIST_COLD in C.mutations)
				return
			if(C.bodytemperature >= SNOWBALL_MINIMALTEMP)
				C.bodytemperature -= 5

/mob/living/simple_animal/hostile/retaliate/snowman/dead/Life()
	return 0
