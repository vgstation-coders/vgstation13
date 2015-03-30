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

/obj/machinery/clockobelisk
	name = "floating prism"
	desc = "A strange, floating yellow prism."
	icon = 'icons/obj/clockwork/structures.dmi'
	icon_state = "obelisk0"
	density = 1
	active_power_usage = 2500
	machine_flags = WRENCHMOVE | FIXED2WORK | WELD_FIXED
	var/on = 0
	var/health = 65
	var/maxhealth = 65
	light_color = LIGHT_COLOR_YELLOW
	light_range_on = 4
	light_power_on = 2
	use_auto_lights = 1

/obj/machinery/s_gateway
	name = "spatial gateway"
	desc = "A Spatial Gateway."
	icon = 'icons/obj/clockwork/96x96.dmi'
	icon_state = "s_gateway-charging"
	pixel_x = -32
	pixel_y = -32
	anchored = 1
	density = 0
	layer = 6
	luminosity = 6
	unacidable = 1
	use_power = 0
	light_color = "#7f6000"
	var/act_timer = 8 //8 seconds base time, counts up to 25 when act_state hits 0
	var/act_state = 0 //0=charging, 1=active
	var/act_safe = 1 //if 0, randomly teleports noncultists
	var/act_target = null
	var/gatewayusers = 0 //how many cultists are activating this thing

/obj/machinery/s_gateway/New(var/turf/t,var/gateinfo)
	..(t)
	act_target = get_turf(gateinfo)

/obj/machinery/s_gateway/proc/activate(var/doom = 0) //1 is 6+, portal becomes dangerous to enemies; 2 is 9+, portal destroys enemies
	act_state = 1
	set_light(6,2)
	icon_state = "s_gateway-active"
	visible_message("<span class='warning'>The gateway stabilizes!</span>")
	if(doom)
		color = "#AAAAAA"
		act_safe = 0 //noncults that enter get randomly teleported
	if(doom == 2)
		color = "#BBBB00"
		for(var/mob/living/L in view(src, 7))
			if(isclockcult(L))
				continue
			if(L.flags & INVULNERABLE)
				continue
			L.apply_effect((iscultist(L) ? 40 : 65), IRRADIATE)
			L.fire_stacks += (iscultist(L) ? 40 : 65)
			L.IgniteMob()
			flick("e_flash", L.flash)
			L << "<span class='danger' style='font-size:16pt'>A relentless, otherworldly energy floods every part of your body, causing you previously unimaginable amounts of pain.</span>"

/obj/machinery/s_gateway/process()
	var/nullblock = 0
	for(var/turf/TR in range(src,1))
		if(findNullRod(TR))
			nullblock = 1
			break
	if(nullblock)
		visible_message("<span class='warning'>The null rod seals the gateway!</span>")
		qdel(src)
		return

	if(act_state == 1)
		for(var/mob/living/L in range(src,1))
			teleport(L)
		act_timer = max(0, act_timer + 1)
		switch(act_timer)
			if(20 to 24)
				icon_state = "s_gateway-closing"
			if(25 to INFINITY)
				qdel(src)
		return

	gatewayusers = 0
	for(var/mob/living/L in range(src,1))
		if(isclockcult(L))// && alive/active/etc/other checks
			gatewayusers++
	switch(gatewayusers)
		if(-INFINITY to 0)
			visible_message("<span class='warning'>The gateway collapses!</span>")
			qdel(src)
		if(1)
			act_timer--
		if(2,3)
			act_timer = min(act_timer - 1, 6)
		if(4,5)
			act_timer = min(act_timer - 1, 4)
		if(6 to 8)
			act_timer = 0
			activate(1)
			return
		if(9 to INFINITY)
			act_timer = 0
			activate(2)
			return

	if(act_timer <= 0)
		activate(0)
	return

/obj/machinery/s_gateway/proc/teleport(mob/living/L as mob)
	if(!L) return

	if(L in range(src, 1))
		if(act_safe == 0 && !isclockcult(L))
			do_teleport(L, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0)	//goodbye!
			if(iscultist(L))
				L << "<span class='clockwork'>As you pass through the gateway, roaring laughter fills your head.</span>"
			return
		else
			do_teleport(L, act_target, 1)	///You will appear adjacent to the beacon
			if(!isclockcult(L))
				L << "<span class='clockwork'>You are overwhelmed by the gateway's bizarre energy!</span>"
				L.Weaken(4)
			return

/obj/machinery/s_gateway/ex_act(severity)
	return
