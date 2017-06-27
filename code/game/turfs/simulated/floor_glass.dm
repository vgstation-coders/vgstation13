/turf/simulated/floor/glass
	name = "glass floor"
	desc = "A floor made of reinforced glass, used for looking into the void."

	plane = PLANE_SPACE_BACKGROUND
	dynamic_lighting = 0
	luminosity = 1

	var/health=40 // same as rwindow.
	var/sheetamount = 1 //Number of sheets needed to build this floor (determines how much shit is spawned via Destroy())
	var/image/damage_overlay
	var/cracked_base = "fcrack"
	var/shardtype = /obj/item/weapon/shard
	var/sheettype = /obj/item/stack/sheet/glass/rglass //Used for deconstruction
	var/glass_state = "glass_floor" // State of the glass itself.

/turf/simulated/floor/glass/New(loc)
	..(loc)
	update_icon()

/turf/simulated/floor/glass/update_icon()
	overlays.Cut()
	if(!floor_overlay)
		floor_overlay = image('icons/turf/overlays.dmi', glass_state)
		//floor_overlay.plane = PLANE_SPACE_DUST
		floor_overlay.plane = TURF_PLANE
		floor_overlay.layer = TURF_LAYER
	overlays += floor_overlay

	if(!damage_overlay)
		damage_overlay = image('icons/obj/structures.dmi', "")
		damage_overlay.plane = TURF_PLANE
		damage_overlay.layer = TURF_LAYER

	if(health < initial(health))
		var/damage_fraction = Clamp(round((initial(health) - health) / initial(health) * 5) + 1, 1, 5) //gives a number, 1-5, based on damagedness
		damage_overlay.icon_state = "[cracked_base][damage_fraction]"
		overlays += damage_overlay

/turf/simulated/floor/glass/examine(var/mob/user)
	..()
	if(health >= initial(health)) //Sanity
		to_chat(user, "It's in perfect shape without a single scratch.")
	else if(health >= 0.8*initial(health))
		to_chat(user, "It has a few scratches and a small impact.")
	else if(health >= 0.5*initial(health))
		to_chat(user, "It has a few impacts with some cracks running from them.")
	else if(health >= 0.2*initial(health))
		to_chat(user, "It's covered in impact marks and most of the outer layer is cracked.")
	else
		to_chat(user, "It's cracked over multiple layers and has many impact marks.")

/turf/simulated/floor/glass/proc/break_turf()
	if(loc)
		playsound(get_turf(src), "shatter", 70, 1)
	spawnBrokenPieces()
	ReplaceWithLattice()

/turf/simulated/floor/glass/proc/spawnBrokenPieces()
	getFromPool(shardtype, loc, sheetamount)
	getFromPool(/obj/item/stack/rods, loc, sheetamount)

/turf/simulated/floor/glass/proc/healthcheck(var/mob/M, var/sound = 1)
	if(health <= 0)
		break_turf()
	else
		if(sound)
			playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
		update_icon()


/turf/simulated/floor/glass/levelupdate()
	update_holomap_planes()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(FALSE) // ALWAYS show subfloor stuff.

/turf/simulated/floor/glass/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck(Proj.firer)
	return
/turf/simulated/floor/glass/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= rand(100, 150)
			healthcheck()
			return
		if(2.0)
			health -= rand(20, 50)
			healthcheck()
			return
		if(3.0)
			health -= rand(5, 15)
			healthcheck()
			return

/turf/simulated/floor/glass/Entered(var/atom/movable/mover)
	if(ishuman(mover))
		var/mob/living/carbon/human/H = mover
		// Fatties damage glass.
		if(M_FAT in H.mutations)
			H.visible_message("<span class='warning'>[H] damages \the [src] with \his[H] sheer weight!</span>",
			"<span class='warning'>You damage \the [src] with your sheer weight!</span>",
			"<span class='italics'>You hear glass cracking!</span>")
			health -= rand(5, 20)
			healthcheck(H)
	if(istype(mover,/obj/mecha))
		var/obj/mecha/M = mover
		M.visible_message("<span class='warning'>\The [M] damages \the [src] with its sheer weight!</span>",
		"<span class='warning'>You damage \the [src] with your sheer weight!</span>",
		"<span class='italics'>You hear glass cracking!</span>")
		health -= rand(20, 40)
		healthcheck()

	return 1

//Someone threw something at us, please advise
/turf/simulated/floor/glass/hitby(AM as mob|obj)

	..()
	if(ismob(AM))
		var/mob/M = AM //Duh
		health -= 10 //We estimate just above a slam but under a crush, since mobs can't carry a throwforce variable
		healthcheck(M)
		visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
		"<span class='danger'>You slam into \the [src].</span>")
	else if(isobj(AM))
		var/obj/item/I = AM
		health -= I.throwforce
		healthcheck()
		visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")

/turf/simulated/floor/glass/attack_hand(mob/living/user as mob)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
		health -= 25
		healthcheck()
		user.delayNextAttack(8)

	//Bang against the window
	else if(usr.a_intent == I_HURT)
		user.do_attack_animation(src, user)
		user.delayNextAttack(10)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")

	//Knock against it
	else
		user.delayNextAttack(10)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] knocks on \the [src].</span>", \
		"<span class='notice'>You knock on \the [src].</span>", \
		"You hear knocking.")
	return

/turf/simulated/floor/glass/attack_paw(mob/user as mob)
	return attack_hand(user)

/turf/simulated/floor/glass/proc/attack_generic(mob/living/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime

	user.do_attack_animation(src, user)
	user.delayNextAttack(10)
	health -= damage
	user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>", \
	"<span class='danger'>You smash into \the [src]!</span>")
	healthcheck(user)

/turf/simulated/floor/glass/attack_alien(mob/user as mob)

	if(islarva(user))
		return
	attack_generic(user, 15)

/turf/simulated/floor/glass/attack_animal(mob/user as mob)

	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/turf/simulated/floor/glass/attack_slime(mob/user as mob)
	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15))

/turf/simulated/floor/glass/plasma
	name = "plasma glass floor"
	desc = "A floor made of reinforced plasma glass, used for looking into the void."
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmarglass
	glass_state = "plasma_glass_floor"
	health = 160
