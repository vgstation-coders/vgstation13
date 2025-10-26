/*
In this file:
objects used when a reactor goes boomy boom so there's some nasty rads and things to clean up.

*/



//l.apply_radiation(rads, RAD_EXTERNAL)

/obj/machinery/corium
	name="corium"
	desc="An amalgam of fissile material and reactor structures, melted together after a meltdown."
	icon='icons/obj/fissionreactor/corium.dmi'
	icon_state="corium"
	density=1
	anchored=0
	var/rads=0
	
/obj/machinery/corium/New(var/turf/location, var/radiation=0)
	..()
	icon_state="corium_[rand(1,3)]"
	rads=radiation

/obj/machinery/corium/attackby(var/obj/item/I,var/mob/user)
	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		user.visible_message("<span class='notice'>[user] begins trying to salvage anything useful from \the [src].</span>", "<span class='notice'>You begin trying to salvage anything useful from \the [src].</span>")
		if(WT.do_weld(user,src,80,0))
			if(rand()<0.5)
				new /obj/item/stack/rods(src.loc,rand(1,3))
			if(rand()<0.5)
				new /obj/item/stack/sheet/plasteel(src.loc,rand(1,5))
			qdel(src)
	
	
/obj/machinery/corium/process()
	for(var/mob/living/l in range(src.loc, 10))
		var/dx=l.x-x
		var/dy=l.y-y
		var/dist=(dx*dx+dy*dy)**0.5
		l.apply_radiation(rads* (1.0-(dist/14))  , RAD_EXTERNAL) //div by 14 because 10 is a square, so multiply it by root2 to get the max distance as a circle.


		