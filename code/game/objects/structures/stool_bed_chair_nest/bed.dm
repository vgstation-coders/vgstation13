// Beds... get your mind out of the gutter, they're for sleeping!

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/stools-chairs-beds.dmi'
	layer = BELOW_OBJ_LAYER
	anchored = 1
	sheet_type = /obj/item/stack/sheet/metal
	sheet_amt = 1
	var/mob_lock_type = /datum/locking_category/buckle/bed
	var/buckle_range = 0 // The distance a spessman needs to be within in order
						 // to be able to use the buckle_in_out verb
/obj/structure/bed/New()
	..()
	if(material_type)
		sheet_type = material_type.sheettype

/obj/structure/bed/cultify()
	var/obj/structure/bed/chair/wood/wings/I = new /obj/structure/bed/chair/wood/wings(loc)
	I.dir = dir
	. = ..()

/obj/structure/bed/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE)) //NOTE: This includes ALL chairs as well! Vehicles have their own override.
		return 1
	return ..()

/obj/structure/bed/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/bed/attack_hand(mob/user as mob)
	manual_unbuckle(user)

/obj/structure/bed/attack_animal(mob/user as mob)
	manual_unbuckle(user)

/obj/structure/bed/attack_robot(mob/user as mob)
	if(Adjacent(user))
		manual_unbuckle(user)

/obj/structure/bed/MouseDropTo(var/atom/movable/AM, var/mob/user)
	if(ismob(AM))
		buckle_mob(AM, user)
	else
		return ..()

/obj/structure/bed/AltClick(mob/user as mob)
	buckle_mob(user, user)

/obj/structure/bed/verb/buckle_in_out()
	set name = "Buckle In/Out"
	set category = "Object"
	set src in range(1)

	var/list/locked_mobs = get_locked(mob_lock_type)
	if(usr in locked_mobs)
		manual_unbuckle(usr)
	else
		if(get_dist(usr, src) > buckle_range)
			to_chat(usr, "<span class='warning'>You're too far away.</span>")
			return
		buckle_mob(usr, usr)

/obj/structure/bed/proc/manual_unbuckle(var/mob/user, var/resisting = FALSE)
	if(user.isStunned())
		return FALSE

	if (user.restrained() && !resisting)
		to_chat(user, "<span class='warning'>Uncuff yourself first!</span>")
		return FALSE

	if(user.size <= SIZE_TINY)
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return FALSE

	if(is_locking(mob_lock_type))
		add_fingerprint(user)

		var/mob/M = get_locked(mob_lock_type)[1]
		var/success = unlock_atom(M)

		if(M != user)
			if(!success)
				user.delayNextAttack(8)
				M.visible_message("<span class='warning'>[user] struggles in vain trying to pull [M] off \the [src].</span>")
				return FALSE
			M.visible_message(
				"<span class='notice'>[M] was unbuckled by [user]!</span>",
				"You were unbuckled from \the [src] by [user].",
				"You hear metal clanking.")
		else
			if(!success)
				user.delayNextAttack(8)
				M.visible_message("<span class='warning'>[user] struggles in vain trying to pull themselves off \the [src].</span>")
				return FALSE
			M.visible_message(
				"<span class='notice'>[M] unbuckled \himself!</span>",
				"You unbuckle yourself from \the [src].",
				"You hear metal clanking.")
		playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)
		return TRUE

/obj/structure/bed/proc/buckle_mob(mob/M as mob, mob/user as mob)
	if(!Adjacent(user) || user.incapacitated() || istype(user, /mob/living/silicon/pai))
		return

	if(!ismob(M) || (M.loc != src.loc)  || M.locked_to)
		return

	if(!user.Adjacent(M))
		return

	for(var/mob/living/L in get_locked(mob_lock_type))
		to_chat(user, "<span class='warning'>Somebody else is already buckled into \the [src]!</span>")
		return

	if(user.size <= SIZE_TINY) //Fuck off mice
		to_chat(user, "<span class='warning'>You are too small to do that.</span>")
		return

	if(isanimal(M))
		if(M.size <= SIZE_TINY) //Fuck off mice
			to_chat(user, "<span class='warning'>The [M] is too small to buckle in.</span>")
			return

	if(istype(M, /mob/living/carbon/slime))
		to_chat(user, "<span class='warning'>The [M] is too squishy to buckle in.</span>")
		return

	if(M == usr)
		M.visible_message(\
			"<span class='notice'>[M.name] buckles in!</span>",\
			"You buckle yourself to [src].",\
			"You hear metal clanking.")
	else
		M.visible_message(\
			"<span class='notice'>[M.name] is buckled in to [src] by [user.name]!</span>",\
			"You are buckled in to [src] by [user.name].",\
			"You hear metal clanking.")

	playsound(src, 'sound/misc/buckle_click.ogg', 50, 1)
	add_fingerprint(user)

	lock_atom(M, mob_lock_type)

	if(M.pulledby)
		M.pulledby.start_pulling(src)

/obj/structure/bed/lock_atom(atom/movable/AM)
	. = ..()
	if(!.)
		return
	if(ismob(AM))
		var/mob/dude = AM
		dude.throw_alert(SCREEN_ALARM_BUCKLE, /obj/abstract/screen/alert/object/buckled, new_master = src)

/obj/structure/bed/unlock_atom(var/atom/movable/AM)
	if(current_glue_state != GLUE_STATE_NONE && ismob(AM))
		return FALSE
	. = ..()
	if(.)
		if(ismob(AM))
			var/mob/dude = AM
			dude.clear_alert(SCREEN_ALARM_BUCKLE)

/obj/structure/bed/Destroy()
	if(current_glue_state == GLUE_STATE_PERMA && is_locking(mob_lock_type))//Don't de-ass someone if it was temporary glue.
		var/mob/living/carbon/human/locked = get_locked(mob_lock_type)[1]
		if(istype(locked) && locked.remove_butt())
			playsound(src, 'sound/items/poster_ripped.ogg', 100, TRUE)
			visible_message("<span class='danger'>[locked]'s butt is ripped from their body as \the [src] gets dismantled!</span>")
			locked.apply_damage(10, BRUTE, LIMB_GROIN)
			locked.apply_damage(10, BURN, LIMB_GROIN)
			locked.audible_scream()
	current_glue_state = GLUE_STATE_NONE
	..()

/obj/structure/bed/attackby(obj/item/weapon/W, mob/user)
	if(W.is_wrench(user))
		wrench_act(W,user)
	else
		..()

/obj/structure/bed/proc/wrench_act(obj/item/weapon/W,mob/user)
	W.playtoolsound(src, 50)
	drop_stack(sheet_type, loc, 2, user)
	qdel(src)

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"

/obj/structure/bed/racecar
	name = "race car bed"
	desc = "Vroom Vroom!"
	icon_state = "racecarbed"
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amt = 2

/obj/structure/bed/racecar/classic
	name = "race car bed"
	desc = "Only fits one driver."
	icon_state = "racecarclassic"

/obj/structure/bed/racecar/shuttle
	name = "shuttle bed"
	desc = "The Emergency Shuttle has docked with dreamland."
	icon_state = "eshuttle"

/obj/structure/bed/racecar/firetruck
	name = "fire truck bed"
	desc = "Excellent at stopping oven fires."
	icon_state = "firetruck"

//therapy couch
//beach ambience found in ambience_datums.dm
//ambience granted in human.dm L1979
/obj/structure/bed/therapy
	name = "therapy couch"
	desc = "A relaxing couch that will make the troubles melt away as you tell a stranger about your father."
	icon_state = "psychcouch"
	anchored = FALSE

/obj/structure/bed/therapy/New()
	..()
	processing_objects += src

/obj/structure/bed/therapy/Destroy()
	processing_objects -= src
	..()

/obj/structure/bed/therapy/process()
	for(var/mob/living/carbon/human/H in get_locked(mob_lock_type))
		//Only humanoids are emotionally complex enough to benefit from this bench
		H.AdjustDizzy(rand(-2,-4))
		H.stuttering = max(0,H.stuttering-rand(2,4))
		H.jitteriness = max(0,H.jitteriness-rand(2,4))
		H.hallucination = max(0,H.hallucination-rand(2,4))
		H.remove_confused(rand(2, 4))
		H.drowsyness = max(0, H.drowsyness-rand(2,4))
		H.pain_shock_stage = max(0, H.pain_shock_stage-rand(2,3))
		H.dir = 8 //face up on couch

/obj/structure/bed/therapy/wrench_act(obj/item/weapon/W,mob/user)
	if(wrenchAnchor(user,W) && !anchored)
		var/mob/living/locked = get_locked(mob_lock_type)[1]
		if(locked)
			unlock_atom(locked)
			to_chat(locked,"<span class='warning'>You are forced off \the [src] as it is unanchored.</span>")

/obj/structure/bed/therapy/buckle_mob(mob/M as mob, mob/user as mob)
	if(!anchored)
		//note .name is used here to avoid "the" appearing
		to_chat(user,"<span class='warning'>You need the stability of an anchored [src.name] to really benefit from that.</span>")
		return
	..()

/obj/structure/bed/therapy/cultify()
	return //tell me about this "papa" you keep chanting about
