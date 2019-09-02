//Corgi
#define IDLE 0
#define BEGIN_FOOD_HUNTING 1
#define FOOD_HUNTING 2
#define BEGIN_POINTER_FOLLOWING 3
#define POINTER_FOLLOWING 4

/mob/living/simple_animal/corgi
	name = "corgi"
	real_name = "corgi"

	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	health = 30
	maxHealth = 30
	gender = MALE
	speak = list("YAP!", "Woof!", "Bark!", "Arf!")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps")
	emote_see = list("shakes its head", "shivers", "pants")
	emote_sound = list("sound/voice/corgibark.ogg")
	speak_chance = 1
	turns_per_move = 10

	speak_override = TRUE

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal/corgi
	holder_type = /obj/item/weapon/holder/animal/corgi

	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5

	childtype = /mob/living/simple_animal/corgi/puppy
	species_type = /mob/living/simple_animal/corgi
	can_breed = 1
	size = SIZE_SMALL

	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/obj/item/clothing/mask/facehugger/facehugger
	var/list/spin_emotes = list("dances around","chases its tail")
	var/corgi_status = IDLE
	var/obj/movement_target
	var/mob/pointer_caller
	var/mob/master //Obtained randomly when petting him. Can be overriden.

//	colourmatrix = list(1,0.0,0.0,0,\
						0,0.5,0.5,0,\
						0,0.5,0.5,0,\
						0,0.0,0.0,1,)
	held_items = list()
	var/time_between_directed_steps = 6

/mob/living/simple_animal/corgi/has_hand_check()
	return 1 // can pull things with his mouth

/mob/living/simple_animal/corgi/Life()
	if(timestopped)
		return 0 //under effects of time magick
	spinaroo(spin_emotes)
	. = ..()
	if(.)
		regular_hud_updates()
	if(!stat && !resting && !locked_to && (ckey == null)) //Behavior mechanisms (om nom :3)
		if(corgi_status == IDLE)
			get_target()
			stop_automated_movement = 0

		else if(corgi_status == BEGIN_FOOD_HUNTING)
			corgi_status = FOOD_HUNTING
			spawn(0) // Separate process
				stop_automated_movement = 1
				var/failedsteps = 0
				var/infinite_chase = loc && locate(/obj/machinery/power/treadmill) in loc
				while(movement_target && !Adjacent(movement_target) && get_dist(src,movement_target) < 7 && corgi_status == FOOD_HUNTING && failedsteps <= 2)
					if(!step_towards(src,movement_target,1) && !infinite_chase)
						failedsteps += 1
					if(time_between_directed_steps >= 1)
						sleep(time_between_directed_steps)
					else
						sleep(1)
				if(movement_target)
					if(isturf(movement_target.loc) && src.Adjacent(movement_target))
						movement_target.attack_animal(src)
					else if(ishuman(movement_target.loc))
						if(prob(20))
							emote("me", 1, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face and whimpers.")
				corgi_status = IDLE
				movement_target = null

		else if(corgi_status == BEGIN_POINTER_FOLLOWING)
			corgi_status = POINTER_FOLLOWING
			if(prob(35) || (master != null && pointer_caller == master))
				spawn(0) // Separate process
					stop_automated_movement = 1
					var/failedsteps = 0
					while(failedsteps <= 3)
						if(!movement_target || src.Adjacent(movement_target) || get_dist(src, movement_target) >= 7)
							break
						if(!step_towards(src,movement_target,1))
							failedsteps++
						sleep(time_between_directed_steps)

					if(movement_target)
						step_towards(src,movement_target,1)
						playsound(loc, 'sound/voice/corgibark.ogg', 80, 1)
						if(istype(movement_target,/obj/item/weapon/reagent_containers/food/snacks))
							emote("me", 1, "barks at [movement_target], as if begging it to go into his mouth.")
							corgi_status = BEGIN_FOOD_HUNTING
						else if(ishuman(movement_target))
							emote("me", 1, "barks at [movement_target] and wags his tail.")
							corgi_status = IDLE
						else
							emote("me", 1, "barks with an attitude!")
							corgi_status = IDLE

			else
				emote("me", 1, "stares into space with a blank expression.")
				corgi_status = IDLE

/mob/living/simple_animal/corgi/regular_hud_updates()
	if(fire)
		if(fire_alert)
			fire.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for heat and 2 for cold.
		else
			fire.icon_state = "fire0"
	update_pull_icon()
	if(oxygen)
		if(oxygen_alert)
			oxygen.icon_state = "oxy1"
		else
			oxygen.icon_state = "oxy0"
	if(toxin)
		if(toxins_alert)
			toxin.icon_state = "tox1"
		else
			toxin.icon_state = "tox0"

	if (healths)
		switch(health)
			if(30 to INFINITY)
				healths.icon_state = "health0"
			if(26 to 29)
				healths.icon_state = "health1"
			if(21 to 25)
				healths.icon_state = "health2"
			if(16 to 20)
				healths.icon_state = "health3"
			if(11 to 15)
				healths.icon_state = "health4"
			if(6 to 10)
				healths.icon_state = "health5"
			if(1 to 5)
				healths.icon_state = "health6"
			else
				healths.icon_state = "health7"
	//regenerate_icons()


/mob/living/simple_animal/corgi/show_inv(mob/user as mob)
	user.set_machine(src)
	if(user.stat)
		return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", real_name))
	onclose(user, "mob[real_name]")
	return

/mob/living/simple_animal/corgi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			user.visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O]</span>")
			spawn(0)
				emote("me", 1, "whines.")
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else if(inventory_head && inventory_back)
		//helmet and armor = 100% protection
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			if( O.force )
				to_chat(usr, "<span class='warning'>[src] is wearing too much armor. You can't cause \him any damage.</span>")
				for (var/mob/M in viewers(src, null))
					M.show_message("<span class='danger'>[user] hits [src] with [O], however [src] is too armored.</span>")
			else
				to_chat(usr, "<span class='warning'>[src] is wearing too much armor. You can't reach \his skin.</span>")
				for (var/mob/M in viewers(src, null))
					M.show_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")
			if(health>0 && prob(15))
				emote("me", 1, "looks at [user] with [pick("an amused","an annoyed","a confused","a resentful", "a happy", "an excited")] expression.")
			return
	else
		var/obj/item/clothing/mask/facehugger/F = O
		if(istype(F))
			user.drop_from_inventory(F)
			F.Attach(src)
			return
	..()

/mob/living/simple_animal/corgi/Topic(href, href_list)
	if(usr.stat)
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		remove_inventory(remove_from,usr)
		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return

		var/add_to = href_list["add_inv"]
		if(!usr.get_active_hand())
			to_chat(usr, "<span class='warning'>You have nothing in your hand to put on its [add_to].</span>")
			return
		switch(add_to)
			if("head")
				place_on_head(usr.get_active_hand())

			if("back")
				if(inventory_back)
					to_chat(usr, "<span class='warning'>It's already wearing something.</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()

					if(!item_to_add)
						usr.visible_message("<span class='notice'>[usr] pets [src]</span>","<span class='notice'>You rest your hand on [src]'s back for a moment.</span>")
						return
					if(istype(item_to_add,/obj/item/weapon/plastique)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that corgis can wear on their backs.
					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/suit/armor/vest/security,
						/obj/item/device/radio,
						/obj/item/device/radio/off,
						/obj/item/clothing/suit/cardborg,
						/obj/item/weapon/tank/oxygen,
						/obj/item/weapon/tank/air,
						/obj/item/weapon/extinguisher,
						/obj/item/clothing/suit/space/rig
					)

					if( ! ( item_to_add.type in allowed_types ) )
						to_chat(usr, "You set [item_to_add] on [src]'s back, but \he shakes it off!")
						usr.drop_item(item_to_add, get_turf(src))

						if(prob(25))
							step_rand(item_to_add)
						if (ckey == null)
							for(var/i in list(1,2,4,8,4,8,4,dir))
								dir = i
								sleep(1)
						return

					usr.drop_item(item_to_add, src, force_drop = 1)
					src.inventory_back = item_to_add
					regenerate_icons()

		show_inv(usr)
	else
		..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
/mob/living/simple_animal/corgi/proc/place_on_head(obj/item/item_to_add)


	if(istype(item_to_add,/obj/item/weapon/plastique)) // last thing he ever wears, I guess
		item_to_add.afterattack(src,usr,1)
		return

	if(inventory_head)
		if(usr)
			to_chat(usr, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		usr.visible_message("<span class='notice'>[usr] pets [src]</span>","<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		return


	var/valid = 0

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.
	switch(item_to_add.type)
		if( /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/head/that, /obj/item/clothing/head/collectable/paper,
				/obj/item/clothing/head/hardhat, /obj/item/clothing/head/collectable/hardhat,/obj/item/clothing/head/hardhat/white, /obj/item/weapon/p_folded/hat )
			valid = 1

		if(/obj/item/clothing/head/helmet/tactical/sec,/obj/item/clothing/head/helmet/tactical/sec/preattached)
			name = "Sergeant [real_name]"
			desc = "The ever-loyal, the ever-vigilant."
			valid = 1

		if(/obj/item/clothing/head/helmet/tactical/swat)
			name = "Lieutenant [real_name]"
			desc = "When the going gets ruff..."
			valid = 1

		if(/obj/item/clothing/head/chefhat,	/obj/item/clothing/head/collectable/chef)
			name = "Sous chef [real_name]"
			desc = "Your food will be taste-tested.  All of it."
			valid = 1

		if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
			name = "Captain [real_name]"
			desc = "Probably better than the last captain."
			emote_hear = list("secures the spare.", "hides the nuke disk.", "assures the crew he is NOT a comdom.")
			valid = 1

		if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/kitty/collectable)
			name = "Runtime"
			emote_see = list("coughs up a furball.", "stretches.")
			emote_hear = list("purrs")
			speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
			desc = "It's a cute little kitty-cat! Well, he's definitely cute!"
			valid = 1

		if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
			name = "Hoppy"
			emote_see = list("twitches its nose.", "hops around a bit.")
			desc = "This is Hoppy. It's a corgi-er, bunny rabbit?"
			valid = 1

		if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
			name = "Yann"
			desc = "Mon dieu! C'est un chien!"
			speak = list("le woof!", "le bark!", "JAPPE!!")
			emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of him.")
			valid = 1

		if(/obj/item/clothing/head/det_hat)
			name = "Detective [real_name]"
			desc = "[name] sees through your lies..."
			emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.")
			valid = 1

		if(/obj/item/clothing/head/nursehat)
			name = "Nurse [real_name]"
			desc = "[name] needs 100cc of beef jerky... STAT!"
			valid = 1

		if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
			name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
			desc = "Yaarghh! Thar' be a scurvy dog!"
			emote_see = list("hunts for treasure.","stares coldly...","gnashes his tiny corgi teeth.")
			emote_hear = list("growls ferociously.", "snarls.")
			speak = list("Arrrrgh!","Grrrrrr!")
			valid = 1

		if(/obj/item/clothing/head/ushanka)
			name = "[pick("Tzar","Vladimir","Chairman")] [real_name]"
			desc = "A follower of Karl Barx."
			emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vangaurdism.", "plans out methods to equally redistribute capital.", "articulates an argument for the primacy of the bourgeoisie.", "develops an economic plan to industrialize the vast rural landscape.")
			valid = 1

		if(/obj/item/clothing/head/collectable/police)
			name = "Officer [real_name]"
			emote_see = list("drools.","looks for donuts.")
			desc = "Stop right there, criminal scum!"
			valid = 1

		if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
			name = "Grandwizard [real_name]"
			speak = list("Woof!", "Bark!", "EI NATH", "FORTI GY AMA")
			emote_see = list("casts a dastardly spell!", "curses you with a bark!", "summons a steak into his stomach.")
			valid = 1

		if(/obj/item/clothing/head/cardborg)
			name = "Borgi"
			speak = list("Ping!","Beep!","Woof!")
			emote_see = list("goes rogue.", "sniffs out non-humans.", "waits for a malfunction.")
			desc = "Result of robotics budget cuts."
			valid = 1

		if(/obj/item/weapon/bedsheet)
			name = "\improper Ghost"
			speak = list("WoooOOOooo~","AuuuuuUuUuUuUuUuUuu~")
			emote_see = list("stumbles around.", "shivers.")
			emote_hear = list("howls.","groans.")
			desc = "Spooky!"
			valid = 1

		if(/obj/item/clothing/head/helmet/space/santahat, /obj/item/clothing/head/christmas/santahat/red)
			name = "Santa's Corgi Helper"
			emote_hear = list("barks christmas songs.", "yaps merrily.")
			emote_see = list("looks for presents.", "checks his list.")
			desc = "He's very fond of milk and cookies."
			valid = 1

		if(/obj/item/clothing/head/soft)
			name = "Corgi Tech [real_name]"
			desc = "The reason your yellow gloves have chew-marks."
			emote_see = list("orders emitter crates.", "declares independence from Nanotrasen.", "acquires insulated gloves.")
			valid = 1

		if(/obj/item/clothing/head/fedora)
			name = "Autistic [real_name]"
			desc = "His paws seem to be covered in what looks like Cheezy Honker dust."
			emote_hear = list("barks ironicly", "makes you cringe")
			emote_see = list("unsheathes katana.", "tips fedora.","posts on Mongolian basket-weaving forums.")
			valid = 1

		if(/obj/item/clothing/head/fez)
			name = "Doctor Whom"
			desc = "A time-dog from the planet barkifray."
			emote_hear =  list("barks cleverly.")
			emote_see = list("fiddles around with a sonic-bone.", "evolves into a hotter version of himself! Er, nevermind.")
			valid = 1

		if(/obj/item/clothing/head/helmet/space/rig)
			name = "Station Engineer [real_name]"
			desc = "Ian want a cracker!"
			valid = 1
			min_oxy = 0
			minbodytemp = 0
			maxbodytemp = 999

		/*
		if(/obj/item/clothing/head/hardhat/reindeer)
			name = "[real_name] the red-nosed Corgi"
			emote_hear = list("lights the way.", "illuminates the night sky.", "is bullied by the other reindogs. Poor Ian.")
			desc = "He has a very shiny nose."
			SetLuminosity(1)
			valid = 1
		*/
		if(/obj/item/clothing/head/alien_antenna)
			name = "Al-Ian"
			desc = "Take us to your dog biscuits!"
			valid = 1

		if(/obj/item/clothing/head/franken_bolt)
			name = "Corgenstein's monster"
			desc = "We can rebuild him, we have the technology!"
			valid = 1

		if(/obj/item/clothing/mask/vamp_fangs)
			var/obj/item/clothing/mask/vamp_fangs/V = item_to_add
			if(!V.glowy_fangs)
				name = "Vlad the Ianpaler"
				desc = "Listen to them, the children of the night. What music they make!"
				valid = 1
			else
				to_chat(usr, "<span class = 'notice'>The glow of /the [V] startles [real_name]!</span>")

	if(valid)
		if(usr)
			usr.visible_message("[usr] puts [item_to_add] on [real_name]'s head.  [src] looks at [usr] and barks once.",
				"You put [item_to_add] on [real_name]'s head.  [src] gives you a peculiar look, then wags \his tail once and barks.",
				"You hear a friendly-sounding bark.")
			usr.drop_item(item_to_add, src, force_drop = 1)
		else
			item_to_add.forceMove(src)
		src.inventory_head = item_to_add
		regenerate_icons()

	else
		to_chat(usr, "You set [item_to_add] on [src]'s head, but \he shakes it off!")
		usr.drop_item(item_to_add, src.loc)

		if(prob(25))
			step_rand(item_to_add)
		if (ckey == null)
			for(var/i in list(1,2,4,8,4,8,4,dir))
				dir = i
				sleep(1)

	return valid

/mob/living/simple_animal/corgi/proc/spinaroo(var/list/emotes)
    if(!stat && !resting && !locked_to)
        if(prob(1))
            if (ckey == null)
                emote("me", 1, pick(emotes))
                spawn(0)
                    for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
                        dir = i
                        sleep(1)

/mob/living/simple_animal/corgi/proc/remove_inventory(var/remove_from = "head", mob/user)
	switch(remove_from)
		if("head")
			if(inventory_head)
				name = real_name
				desc = initial(desc)
				speak = list("YAP!", "Woof!", "Bark!", "Arf!")
				speak_emote = list("barks.", "woofs.")
				emote_hear = list("barks.", "woofs.", "yaps.")
				emote_see = list("shakes its head.", "shivers.", "pants.")
				emote_sound = list("sound/voice/corgibark.ogg")
				min_oxy = initial(min_oxy)
				minbodytemp = initial(minbodytemp)
				maxbodytemp = initial(maxbodytemp)
				set_light(0)
				inventory_head.forceMove(src.loc)
				inventory_head = null
				regenerate_icons()
			else
				if(user)
					to_chat(user, "<span class='warning'>There is nothing to remove from its [remove_from].</span>")
				return
		if("back")
			if(inventory_back)
				inventory_back.forceMove(src.loc)
				inventory_back = null
				regenerate_icons()
			else
				if(user)
					to_chat(user, "<span class='warning'>There is nothing to remove from its [remove_from].</span>")
				return

/mob/living/simple_animal/corgi/proc/get_target()
	var/vision_range = 5
	var/list/can_see = view(src, vision_range)
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in can_see)
		if(isturf(S.loc) || ishuman(S.loc))
			movement_target = S
			corgi_status = BEGIN_FOOD_HUNTING
			return
	for(var/mob/living/carbon/M in can_see)
		for(var/obj/item/H in M.held_items)
			if(istype(H, /obj/item/weapon/reagent_containers/food/snacks))
				movement_target = H
				corgi_status = BEGIN_FOOD_HUNTING
				return

	for(var/obj/effect/decal/point/pointer in can_see)
		var/atom/pointer_target = pointer.target
		if(pointer_target == src)
			return
		corgi_status = BEGIN_POINTER_FOLLOWING
		pointer_caller = pointer.pointer
		movement_target = pointer_target
		return

/mob/living/simple_animal/corgi/Destroy()
	..()
	master = null
	pointer_caller = null

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's a corgi."
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	spin_emotes = list("dances around.","chases his tail.")
	is_pet = TRUE
	var/creatine_had = 0
	
/mob/living/simple_animal/corgi/Ian/Life()
	..()
	var/creatine =  reagents.has_reagent(CREATINE)
	var/hyperzine = reagents.has_any_reagents(HYPERZINES)
	if(creatine && !creatine_had)
		creatine_had = 1
		visible_message("<span class='danger'>[src]'s muscles bulge!</span>")
		desc = "It's a corgi... but his muscles have veins running over them."
		name = "Ian the Buff"
	else if(!creatine && creatine_had)
		visible_message("<span class='danger'>[src]'s muscles tear themselves apart!</span>")
		gib()
		
	if(creatine && hyperzine)
		treadmill_speed = 30
		time_between_directed_steps = 1
	else if(creatine)
		treadmill_speed = 10
		time_between_directed_steps = 3
	else if(hyperzine)
		treadmill_speed = 3
		src.Jitter(2 SECONDS)
		time_between_directed_steps = 3	
	else
		treadmill_speed = 0.5
		time_between_directed_steps = initial(time_between_directed_steps)

/mob/living/simple_animal/corgi/Ian/santa
	name = "Santa's Corgi Helper"
	emote_hear = list("barks christmas songs", "yaps merrily")
	emote_see = list("looks for presents", "checks his list")
	desc = "He's very fond of milk and cookies."

/mob/living/simple_animal/corgi/Ian/santa/New()
	..()

	inventory_head = new/obj/item/clothing/head/christmas/santahat/red(src)
	regenerate_icons()

/mob/living/simple_animal/corgi/regenerate_icons()
	overlays = list()

	if(inventory_head)
		var/head_icon_state = inventory_head.icon_state
		if(health <= 0)
			head_icon_state += "2"

		var/icon/head_icon = image('icons/mob/corgi_head.dmi',head_icon_state)
		if(head_icon)
			overlays += head_icon

	if(inventory_back)
		var/back_icon_state = inventory_back.icon_state
		if(health <= 0)
			back_icon_state += "2"

		var/icon/back_icon = image('icons/mob/corgi_back.dmi',back_icon_state)
		if(back_icon)
			overlays += back_icon

	if(facehugger)
		if(istype(src, /mob/living/simple_animal/corgi/puppy))
			overlays += image('icons/mob/mask.dmi',"facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi',"facehugger_corgi")

	return



/mob/living/simple_animal/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	size = SIZE_TINY

//puppies cannot wear anything.
/mob/living/simple_animal/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>You can't fit this on [src]</span>")
		return
	..()


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0
	spin_emotes = list("dances around.","chases her tail.")

//Lisa already has a cute bow!
/mob/living/simple_animal/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>[src] already has a cute bow!</span>")
		return
	..()

/mob/living/simple_animal/corgi/attack_hand(mob/living/carbon/human/M)
	. = ..()
	react_to_touch(M)
	M.delayNextAttack(2 SECONDS)

/mob/living/simple_animal/corgi/proc/react_to_touch(mob/M)
	if(M && !isUnconscious())
		switch(M.a_intent)
			if(I_HELP)
				var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
				heart.plane = ABOVE_HUMAN_PLANE
				flick_overlay(heart, list(M.client), 20)
				emote("me", EMOTE_AUDIBLE, pick("yaps happily.","yips happily.","gives a hearty bark!","yips and cuddles up to you."))
				playsound(loc, 'sound/voice/corgibark.ogg', 80, 1)
				if(prob(5))
					master = M
					to_chat(M, "[src] seems closer to you now. At least until somebody else gives him attention, anyway.")
			if(I_HURT)
				playsound(loc, 'sound/voice/corgigrowl.ogg', 80, 1)
				emote("me", EMOTE_AUDIBLE, "growls.")

//Sasha isn't even a corgi you dummy!
/mob/living/simple_animal/corgi/sasha
	name = "Sasha"
	real_name = "Sasha"
	gender = FEMALE
	desc = "It's a doberman, how intimidating!"
	icon_state = "doby"
	icon_living = "doby"
	icon_dead = "doby_dead"
	spin_emotes = list("prances around","chases her nub of a tail")
	is_pet = TRUE

	species_type = /mob/living/simple_animal/corgi/sasha
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal

//Sasha can't wear hats!
/mob/living/simple_animal/corgi/sasha/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>[src] won't wear that!</span>")
		return
	..()

/obj/item/weapon/reagent_containers/glass/replenishing/rescue
	name = "rescue barrel"
	reagent_list = list(LEPORAZINE)

/mob/living/simple_animal/corgi/saint
	name = "saint corgi"
	real_name = "saint corgi"
	desc = "It's a saint bernard corgi mix breed. It has a tiny rescue barrel strapped around his collar to warm up travelers."
	icon_state = "saint_corgi"
	icon_living = "saint_corgi"
	icon_dead = "saint_corgi_dead"
	health = 60
	maxHealth = 60
	minbodytemp = 0
	var/turns_since_scan = 0
	var/mob/living/carbon/victim = null
	can_breed = FALSE //tfw no gf
	var/obj/item/weapon/reagent_containers/glass/replenishing/rescue/barrel = null

/mob/living/simple_animal/corgi/saint/death(var/gibbed = FALSE)
	if(barrel)
		qdel(barrel)
	..(gibbed)

/mob/living/simple_animal/corgi/saint/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "<span class='warning'>[src] already has a rescue barrel!</span>")
		return
	..()

/mob/living/simple_animal/corgi/saint/proc/rescue(var/mob/M)
	if(!M || !Adjacent(M))
		return
	if(!barrel)
		barrel = new /obj/item/weapon/reagent_containers/glass/replenishing/rescue(src)
	barrel.attack(M,src)

/mob/living/simple_animal/corgi/saint/proc/IsVictim(var/mob/M)
	if(iscarbon(M))
		var/mob/living/carbon/victim = M
		if(victim.undergoing_hypothermia() && !victim.isDead())
			return TRUE
	return FALSE

/mob/living/simple_animal/corgi/saint/UnarmedAttack(var/atom/A)
	if(client && IsVictim(A))
		rescue(A)
		return
	return ..()

/mob/living/simple_animal/corgi/saint/Life()
	if(timestopped)
		return FALSE //under effects of time magick
	..()

	if(!incapacitated() && !resting && !locked_to && !client)
		var/list/can_see = view(src, 6) //Might need tweaking.
		if(victim && (!IsVictim(victim) || !(victim.loc in can_see)))
			victim = null
			stop_automated_movement = FALSE
		if(!victim)
			for(var/mob/living/carbon/M in can_see)
				if(IsVictim(M))
					victim = M //Oh shit.
					break
		if(victim)
			stop_automated_movement = TRUE
			step_towards(src,victim)
			if(Adjacent(victim) && IsVictim(victim)) //Seriously don't try to rescue the dead.
				rescue(victim)

#undef IDLE
#undef BEGIN_FOOD_HUNTING
#undef FOOD_HUNTING
#undef BEGIN_POINTER_FOLLOWING
#undef POINTER_FOLLOWING