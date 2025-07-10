/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/mob/living/simple_animal/mouse/mouse = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.

	name = "Spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	wander = 0
	voice_name = "synthesized voice"

	health = 10
	maxHealth = 10

	mob_property_flags = MOB_ROBOTIC

	attacktext = "shocks"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/obj/item/held_item = null //Storage for single item they can hold.
	var/lob_range = 3
	var/syndie = 0                //IS WE SYNDICAT? (currently unused)
	speed = 1                    //Spiderbots gotta go fast.
	pass_flags = PASSTABLE | PASSRAILING
	speak_emote = list("beeps","clicks","chirps")
	size = SIZE_SMALL
	meat_type = null

	blooded = FALSE

/mob/living/simple_animal/spiderbot/canEnterVentWith()
	var/static/list/allowed_items = list(
		/obj/item/device/radio/borg,
		/obj/machinery/camera,
		/obj/item/device/mmi,
	)
	return allowed_items

/mob/living/simple_animal/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/device/mmi) || istype(O, /obj/item/device/mmi/posibrain))
		var/obj/item/device/mmi/B = O
		if(src.mmi) //There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return
		if(!B.brainmob.key)
			if(!mind_can_reenter(B.brainmob.mind))
				to_chat(user, "<span class='notice'>[O] is completely unresponsive; there's no point.</span>")
				return

		if(B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[O] is dead. Sticking it into the frame would sort of defeat the purpose.</span>")
			return

		if(!user.drop_item(O, src, failmsg = TRUE))
			return

		to_chat(user, "<span class='notice'>You install [O] in [src]!</span>")

		src.mmi = O
		src.transfer_personality(O)
		src.update_icon()
		return 1

	if (iswelder(O))
		var/obj/item/tool/weldingtool/WT = O
		if (WT.remove_fuel(0))
			if(health < maxHealth)
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				for(var/mob/W in viewers(user, null))
					W.show_message(text("<span class='warning'>[user] has spot-welded some of the damage to [src]!</span>"), 1)
			else
				to_chat(user, "<span class='notice'>[src] is undamaged!</span>")
		else
			to_chat(user, "Need more welding fuel!")
			return
	else if(istype(O, /obj/item/weapon/card/id)||istype(O, /obj/item/device/pda))
		if (!mmi && !mouse)
			to_chat(user, "<span class='warning'>There's no reason to swipe your ID - the spiderbot has nothing to remove.</span>")
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			if(mouse)
				to_chat(user, "<span class='notice'>You swipe your access card and pop the mouse out of [src].</span>")
			else
				to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>")
			eject_brain()

			if(held_item)
				held_item.forceMove(src.loc)
				held_item = null

			return 1
		else
			to_chat(user, "<span class='warning'>You swipe your card, with no effect.</span>")
			return 0
	else
		return ..()

/mob/living/simple_animal/spiderbot/emag_act(mob/user)
	if (emagged)
		to_chat(user, "<span class='warning'>[src] is already overloaded - better run.</span>")
	else
		emagged = 1
		to_chat(user, "<span class='notice'>You short out the security protocols and overload [src]'s cell, priming it to explode in a short time.</span>")
		spawn(100)	to_chat(src, "<span class='warning'>Your cell seems to be outputting a lot of power...</span>")
		spawn(200)	to_chat(src, "<span class='warning'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>")
		spawn(300)	src.explode()

/mob/living/simple_animal/spiderbot/attack_animal(var/mob/user as mob)
	if(istype(user,/mob/living/simple_animal/mouse) && !(src.mmi || src.mouse))
		visible_message("<span class='warning'>The [user.name] climbs into the spider-bot chassis!</span>")
		user.mind.transfer_to(src)
		src.name = "Spider-bot ([user.name])"
		src.mouse = user
		add_language(LANGUAGE_MOUSE)
		user.forceMove(src)
		src.update_icon()
	else
		return ..()

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/device/mmi/M as obj)
	src.mind = M.brainmob.mind
	src.mind.key = M.brainmob.key
	src.ckey = M.brainmob.ckey
	src.name = "Spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	explosion(get_turf(loc), -1, -1, 3, 5, whodunnit = src)
	death()

/mob/living/simple_animal/spiderbot/update_icon()
	if(mmi)
		if(istype(mmi,/obj/item/device/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/device/mmi/posibrain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"
	else if(mouse)
		var/color = mouse._color
		icon_state = "spiderbot-chassis-mouse-[color]"
		icon_living = "spiderbot-chassis-mouse-[color]"
	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	var/turf/T = get_turf(src)
	if(mmi)
		if(T)
			mmi.forceMove(T)
		if(mind)
			mind.transfer_to(mmi.brainmob)
		mmi = null
	if(mouse)
		if(T)
			mouse.forceMove(T)
			mind.transfer_to(mouse)
			mouse = null
			remove_language(LANGUAGE_MOUSE)

	src.name = "Spider-bot"
	update_icon()

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	..()

/mob/living/simple_animal/spiderbot/New()

	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "Spiderbot-[real_name]"
	camera.network = list(CAMERANET_SS13)

	..()

/mob/living/simple_animal/spiderbot/death(var/gibbed = FALSE)
	..(TRUE)
	if(camera)
		camera.status = 0
	if(held_item && !isnull(held_item))
		held_item.forceMove(src.loc)
		held_item = null

	visible_message("<span class='warning'>The spider-bot explodes!</span>")
	if(mouse)
		visible_message("<span class='warning'>The [mouse.name] springs free of the wreckage!</span>")
	robogibs(src.loc, virus2)
	qdel(src)

/mob/living/simple_animal/spiderbot/emp_act(severity)
	if(flags & INVULNERABLE)
		return ..()

	switch(severity)
		if(1)
			if(prob(5))
				explode()
				return
			adjustBruteLoss(rand(4,5))
		if(2)
			adjustBruteLoss(rand(2,3))
	flash_eyes(visual = 1, type = /obj/abstract/screen/fullscreen/flash/noise)
	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/spiderbot/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Spiderbot"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/spiderbot/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Spiderbot"

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

//Cannibalized from the parrot mob. ~Zuhayr

/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(incapacitated())
		return

	if(!held_item)
		to_chat(usr, "<span class='warning'>You have nothing to drop!</span>")
		return 0

	if(istype(held_item, /obj/item/weapon/grenade))
		visible_message("<span class='warning'>[src] launches \the [held_item]!</span>", "<span class='warning'>You launch \the [held_item]!</span>", "You hear a skittering noise and a thump!")
		var/obj/item/weapon/grenade/G = held_item

		//Make a dumbfire throw
		var/turf/lob_target
		var/lob_dir = dir
		var/turf/start_turf = get_turf(src)
		var/current_turf = start_turf
		for(var/i in 1 to lob_range)
			current_turf = get_step(current_turf, lob_dir)
		lob_target = current_turf

		throw_item(lob_target, G)

		G.activate(src)
		held_item = null
		return 1

	visible_message("<span class='notice'>[src] drops \the [held_item]!</span>", "<span class='notice'>You drop \the [held_item]!</span>", "You hear a skittering noise and a soft thump.")

	held_item.forceMove(src.loc)
	held_item = null
	return 1

/mob/living/simple_animal/spiderbot/verb_pickup()
	return get_item()

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(incapacitated())
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding \the [held_item]</span>")
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= W_CLASS_SMALL)
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				if(selection.anchored)
					to_chat(src, "<span class='warning'>It's fastened down!</span>")
					return 0
				held_item = selection
				selection.forceMove(src)
				visible_message("<span class='notice'>[src] scoops up \the [held_item]!</span>", "<span class='notice'>You grab \the [held_item]!</span>", "You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, "<span class='warning'>\The [selection] is too far away.</span>")
		return 0

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..()
	if(src.held_item)
		to_chat(user, "It is carrying \a [src.held_item] [bicon(src.held_item)].")

/mob/living/simple_animal/spiderbot/CheckSlip(slip_on_walking = FALSE, overlay_type = TURF_WET_WATER, slip_on_magbooties = FALSE)
	return SLIP_HAS_MAGBOOTS

/mob/living/simple_animal/spiderbot/say(var/message)
	return ..(message, "R")

/mob/living/simple_animal/spiderbot/treat_speech(var/datum/speech/speech, genesay = 0)
	..(speech)
	speech.message_classes.Add("siliconsay")

/mob/living/simple_animal/spiderbot/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "Spiderbot"

	if(incapacitated())
		to_chat(src, "Can't do that while incapacitated or dead.")
		return

	radio.listening = !radio.listening
	to_chat(src, "<span class='notice'>Radio is [radio.listening ? "" : "no longer "]receiving broadcasts.</span>")
