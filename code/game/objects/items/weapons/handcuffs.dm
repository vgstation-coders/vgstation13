#define SYNDICUFFS_ON_APPLY 0
#define SYNDICUFFS_ON_REMOVE 1

/obj/item/weapon/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
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
	origin_tech = Tc_MATERIALS + "=1"
	toolsounds = list('sound/weapons/handcuffs.ogg')
	restraint_resist_time = 2 MINUTES
	var/list/mutual_handcuffed_mobs = list()

/obj/item/weapon/handcuffs/Destroy()
	for (var/mob/living/carbon/cuffed_mob in mutual_handcuffed_mobs)
		src.remove_mutual_cuff_events(cuffed_mob)
	. = ..()

/obj/item/weapon/handcuffs/restraint_apply_intent_check(mob/user)
	return 1

/obj/item/weapon/handcuffs/cyborg
//This space intentionally left blank

/obj/item/weapon/handcuffs/cyborg/on_restraint_removal(var/mob/living/carbon/C)
	spawn(1)
		qdel(src)

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

/obj/item/weapon/handcuffs/syndicate/on_restraint_removal(mob/living/carbon/C)
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
	icon_state = "cablecuff"
	restraint_resist_time = 30 SECONDS
	toolsounds = list('sound/weapons/cablecuff.ogg')

/obj/item/weapon/handcuffs/cable/red
	color = "#FF0000"

/obj/item/weapon/handcuffs/cable/yellow
	color = "#FFED00"

/obj/item/weapon/handcuffs/cable/blue
	color = "#005C84"

/obj/item/weapon/handcuffs/cable/green
	color = "#0B8400"

/obj/item/weapon/handcuffs/cable/pink
	color = "#CA00B6"

/obj/item/weapon/handcuffs/cable/orange
	color = "#CA6900"

/obj/item/weapon/handcuffs/cable/cyan
	color = "#00B5CA"

/obj/item/weapon/handcuffs/cable/white
	color = "#D0D0D0"

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

/obj/item/weapon/handcuffs/cable/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		// Figure out how much water or cleaner there is
		var/cleaner_percent = get_reagent_paint_cleaning_percent(target)

		if (cleaner_percent >= 0.7)
			// Clean up that cable
			color = "#D0D0D0"
			to_chat(user, "<span class='notice'>You clean \the [name] in \the [target.name].</span>")
		else
			// Take the reagent mix's color
			var/list/paint_color_rgb = rgb2num(mix_color_from_reagents(target.reagents.reagent_list, TRUE))//only pigments
			color = rgb(paint_color_rgb[1], paint_color_rgb[2], paint_color_rgb[3])
			to_chat(user, "<span class='notice'>You dip \the [name] in \the [target.name].</span>")
		user.update_inv_hands()
