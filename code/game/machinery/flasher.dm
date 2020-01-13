// It is a gizmo that flashes a small area
var/list/obj/machinery/flasher/flashers = list()

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id_tag = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How knocked down targets are when flashed.
	var/base_state = "mflash"
	anchored = 1
	ghost_read=0
	ghost_write=0
	min_harm_label = 15 //Seems low, but this is going by the sprite. May need to be changed for balance.
	harm_label_examine = list("<span class='info'>A label is on the bulb, but doesn't cover it.</span>", "<span class='warning'>A label covers the bulb!</span>")

	flags = FPRINT | PROXMOVE

/obj/machinery/flasher/New()
	..()
	flashers += src

/obj/machinery/flasher/Destroy()
	..()
	flashers -= src

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1
	min_harm_label = 35 //A lot. Has to wrap around the bulb, after all.

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
	if (iswirecutter(W))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("<span class='warning'>[user] has disconnected the [src]'s flashbulb!</span>", "<span class='warning'>You disconnect the [src]'s flashbulb!</span>")
		if (!src.disable)
			user.visible_message("<span class='warning'>[user] has connected the [src]'s flashbulb!</span>", "<span class='warning'>You connect the [src]'s flashbulb!</span>")

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

	playsound(src, 'sound/weapons/flash.ogg', 100, 1)
	src.last_flash = world.time
	use_power(1000)
	if(harm_labeled >= min_harm_label)
		return //Still "flashes," so power is used and the noise is made, etc., but it doesn't actually flash anyone.
	flick("[base_state]_flash", src)

	for (var/mob/O in viewers(src, null))
		if(isobserver(O))
			continue
		if (get_dist(src, O) > src.range)
			continue
		if(O.blinded)
			continue
		if(istype(O, /mob/living/carbon/alien))//So aliens don't get flashed (they have no external eyes)/N
			continue
		if(isrobot(O)) //SOMEDAY WE WILL GIVE MOBS A FLASH_ACT OR EVEN FIX THE DAMN EYE/EAR CHECK MADNESS, BUT THAT DAY IS NOT TODAY
			var/mob/living/silicon/robot/R = O
			if(HAS_MODULE_QUIRK(R, MODULE_IS_FLASHPROOF))
				continue
			if(HAS_MODULE_QUIRK(R, MODULE_HAS_FLASH_RES))
				strength = strength/2
		if(istype(O, /mob/living))
			var/mob/living/L = O
			L.flash_eyes(affect_silicon = 1)
		if(istype(O, /mob/living/carbon))
			var/mob/living/carbon/C = O
			if(C.eyecheck() <= 0) // Identical to handheld flash safety check
				C.Knockdown(strength)
				C.Stun(strength)
		else
			O.Knockdown(strength)
			O.Stun(strength)


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
		if ((M.m_intent != "walk") && (src.anchored))
			src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (W.is_wrench(user))
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			user.show_message(text("<span class='warning'>[src] can now be moved.</span>"))
			src.overlays.len = 0

		else if (src.anchored)
			user.show_message(text("<span class='warning'>[src] is now secured.</span>"))
			src.overlays += image(icon = icon, icon_state = "[base_state]-s")

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

	for(var/obj/machinery/flasher/M in flashers)
		if(M.id_tag == src.id_tag)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
