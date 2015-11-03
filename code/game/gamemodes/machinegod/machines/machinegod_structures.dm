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

/obj/machinery/clockobelisk/New()
	. = ..()
	clockobelisks += src

/obj/machinery/clockobelisk/Destroy()
	. = ..()
	clockobelisks -= src

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
