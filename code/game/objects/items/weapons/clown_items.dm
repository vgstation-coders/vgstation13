/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Bike Horns
 */

/*
 * Banana Peels
 */
/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if(..())  // Slipping if these are below a floor tile is nonsensical
		return 1
	if(!arcanetampered)
		handle_slip(AM)

/datum/locking_category/banana_peel

/obj/item/weapon/bananapeel/dropped(mob/user)
	..()
	if(arcanetampered)
		slip_n_slide(user,2,2,"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")

/obj/item/weapon/bananapeel/proc/handle_slip(atom/movable/AM)
	if(iscarbon(AM) || istype(AM, /obj/structure/bed/chair/vehicle/gokart))
		return slip_n_slide(AM,2,2,"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")

/obj/item/weapon/bananapeel/proc/slip_n_slide(var/atom/movable/AM,var/stun_amount,var/weaken_amount,var/drug_message)
	if(iscarbon(AM) || istype(AM, /obj/structure/bed/chair/vehicle/gokart))
		var/old_dir = AM.dir // Slipping changes dir, this is consistent
		if(iscarbon(AM))
			var/mob/living/carbon/M = AM
			if(!M.Slip(stun_amount, weaken_amount, 1, slipped_on = src, drugged_message = drug_message))
				return 0
		var/tiles_to_slip = slip_override > 0 ? slip_override : rand(round(potency/20, 1),round(potency/10, 1))
		if(istype(AM, /obj/structure/bed/chair/vehicle/gokart))
			var/obj/structure/bed/chair/vehicle/gokart/kart = AM
			var/left_or_right = prob(50) ? turn(AM.dir, 90) : turn(AM.dir, -90)
			kart.speen()
			playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
			spawn()
				for(var/i in 1 to tiles_to_slip)
					step(AM, left_or_right)
					sleep(1)
		else if(tiles_to_slip && !locked_to) //The banana peel will not be dragged along so stop the ride
			AM.lock_atom(src, /datum/locking_category/banana_peel)
			for(var/i = 1 to tiles_to_slip)
				if(!AM.locked_to)
					step(AM, old_dir)
					sleep(1)
			spawn(1) AM.unlock_atom(src)
	return 1

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKS")
	hitsound = 'sound/items/bikehorn.ogg'
	var/honk_delay = 20
	var/last_honk_time = 0
	var/vary_pitch = 1
	var/can_honk_baton = 1
	var/next_honk = 0

/obj/item/weapon/bikehorn/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] places the [src.name] into \his mouth and honks the horn. </span>")
	playsound(user, hitsound, 100, vary_pitch)
	user.gib()

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if(honk(user))
		add_fingerprint(user)

/obj/item/weapon/bikehorn/Crossed(var/mob/living/AM)
	if(isliving(AM))
		var/real_next_honk = next_honk
		if(clumsy_check(AM))
			real_next_honk -= honk_delay * 0.75
		if (world.time > real_next_honk) // Honking these while under floortiles is fine though
			honk(AM)
			next_honk = world.time + honk_delay

/obj/item/weapon/bikehorn/afterattack(atom/target, mob/user as mob, proximity_flag)
	//hitsound takes care of that
	//if(proximity_flag && istype(target, /mob)) //for honking in the chest
		//honk()
		//return

	if(!proximity_flag && istype(target, /mob) && honk(user)) //for skilled honking at a range
		target.visible_message(\
			"<span class='notice'>[user] honks \the [src] at \the [target].</span>",\
			"[user] honks \the [src] at you.")

/obj/item/weapon/bikehorn/kick_act(mob/living/H)
	if(..())
		return 1

	honk(H)

/obj/item/weapon/bikehorn/bite_act(mob/living/H)
	H.visible_message("<span class='danger'>[H] bites \the [src]!</span>", "<span class='danger'>You bite \the [src].</span>")

	honk(H)

/obj/item/weapon/bikehorn/proc/honk(var/mob/user)
	var/is_clowny = clumsy_check(user)
	if(world.time - last_honk_time >= honk_delay - (is_clowny ? honk_delay*0.75 : 0)) //Clowns can honk 4x faster
		var/initial_hitsound = hitsound
		if(ishuman(user)) //Merry Cico Del Mayo, ai caramba!!!!!
			var/mob/living/carbon/human/H = user
			if(is_clowny)
				if(H.is_wearing_item(/obj/item/clothing/head/sombrero) && H.is_wearing_item(/obj/item/clothing/suit/poncho))
					hitsound = 'sound/items/bikehorn_curaracha.ogg'
					spawn(0)
						hitsound = initial_hitsound
		last_honk_time = world.time
		playsound(src, hitsound, 50, vary_pitch)
		return 1
	return 0

/obj/item/weapon/bikehorn/arcane_act(mob/user) // ideally only on cast because this thing would be dummy broken if it was kept like that
	visible_message("<span class='warning'>HONK</span>")
	playsound(user, istype(src,/obj/item/weapon/bikehorn/skullhorn) ? hitsound : 'sound/items/AirHorn.ogg', 100, 1)
	for(var/mob/living/carbon/M in hearers(4, src))
		M.sleeping = 0
		M.stuttering += 10
		M.ear_deaf += 5
		M.confused += 5
		M.dizziness += 5
		M.jitteriness += 5

/obj/item/weapon/bikehorn/syndicate
	var/super_honk_delay = 50 //5 seconds
	var/last_super_honk_time

/obj/item/weapon/bikehorn/syndicate/attack_self(mob/user)
	add_fingerprint(user)
	super_honk(user)

/obj/item/weapon/bikehorn/syndicate/proc/super_honk(var/mob/user)
	if(world.time - last_super_honk_time >= super_honk_delay)
		last_super_honk_time = world.time
		to_chat(user, "<span class='warning'>HONK</span>")
		playsound(user, 'sound/items/AirHorn.ogg', 100, 1)
		for(var/mob/living/carbon/M in ohearers(4, user))
			if(M.is_deaf() || M.earprot())
				continue
			to_chat(M, "<font color='red' size='5'>HONK</font>")
			M.sleeping = 0
			M.stuttering += 10
			M.ear_deaf += 5
			M.confused += 5
			M.dizziness += 5
			M.jitteriness += 5

/obj/item/weapon/bikehorn/syndicate/examine(mob/user)
	..()
	if(is_holder_of(user, src))
		to_chat(user, "<span class='warning'>On closer inspection, this one appears to have a tiny megaphone inside...</span>")

/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky, you're the one, you make bathtime lots of fuuun. Rubber ducky, I'm awfully fooooond of yooooouuuu~"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	attack_verb = list("quacks")
	hitsound = 'sound/items/quack.ogg'
	honk_delay = 10
	can_honk_baton = 0

/obj/item/weapon/bikehorn/rubberducky/arcane_act(mob/user)
	to_chat(user,"<span class='danger'>You divide by zero!</span>")
	var/obj/item/toy/spinningtoy/ST = new(loc)
	ST.arcane_act(user)
	qdel(src)

/obj/item/weapon/bikehorn/baton
	name = "honk baton"
	desc = "A stun baton for honking people with."
	icon = 'icons/obj/weapons.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "honkbaton"
	item_state = "honkbaton"
	can_honk_baton = 0

/obj/item/weapon/bikehorn/skullhorn
	name = "skull horn"
	desc = "To be or not to be bad to the bone..."
	icon = 'icons/effects/blood.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/remains.dmi', "right_hand" = 'icons/mob/in-hand/right/remains.dmi')
	icon_state = "remains_skull"
	item_state = "skull"
	attack_verb = list("hits")
	hitsound = 'sound/items/badtothebone.ogg'
	can_honk_baton = 0

#define TELE_COOLDOWN 5 SECONDS

/obj/item/weapon/bikehorn/rubberducky/quantum
	desc = "A quantum quacker."
	var/teleport_range = 5
	var/last_teleport

/obj/item/weapon/bikehorn/rubberducky/quantum/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/bikehorn/rubberducky/quantum/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/bikehorn/rubberducky/quantum/process()
	if(world.time > last_teleport + TELE_COOLDOWN)
		var/visible = FALSE

		for (var/mob/living/M in viewers(src))
			if(!M.isUnconscious() && !is_blind(M))
				visible = TRUE
				break

		if(!visible)
			do_teleport(src, get_turf(src), teleport_range, asoundin = hitsound)
			last_teleport = world.time

/obj/item/weapon/bikehorn/rubberducky/quantum/equipped(var/mob/user, var/slot, hand_index = 0)
	to_chat(user, "<span class = 'warning'>\The [src] disappears from your grasp!</span>")
	user.drop_item(src)
	do_teleport(src, get_turf(src), teleport_range, asoundout = hitsound)
	last_teleport = world.time

#undef TELE_COOLDOWN


/obj/item/weapon/glue
	name = "bottle of superglue"
	desc = "A small plastic bottle full of superglue."

	icon = 'icons/obj/items.dmi'
	icon_state = "glue0"

	w_class = W_CLASS_TINY
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/uses = 1 //How many uses the glue has.
	var/glue_duration = -1 //-1 For infinite.
	var/glue_state_to_set = GLUE_STATE_PERMA //This is the glue state we set to the item the user puts glue on.
	var/list/allowed_glue_types = list(
		/obj/item,
		/obj/structure/bed,
	)

/obj/item/weapon/glue/examine(mob/user)
	..()
	if(Adjacent(user))
		user.show_message("<span class='info'>The label reads:</span><br><span class='notice'>1) Apply glue to the surface of an object<br>2) Apply object to human flesh</span>", MESSAGE_SEE)

/obj/item/weapon/glue/update_icon()
	..()
	icon_state = "glue[uses ? "1" : "0"]"

/obj/item/weapon/glue/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(!uses)
		to_chat(user,"<span class='warning'>There's no glue left in the bottle.</span>")
		return

	if(!is_type_in_list(target, allowed_glue_types))
		to_chat(user,"<span class='warning'>That would be such a waste of glue.</span>")
		return

	if(istype(target, /obj/item/stack)) //The whole cant_drop thing is EXTREMELY fucky with stacks and can be bypassed easily
		to_chat(user,"<span class='warning'>There's not enough glue in \the [src] to cover the whole [target]!</span>")
		return

	if(isitem(target))
		var/obj/item/target_item = target
		if(target_item.current_glue_state != GLUE_STATE_NONE) //Check to see if its glued first.
			to_chat(user,"<span class='warning'>It already has glue on it!</span>")
			return
		if(target_item.abstract) //Can't glue TK grabs, grabs, offhands!
			return

	to_chat(user,"<span class='info'>You put some glue on \the [target].</span>")
	uses--
	update_icon()
	apply_glue(target)


/obj/item/weapon/glue/temp_glue
	name = "bottle of school glue"
	desc = "An ordinary bottle of glue. Stickiness lasts for 3 minutes. <b>Non-toxic.</b>"
	icon = 'icons/obj/items.dmi'
	icon_state = "glue_safe"
	w_class = W_CLASS_TINY
	glue_duration = 3 MINUTES
	glue_state_to_set = GLUE_STATE_TEMP
	uses = 4

/obj/item/weapon/glue/temp_glue/examine(mob/user)
	..()
	if(Adjacent(user))
		to_chat(user,"<span class='info'>It looks [uses ? "like it has about [uses] use(s) left" : "empty"].</span>")

/obj/item/weapon/glue/temp_glue/update_icon()
	if(uses)
		icon_state = "glue_safe"
		return
	name = "empty school glue bottle"
	icon_state = "glue_safe0"

/obj/proc/glue_act(var/stick_time = 1 SECONDS, var/glue_state = GLUE_STATE_NONE) //proc for when glue is used on something
	default_glue_act(stick_time, glue_state)

/obj/proc/default_glue_act(stick_time, glue_state)
	last_glue_application = world.time
	switch(glue_state)
		if(GLUE_STATE_TEMP)
			current_glue_state = GLUE_STATE_TEMP
			spawn(stick_time+1)
				if (last_glue_application+stick_time < world.time)
					unglue()
		else
			current_glue_state = GLUE_STATE_PERMA

/obj/proc/unglue()
	return default_unglue()

/obj/proc/default_unglue()
	if(current_glue_state == GLUE_STATE_TEMP)
		current_glue_state = GLUE_STATE_NONE
		if ("glue" in blood_DNA)
			clean_blood()
		return 1
	else
		return 0

/obj/item/glue_act(stick_time)
	cant_drop++
	..()

/obj/item/unglue()
	if(..())
		cant_drop--

/obj/item/clothing/glue_act(stick_time, glue_state)
	canremove--
	default_glue_act(stick_time, glue_state)

/obj/item/clothing/unglue()
	if(default_unglue())
		canremove++

/obj/structure/bed/glue_act(stick_time)
	..()

/obj/item/weapon/glue/proc/apply_glue(obj/item/target)
	target.glue_act(glue_duration, glue_state_to_set)

/obj/item/weapon/glue/infinite/afterattack()
	.=..()
	uses = 1
	update_icon()

