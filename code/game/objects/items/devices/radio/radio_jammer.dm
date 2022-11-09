var/global/list/obj/item/device/radio_jammer/radio_jammer_list = list()

#define JAMMING_SILENCE_SEVERITY 100

/obj/item/device/radio_jammer
	name = "radio jammer"
	desc = "A device used to jam radio communications. Requires a power cell to function."
	icon_state = "radio_jammer0"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 100)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=4;" + Tc_MATERIALS + "=4;" + Tc_PROGRAMMING + "=3;" + Tc_SYNDICATE + "=3;" + Tc_BLUESPACE + "=3"
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/on = 0
	var/cover_open = 0
	var/base_state = "radio_jammer"
	var/obj/item/weapon/cell/power_src = null
	var/power_usage = 500 // approx 1 minute of leisure action on default cells

/obj/item/device/radio_jammer/Destroy()
	if (on)
		processing_objects.Remove(src)
		radio_jammer_list -= src
	..()

/obj/item/device/radio_jammer/attack_self(mob/user)
	if (power_src == null || power_src.charge == 0)
		to_chat(user, "<span class='warning'>[src] is unresponsive. Perhaps there's something wrong with its power supply...</span>")
		return
	if (power_src.charge > 0 && power_src.charge < power_usage)
		// suck up the rest of remaining power
		power_src.use(power_usage)
		to_chat(user, "<span class='warning'>[src] flickers a bit, but then dies. Perhaps there's something wrong with its power supply...</span>")
		return

	on = !on
	icon_state = "[base_state][on]"

	if (on)
		to_chat(user, "<span class='notice'>You turn on [src].</span>")
		playsound(src, 'sound/items/radio_jammer.wav', 100, 1)
		processing_objects.Add(src)
		radio_jammer_list += src
	else
		// should be removed from processing objects on next Process()
		to_chat(user, "<span class='warning'>You turn off [src].</span>")

/obj/item/device/radio_jammer/attack_hand(mob/user)
	if (cover_open && power_src && user.is_holding_item(src))
		user.put_in_hands(power_src)
		power_src.add_fingerprint(user)
		power_src.updateicon()

		// Don't rip out cells while the device is working
		// Or at least if its still charged
		if (on)
			if (electrocute_mob(user, power_src, src))
				user.visible_message("<span class='warning'>[user] gets shocked as [src] is still working!</span>", "<span class='warning'>You get shocked as [src] is still working!</span>")
				spark(src)

		src.power_src = null
		user.visible_message("<span class='notice'>[user] removes the cell from [src].</span>", "<span class='notice'>You remove the cell from [src].</span>")
		return
	..()

/obj/item/device/radio_jammer/attackby(obj/item/W as obj, mob/user as mob)
	if (W.is_screwdriver(user))
		cover_open = !cover_open
		if (cover_open)
			to_chat(user, "<span class='notice'>You open up the power cell cover.</span>")
		else
			to_chat(user, "<span class='notice'>You close the power cell cover.</span>")
		src.add_fingerprint(user)
		return

	if (istype(W, /obj/item/weapon/cell))
		if (cover_open)
			if (power_src)
				to_chat(user, "<span class='warning'>There is already a cell inside, remove it first.</span>")
				return
			if (user.drop_item(W, src))
				power_src = W
				user.visible_message("<span class='notice'>[user] inserts a cell into [src].</span>", "<span class='notice'>You insert a cell into [src].</span>")
				src.add_fingerprint(user)
				return
		else
			to_chat(user, "<span class='warning'>You have to open the cover first, it's closed!</span>")
			return
	..()

/obj/item/device/radio_jammer/process()
	if (power_src == null || !power_src.use(power_usage))
		on = 0
		icon_state = "[base_state][on]"
		visible_message("<span class='warning'>[src] suddenly shuts down!</span>")

	if (!on)
		processing_objects.Remove(src)
		radio_jammer_list -= src
		return null

/obj/item/device/radio_jammer/examine(mob/user)
	..()
	to_chat(user, "The cover is [cover_open ? "open" : "closed"].")
	to_chat(user, "<span class='warning'>It's turned [on ? "on!" : "off."]</span>")
	// Can only see cell charge % if its turned on
	// or if the cover is open
	if (cover_open)
		to_chat(user, "There is [power_src ? "a" : "no"] power cell inside.")
		if (power_src)
			to_chat(user, "You can see that it's current charge is [round(power_src.percent())]%")
	else
		if (on)
			to_chat(user, "Current charge: [round(power_src.percent())]%")

// Returns distance to the closest radio jammer
/proc/get_min_radio_jammer_dist(position)
	var/mindist = MAX_VALUE

	for (var/obj/item/device/radio_jammer/J in radio_jammer_list)
		var/dist = get_dist(position, J)
		if (dist < mindist)
			mindist = dist
	return mindist

// Returns the severity of jamming applied to parameter obj
// 100 or more severity = silence.
/proc/radio_jamming_severity(who)
	// could multiply the effect of several jammers tbh but this is faster
	var/mindist = get_min_radio_jammer_dist(who)

	if (mindist <= 1)
		// ;HELP IN DORMS
		return JAMMING_SILENCE_SEVERITY
	if (mindist == 2)
		return 99
	if (mindist == 3)
		return 80
	if (mindist == 4)
		return 66
	if (mindist == 5)
		return 40
	if (mindist == 6)
		return 25
	if (mindist == 7)
		return 12

	return 0

// Returns true if severity is bad enough to completely silence the radio device
/proc/is_completely_jammed(severity)
	return severity >= JAMMING_SILENCE_SEVERITY;

// Both could be tuples tbh
/datum/jammed_radio_src
	var/obj/item/device/radio/radio
	var/severity

/datum/jammed_radio_src/New(var/r, var/s)
	radio = r
	severity = s

/datum/jammed_mob_dst
	var/atom/movable/attached
	var/severity

/datum/jammed_mob_dst/New(var/a, var/s)
	attached = a
	severity = s

// Returns a list of mobs that heard the msg through jammed radio devices and their disruption severity
// Each mob will hear the least disrupted msg.
// @radios - list of radio devices and corresponding jamming severity
/proc/get_mobs_in_jammed_radio_ranges(list/datum/jammed_radio_src/radios)
	var/list/datum/jammed_mob_dst/mobs = new/list()

	for (var/datum/jammed_radio_src/S in radios)
		if (S.radio)
			var/turf/turf = get_turf(S.radio)

			if (turf)
				for (var/mob/virtualhearer/VH in hearers(S.radio.canhear_range, turf))
					// Update minimal jamming severity for hearers.
					if (mobs[VH] == null)
						mobs[VH] = new /datum/jammed_mob_dst(VH.attached, S.severity)
					else
						if (S.severity < mobs[VH].severity)
							mobs[VH].severity = S.severity
	return mobs
