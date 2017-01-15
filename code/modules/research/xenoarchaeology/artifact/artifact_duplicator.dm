/obj/machinery/duplicator
	name = "alien machine"
	desc = "It's some kind of large computer. There appear to be disks of some kind anchored to the sides."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "duplicator_idle"
	density = 1
	var/obj/structure/duplicator_pod/leftpod
	var/obj/structure/duplicator_pod/rightpod
	var/deployed = FALSE
	var/duplicating = FALSE
	var/dupe_time = 10 SECONDS

	idle_power_usage = 100
	active_power_usage = 1000
	use_power = 1

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/duplicator/New()
	..()
	leftpod = new(src)
	rightpod = new(src)
	update_icon()

/obj/machinery/duplicator/update_icon()
	..()
	icon_state = initial(icon_state)
	if(stat & NOPOWER || !anchored)
		icon_state = "duplicator_off"
	else if(duplicating)
		icon_state = "duplicator_duplicating"

/obj/machinery/duplicator/power_change()
	. = ..()
	update_icon()
	if(anchored && !deployed)
		deploy_pods()
	else if(!anchored && deployed)
		retract_pods()

/obj/machinery/duplicator/proc/deploy_pods()
	desc = "It's some kind of large computer."
	visible_message("The disks detach from the sides of \the [src] and unfold into large pods.")
	leftpod.forceMove(locate(x-1,y,z))
	rightpod.forceMove(locate(x+1,y,z))
	flick("duplicator_pad_deploying", leftpod)
	flick("duplicator_pad_deploying", rightpod)
//	leftpod.icon_state = "duplicator_pad_deploying"
//	rightpod.icon_state = "duplicator_pad_deploying"
	deployed = TRUE

/obj/machinery/duplicator/proc/retract_pods()
	desc = initial(desc)
	visible_message("The pods retract into their bases and reattach to the sides of \the [src].")
	leftpod.forceMove(src)
	rightpod.forceMove(src)
	deployed = FALSE

/obj/machinery/duplicator/attack_hand(mob/user as mob)
	if(..() || !anchored)
		return 1
	interact(user)

/obj/machinery/duplicator/interact(mob/user)
	if(!leftpod || !rightpod)
		visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Both pods not present.</span>\"")
		flick("duplicator_denied", src)
		return
	if(!leftpod.get_object() || !rightpod.get_object())
		if(leftpod.get_object())
			if(!leftpod.has_multiple_objects())
				var/atom/movable/A = leftpod.get_object()
				if(!A.anchored && istype(A))
					begin_duplication(leftpod, rightpod, A)
				else
					visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Object anchored, pod cannot close.</span>\"")
					flick("duplicator_denied", src)
			else
				visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Too many objects present in pod.</span>\"")
				flick("duplicator_denied", src)
		else if(rightpod.get_object())
			if(!rightpod.has_multiple_objects())
				var/atom/movable/A = rightpod.get_object()
				if(!A.anchored && istype(A))
					begin_duplication(rightpod, leftpod, A)
				else
					visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Object anchored, pod cannot close.</span>\"")
					flick("duplicator_denied", src)
			else
				visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Too many objects present in pod.</span>\"")
				flick("duplicator_denied", src)
		else
			visible_message("\The [src] buzzes \"<span class='warning'>ERROR: No object present in pod.</span>\"")
	else
		visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Both pods obstructed.</span>\"")
		flick("duplicator_denied", src)

/obj/machinery/duplicator/proc/begin_duplication(obj/structure/duplicator_pod/sourcepod, obj/structure/duplicator_pod/destpod, atom/movable/A)
	if(!sourcepod || !destpod || !istype(A))
		visible_message("\The [src] buzzes \"<span class='warning'>ERROR: Unspecified error. Please contact maintenance.</span>\"")
		return
	duplicating = TRUE
	update_icon()
	A.forceMove(sourcepod)
	sourcepod.icon_state = "borgcharger1(old)"
	sourcepod.density = 1
	destpod.icon_state = "borgcharger1(old)"
	destpod.density = 1
	A.duplicate(destpod)
	spawn(dupe_time)
		var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
		smoke.set_up(3, 0, get_turf(destpod))
		smoke.start()
		sourcepod.icon_state = initial(sourcepod.icon_state)
		sourcepod.density = 0
		destpod.icon_state = initial(destpod.icon_state)
		destpod.density = 0
		A.forceMove(get_turf(sourcepod))
		for(var/atom/movable/I in destpod.contents)
			I.forceMove(get_turf(destpod))
		duplicating = FALSE
		update_icon()

/datum/proc/duplicate(atom/destination)
	if(!destination)
		destination = get_turf(src)
	var/datum/dupe
	if(istype(src, /atom) && !istype(src, /obj/screen))
		dupe = new type(destination)
	else
		dupe = new type()

	if(istype(dupe, /datum) && dupe.vars)
		for(var/x in vars)
			if(!exclude.Find(x)) // Important!
				if(istype(vars[x], /datum) || istype(vars[x], /event) || istype(vars[x], /client) || vars[x] == "ckey")
					continue
				//to_chat(world, "NOW COPYING FROM [src] VAR [x]")
				if(x == "contents")
					var/atom/A = src
					for(var/datum/D in A.contents)
						D.duplicate(dupe)
					continue
				if(istype(vars[x], /list))
					var/list/OL = vars[x]
					var/list/DL = dupe.vars[x]
					if(!DL || !OL)
						if(!DL)
							DL = list()
						if(!OL)
							OL = list()
					if(OL && DL)
						for(var/y in OL)
							if(istext(y) || isnum(y))
								if(!isnum(y) && OL[y])
									DL[y] = OL[y]
								else
									for(var/i = 1, i <= OL.len, i++)
										if(OL[i] == y)
											DL.Add(y)
											break
							else
								break
				else
					dupe.vars[x] = vars[x]
	return dupe

/obj/structure/duplicator_pod
	name = "alien pod"
	desc = "It appears to be a containment pod of some kind."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "borgcharger0(old)"
	density = 0
	anchored = 1

/obj/structure/duplicator_pod/proc/get_object()
	var/turf/T = get_turf(src)
	var/O = null
	for(var/I in T.contents)
		if(I != src && !istype(I, /atom/movable/lighting_overlay) && !istype(I, /mob/virtualhearer) && !istype(I, /obj/effect))
			O = I
	return O

/obj/structure/duplicator_pod/proc/has_multiple_objects()
	var/turf/T = get_turf(src)
	var/count = 0
	for(var/I in T.contents)
		if(I != src && !istype(I, /atom/movable/lighting_overlay) && !istype(I, /mob/virtualhearer) && !istype(I, /obj/effect))
			count++
	if(count)
		return count - 1