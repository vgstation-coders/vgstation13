#define SYNDICUFFS_ON_APPLY 0
#define SYNDICUFFS_ON_REMOVE 1

/obj/item/weapon/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	setGender(PLURAL)
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	starting_materials = list(MAT_IRON = 500)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1"
	var/cuffing_sound = 'sound/weapons/handcuffs.ogg'
	var/breakouttime = 2 MINUTES

/obj/item/weapon/handcuffs/attack(var/mob/living/carbon/M, var/mob/user, var/def_zone)
	if(!istype(M))
		return

	if(!user.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if((M_CLUMSY in user.mutations) && prob(50))
		to_chat(usr, "<span class='warning'>Uh... how do these things work?!</span>")
		handcuffs_apply(M, user, TRUE)
		return

	if(M.handcuffed)
		return

	M.attack_log += text("\[[time_stamp()]] <span style='color: orange'>Has been handcuffed (attempt) by [user.name] ([user.ckey])</span>")
	user.attack_log += text("\[[time_stamp()]] <span style='color: red'>Attempted to handcuff [M.name] ([M.ckey])</span>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	log_attack("[user.name] ([user.ckey]) Attempted to handcuff [M.name] ([M.ckey])")

	handcuffs_apply(M, user)

//Our inventory procs should be able to handle the following, but our inventory code is hot spaghetti bologni, so here we go //There's no real reason for this to be a separate proc now but whatever
/obj/item/weapon/handcuffs/proc/handcuffs_apply(var/mob/living/carbon/C, var/mob/user, var/clumsy = FALSE)
	if(!istype(C)) //Sanity doesn't hurt, right ?
		return FALSE

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if (!H.has_organ_for_slot(slot_handcuffed))
			to_chat(user, "<span class='danger'>\The [C] needs at least two wrists before you can cuff them together!</span>")
			return

	playsound(get_turf(src), cuffing_sound, 30, 1, -2)
	user.visible_message("<span class='danger'>[user] is trying to handcuff \the [C]!</span>",
						 "<span class='danger'>You try to handcuff \the [C]!</span>")

	if(do_after(user, C, 3 SECONDS))
		if(istype(src, /obj/item/weapon/handcuffs/cable))
			feedback_add_details("handcuffs", "C")
		else
			feedback_add_details("handcuffs", "H")

		user.visible_message("<span class='danger'>\The [user] has put \the [src] on \the [C]!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has put \the [src] on [C.name] ([C.ckey])</font>")
		C.attack_log += text("\[[time_stamp()]\] <font color='red'>Handcuffed with \the [src] by [user.name] ([user.ckey])</font>")
		log_attack("[user.name] ([user.ckey]) has cuffed [C.name] ([C.ckey]) with \the [src]")

		var/obj/item/weapon/handcuffs/cuffs = src
		if(istype(src, /obj/item/weapon/handcuffs/cyborg)) //There's GOT to be a better way to check for this.
			cuffs = new(get_turf(user))
		else
			user.drop_from_inventory(cuffs)
		C.equip_to_slot(cuffs, slot_handcuffed)

/obj/item/weapon/handcuffs/cyborg
//This space intentionally left blank


//Syndicate Cuffs. Disguised as regular cuffs, they are pretty explosive
/obj/item/weapon/handcuffs/syndicate
	var/countdown_time   = 3 SECONDS
	var/mode             = SYNDICUFFS_ON_APPLY //Handled at this level, Syndicate Cuffs code
	var/charge_detonated = FALSE

/obj/item/weapon/handcuffs/syndicate/attack_self(mob/user)

	mode = !mode

	switch(mode)
		if(SYNDICUFFS_ON_APPLY)
			to_chat(user, "<span class='notice'>You pull the rotating arm back until you hear two clicks. \The [src] will detonate a few seconds after being applied.</span>")
		if(SYNDICUFFS_ON_REMOVE)
			to_chat(user, "<span class='notice'>You pull the rotating arm back until you hear one click. \The [src] will detonate when removed.</span>")

/obj/item/weapon/handcuffs/syndicate/equipped(var/mob/user, var/slot)
	..()

	if(slot == slot_handcuffed && mode == SYNDICUFFS_ON_APPLY && !charge_detonated)
		detonate(1)

/obj/item/weapon/handcuffs/proc/on_remove(var/mob/living/carbon/C) //Needed for syndicuffs
	return

/obj/item/weapon/handcuffs/syndicate/on_remove(mob/living/carbon/C)
	if(mode == SYNDICUFFS_ON_REMOVE && !charge_detonated)
		detonate(0) //This handles cleaning up the inventory already
		return //Don't clean up twice, we don't want runtimes

//C4 and EMPs don't mix, will always explode at severity 1, and likely to explode at severity 2
/obj/item/weapon/handcuffs/syndicate/emp_act(severity)

	switch(severity)
		if(1)
			if(prob(80))
				detonate(1)
			else
				detonate(0)
		if(2)
			if(prob(50))
				detonate(1)

/obj/item/weapon/handcuffs/syndicate/ex_act(severity)

	switch(severity)
		if(1)
			if(!charge_detonated)
				detonate(0)
		if(2)
			if(!charge_detonated)
				detonate(0)
		if(3)
			if(!charge_detonated && prob(50))
				detonate(1)
		else
			return

	qdel(src)

/obj/item/weapon/handcuffs/syndicate/proc/detonate(countdown)
	set waitfor = FALSE
	if(charge_detonated)
		return

	charge_detonated = TRUE // Do it before countdown to prevent spam fuckery.
	if(countdown)
		sleep(countdown_time)

	explosion(get_turf(src), 0, 1, 3, 0)
	qdel(src)

/obj/item/weapon/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_red"
	_color = "red"
	breakouttime = 300 //Deciseconds = 30s
	cuffing_sound = 'sound/weapons/cablecuff.ogg'

/obj/item/weapon/handcuffs/cable/red
	icon_state = "cuff_red"

/obj/item/weapon/handcuffs/cable/yellow
	icon_state = "cuff_yellow"
	_color = "yellow"

/obj/item/weapon/handcuffs/cable/blue
	icon_state = "cuff_blue"
	_color = "blue"

/obj/item/weapon/handcuffs/cable/green
	icon_state = "cuff_green"
	_color = "green"

/obj/item/weapon/handcuffs/cable/pink
	icon_state = "cuff_pink"
	_color = "pink"

/obj/item/weapon/handcuffs/cable/orange
	icon_state = "cuff_orange"
	_color = "orange"

/obj/item/weapon/handcuffs/cable/cyan
	icon_state = "cuff_cyan"
	_color = "cyan"

/obj/item/weapon/handcuffs/cable/white
	icon_state = "cuff_white"
	_color = "white"

/obj/item/weapon/handcuffs/cable/update_icon()
	if(_color)
		icon_state = "cuff_[_color]"

/obj/item/weapon/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod
		R.use(1)

		user.before_take_item(src)

		user.put_in_hands(W)
		to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")

		qdel(src)
