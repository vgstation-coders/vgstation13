/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peels
 */
/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(2, 2, 1))
			M.simple_message("<span class='notice'>You slipped on the [name]!</span>",
				"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")

/*
 * Soap
 */
/obj/item/weapon/soap/Crossed(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(3, 2, 1))
			M.simple_message("<span class='notice'>You slipped on the [name]!</span>",
				"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob)
	//I couldn't feasibly fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	//Overlay bugs can probably be fixed by updating the user's icon, see watercloset.dm
	if(!user.Adjacent(target))
		return

	if(user.client && (target in user.client.screen) && !(user.is_holding_item(target)))
		user.simple_message("<span class='notice'>You need to take that [target.name] off before cleaning it.</span>",
			"<span class='notice'>You need to take that [target.name] off before destroying it.</span>")

	else if(istype(target,/obj/effect/decal/cleanable))
		user.simple_message("<span class='notice'>You scrub \the [target.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		returnToPool(target)

	else if(istype(target,/turf/simulated))
		var/turf/simulated/T = target
		var/list/cleanables = list()

		for(var/obj/effect/decal/cleanable/CC in T)
			if(!istype(CC) || !CC)
				continue
			cleanables += CC

		for(var/obj/effect/decal/cleanable/CC in get_turf(user)) //Get all nearby decals drawn on this wall and erase them
			if(CC.on_wall == target)
				cleanables += CC

		if(!cleanables.len)
			user.simple_message("<span class='notice'>You fail to clean anything.</span>",
				"<span class='notice'>There is nothing for you to vandalize.</span>")
			return
		cleanables = shuffle(cleanables)
		var/obj/effect/decal/cleanable/C
		for(var/obj/effect/decal/cleanable/d in cleanables)
			if(d && istype(d))
				C = d
				break
		user.simple_message("<span class='notice'>You scrub \the [C.name] out.</span>",
			"<span class='warning'>You destroy [pick("an artwork","a valuable artwork","a rare piece of art","a rare piece of modern art")].</span>")
		returnToPool(C)
	else
		user.simple_message("<span class='notice'>You clean \the [target.name].</span>",
			"<span class='warning'>You [pick("deface","ruin","stain")] \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()

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

/obj/item/weapon/bikehorn/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] places the [src.name] into \his mouth and honks the horn. </span>")
	playsound(user, hitsound, 100, vary_pitch)
	user.gib()

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if(honk())
		add_fingerprint(user)

/obj/item/weapon/bikehorn/afterattack(atom/target, mob/user as mob, proximity_flag)
	//hitsound takes care of that
	//if(proximity_flag && istype(target, /mob)) //for honking in the chest
		//honk()
		//return

	if(!proximity_flag && istype(target, /mob) && honk()) //for skilled honking at a range
		target.visible_message(\
			"<span class='notice'>[user] honks \the [src] at \the [target].</span>",\
			"[user] honks \the [src] at you.")

/obj/item/weapon/bikehorn/kick_act(mob/living/H)
	if(..())
		return 1

	honk()

/obj/item/weapon/bikehorn/bite_act(mob/living/H)
	H.visible_message("<span class='danger'>[H] bites \the [src]!</span>", "<span class='danger'>You bite \the [src].</span>")

	honk()

/obj/item/weapon/bikehorn/proc/honk()
	if(world.time - last_honk_time >= honk_delay)
		last_honk_time = world.time
		playsound(src, hitsound, 50, vary_pitch)
		return 1
	return 0

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

/obj/item/weapon/bikehorn/baton
	name = "honk baton"
	desc = "A stun baton for honking people with."
	icon = 'icons/obj/weapons.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "honkbaton"
	item_state = "honkbaton"
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


#define GLUE_WEAROFF_TIME -1 //was 9000: 15 minutes, or 900 seconds. Negative values = infinite glue

/obj/item/weapon/glue
	name = "bottle of superglue"
	desc = "A small plastic bottle full of superglue."

	icon = 'icons/obj/items.dmi'
	icon_state = "glue0"

	w_class = W_CLASS_TINY

	var/spent = 0

/obj/item/weapon/glue/examine(mob/user)
	..()
	if(Adjacent(user))
		user.show_message("<span class='info'>The label reads:</span><br><span class='notice'>1) Apply glue to the surface of an object<br>2) Apply object to human flesh</span>", MESSAGE_SEE)

/obj/item/weapon/glue/update_icon()
	..()
	icon_state = "glue[spent]"

/obj/item/weapon/glue/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(spent)
		to_chat(user,"<span class='warning'>There's no glue left in the bottle.</span>")
		return

	var/static/list/allowed_types = list(
		/obj/item,
		/obj/structure/bed,
	)
	if(!is_type_in_list(target, allowed_types))
		to_chat(user,"<span class='warning'>That would be such a waste of glue.</span>")
		return

	if(istype(target, /obj/item/stack)) //The whole cant_drop thing is EXTREMELY fucky with stacks and can be bypassed easily
		to_chat(user,"<span class='warning'>There's not enough glue in \the [src] to cover the whole [target]!</span>")
		return

	if(isitem(target))
		var/obj/item/target_item = target
		if(target_item.abstract) //Can't glue TK grabs, grabs, offhands!
			return

	to_chat(user,"<span class='info'>You gently apply the whole [src] to \the [target].</span>")
	spent = 1
	update_icon()
	apply_glue(target)

/obj/proc/glue_act() //proc for when glue is used on something
	return

/obj/item/glue_act()
	cant_drop++
	if(GLUE_WEAROFF_TIME > 0)
		spawn(GLUE_WEAROFF_TIME)
			cant_drop--

/obj/item/clothing/glue_act()
	canremove--
	if(GLUE_WEAROFF_TIME > 0)
		spawn(GLUE_WEAROFF_TIME)
			canremove++

/obj/structure/bed/glue_act()
	glued = TRUE
	if(GLUE_WEAROFF_TIME > 0)
		spawn(GLUE_WEAROFF_TIME)
			glued = FALSE

/obj/item/weapon/glue/proc/apply_glue(obj/item/target)
	src = null
	target.glue_act()

/obj/item/weapon/glue/infinite/afterattack()
	.=..()

	spent = 0
	update_icon()

#undef GLUE_WEAROFF_TIME
