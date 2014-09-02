// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "\improper mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id_tag = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1
	ghost_read=0
	ghost_write=0

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "\improper portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1

/*
/obj/machinery/flasher/New()
	sleep(4)					//<--- What the fuck are you doing? D=
	src.sd_SetLuminosity(2)
*/
/obj/machinery/flasher/power_change()
	if ( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"
//		src.sd_SetLuminosity(0)

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		add_fingerprint(user)
		src.disable = !src.disable
		playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
		if (src.disable)
			user.visible_message("<span class='warning'>[user] disconnects [src]'s flashbulb!</span>", "<span class='notice'>You disconnect [src]'s flashbulb.</span>")
		if (!src.disable)
			user.visible_message("<span class='warning'>[user] connects [src]'s flashbulb!</span>", "<span class='notice'>You connect [src]'s flashbulb!</span>")

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (src.anchored)
		return src.flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	src.last_flash = world.time
	use_power(500)

	for (var/mob/O in viewers(src, null))
		if(isobserver(O)) continue
		if (get_dist(src, O) > src.range)
			continue

		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			if(!H.eyecheck() <= 0)
				continue

		if (istype(O, /mob/living/carbon/alien))//So aliens don't get flashed (they have no external eyes)/N
			continue

		O.Weaken(strength)
		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			var/datum/organ/internal/eyes/E = H.internal_organs["eyes"]
			if ((E.damage > E.min_bruised_damage && prob(E.damage + 50)))
				flick("e_flash", O:flash)
				E.damage += rand(1, 5)
		else
			if(!O.blinded)
				flick("flash", O:flash)


/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if((M.m_intent != "walk") && (src.anchored))
			src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		add_fingerprint(user)
		src.anchored = !src.anchored
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)

		if(!src.anchored)
			user.visible_message("<span class='warning'>[user] unsecures [src]!", "<span class='notice'>[src] can now be moved.</span>")
			src.overlays.Cut()

		else if(src.anchored)
			user.visible_message("<span class='warning'>[user] secures [src]!", "<span class='notice'>[src] is now secure.</span>")
			src.overlays += "[base_state]-s"

/obj/machinery/flasher_button/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/flasher_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/flasher_button/attackby(obj/item/weapon/W, mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in world)
		if(M.id_tag == src.id_tag)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return