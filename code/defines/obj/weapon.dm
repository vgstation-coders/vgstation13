/obj/item/weapon/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	flags = FPRINT
	siemens_coefficient = 1
	force = 3.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_SMALL
	attack_verb = list("calls", "rings", "dials")
	hitsound = 'sound/weapons/ring.ogg'

/obj/item/weapon/phone/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] wraps the cord of the [src.name] around \his neck! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/rsp
	name = "\improper Rapid-Seed-Producer (RSP)"
	desc = "A device used to rapidly deploy seeds."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/hydroponics/banana.dmi'
	icon_state = "peel"
	item_state = "banana_peel"
	w_class = W_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	var/potency = 20
	var/slip_override = 0

/obj/item/weapon/bananapeel/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] drops the [src.name] on the ground and steps on it causing \him to crash to the floor, bashing \his head wide open. </span>")
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 5

/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	origin_tech = Tc_MATERIALS + "=1"
	icon_state = "cane"
	item_state = "stick"
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	throwforce = 7.0
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 50)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_STEEL
	attack_verb = list("bludgeons", "whacks", "disciplines", "thrashes")

/obj/item/weapon/disk
	name = "Corrupted Data Disk"
	desc = "The data on this disk has decayed, and cannot be read by any computer anymore. Can still be used by a duplicator as if it were a blank disk."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/datadisks.dmi', "right_hand" = 'icons/mob/in-hand/right/datadisks.dmi')
	w_class = W_CLASS_TINY
	w_type = RECYK_ELECTRONIC
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)

/obj/item/weapon/disk/blank
	name = "Blank Data Disk"
	desc = "An empty data disk, to be used with a disk duplicator."

/obj/item/weapon/disk/hdd
	name = "Hard Disk Drive"
	icon_state = "harddisk"
	item_state = "harddisk"
	w_class = W_CLASS_SMALL
	w_type = RECYK_ELECTRONIC
	starting_materials = list(MAT_IRON = 200, MAT_GLASS = 20)

//TODO: Figure out wtf this is and possibly remove it -Nodrak
/obj/item/weapon/dummy
	name = "dummy"
	invisibility = 101.0
	anchored = 1.0
	flags = 0

/obj/item/weapon/dummy/ex_act()
	return

/obj/item/weapon/dummy/blob_act()
	return


/*
/obj/item/weapon/game_kit
	name = "Gaming Kit"
	icon = 'icons/obj/items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = W_CLASS_HUGE
*/

/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 0
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_MATERIALS + "=1"
	var/breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/legcuffs/bolas
	name = "bolas"
	desc = "An entangling bolas. Throw at your foes to trip them and prevent them from running."
	gender = NEUTER
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolas"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 2
	w_class = W_CLASS_SMALL
	w_type = RECYK_METAL
	origin_tech = Tc_MATERIALS + "=1"
	attack_verb = list("lashes", "bludgeons", "whips")
	force = 4
	breakouttime = 50 //10 seconds
	throw_speed = 1
	throw_range = 10
	var/dispenser = 0
	var/throw_sound = 'sound/weapons/whip.ogg'
	var/trip_prob = 100
	ignore_blocking = IGNORE_SOME_SHIELDS

/obj/item/weapon/legcuffs/bolas/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	user.throw_item(target)

/obj/item/weapon/legcuffs/bolas/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is wrapping the [src.name] around \his neck! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/legcuffs/bolas/throw_at(var/atom/A, throw_range, throw_speed)
	if(!throw_range)
		return //divide by zero, also you throw like a girl
	if(istype(usr, /mob/living/carbon/human)) //if the user is human
		var/mob/living/carbon/human/H = usr
		if(clumsy_check(H) && prob(50))
			to_chat(H, "<span class='warning'>You smack yourself in the face while swinging the [src]!</span>")
			H.Stun(2)
			H.drop_item(src)
			return
	var/turf/target = get_turf(A)
	var/new_x = src.x
	var/new_y = src.y
	var/scaler //used to changed the normalised vector to the proper size
	scaler = throw_range / max(abs(target.x - src.x), abs(target.y - src.y),1) //whichever is larger magnitude is what we normalise to
	if (target.x - src.x != 0) //just to avoid fucking with math for no reason
		var/xadjust = round((target.x - src.x) * scaler) //normalised vector is now scaled up to throw_range
		new_x = src.x + xadjust //the new target at max range
	if (target.y - src.y != 0)
		var/yadjust = round((target.y - src.y) * scaler)
		new_y = src.y + yadjust
	// log_admin("Adjusted target of [adjtarget.x] and [adjtarget.y], adjusted with [xadjust] and [yadjust] from [scaler]")
	..(locate(new_x, new_y, src.z), throw_range, throw_speed)

/obj/item/weapon/legcuffs/bolas/throw_impact(atom/hit_atom) //Pomf was right, I was wrong - Comic
	if(isliving(hit_atom) && hit_atom != usr) //if the target is a live creature other than the thrower
		var/mob/living/M = hit_atom
		if(ishuman(M)) //if they're a human species
			var/mob/living/carbon/human/H = M
			if(H.m_intent == "run") //if they're set to run (though not necessarily running at that moment)
				if(prob(trip_prob)) //this probability is up for change and mostly a placeholder - Comic
					step(H, H.dir)
					H.visible_message("<span class='warning'>[H] was tripped by the bolas!</span>","<span class='warning'>Your legs have been tangled!</span>");
					H.Stun(2) //used instead of setting damage in vars to avoid non-human targets being affected
					H.Knockdown(4)
					H.legcuffed = src //applies legcuff properties inherited through legcuffs
					src.forceMove(H)
					H.update_inv_legcuffed()
					if(!H.legcuffed) //in case it didn't happen, we need a safety net
						throw_failed()
			else if(H.legcuffed) //if the target is already legcuffed (has to be walking)
				throw_failed()
				return
			else //walking, but uncuffed, or the running prob() failed
				to_chat(H, "<span class='notice'>You stumble over the thrown bolas</span>")
				step(H, H.dir)
				H.Stun(1)
				throw_failed()
				return
		else
			M.Stun(2) //minor stun damage to anything not human
			throw_failed()
			return

/obj/item/weapon/legcuffs/bolas/proc/throw_failed() // Empty, overriden on mechs
	return

/obj/item/weapon/legcuffs/bolas/mech/throw_failed() // To avoid infinite Bolas
	qdel(src)

/obj/item/weapon/legcuffs/bolas/to_bump()
	..()
	throw_failed() //allows a mech bolas to be destroyed

// /obj/item/weapon/legcuffs/bolas/cyborg To be implemented
//	dispenser = 1

/obj/item/weapon/legcuffs/bolas/cable
	name = "cable bolas"
	desc = "A poorly made bolas, tied together with cable."
	icon_state = ""
	item_state = "cbolas"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	throw_speed = 1
	throw_range = 6
	trip_prob = 20 //gets updated below in update_icon()
	var/obj/item/weight1 = null //the two items that are attached to the cable
	var/obj/item/weight2 = null
	var/cable_color = ""
	var/desc_empty = "A poorly made bolas, tied together with cable. It has nothing on it."
	var/screw_state = "" //used for storing info about the screwdriver
	var/screw_istate = ""

/obj/item/weapon/legcuffs/bolas/cable/New()
	..()
	desc = desc_empty
	weight1 = null
	weight2 = null
	update_icon()

/obj/item/weapon/legcuffs/bolas/cable/update_icon()
	if (!weight1 && !weight2)
		icon_state = "cbolas_[cable_color]"
		overlays.len = 0
		desc = desc_empty
		trip_prob = 0
		return
	else
		overlays.len = 0
		if (weight1)
			trip_prob = 20
			overlays += icon("icons/obj/weapons.dmi", "cbolas_weight1")
		if (weight2)
			trip_prob = 60
			overlays += icon("icons/obj/weapons.dmi", "cbolas_weight2")
		desc = "A poorly made bolas, made out of \a [weight1] and [weight2 ? "\a [weight2]": "missing a second weight"], tied together with cable."

/obj/item/weapon/legcuffs/bolas/cable/throw_failed()
	if(prob(20))
		src.visible_message("<span class='rose'>\The [src] falls to pieces on impact!</span>")
		if(weight1)
			weight1.forceMove(src.loc)
			weight1 = null
		if(weight2)
			weight2.forceMove(src.loc)
			weight2 = null
		update_icon(src)

/obj/item/weapon/legcuffs/bolas/cable/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item))
		if(istype(O, /obj/item/weapon/gift) || istype(O,/obj/item/delivery))
			return
		var/obj/item/I = O
		if(istype(O, /obj/item/weapon/legcuffs/bolas)) //don't stack into infinity
			return
		if(I.is_wirecutter(user)) //allows you to convert the wire back to a cable coil
			if(!weight1 && !weight2) //if there's nothing attached
				user.show_message("<span class='notice'>You cut the knot in the [src].</span>")
				I.playtoolsound(usr, 50)
				var /obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(user.loc) //we get back the wire lengths we put in
				var /obj/item/stack/cable_coil/S = new /obj/item/tool/screwdriver(user.loc)
				C.amount = 10
				C._color = cable_color
				C.icon_state = "coil_[C._color]"
				C.update_icon()
				S.item_state = screw_state
				S.icon_state = screw_istate
				S.update_icon()
				user.put_in_hands(S)
				qdel(src)
				return
			else
				user.show_message("<span class='notice'>You cut off [weight1] [weight2 ? "and [weight2]" : ""].</span>") //you remove the items currently attached
				if(weight1)
					weight1.forceMove(get_turf(usr))
					weight1 = null
				if(weight2)
					weight2.forceMove(get_turf(usr))
					weight2 = null
				I.playtoolsound(user, 50)
				update_icon()
				return
		if(I.w_class) //if it has a defined weight
			if(I.w_class == W_CLASS_SMALL || I.w_class == W_CLASS_MEDIUM) //just one is too specific, so don't change this
				if(!weight1)
					if(user.drop_item(I, src))
						weight1 = I
						user.show_message("<span class='notice'>You tie [weight1] to the [src].</span>")
						update_icon()
						//del(I)
						return
				if(!weight2) //just in case
					if(user.drop_item(I, src))
						weight2 = I
						user.show_message("<span class='notice'>You tie [weight2] to the [src].</span>")
						update_icon()
						//del(I)
						return
				else
					user.show_message("<span class='rose'>There are already two weights on this [src]!</span>")
					return
			else if (I.w_class < W_CLASS_SMALL)
				user.show_message("<span class='rose'>\The [I] is too small to be used as a weight.</span>")
			else if (I.w_class > W_CLASS_MEDIUM)
				user.show_message("<span class='rose'>\The [I] is [I.w_class > W_CLASS_LARGE ? "far " : ""] too big to be used a weight.</span>")
			else
				user.show_message("<span class='rose'>There are already two weights on this [src]!</span>")

/datum/locking_category/beartrap
		flags = LOCKED_CAN_LIE_AND_STAND

/obj/item/weapon/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	siemens_coefficient = 1
	plane = OBJ_PLANE
	layer = BELOW_CLOSED_DOOR_LAYER
	icon = 'icons/obj/items.dmi'
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	flags = FPRINT
	origin_tech = Tc_MATERIALS + "=1"
	starting_materials = list(MAT_IRON = 50000)
	w_type = RECYK_METAL
	w_class = W_CLASS_LARGE
	anchored = FALSE
	var/breakouttime = 60
	var/armed = 0
	var/trapped = 0
	var/datum/organ/external/trappedorgan //The limb currently trapped, it must be a leg
	var/mob/living/carbon/human/trappeduser
	var/mob/living/simple_animal/hostile/bear/trappedbear
	var/obj/item/weapon/grenade/iedcasing/IED = null
	var/image/ied_overlay

	var/trapped_user_key

/obj/item/weapon/beartrap/New()
	..()
	ied_overlay = image('icons/obj/items.dmi')
	ied_overlay.icon_state = "beartrap_ied"

/obj/item/weapon/beartrap/Destroy()
	trappedorgan = null
	if (trappeduser)
		unlock_atom(trappeduser)
	trappeduser = null
	if (trappedbear)
		unlock_atom(trappedbear)
	trappedbear = null
	if (IED)
		qdel(IED)
	IED = null
	..()

/obj/item/weapon/beartrap/ex_act(var/severity, var/child = null, var/mob/whodunnit)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (IED)
				IED.prime(whodunnit)
		if (3)
			if (IED && prob(50))
				IED.prime(whodunnit)

/obj/item/weapon/beartrap/armed
	armed = 1
	anchored = TRUE
	icon_state = "beartrap1"

/obj/item/weapon/beartrap/ied/New()
	..()
	desc = "A trap used to catch bears and other legged creatures. <span class='warning'>There is an IED hooked up to it.</span>"
	IED = new /obj/item/weapon/grenade/iedcasing/preassembled(src)
	overlays += ied_overlay

/obj/item/weapon/beartrap/ied/armed
	armed = 1
	anchored = TRUE
	icon_state = "beartrap1"

/obj/item/weapon/beartrap/suicide_act(var/mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
		if(head_organ)
			to_chat(viewers(user), "<span class='danger'>[user] is arming the [src.name] on \his head! It looks like \he's trying to commit suicide!</span>")
			playsound(src, 'sound/effects/snap.ogg', 75, 1)
			head_organ.explode()
			return (SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/beartrap/update_icon()
	icon_state = "beartrap[armed]"

/obj/item/weapon/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed

		update_icon()

		to_chat(user, "<span class='notice'>The [src.name] is now [armed ? "armed" : "disarmed"]</span>")
		playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
		anchored = TRUE
		user.drop_item(src, force_drop = 1)

		if(armed && IED)
			message_admins("[key_name(usr)] has armed a beartrap rigged with an IED at [formatJumpTo(get_turf(src))]!")
			log_game("[key_name(usr)] has armed a beartrap rigged with an IED at [formatJumpTo(get_turf(src))]!")

/obj/item/weapon/beartrap/attack_hand(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(armed)
			var/datum/organ/external/affecting = user.get_active_hand_organ()
			if (!affecting)
				return

			user.visible_message("<span class='warning'>\The [H] sets off \the [src]!</span>", \
			"<span class='danger'>You set off \the [src] and it crushes your hand!</span>")
			playsound(src, 'sound/effects/snap.ogg', 60, 1)

			H.audible_scream()
			if(affecting.take_damage(15, 0, 15, SERRATED_BLADE & SHARP_BLADE))
				H.UpdateDamageIcon()
				H.updatehealth()

			armed = 0
			anchored = FALSE
			update_icon()

			return

		else if(trapped)
			if (istype(trappeduser))
				if(!trappeduser.pick_usable_organ(trappedorgan)) //check if they lost their leg, and get them out of the trap
					to_chat(trappeduser, "<span class='warning'>With your leg missing, you slip out of the bear trap.</span>")
					trapped = 0
					unlock_atom(trappeduser)
					trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
					trappeduser = null
					anchored = FALSE
					return
				else
					user.visible_message("<span class='notice'>[H] tries to pry \the [src] off of [trappeduser]!</span>", \
					"<span class='notice'>You try to pry open \the [src] with your bear hands.</span>")

					if(do_after(user, src, 40) && prob(60)) //60% chance I think

						user.visible_message("<span class='notice'>\The [H] managed to pry \the [src] off of [trappeduser]!</span>", \
						"<span class='notice'>You manage to pry \the [src] off!</span>")
						playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
						trapped = 0
						unlock_atom(trappeduser)
						trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
						trappeduser = null
						anchored = FALSE
						return
					else
						user.visible_message("<span class='warning'>\The [H] fails to pry \the [src] off of [trappeduser], and crushes their leg even more!</span>", \
						"<span class='warning'>You fail to pry \the [src] off of [trappeduser], and you crush their leg even more!</span>")

						trappeduser.audible_scream()
						if(trappedorgan.take_damage(5,0,0)) //holy fuck it's easy to knock out legs
							trappeduser.UpdateDamageIcon()
						trappeduser.updatehealth()
						return
			else if (istype(trappedbear))
				user.visible_message("<span class='notice'>[H] tries to pry \the [src] off of \the [trappedbear]!</span>", \
				"<span class='notice'>You try to pry open \the [src] with your bear hands.</span>")

				if(do_after(user, src, 40) && prob(60))
					user.visible_message("<span class='notice'>\The [H] managed to pry \the [src] off of \the [trappedbear]!</span>", \
					"<span class='notice'>You manage to pry \the [src] off!</span>")
					playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)
					trapped = 0
					unlock_atom(trappedbear)
					trappedbear.update_icon()
					trappedbear = null
					anchored = FALSE
					return
				else
					user.visible_message("<span class='warning'>\The [H] fails to pry \the [src] off of \the [trappedbear], and crushes their leg even more!</span>", \
					"<span class='warning'>You fail to pry \the [src] off of \the [trappedbear], and you crush their leg even more!</span>")
					trappedbear.adjustBruteLoss(5)
					return
	..()

/obj/item/weapon/beartrap/attackby(var/obj/item/I, mob/user) //Let's get explosive.
	if(istype(I, /obj/item/weapon/grenade/iedcasing))
		if(IED)
			to_chat(user, "<span class='warning'>This beartrap already has an IED hooked up to it!</span>")
			return
		var/obj/item/weapon/grenade/iedcasing/candidate_IED = I
		switch(candidate_IED.assembled)
			if(0,1) //if it's not fueled/hooked up
				to_chat(user, "<span class='warning'>You haven't prepared this IED yet!</span>")
				return
			if(2)
				if(user.drop_item(I, src))
					var/turf/bombturf = get_turf(src)
					var/area/A = get_area(bombturf)
					var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> has rigged a beartrap with an IED at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
					message_admins(log_str)
					log_game(log_str)
					IED = I
					to_chat(user, "<span class='notice'>You sneak the [IED] underneath the pressure plate and connect the trigger wire.</span>")
					desc = "A trap used to catch bears and other legged creatures. <span class='warning'>There is an IED hooked up to it.</span>"
					overlays.Add(ied_overlay)
			if(3) //There is a whole thing about setting the IED's detonation status for IED'd bear traps, this is to avoid insanity
				to_chat(user, "<span class='warning'It's dangerous to shove a lit IED into a bear trap! Find another way to get rid of it!</span>")
				return
			else
				to_chat(user, "<span class='danger'>You shouldn't be reading this message! Contact a coder or someone, something broke!</span>")
				return
	else if(I.is_screwdriver(user) && IED)
		IED.forceMove(get_turf(src.loc))
		IED = null
		to_chat(user, "<span class='notice'>You remove the IED from the [src].</span>")
		overlays.Remove(ied_overlay)
		return
	else if(iscrowbar(I) && trapped)
		if (istype(trappeduser))
			if(!trappeduser.pick_usable_organ(trappedorgan))
				to_chat(user, "<span class='notice'>Without a leg for the bear trap to pin onto, you safely crowbar it open.</span>")
				trapped = 0
				anchored = FALSE
				unlock_atom(trappeduser)
				trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
				trappeduser = null
			else
				to_chat(user, "<span class='notice'>You begin to pry the bear trap off of [trappeduser.name].</span>")
				if(do_after(user, src, 30))
					to_chat(user, "<span class='notice'>You pry open the bear trap with \the [I.name].</span>")
					trapped = 0
					anchored = FALSE
					unlock_atom(trappeduser)
					trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
					trappeduser = null
		else if (istype(trappedbear))
			to_chat(user, "<span class='notice'>You begin to pry the bear trap off of [trappedbear.name].</span>")
			if(do_after(user, src, 30))
				to_chat(user, "<span class='notice'>You pry open the bear trap with \the [I.name].</span>")
				trapped = 0
				anchored = FALSE
				unlock_atom(trappedbear)
				trappedbear.update_icon()
				trappedbear = null
	else
		to_chat(user, "<span class='notice'>You carefully set the bear trap off with \the [I.name].</span>")
		playsound(src, 'sound/effects/snap.ogg', 60, 1)
		armed = 0
		anchored = FALSE
		update_icon()
	..()

/obj/item/weapon/beartrap/Crossed(AM)
	if(armed && isliving(AM) && isturf(src.loc))

		var/mob/living/L = AM

		if(L.on_foot()) //Flying mobs can't get caught in beartraps! Note that this also prevents lying mobs from triggering traps
			if (ishuman(L))
				var/mob/living/carbon/human/H = L
				H.visible_message("<span class='danger'>[H] steps on \the [src].</span>",\
						"<span class='danger'>You step on \the [src]![(IED && IED.active) ? " The explosive device attached to it activates." : ""]</span>",\
						"<span class='notice'>You hear a sudden snapping sound!",\
						//Hallucination messages
						"<span class='danger'>A terrifying crocodile snaps at [H]!</span>",\
						"<span class='danger'>A [(IED && IED.active) ? "horrifying fiery dragon" : "crocodile"] attempts to bite your leg off!</span>")

				if(H.m_intent == "run") //This is where the real fun begins
					trap(H)

			else if (istype(AM,/mob/living/simple_animal/hostile/bear))
				trap(AM)

			else if(isanimal(AM))
				armed = 0
				anchored = FALSE
				var/mob/living/simple_animal/SA = AM
				SA.visible_message("<span class='danger'>\The [SA] steps on \the [src].</span>",\
						"<span class='danger'>You step on \the [src]![(IED && IED.active) ? " The explosive device attached to it activates." : ""]</span>",\
						"<span class='notice'>You hear a sudden snapping sound!",\
						//Hallucination messages
						"<span class='danger'>A terrifying crocodile snaps at [AM]!</span>",\
						"<span class='danger'>A [(IED && IED.active) ? "horrifying fiery dragon" : "crocodile"] attempts to bite your leg off!</span>")
				SA.adjustBruteLoss(20)

	update_icon()
	..()


/obj/item/weapon/beartrap/proc/trap(var/mob/living/L)
	if (ishuman(L))
		var/mob/living/carbon/human/H = L
		trappedorgan = H.pick_usable_organ(LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
		if(!trappedorgan)//no leg to snap to
			return
		trapped = 1
		trappeduser = H
		armed = 0

		playsound(src, 'sound/effects/snap.ogg', 60, 1)
		H.audible_scream()
		lock_atom(H, /datum/locking_category/beartrap)
		H.register_event(/event/moved, src, nameof(src::forcefully_remove()))

		if(trappedorgan.take_damage(15, 0, 25, SERRATED_BLADE & SHARP_BLADE))
			H.UpdateDamageIcon()
			H.updatehealth()

		if(!H.pick_usable_organ(trappedorgan)) //check if they lost their leg, and get them out of the trap
			to_chat(H, "<span class='warning'>With your leg missing, you slip out of the bear trap!</span>")
			trapped = 0
			trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
			trappeduser = null
			unlock_atom(H)
			anchored = FALSE

		H.update_canmove()
	else if (istype(L,/mob/living/simple_animal/hostile/bear) || istype(L,/mob/living/simple_animal/hostile/spacehog))
		trapped = 1
		trappedbear = L
		trappedbear.LostTarget()
		trappedbear.dir = SOUTH
		armed = 0
		playsound(src, 'sound/effects/snap.ogg', 60, 1)
		lock_atom(trappedbear, /datum/locking_category/beartrap)
		trappedbear.adjustBruteLoss(20)
		trappedbear.update_canmove()
		trappedbear.update_icon()

	if (IED)
		IED_det(L)

/obj/item/weapon/beartrap/proc/IED_det(var/mob/living/L)
	to_chat(L, "<span class='danger'>The bear trap latches to your legs as you hear a hissing sound!</span>")
	playsound(src, 'sound/effects/snap.ogg', 60, 1)
	trapped = 1
	IED.active = 1
	IED.overlays -= image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
	IED.icon_state = initial(icon_state) + "_active"
	IED.assembled = 3
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)
	var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[L]'>?</A> has triggered an IED-rigged [name] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
	message_admins(log_str)
	log_game(log_str)
	spawn(IED.det_time)
		IED.prime(L)
		desc = initial(desc)
		overlays.Remove(ied_overlay)
		if (trappeduser && trappedorgan?.amputated)//check if they lost their leg, and get them out of the trap
			to_chat(trappeduser, "<span class='warning'>With your leg missing, you slip out of the bear trap.</span>")
			trapped = 0
			unlock_atom(trappeduser)
			trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
			trappeduser = null
			anchored = FALSE

		if(trappedbear)
			unlock_atom(trappedbear)
			trappedbear.gib()
			trapped = 0
			trappedbear = null
			anchored = FALSE

// Called when the dude is moved from the trap on way or the other.
/obj/item/weapon/beartrap/proc/forcefully_remove(atom/movable/mover)
	if (get_turf(mover) != src.loc)
		if (ishuman(mover))
			var/mob/living/carbon/human/H = mover
			playsound(mover, 'sound/effects/snap.ogg', 60, 1)
			H.audible_scream()

			var/datum/organ/external/affecting = H.pick_usable_organ(LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
			if(affecting)
				if(affecting.take_damage(30, 0, 50, SERRATED_BLADE & SHARP_BLADE)) // This is going to hurt.
					H.UpdateDamageIcon()
					H.updatehealth()
		visible_message("<span class='warning'>The wound on [mover]'s leg worsens terribly as the trap let go of them.</span>")
		trapped = 0
		unlock_atom(trappeduser)
		trappeduser.unregister_event(/event/moved, src, nameof(src::forcefully_remove()))
		anchored = FALSE
		trappeduser.update_canmove()
		trappeduser = null
		return

/obj/item/weapon/batteringram
	name = "battering ram"
	desc = "A hydraulic compression/spreader-type mechanism which, when applied to a door, will charge before rapidly expanding and dislodging frames."
	flags = TWOHANDABLE | MUSTTWOHAND | FPRINT
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ram"
	item_state = "ram"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	siemens_coefficient = 0
	throwforce = 15
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_METAL
	origin_tech = Tc_COMBAT + "=5"
	attack_verb = list("rams", "bludgeons")
	force = 15
	throw_speed = 1
	throw_range = 3

/obj/item/weapon/batteringram/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I,/obj/item/weapon/ram_kit))
		flags &= ~MUSTTWOHAND //Retains FPRINT and TWOHANDABLE
		icon_state = "ram-upgraded"
		qdel(I)
	else
		..()

/obj/item/weapon/batteringram/proc/can_ram(mob/user)
	if(ishuman(user))
		if(wielded)
			return TRUE
		else
			to_chat(user,"<span class='warning'>\The [src] must be wielded!</span>")
			return FALSE
	else if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(HAS_MODULE_QUIRK(R,MODULE_IS_THE_LAW))
			return TRUE
		else
			to_chat(user,"<span class='warning'>You are not compatible with \the [src]!</span>")
			return FALSE
	else
		to_chat(user,"<span class='warning'>\The [src] is too bulky!</span>")
		return FALSE

// Used by do_after to play the sound and animation repeatedly while bashing stuff down
/obj/item/weapon/batteringram/proc/on_do_after(mob/user, use_user_turf, user_original_location, atom/target, target_original_location, needhand, obj/item/originally_held_item)
	. = do_after_default_checks(arglist(args))
	if(.)
		playsound(src, 'sound/effects/shieldbash.ogg', 50, 1)
		target.shake_animation(3, 3, 0.2, 15)

/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	attack_verb = list("warns", "cautions", "smashes")

/obj/item/weapon/caution/proximity_sign
	var/timing = 0
	var/armed = 0
	var/timepassed = 0
	flags = FPRINT | PROXMOVE

/obj/item/weapon/caution/proximity_sign/attack_self(mob/user as mob)
	if(ishuman(user))
		if(armed)
			armed = 0
			to_chat(user, "<span class='notice'>You disarm \the [src].</span>")
			return
		timing = !timing
		if(timing)
			processing_objects.Add(src)
		else
			armed = 0
			timepassed = 0
		to_chat(user, "<span class='notice'>You [timing ? "activate \the [src]'s timer, you have 15 seconds." : "de-activate \the [src]'s timer."]</span>")

/obj/item/weapon/caution/proximity_sign/process()
	if(!timing)
		processing_objects.Remove(src)
	timepassed++
	if(timepassed >= 15 && !armed)
		armed = 1
		timing = 0

/obj/item/weapon/caution/proximity_sign/HasProximity(atom/movable/AM as mob|obj)
	if(armed)
		if(istype(AM, /mob/living/carbon) && !istype(AM, /mob/living/carbon/brain))
			var/mob/living/carbon/C = AM
			if(C.glide_size > GLIDE_SIZE_OF_A_WALKING_HUMAN)
				src.visible_message("The [src.name] beeps, \"Running on wet floors is hazardous to your health.\"")
				message_admins("[C] triggered the explosive wet floor sign at [loc] ([x], [y], [z]): <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>, last touched by [fingerprintslast].")
				log_game("[C] triggered the explosive wet floor sign at [loc]([x], [y], [z]): <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>, last touched by [fingerprintslast].")
				explosion(src.loc,-1,2,0, whodunnit = get_mob_by_key(fingerprintslast))
				if(ishuman(C))
					dead_legs(C)
				if(src)
					qdel(src)

/obj/item/weapon/caution/proximity_sign/proc/dead_legs(mob/living/carbon/human/H as mob)
	for(var/datum/organ/external/OE in H.get_organs(LIMB_LEFT_LEG, LIMB_RIGHT_LEG))
		OE.droplimb()

/obj/item/weapon/caution/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	item_state = "cone"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = HEAD
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_HEAD
	starting_materials = list(MAT_PLASTIC = 2*CC_PER_SHEET_MISC) //Recipe calls for 2 sheets
	w_type = RECYK_PLASTIC

/obj/item/weapon/caution/attackby(obj/item/I as obj, mob/user as mob)
	if(I.is_wirecutter(user))
		to_chat(user, "<span class='info'>You cut apart the cone into plastic.</span>")
		drop_stack(/obj/item/stack/sheet/mineral/plastic, user.loc, starting_materials[MAT_PLASTIC]/CC_PER_SHEET_PLASTIC, user)
		qdel(src)
		return
	return ..()

/obj/item/weapon/SWF_uplink
	name = "station-bounced radio"
	desc = "Used for communication, it appears."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 8.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	item_state = "radio"
	throwforce = 5
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 100)
	w_type = RECYK_ELECTRONIC
	melt_temperature=MELTPOINT_SILICON
	origin_tech = Tc_MAGNETS + "=1"

/obj/item/weapon/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	attack_verb = list("bludgeons", "whacks", "disciplines")

/obj/item/weapon/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"
	item_state = "broom0"
	flags = FPRINT | TWOHANDABLE

/obj/item/weapon/staff/broom/update_wield(mob/user)
	..()
	item_state = "broom[wielded ? 1 : 0]"
	force = wielded ? 5 : 3
	attack_verb = wielded ? list("rams into", "charges at") : list("bludgeons", "whacks", "cleans", "dusts")
	if(user)
		user.update_inv_hands()
		if(iswizard(user) || isapprentice(user))
			user.flying = wielded ? 1 : 0
			if(wielded)
				to_chat(user, "<span class='notice'>You hold \the [src] between your legs.</span>")
				user.say("QUID 'ITCH")
				animate(user, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER , time = 10, loop = 1, easing = SINE_EASING)
			else
				animate(user, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER , time = 1, loop = 1)
				animate(user, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
				animate(user)
				if(user.lying)//aka. if they have just been stunned
					user.pixel_y -= 6 * PIXEL_MULTIPLIER
		else
			if(wielded)
				to_chat(user, "<span class='notice'>You hold \the [src] between your legs.</span>")

/obj/item/weapon/staff/broom/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/clothing/mask/horsehead))
		new/obj/item/weapon/staff/broom/horsebroom(get_turf(src))
		user.u_equip(O)
		qdel(O)
		qdel(src)
		return
	..()

/obj/item/weapon/staff/broom/horsebroom
	name = "broomstick horse"
	desc = "Saddle up!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "horsebroom"
	item_state = "horsebroom0"

/obj/item/weapon/staff/broom/horsebroom/update_wield(mob/user)
	..()
	item_state = "horsebroom[wielded ? 1 : 0]"



/obj/item/weapon/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'icons/obj/power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	starting_materials = list(MAT_IRON = 70)
	w_type = RECYK_METAL
	melt_temperature=MELTPOINT_STEEL
	attack_verb = list("whips", "lashes", "disciplines", "tickles")

/obj/item/weapon/wire/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/module
	icon = 'icons/obj/module.dmi'
	//icon_state = "std_module"
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/circuitboard/power_control
	icon = 'icons/obj/module.dmi'
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
	board_type = OTHER

/obj/item/weapon/circuitboard/station_map
	icon = 'icons/obj/module.dmi'
	name = "holomap module"
	icon_state = "card_mod"
	desc = "Holographic circuits for station holomaps."
	board_type = OTHER

/obj/item/weapon/module/id_auth
	name = "\improper ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."

/obj/item/weapon/syntiflesh
	name = "syntiflesh"
	desc = "Meat that appears... strange..."
	icon = 'icons/obj/food.dmi'
	icon_state = "meat"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	origin_tech = Tc_BIOTECH + "=2"

/*
/obj/item/weapon/cigarpacket
	name = "Pete's Cuban Cigars"
	desc = "The most robust cigars on the planet."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarpacket"
	item_state = "cigarpacket"
	w_class = W_CLASS_TINY
	throwforce = 2
	var/cigarcount = 6
	flags = ONBELT  */

/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

	var/obj/machinery/machine

/*
/obj/item/weapon/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
	origin_tech = Tc_MATERIALS + "=8;" + Tc_PROGRAMMING + "=8;" + Tc_MAGNETS + "=8;" + Tc_POWERSTORAGE + "=8;" + Tc_BLUESPACE + "=8;" + Tc_COMBAT + "=8;" + Tc_BIOTECH + "=8;" + Tc_SYNDICATE + "=8"
*/

/obj/item/weapon/ectoplasm
	name = "ectoplasm"
	desc = "The remnants of a being between the world of the living and the dead. Spooky."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	w_type = RECYK_BIOLOGICAL


/obj/item/weapon/ectoplasm/New(turf/loc, var/alt_color)
	..()
	if (alt_color)
		var/icon/color_icon = icon(icon,"[icon_state]_blank")
		color_icon.Blend(alt_color, ICON_ADD)
		icon = color_icon

/////////Random shit////////

/obj/item/weapon/lightning
	name = "lightning"
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	desc = "test lightning"
	flags = 0

/obj/item/weapon/lightning/New()
	icon = midicon
	icon_state = "1"

/obj/item/weapon/lightning/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	var/angle = get_angle(A, user)
//	to_chat(world, angle)
	angle = round(angle) + 45
	if(angle > 180)
		angle -= 180
	else
		angle += 180

	if(!angle)
		angle = 1
//	to_chat(world, "adjusted [angle]")
	icon_state = "[angle]"
//	to_chat(world, "[angle] [(get_dist(user, A) - 1)]")
	user.Beam(A, "lightning", 'icons/obj/zap.dmi', 50, 15)
/*Testing
    //  creates an /icon object with 360 states of rotation
proc/rotate_icon(file, state, step = 1, aa = FALSE)
	var icon/base = icon(file, state)

	var w, h, w2, h2
	if(aa)
		aa ++
		w = base.Width()
		w2 = w * aa
		h = base.Height()
		h2 = h * aa

	var icon{result = icon(base); temp}

	for(var/angle in 0 to 360 step step)
		if(angle == 0  )
			continue
		if(angle == 360)
			continue

		temp = icon(base)

		if(aa)
			temp.Scale(w2, h2)
		temp.Turn(angle)
		if(aa)
			temp.Scale(w,   h)

		result.Insert(temp, "[angle]")

	return result*/
