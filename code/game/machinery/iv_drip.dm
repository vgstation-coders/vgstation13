/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	anchored = 0
	density = 0 //Tired of these blocking up the station


/obj/machinery/iv_drip/var/mob/living/carbon/human/attached = null
/obj/machinery/iv_drip/var/mode = 1 // 1 is injecting, 0 is taking blood.
/obj/machinery/iv_drip/var/obj/item/weapon/reagent_containers/beaker = null

/obj/machinery/iv_drip/update_icon()
	if(src.attached)
		icon_state = "hooked"
	else
		icon_state = ""

	overlays = null

	if(beaker)
		var/datum/reagents/reagents = beaker.reagents
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

/obj/machinery/iv_drip/MouseDrop(over_object, src_location, over_location)
	..()
	if(isobserver(usr)) return
	if(usr.stat) // Stop interacting with shit while dead pls
		return
	if(isanimal(usr))
		return
	if(attached)
		visible_message("<span class='notice'>[src.attached] is detached from [src]</span>")
		src.attached = null
		src.update_icon()
		return

	if(in_range(src, usr) && ishuman(over_object) && get_dist(over_object, src) <= 1)
		usr.visible_message("<span class='warning'>[usr] attaches [src] to [over_object]!</span>", "<span class='notice'>You attach [src] to [over_object].</span>")
		src.attached = over_object
		src.update_icon()


/obj/machinery/iv_drip/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isobserver(user)) return
	if(user.stat)
		return
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] starts dismantling [src]!</span>", "<span class='notice'>You start dismantling [src].</span>")
		if(do_after(user,50))
			new /obj/item/stack/sheet/metal(src.loc,2)
			if(src.beaker)
				src.beaker.loc = get_turf(src)
				src.beaker = null
			user.visible_message("<span class='warning'>[user] dismantles [src]!</span>", "<span class='notice'>You dismantle [src].</span>")
			del(src)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(src.beaker))
			user << "<span class='warning'>There is a reagent container loaded already!</span>"
			return

		user.drop_item()
		W.loc = src
		src.beaker = W
		user.visible_message("<span class='warning'>[user] attaches [W] to [src]!</span>", "<span class='notice'>You attach [W] to [src].</span>")
		src.update_icon()
		return
	else
		return ..()


/obj/machinery/iv_drip/process()
	//set background = 1

	if(src.attached)
		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			visible_message("<span class='warning'>The needle is ripped out of [src.attached], doesn't that hurt?</span>")
			src.attached:apply_damage(3, BRUTE, pick("r_arm", "l_arm"))
			src.attached = null
			src.update_icon()
			return

	if(src.attached && src.beaker)
		// Give blood
		if(mode)
			if(src.beaker.volume > 0)
				var/transfer_amount = REAGENTS_METABOLISM
				if(istype(src.beaker, /obj/item/weapon/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 4
				src.beaker.reagents.trans_to(src.attached, transfer_amount)
				update_icon()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)
			// If the beaker is full, ping
			if(amount == 0)
				if(prob(5)) visible_message("<span class='notice'>[src] pings.</span>")
				return

			var/mob/living/carbon/human/T = attached

			if(!istype(T)) return
			if(!T.dna)
				return
			if(M_NOCLONE in T.mutations)
				return

			// If the human is losing too much blood, beep.
			if(T.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_SAFE) if(prob(5))
				visible_message("<span class='warning'>[src] beeps loudly.</span>")

			var/datum/reagent/B = T.take_blood(beaker,amount)

			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

/obj/machinery/iv_drip/attack_hand(mob/user as mob)
	if(isobserver(usr)) return
	if(user.stat) return
	if(src.beaker)
		src.beaker.loc = get_turf(src)
		src.beaker = null
		update_icon()
	else
		return ..()


/obj/machinery/iv_drip/verb/toggle_mode()
	set name = "Toggle Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that.</span>"
		return

	if(usr.stat)
		return

	mode = !mode
	usr << "<span class='notice'>[src] is now [mode ? "injecting" : "taking blood"].</span>"

/obj/machinery/iv_drip/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return

	usr << "The [src] is [mode ? "injecting" : "taking blood"]."

	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			usr << "\blue Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid."
		else
			usr << "\blue Attached is an empty [beaker]."
	else
		usr << "\blue No chemicals are attached."

	usr << "\blue [attached ? attached : "No one"] is attached."