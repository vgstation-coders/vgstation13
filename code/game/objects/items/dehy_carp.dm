/*
 *	Dehydrated Carp
 *	Instant carp, just add water
 */

// Child of carpplushie because this should do everything the toy does and more

/mob/living/simple_animal/hostile/carp/instant_carp
	var/owner = null
	can_breed = 0

/mob/living/simple_animal/hostile/carp/instant_carp/CanAttack(var/atom/the_target)
	if(ismob(the_target))
		var/mob/mob_target = the_target
		if(isnukeop(mob_target))
			return 0
		if(mob_target == owner)
			return 0
	return ..()

/obj/item/toy/carpplushie/dehy_carp
	var/mob/owner = null	// Carp doesn't attack owner, set when using in hand
	var/owned = 0	// Boolean, no owner to begin with

// Attack self
/obj/item/toy/carpplushie/dehy_carp/attack_self(mob/user)
	add_fingerprint(user)	// Anyone can add their fingerprints to it with this
	if(!owned)
		to_chat(user, "<span class='notice'>\The [src] stares up at you with friendly eyes.</span>")
		owner = user
		owned = 1
	return ..()


/obj/item/toy/carpplushie/dehy_carp/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O,/obj/structure/sink))
		to_chat(user, "<span class='notice'>You place \the [src] under a stream of water...</span>")
		user.drop_item(get_turf(O))
		return Swell()
	..()

/obj/item/toy/carpplushie/dehy_carp/proc/Swell()
	desc = "It's growing!"
	visible_message("<span class='notice'>\The [src] swells up!</span>")

	// Animation
	icon = 'icons/mob/animal.dmi'
	flick("carp_swell", src)
	// Wait for animation to end
	sleep(6)
	if(!src || qdeleted(src))//we got toasted while animating
		return
	//Make space carp
	var/mob/living/simple_animal/hostile/carp/instant_carp/C = new/mob/living/simple_animal/hostile/carp/instant_carp(get_turf(src))
	C.owner = owner
	qdel(src)
