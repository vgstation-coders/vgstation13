/obj/structure/stool/bed/chair/clowncart
	name = "clowncart"
	desc = "Transport of the future, an advanced cart that runs on banana essence - an environmentally clean fuel extracted from bananas. A coin slot on its side is used for unlocking new features."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "clowncar"
	anchored = 1
	density = 1
	//copypaste sorry
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
	var/empstun = 0
	var/health = 100
	var/destroyed = 0
	var/activated = 0 //honk to activate, it stays active while you sit in it, and will deactivate when you unbuckle
	var/fuel = 0 //banana-type items add fuel, you can't ride without fuel
	var/mode = 0 	//0 - normal, 1 - leave grafitti behind, 2 - leave banana peels behind
					//modes 1 and 2 consume extra fuel
					//use bananium coins to cycle between modes
	var/maximum_health = 100 //bananium increases maximum health by 20
	var/printing_text = "nothing"	//what is printed on the ground in mode 1
	var/printing_pos				//'rune' draws runes and 'graffiti' draws graffiti, other draws text
	var/trail //trail from banana pie
	var/colour1 = "#FF1111"
	var/colour2 = "#FFFF22"	//can't change it yet, sadly
	var/emagged = 0			//does nothing yet
	var/honk				//if you honk too much, explode
/obj/structure/stool/bed/chair/clowncart/process()
	icon_state = "clowncar"
	if(empstun > 0) empstun--
	if(honk > 0) honk -= 2
	if(honk < 0) honk = 0
	if(empstun < 0)
		empstun = 0
	if(activated) //activated and nobody sits in it
		icon_state = "clowncar_active"
		if(!buckled_mob)
			activated = 0
			icon_state = "clowncar"
	if(fuel < 0)
		fuel = 0
	if(trail < 0)
		trail = 0

/obj/structure/stool/bed/chair/clowncart/New()
	fuel = 0

	processing_objects |= src
	handle_rotation()

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

/obj/structure/stool/bed/chair/clowncart/examine()
	set src in usr
	usr << "\icon[src] [desc]"
	usr << "This honkin' ride contains [fuel] unit\s of banana essence!"
	if(maximum_health > 100)
		usr << "It is reinforced with [(maximum_health-100)/20] bananium sheets."
	switch(health)
		if(maximum_health*0.5 to maximum_health)
			usr << "\blue It appears slightly dented."
		if(1 to maximum_health*0.5)
			usr << "\red It appears heavily dented."
		if((INFINITY * -1) to 0)
			usr << "It appears completely unsalvageable"

/obj/structure/stool/bed/chair/clowncart/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/bikehorn))
		if(destroyed)
			user << "\red The [src.name] is destroyed beyond repair."
			return
		add_fingerprint(user)
		user.visible_message("\blue [user] honks at the [src].", "\blue You honk at \the [src]")
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		if(fuel <= 5)
			if(activated)
				src.visible_message("\red The [src.name] lets out a last honk before running out of fuel.")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				activated = 0
				fuel = 0
			else
				user << "\red The [src.name] doesn't have enough banana essence!"
		else
			spawn(5)
				activated = 1
				src.visible_message("\blue The [src.name] honks back happily.")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				fuel -= 5 //honking costs 5 fuel
				honk++
				if(honk == 4)
					user << "\red You don't think this is a good idea."
				if(honk == 8)
					user << "\red The [src.name] starts to overheat!"
				if(honk >= 12)
					fuel = round(fuel * 0.5)
					explosion(src.loc,-1,0,3,7,10)
					health -= 30
					honk = 0
	//banana type items add fuel to the ride
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice))
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		fuel += 75
		del(W)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/banana))
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		fuel += 100
		del(W)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread))
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		fuel += 375
		del(W)
	else if(istype(W, /obj/item/weapon/bananapeel)) //banana peels
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		fuel += 5
		health += 5 //banana peels repair some of the damage
		empstun = 0 //and disable emp stun
		del(W)
	else if(istype(W, /obj/item/seeds/bananaseed)) //banana seeds
		user.visible_message("\blue [user] repairs the [src] with the [W.name].", "\blue You repair the [src] with the [W.name].")
		health += 50 //banana seeds repair a lot of damage
		del(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/clown)) //bananium
		user << "\blue You reinforce the [src] with [W.name]."
		fuel += 250
		maximum_health += 20
		health += 20

		var/obj/item/stack/ST = W
		ST.use(1)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/pie)) //banana pie
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		playsound(get_turf(src), 'sound/effects/bubbles.ogg', 50, 1)
		usr << "\red The [W.name] starts boiling inside the [src]!"
		fuel += 175
		trail += 5
		del(W)
	else if(istype(W, /obj/item/weapon/coin/clown)) //bananium coin
		user.visible_message("\red [user] inserts a coin in the [src].", "\blue You insert a coin in the [src].")
		playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
		mode += 1
		if(mode > 2) //only 3 modes, so when it raises above 2 reset to 0
			mode = 0
		switch(mode)
			if(0)
				spawn(5)
					user << "\red The SynthPeel Generator turns off with a buzz."
					playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			if(1)
				user << "\blue SmartCrayon II appears under the [src], ready to draw!"
				user << "Use a crayon to decide what you want to draw."
			if(2)
				user << "\red The SmartCrayon II disappears in a puff of art!"
				spawn(5)
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
					user << "\blue You hear a ping as the SynthPeel Generator starts transforming banana essence into slippery peels."
		del(W)
	else if(istype(W, /obj/item/toy/crayon/)) //any crayon
		if(mode == 1)
			printing_text = input(user, "Enter a message to print. To draw runes and graffiti, type 'rune' and 'graffiti' respectively.", "Message", printing_text)
			printing_pos = 0
			user << "\blue Now printing the following text: [printing_text]"
	else if(istype(W, /obj/item/weapon/card/emag)) //emag
		if(!emagged)
			emagged = 1
			src.visible_message("\red [src.name]'s eyes glow red for a second.")

/obj/structure/stool/bed/chair/clowncart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(empstun > 0)
		if(user)
			user << "\red \the [src] is unresponsive."
		return
	if(fuel <= 0) //no fuel
		if(user)
			user << "\red \the [src] has no fuel!"
			activated = 0
		return
	if(activated)
		var/old_pos = get_turf(src)
		step(src, direction)
		if(get_turf(src) <> old_pos) //if we actually moved
			if(maximum_health < 300) fuel -= 1 //10 sheets of bananium required to drive without using fuel

			if(mode == 1) //graffiti
				if(printing_text != "nothing" && printing_text != "")
					fuel -= 2
					if(printing_text == "graffiti" || printing_text == "rune")
						new /obj/effect/decal/cleanable/crayon(old_pos, colour1, colour2, printing_text)
					else
						if(dir == WEST || dir == NORTH) //if going left or up
							if(printing_pos >= 0)
								printing_pos = -length(printing_text)-1 //indian code magic
						printing_pos++
						new /obj/effect/decal/cleanable/crayon(old_pos, colour1, colour2, copytext(printing_text, abs(printing_pos), 1+abs(printing_pos)))
						if(printing_pos > length(printing_text) - 1 || printing_pos == - 1)
							printing_text = ""
							printing_pos = 0
			if(mode == 2) //peel
				new /obj/item/weapon/bananapeel/(old_pos)
				fuel -= 4
			if(trail > 0)
				new /obj/effect/decal/cleanable/pie_smudge/(old_pos)
				trail--
		update_mob()
		handle_rotation()

		/*
		if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
			var/turf/space/S = src.loc
			S.Entered(src)*/
	else
		user << "<span class='notice'>You have to honk to be able to ride this.</span>"

/obj/structure/stool/bed/chair/clowncart/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc

/obj/structure/stool/bed/chair/clowncart/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon) || destroyed)
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs onto the honkin' ride!</span>",\
		"<span class='notice'>You climb onto the honkin' ride!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)
	return

/obj/structure/stool/bed/chair/clowncart/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()

/obj/structure/stool/bed/chair/clowncart/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/stool/bed/chair/clowncart/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7

/obj/structure/stool/bed/chair/clowncart/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("\red The [src.name]'s motor short circuits!")
	spark_system.attach(src)
	spark_system.set_up(5, 0, src)
	spark_system.start()

/obj/structure/stool/bed/chair/clowncart/bullet_act(var/obj/item/projectile/Proj)
	var/hitrider = 0
	if(istype(Proj, /obj/item/projectile/ion))
		Proj.on_hit(src, 2)
		return
	if(buckled_mob)
		if(prob(75))
			hitrider = 1
			var/act = buckled_mob.bullet_act(Proj)
			if(act >= 0)
				visible_message("<span class='warning'>[buckled_mob.name] is hit by [Proj]!")
				if(istype(Proj, /obj/item/projectile/energy))
					unbuckle()
			return
		if(istype(Proj, /obj/item/projectile/energy/electrode))
			if(prob(25))
				unbuckle()
				visible_message("<span class='warning'>The [src.name] absorbs the [Proj]")
				if(!istype(buckled_mob, /mob/living/carbon/human))
					return buckled_mob.bullet_act(Proj)
				else
					var/mob/living/carbon/human/H = buckled_mob
					return H.electrocute_act(0, src, 1, 0)
	if(!hitrider)
		visible_message("<span class='warning'>[Proj] hits the honkin' ride!</span>")
		if(!Proj.nodamage && Proj.damage_type == BRUTE || Proj.damage_type == BURN)
			health -= Proj.damage
		HealthCheck()

/obj/structure/stool/bed/chair/clowncart/proc/HealthCheck()
	if(health > maximum_health) health = maximum_health
	if(health <= 0 && !destroyed)
		destroyed = 1
		density = 0
		if(buckled_mob)
			unbuckle()
		visible_message("<span class='warning'>The honkin' ride explodes in a puff of potassium!</span>")
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 75, 1)
		explosion(src.loc,-1,0,3,7,10)
		for(var/a=0, a<(fuel*0.25), a++) //spawn banana peels in place of the ride
			new /obj/item/weapon/bananapeel/traitorpeel( get_turf(src) )
		del(src)

/obj/structure/stool/bed/chair/clowncart/ex_act(severity)
	switch (severity)
		if(1.0)
			health -= 125
		if(2.0)
			health -= 75
		if(3.0)
			health -= 45
	HealthCheck()