/**
	Rigsuit modification station

	Person inserts the modules they want to install into the machine
	Steps inside
	Machine locks them in place
	Spend N*5 SECONDS for each module to be installed
	Close up, re initialize the suit, eject the user.

	If malfunctioning, during the close up stage,  chop their limbs off?

**/

/obj/machinery/suit_modifier
	name = "Rigsuit modification station"
	desc = "A man-sized machine, akin to a coffin, meant to install modifications into a worn rigsuit."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "suitmodifier"

	var/list/modules_to_install = list()
	var/obj/item/weapon/cell/cell = null
	idle_power_usage = 50
	active_power_usage = 300

/obj/machinery/suit_modifier/examine(mob/user)
	..()
	if(modules_to_install.len)
		to_chat(user, "<span class = 'notice'>There is:</span>")
		for(var/obj/item/rig_module/RM in modules_to_install)
			to_chat(user, "<span class = 'notice'>[RM.name]:</span>")
		to_chat(user, "<span class = 'notice'>within \the [src].</span>")


/obj/machinery/suit_modifier/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/rig_module) && user.drop_item(I, src))
		say("Module installed.", class = "binaryradio")
		modules_to_install.Add(I)
		return
	if(istype(I, /obj/item/weapon/cell) && !cell && user.drop_item(I, src))
		say("Cell installed.", class = "binaryradio")
		cell = I
		return
	.=..()

/obj/machinery/suit_modifier/attack_hand(mob/user)
	if(is_locking(/mob/living/carbon/human))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, 0)
		say("Unit Occupied.", class = "binaryradio")
		return
	if(!modules_to_install.len)
		say("No modules available.", class = "binaryradio")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.is_wearing_item(/obj/item/clothing/suit/space/rig, slot_wear_suit))
			say("Unable to detect rigsuit on person.", class = "binaryradio")
			return
		if(H.loc == loc) //Same turf
			lock_atom(H)
			process_module_installation(H)

/obj/machinery/suit_modifier/proc/process_module_installation(var/mob/living/carbon/human/H)
	var/image/overlay = image(icon, src, null)
	overlays += overlay
	flick("suitmodifier_activate", overlay)
	use_power = 2
	spawn(12) //Length of above animation
		overlay.icon_state = "suitmodifier_working"
		var/obj/item/clothing/suit/space/rig/R = H.is_wearing_item(/obj/item/clothing/suit/space/rig, slot_wear_suit)
		var/list/modules_to_activate = list()
		for(var/obj/item/rig_module/RM in modules_to_install)
			if(locate(RM.type) in R.modules) //One already installed
				continue
			if(do_after(H, src, 5 SECONDS, needhand = FALSE))
				say("Module installed.", class = "binaryradio")
				R.modules.Add(RM)
				modules_to_install.Remove(RM)
				modules_to_activate.Add(RM)
				RM.forceMove(R)
		flick("suitmodifier_close", overlay)
		for(var/obj/item/rig_module/RM in modules_to_activate)
			RM.activate(H, R)
			say("[RM] initialized", class = "binaryradio")
		if(cell && R.cell.charge < cell.charge)
			R.cell.forceMove(get_turf(src))
			cell.forceMove(R)
			R.cell = cell
			cell = null
		playsound(src, 'sound/machines/pressurehiss.ogg', 40, 1)
		new /obj/effect/effect/smoke(get_turf(src))
		unlock_atom(H)
		overlay.icon_state = null
		overlays.Cut()
		qdel(overlay)
		use_power = 1