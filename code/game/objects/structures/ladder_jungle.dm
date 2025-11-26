//subtype used in junglestation for tunnels. do NOT spawn it normally.

/obj/structure/ladder/jungle_tunnel


/obj/structure/ladder/jungle_tunnel/ex_act()
	return
/obj/structure/ladder/jungle_tunnel/singularity_act()
	return 0


/obj/structure/ladder/jungle_tunnel/MouseDropTo(var/atom/movable/over_object,var/mob/user,var/src_location,var/over_location,var/src_control,var/over_control,var/params)
	if(!over_object)
		return
	if(!up && !down)
		return
	if(!(user.Adjacent(over_object) && src.Adjacent(user) ))
		return
	if(!(istype(user,/mob/living/carbon) || istype(user,/mob/living/silicon/robot) ))
		return
	var/obj/structure/ladder/jungle_tunnel/destination = up || down
	var/timetodragin = 0
	if(istype(over_object,/mob))
		timetodragin = 4 SECONDS
	if(istype(over_object,/obj))
		timetodragin = 0.5 SECONDS
		var/obj/O = over_object
		if(O.anchored)
			to_chat(user, "<span class='warning'>You're unable to move \The [O]!</span>")
			return
		if(O.density)
			timetodragin = 3 SECONDS	
	if(!timetodragin)
		return
	user.visible_message("<span class='notice'>[user] begins moving \the [over_object] [up ? "out of" :"into"] the hole.</span>")
	if(do_after(user,over_object,timetodragin))
		user.visible_message("<span class='notice'>[user] moves \the [over_object] [up ? "out of" :"into"] the hole.</span>")
		over_object.loc = destination.loc

	
/obj/structure/ladder/jungle_tunnel/Destroy()
	..()
	if(up)
		qdel(up)
	if(down)
		qdel(down)
	var/turf/T = loc
	if(T.type==/turf/unsimulated/floor/jungle/bedrock)
		var/turf/unsimulated/floor/jungle/bedrock/TT=T
		TT.hashole=null
		TT.update_icon()
	if(T.type==/turf/unsimulated/floor/jungle/dirt)
		var/turf/unsimulated/floor/jungle/dirt/TT=T
		TT.hashole=null
	

/obj/structure/ladder/jungle_tunnel/mapped

/obj/structure/ladder/jungle_tunnel/mapped/New(var/loc)
	..()
	if(istype(loc,/turf/unsimulated/floor/jungle/dirt))
		var/turf/unsimulated/floor/jungle/dirt/TT=loc
		TT.hashole=src
		var/turf/T=locate(x,y,z==1 ? 2 : 6)
		var/obj/structure/ladder/jungle_tunnel/mapped/MJT = (locate(/obj/structure/ladder/jungle_tunnel/mapped) in T.contents)
		if(MJT)
			MJT.up=src
			down=MJT
			
	if(istype(loc,/turf/unsimulated/floor/jungle/bedrock))
		var/turf/unsimulated/floor/jungle/bedrock/TT=loc
		TT.hashole=src
		var/turf/T=locate(x,y,z==2 ? 1 : 4)
		var/obj/structure/ladder/jungle_tunnel/mapped/MJT = (locate(/obj/structure/ladder/jungle_tunnel/mapped) in T.contents)
		if(MJT)
			MJT.down=src
			up=MJT