/obj/effect/mine
	name = "Mine"
	desc = "I better stay away from that thing."
	density = 0
	anchored = 1
	w_type=NOT_RECYCLABLE
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/mine/New()
	..()
	icon_state = "uglyminearmed"

/obj/effect/mine/Crossed(mob/living/carbon/AM)
	if(istype(AM))
		visible_message("<span class='warning'>[AM] triggered \the [bicon(src)] [src]</span>")
		trigger(AM)

/obj/effect/mine/proc/trigger(mob/living/carbon/AM)
	explosion(loc, 0, 1, 2, 3)
	qdel(src)

/obj/effect/mine/dnascramble
	name = "Radiation Mine"

/obj/effect/mine/dnascramble/trigger(mob/living/carbon/AM)
	spark(src)
	AM.apply_radiation(50, RAD_INTERNAL)
	randmutb(AM)
	domutcheck(AM,null)
	qdel(src)

/obj/effect/mine/plasma
	name = "Plasma Mine"

/obj/effect/mine/plasma/trigger(AM)
	for(var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)
			target.zone.air.adjust_gas(GAS_PLASMA, 30)
			target.hotspot_expose(1000, CELL_VOLUME)
	qdel(src)

/obj/effect/mine/kick
	name = "Kick Mine"

/obj/effect/mine/kick/trigger(mob/AM)
	spark(src)
	del(AM.client)
	qdel(src)

/obj/effect/mine/stun
	name = "Stun Mine"

/obj/effect/mine/stun/trigger(mob/AM)
	if(ismob(AM))
		AM.Knockdown(10)
		AM.Stun(10)
	spark(src)
	qdel(src)
