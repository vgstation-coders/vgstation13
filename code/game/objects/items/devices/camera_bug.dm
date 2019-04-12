/obj/item/device/camera_bug
	name = "camera bug"
	desc = "A tiny spy camera that can stick to most surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant_evil"
	w_class = W_CLASS_TINY
	item_state = ""
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | NO_ATTACK_MSG
	var/c_tag = ""
	var/active = FALSE
	var/network = ""
	var/list/excludes = list(
		/obj/effect,
		/turf/simulated/floor,
		/turf/space,
		/turf/simulated/shuttle,
		/mob/living/carbon,
		/obj/item/weapon/storage
	)

/obj/item/device/camera_bug/attack_self(var/mob/user)
	var/newtag = sanitize(input(user, "Choose a unique ID tag:", name, c_tag) as null|text)
	if(newtag)
		c_tag = newtag
		if(user.mind)
			network = "\ref[user.mind]"

/obj/item/device/camera_bug/afterattack(var/atom/A, var/mob/user, var/proximity_flag)
	if(!proximity_flag)
		to_chat(user, "<span class='warning'>You can't seem to reach \the [A].</span>")
		return 0
	var/atom/movable/AM = A
	if(isatommovable(AM))
		var/turf/atom_turf = get_turf(A)
		if(AM.level == LEVEL_BELOW_FLOOR && isturf(atom_turf) && atom_turf.intact)
			to_chat(user, "<span class='notice'>You need to remove the plating first.</span>")
			return 0
	if(!c_tag || c_tag == "")
		to_chat(user, "<span class='notice'>Set the tag first, dumbass.</span>")
		return 0
	if(is_type_in_list(A, excludes))
		to_chat(user, "<span class='warning'>\The [src] won't stick!</span>")
		return 0
	if(istype(A, /obj/item))
		var/obj/item/I = A
		if(I.w_class < W_CLASS_MEDIUM)
			to_chat(user, "<span class='warning'>\The [I] is too small for \the [src].</span>")
			return 0
	var/obj/item/device/camera_bug/bug = locate() in A
	if(bug)
		to_chat(user, "<span class='warning'>\A [bug] is already on \the [A].</span>")
		return 0
	if(!user.drop_item(src, A))
		to_chat(user, "<span class='warning'>You can't let go of \the [src]!</span>")
		return 0
	to_chat(user, "<span class='notice'>You stealthily place \the [src] onto \the [A].</span>")
	active = TRUE
	camera_bugs += src
	return 1

/obj/item/device/camera_bug/emp_act(var/severity)
	var/message = "<span class='notice'>\The [src] deactivates and falls off!</span>"
	switch(severity)
		if(3)
			if(prob(10))
				removed(null, message, prob(1))
		if(2)
			if(prob(40))
				removed(null, message, prob(5))
		if(1)
			removed(null, message, prob(30))

/*
  user is who removed it if possible
  message is the displayed message on removal
  catastrophic is whether it should explode on removal or not
*/
/obj/item/device/camera_bug/proc/removed(var/mob/user = null, var/message = "[user] pries \the [src] away from \the [loc].", var/catastrophic = FALSE)
	active = FALSE
	camera_bugs -= src
	if(user)
		user.put_in_hands(src)
	else
		forceMove(get_turf(src))
	if(message)
		visible_message(message)
	if(catastrophic)
		spawn(0.5 SECONDS)
			explosion(loc, 0, prob(15), 2, 0)

/obj/item/device/camera_bug/Destroy()
	camera_bugs -= src
	..()