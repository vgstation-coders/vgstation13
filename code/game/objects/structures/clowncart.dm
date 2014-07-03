/obj/structure/stool/bed/chair/vehicle/clowncart
	name = "clowncart"
	desc = "A goofy-looking cart, commonly used by space clowns for entertainment. There appears to be a coin slot on its side."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "clowncar"
	anchored = 1
	density = 1
	nick = "honkin' ride"
	var/activated = 0 //honk to activate, it stays active while you sit in it, and will deactivate when you unbuckle
	var/fuel = 0 //banana-type items add fuel, you can't ride without fuel
	var/mode = 0 	//0 - normal, 1 - leave grafitti behind, 2 - leave banana peels behind
					//modes 1 and 2 consume extra fuel
					//use bananium coins to cycle between modes
	var/maximum_health = 100 //bananium increases maximum health by 20
	var/printing_text = "nothing"	//what is printed on the ground in mode 1
	var/printing_pos				//'rune' draws runes and 'graffiti' draws graffiti, other draws text
	var/trail //trail from banana pie
	var/colour1 = "#000000" //change it by using stamps
	var/colour2 = "#3D3D3D" //default is boring black
	var/emagged = 0			//does nothing yet
	var/honk				//if you honk too much, you explode
/obj/structure/stool/bed/chair/vehicle/clowncart/process()
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

/obj/structure/stool/bed/chair/vehicle/clowncart/New()
	fuel = 0

	processing_objects |= src
	handle_rotation()

/obj/structure/stool/bed/chair/vehicle/clowncart/examine()
	set src in usr
	usr << "\icon[src] [desc]"
	usr << "This [nick] contains [fuel] unit\s of banana essence!"
	if(maximum_health > 100)
		usr << "It is reinforced with [(maximum_health-100)/20] bananium sheets."
	switch(health)
		if(maximum_health*0.5 to maximum_health)
			usr << "\blue It appears slightly dented."
		if(1 to maximum_health*0.5)
			usr << "\red It appears heavily dented."
		if((INFINITY * -1) to 0)
			usr << "It appears completely unsalvageable"

/obj/structure/stool/bed/chair/vehicle/clowncart/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/bikehorn))
		if(destroyed)
			user << "\red The [src.name] is destroyed beyond repair."
			return
		add_fingerprint(user)
		user.visible_message("\blue [user] honks at the [src].", "\blue You honk at \the [src]")
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		if(fuel <= 5)
			if(activated)
				src.visible_message("\red The [nick] lets out a last honk before running out of fuel.")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				activated = 0
				fuel = 0
			else
				user << "\red The [src.name] doesn't have enough banana essence!"
		else
			spawn(5)
				activated = 1
				src.visible_message("\blue The [nick] honks back happily.")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				fuel -= 5 //honking costs 5 fuel
				honk++
				if(honk == 4)
					user << "\red You don't think this is a good idea."
				if(honk == 8)
					user << "\red The [nick] starts to overheat!"
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
		if(health > maximum_health) health = maximum_health
		empstun = 0 //and disable emp stun
		del(W)
	else if(istype(W, /obj/item/seeds/bananaseed)) //banana seeds
		user.visible_message("\blue [user] repairs the [src] with the [W.name].", "\blue You repair the [src] with the [W.name].")
		health += 50 //banana seeds repair a lot of damage
		if(health > maximum_health) health = maximum_health
		del(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/clown)) //bananium
		user << "\blue You reinforce the [src] with [W.name]."
		fuel += 10
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
				user << ""
				user << "Use a crayon to decide what you want to draw."
				user << "Use stamps to change the colour of SmartCrayon II."
			if(2)
				user << "\red SmartCrayon II disappears in a puff of art!"
				spawn(5)
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
					user << "\blue You hear a ping as the SynthPeel Generator starts transforming banana essence into slippery peels."
		del(W)
	else if(istype(W, /obj/item/toy/crayon/)) //any crayon
		if(mode == 1)
			printing_text = input(user, "Enter a message to print. To draw runes and graffiti, type 'rune' and 'graffiti' respectively.", "Message", printing_text)
			printing_pos = 0
			if(printing_text == "graffiti")
				user << "\blue Drawing graffiti!"
			else if(printing_text == "rune")
				user << "\blue Drawing runes!"
			else if(printing_text == "" || printing_text == "nothing")
				user << "\red Not drawing anything."
			else
				user << "\blue Now printing the following text: [printing_text]"
	else if(istype(W, /obj/item/weapon/card/emag)) //emag
		if(!emagged)
			emagged = 1
			src.visible_message("\red The [src.name]'s eyes glow red for a second.")
	else if(istype(W, /obj/item/weapon/stamp/))
		if(mode == 1)
			if(istype(W, /obj/item/weapon/stamp/captain))
				colour1 = "#004B8F"
				colour2 = "#0060B8"
				user << "\blue Selected colour: Condom Blue"
			else if(istype(W, /obj/item/weapon/stamp/ce))
				colour1 = "#FFFF00"
				colour2 = "#FFD000"
				user << "\yellow Selected colour: Electric Yellow"
			else if(istype(W, /obj/item/weapon/stamp/clown))
				colour1 = "#ED66F9"
				colour2 = "#F963CF"
				user << "Selected colour: Joyful Pink"
			else if(istype(W, /obj/item/weapon/stamp/cmo))
				colour1 = "#FFFFFF"
				colour2 = "#ECECEC"
				user << "Selected colour: Healthy White"
			else if(istype(W, /obj/item/weapon/stamp/denied))
				colour1 = "#FF0000"
				colour2 = "#E22C00"
				user << "\red Selected colour: Red Denial"
			else if(istype(W, /obj/item/weapon/stamp/hop))
				colour1 = "#1CA800"
				colour2 = "#238E0E"
				user << "\green Selected colour: Accessible Green"
			else if(istype(W, /obj/item/weapon/stamp/hos))
				colour1 = "#7F4D21"
				colour2 = "#B24611"
				user << "Selected colour: Shitcurity Brown"
			else if(istype(W, /obj/item/weapon/stamp/rd))
				colour1 = "#FF8C00"
				colour2 = "#FF4A00"
				user << "\red Selected colour: Explosive Orange"
			else
				colour1 = "#000000"
				colour2 = "#6D6D6D"
				user << "Selected colour: Boring Black"
/obj/structure/stool/bed/chair/vehicle/clowncart/relaymove(mob/user, direction)
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
		update_mob()
		handle_rotation()
		if(get_turf(src) <> old_pos) //if we actually moved
			if(maximum_health < 300) fuel -= 1 //10 sheets of bananium required to drive without using fuel

			if(mode == 1) //graffiti
				var/graffiti_amount = 0//built-in safety measures allow only 3 drawings on the floor at same time
				for(var/obj/effect/decal/cleanable/crayon/C in old_pos)
					graffiti_amount++
				if(graffiti_amount > 3+(3*emagged)) //limit is upped to 6 if emagged
					return //don't draw anything
				if(!istype(old_pos,/turf/simulated/floor)) //no drawing in open space
					return
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
		/*
		if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
			var/turf/space/S = src.loc
			S.Entered(src)*/
	else
		user << "<span class='notice'>You have to honk to be able to ride this.</span>"

/obj/structure/stool/bed/chair/vehicle/clowncart/die()
	destroyed = 1
	density = 0
	if(buckled_mob)
		unbuckle()
	visible_message("<span class='warning'>The honkin' ride explodes in a puff of potassium!</span>")
	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 75, 1)
	explosion(src.loc,-1,0,3,7,10)
	for(var/a=0, a<(fuel*0.25), a++) //spawn banana peels in place of the cart
		new /obj/item/weapon/bananapeel/traitorpeel( get_turf(src) )
	del(src)