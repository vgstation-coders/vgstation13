/obj/structure/closet/statue
	name = "statue"
	desc = "An incredibly lifelike marble carving"
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	density = 1
	anchored = 1
	health = 0 //destroying the statue kills the mob within
	var/intialTox = 0 	//these are here to keep the mob from taking damage from things that logically wouldn't affect a rock
	var/intialFire = 0	//it's a little sloppy I know but it was this or the GODMODE flag. Lesser of two evils.
	var/intialBrute = 0
	var/intialOxy = 0
	var/timer = 80 // time in seconds = 2.5(timer) - 50, this makes 150 seconds = 2.5m. Set to -1 to make the statue last forever

/obj/structure/closet/statue/eternal
	timer = -1 //forever

/obj/structure/closet/statue/New(loc, var/mob/living/L)

	if(istype(L))
		if(L.locked_to)
			L.locked_to = 0
			L.anchored = 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src

		for(var/obj/item/I in L.held_items)
			L.drop_item(I)

		if(L.locked_to)
			L.unlock_from()
		L.forceMove(src)
		L.sdisabilities |= MUTE
		L.delayNextAttack(timer)
		L.click_delayer.setDelay(timer)
		health = L.health + 100 //stoning damaged mobs will result in easier to shatter statues
		intialTox = L.getToxLoss()
		intialFire = L.getFireLoss()
		intialBrute = L.getBruteLoss()
		intialOxy = L.getOxyLoss()

		appearance = L.appearance
		dir = L.dir

		if(ishuman(L))
			name = "statue of [L.name]"
		else if(ismonkey(L))
			name = "statue of [L.name]"
		else if(iscorgi(L))
			name = "statue of [L.name]"
			desc = "If it takes forever, I will wait for you..."
		else
			name = "statue of [L.name]"

		density = L.density

		//Monsters with animated icons look bad as statues!
		var/icon/static_icon = icon(L.icon)
		var/icon/original = icon(L.icon, L.icon_state, frame = 1)
		var/new_iconstate = "[L.icon_state]\ref[L]" //to avoid conflict with other icon states eh
		static_icon.Insert(original, new_iconstate)

		icon = static_icon
		icon_state = new_iconstate

		animate(src, color = grayscale, 30)

		processing_objects.Add(src)

		if(timer < 0) //No timer - the guy's going to be in there forever, might as well ghost him
			L.ghostize()

	if(health == 0) //meaning if the statue didn't find a valid target
		qdel(src)
		return

	..()

/obj/structure/closet/statue/process()
	if(timer > 0)
		timer--

	for(var/mob/living/M in src) //Go-go gadget stasis field
		M.setToxLoss(intialTox)
		M.adjustFireLoss(intialFire - M.getFireLoss())
		M.adjustBruteLoss(intialBrute - M.getBruteLoss())
		M.setOxyLoss(intialOxy)

	if (timer == 0)
		dump_contents()
		processing_objects.Remove(src)
		qdel(src)

/obj/structure/closet/statue/dump_contents()

	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/living/M in src)
		M.loc = src.loc
		M.sdisabilities &= ~MUTE
		M.take_overall_damage((M.health - health - 100),0) //any new damage the statue incurred is transfered to the mob
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/closet/statue/take_contents()
	return

/obj/structure/closet/statue/open()
	return

/obj/structure/closet/statue/take_contents()
	return

/obj/structure/closet/statue/open()
	return

/obj/structure/closet/statue/insert()
	return

/obj/structure/closet/statue/close()
	return

/obj/structure/closet/statue/toggle()
	return

/obj/structure/closet/statue/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	if(health <= 0)
		for(var/mob/M in src)
			shatter(M)

	return

/obj/structure/closet/statue/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash)
		for(var/mob/M in src)
			shatter(M)

/obj/structure/closet/statue/blob_act()
	for(var/mob/M in src)
		shatter(M)

/obj/structure/closet/statue/attackby(obj/item/I as obj, mob/user as mob)
	health -= I.force
	visible_message("<span class='warning'>[user] strikes [src] with [I].</span>")
	user.delayNextAttack(10)
	if(health <= 0)
		for(var/mob/M in src)
			shatter(M)

/obj/structure/closet/statue/place()
	return

/obj/structure/closet/statue/MouseDrop_T()
	return

/obj/structure/closet/statue/relaymove()
	return

/obj/structure/closet/statue/attack_hand()
	return

/obj/structure/closet/statue/verb_toggleopen()
	return

/obj/structure/closet/statue/update_icon()
	return

/obj/structure/closet/statue/proc/shatter(mob/user as mob)
	if (user)
		user.gib()
	dump_contents()
	visible_message("<span class='warning'>[src] shatters into pieces!. </span>")
	qdel(src)

/obj/structure/closet/statue/container_resist()
	return
