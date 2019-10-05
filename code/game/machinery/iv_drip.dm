#define IVDRIP_INJECTING 1
#define IVDRIP_DRAWING 0

/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "unhooked_inject"
	anchored = 0
	density = 0 //Tired of these blocking up the station
	var/mode = IVDRIP_INJECTING
	var/obj/item/weapon/reagent_containers/beaker = null
	var/mob/living/carbon/human/attached = null

/obj/machinery/iv_drip/update_icon()
	if(src.attached)
		icon_state = "hooked[mode ? "_inject" : "_draw"]"
	else
		icon_state = "unhooked[mode ? "_inject" : "_draw"]"

	overlays = null

	if(beaker)
		var/datum/reagents/reagents = beaker.reagents
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, REAGENT)

			var/percent = round((reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)
					filling.icon_state = "reagent0"
				if(10 to 24)
					filling.icon_state = "reagent10"
				if(25 to 49)
					filling.icon_state = "reagent25"
				if(50 to 74)
					filling.icon_state = "reagent50"
				if(75 to 79)
					filling.icon_state = "reagent75"
				if(80 to 90)
					filling.icon_state = "reagent80"
				if(91 to INFINITY)
					filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

/obj/machinery/iv_drip/MouseDropFrom(over_object, src_location, over_location)
	if(isobserver(usr))
		return ..()
	if(usr.incapacitated()) // Stop interacting with shit while dead pls
		return ..()
	if(isanimal(usr))
		return ..()
	if(!usr.Adjacent(src))
		return ..()

	if(attached)
		visible_message("[src.attached] is detached from \the [src].")
		detach()
		return

	if(ishuman(over_object) && get_dist(over_object, src) <= 1)
		var/mob/living/carbon/human/H = over_object
		if(H.species && (H.species.chem_flags & NO_INJECT))
			H.visible_message("<span class='warning'>[usr] struggles to place the IV into [H] but fails.</span>","<span class='notice'>[usr] tries to place the IV into your arm but is unable to.</span>")
			return
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		src.attached = over_object
		src.update_icon()

/obj/machinery/iv_drip/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isobserver(user))
		return
	if(user.stat)
		return
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal,get_turf(src))
		M.amount = 2
		if(src.beaker)
			src.remove_container()
		to_chat(user, "<span class='notice'>You dismantle \the [name].</span>")
		qdel(src)
	if (istype(W, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/R = W
		if(R.fits_in_iv_drip())
			if(!isnull(src.beaker))
				to_chat(user, "There is already a reagent container loaded!")
				return

			if(user.drop_item(R, src))
				src.beaker = R
				to_chat(user, "You attach \the [R] to \the [src].")
				investigation_log(I_CHEMS, "was loaded with \a [R] by [key_name(user)], containing [R.reagents.get_reagent_ids(1)]")
				src.update_icon()
				return
		else
			to_chat(user, "<span class='warning'>\The [R] doesn't fit on \the [src].</span>")
	else
		return ..()


/obj/machinery/iv_drip/process()
	if(src.attached)
		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			src.attached:apply_damage(3, BRUTE, pick(LIMB_RIGHT_ARM, LIMB_LEFT_ARM))
			src.detach()
			return

	if(src.attached && src.beaker)
		// Give blood
		if(mode)
			if(beaker.volume > 0)
				if(beaker.reagents.reagent_list.len == 1 && beaker.reagents.has_reagent(BLOOD))
					// speed up transfer if the container has ONLY blood
					beaker.reagents.trans_to(attached, 12)
				else
					// otherwise: transfer a little bit of all reagents to the patient. the reason why we don't transfer a set amount is because 0.2u of 10 different reagents is 0.02u of each, which is entirely too little.
					for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
						beaker.reagents.trans_id_to(attached, reagent.id, reagent.custom_metabolism)
				update_icon()

				if(beaker.is_empty() && beaker.should_qdel_if_empty())
					qdel(beaker)
					detach()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 12)
			// If the beaker is full, ping
			if(amount == 0)
				if(prob(5))
					visible_message("\The [src] pings.")
				return

			var/mob/living/carbon/human/T = attached

			if(!istype(T))
				return
			if(!T.dna)
				return
			if(M_HUSK in T.mutations)
				return

			// If the human is losing too much blood, beep.
			if(T.vessel.get_reagent_amount(BLOOD) < BLOOD_VOLUME_SAFE)
				if(prob(5))
					visible_message("\The [src] beeps loudly.")

			var/datum/reagent/blood/B = T.take_blood(beaker,amount)

			if(B)
				update_icon()

/obj/machinery/iv_drip/attack_hand(mob/user)
	if(isobserver(usr) || user.incapacitated())
		return
	if(attached)
		visible_message("[src.attached] is detached from \the [src].")
		detach()
	else if(src.beaker)
		remove_container()
	else
		return ..()

/obj/machinery/iv_drip/proc/remove_container()
	src.beaker.forceMove(get_turf(src))
	src.beaker = null
	update_icon()

/obj/machinery/iv_drip/proc/detach()
	if(!src.attached)
		return
	src.attached = null
	src.update_icon()

/obj/machinery/iv_drip/attack_ai(mob/living/user)
	attack_hand(user)

/obj/machinery/iv_drip/verb/toggle_mode()
	set name = "Toggle Mode"
	set category = "Object"
	set src in view(1)

	if(usr.isUnconscious())
		return

	if(!istype(usr, /mob/living) || istype(usr, /mob/living/simple_animal))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(locked_to) //attached to rollerbed? probably?
		to_chat(usr, "<span class='warning'>You can't do that while \the [src] is fastened to something.</span>")
		return

	mode = !mode
	to_chat(usr, "<span class='info'>The [src] is now [mode ? "injecting" : "taking blood"].</span>")
	update_icon()

/obj/machinery/iv_drip/AltClick()
	if(!usr.isUnconscious() && Adjacent(usr))
		toggle_mode()
		return
	return ..()

/obj/machinery/iv_drip/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>\The [src] is [mode ? "injecting" : "taking blood"].</span>")
	to_chat(user, "<span class='info'>It is attached to [attached ? attached : "no one"].</span>")
	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			if(beaker.reagents.reagent_list.len == 1 && beaker.reagents.has_reagent(BLOOD))
				to_chat(user, "<span class='info'>Attached is \an [beaker] with [beaker.reagents.total_volume] units of blood remaining.</span>")
			else
				to_chat(user, "<span class='info'>Attached is \an [beaker] with a solution of:</span>")
				for(var/datum/reagent/R in beaker.reagents.reagent_list)
					to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
		else
			to_chat(user, "<span class='info'>Attached is \an empty [beaker].</span>")
	else
		to_chat(user, "<span class='info'>No chemicals are attached.</span>")
