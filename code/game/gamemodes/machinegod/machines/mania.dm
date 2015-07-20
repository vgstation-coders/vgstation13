/obj/machinery/maniamotor
	name = "strange device"
	desc = "A large, bizarre device."
	icon = 'icons/obj/clockwork/structures.dmi'
	icon_state = "maniamotor0"
	density = 1
	active_power_usage = 5500
	machine_flags = WRENCHMOVE | FIXED2WORK | WELD_FIXED
	var/on = 0
	var/health = 45
	var/maxhealth = 45
	light_color = LIGHT_COLOR_PINK
	light_range_on = 4
	light_power_on = 2
	use_auto_lights = 1

/obj/machinery/maniamotor/process()
	if(!on) return
	if(stat & NOPOWER) return

	for(var/mob/living/L in range(src, 12))
		if(isclockcult(L)) continue //clock cultists are unaffected
		for(var/turf/T in range(1, L)) //null rod blocks the motor's effects
			if(findNullRod(T))
				if(prob(5))
					L << "<span class='info'>The power of the null rod shields your mind from evil.</span>"
				continue

		L.adjustBrainLoss((13 - get_dist(src, L)) * (iscultist(L) ? 0.75 : 0.25)) //enemy cultists take extra braindamage

		if(src in view(L)) //If you see it, get ready for brainfuck
			if(prob(6)) L << "<span class='sinister'>Your sanity rapidly deteriorates as you look at the [src].</span>"
			L.hallucination = max(L.hallucination, 10)

		if(get_dist(src, L) <= 4)
			if(L.getBrainLoss() >= 60)
				if(prob(10))
					bad_event(L)
				if(iscultist(L) && prob(6))
					bad_event(L)

		if(prob(4))
			L << "<span class='sinister'>A dark presence weighs on your mind.</span>"

/obj/machinery/maniamotor/proc/bad_event(var/mob/living/L as mob)
	if(isclockcult(L)) return

	var/event_id = pick(2;"hallucination", 1;"clumsiness", 2;"disorient", 1;"vomit")
	switch(event_id)
		if("hallucination")
			L.hallucination = max(L.hallucination, 35)
		if("clumsiness")
			if(!(M_CLUMSY in L.mutations))
				L.mutations.Add(M_CLUMSY)
		if("disorient")
			L.stuttering += 6
			L.jitteriness += 6
			L.confused += 6
		if("vomit")
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				H.vomit()

	L << "<span class='sinister'>Your sanity rapidly deteriorates.</span>"

/obj/machinery/maniamotor/update_icon()
	if((stat & NOPOWER) || (stat & BROKEN) || !on)
		icon_state = "maniamotor0"
		/*if(stat & BROKEN) //If the thing is smashed, add crack overlay on top of the unpowered sprite.
			src.overlays.len = 0
			src.overlays += image(src.icon, "busted")*/
		return
	icon_state = "maniamotor"
	return

/obj/machinery/maniamotor/examine(mob/user)
	..()
	if(!isclockcult(user))
		user << "<span class='sinister'>You hear incessant cackling.</span>"

/obj/machinery/maniamotor/attack_hand(mob/user as mob)
	if(!isclockcult(user) && !iscultist(user))
		user << "<span class='warning'>You're unsure of how to operate this device.</span>"
		return

	if(!state)
		user << "<span class='warning'>The motor needs to be bolted down first before you activate it!</span>"

	for(var/obj/machinery/maniamotor/MM in range(src, 12))
		if(MM == src) continue //it's done this way just in case some wiseass puts two motors on the same tile
		user << "<span class='sinister'>Another mania motor is already installed nearby. It's unsafe to try and activate these too close to each other!</span>"
		user << "<span class='info'>The nearest motor is [get_dist(src, MM)] meters away from your motor.</span>"
		return

	if(on)
		on = 0
		use_power = 0
	else
		on = 1
		use_power = 2

	user.visible_message("<span class='notice'>[user] turns \the [src] [on ? "on":"off"].</span>", \
	"<span class='notice'>You turn \the mania motor [on ? "on":"off"].</span>")
	update_icon()

/obj/machinery/maniamotor/wrenchAnchor(var/mob/user)
	if(..() == 1 && on)
		on = !on
		use_power = 0

/obj/machinery/maniamotor/power_change()
	..()
	if(powered(power_channel))
		on = 1
		use_power = 2
	else
		on = 0
		use_power = 0
