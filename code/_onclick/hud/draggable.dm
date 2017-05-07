/obj/abstract/screen/draggable
	icon = 'icons/mob/screen_draggable.dmi'
	icon_state = "blank"
	var/mob/attachedmob
	var/obj/attachedobject
	mouse_opacity = 2
	screen_loc = ui_entire_screen
	var/centerdist_x
	var/centerdist_y

//Necessary because we have no way to detect if someone does a single click
//So we put a temporary screen object to catch clicks until someone tries dragging
//If they drag we remove the screen object, if they don't it catches the click and removes the draggable
////////////////////////////////////////////
	var/obj/abstract/screen/fuckbyond

/obj/abstract/screen/fuckbyond
	icon = 'icons/mob/screen_draggable.dmi'
	icon_state = "blank"
	mouse_opacity = 0
	screen_loc = ui_entire_screen
	var/obj/abstract/screen/draggable

/obj/abstract/screen/fuckbyond/New(master)
	..()
	draggable = master
	name = draggable.name

/obj/abstract/screen/fuckbyond/Destroy()
	..()
	draggable = null

/obj/abstract/screen/fuckbyond/MouseUp()
	returnToPool(draggable)
///////////////////////////////////////////////


/obj/abstract/screen/draggable/New(loc, mob/user)
	..()
//But no seriously, fuck byond
	fuckbyond = getFromPool(/obj/abstract/screen/fuckbyond, src)

//References to the object/user
	attachedobject = loc
	attachedmob = user
	attachedmob.client.screen += src
	attachedmob.client.screen += fuckbyond

//Copy over the icon state to the draggable screen objects.dmi for this to function
	name = "[capitalize(attachedobject.name)] Construction"
	mouse_over_pointer = "[attachedobject.icon_state]"
	mouse_drag_pointer = "[attachedobject.icon_state]"

/obj/abstract/screen/draggable/Destroy()
	..()
	if(attachedobject)
		attachedobject.end_drag_use(attachedmob)
		attachedobject = null
	if(attachedmob && attachedmob.client)
		attachedmob.client.screen -= src
		attachedmob.client.screen -= fuckbyond
	attachedmob = null
	if(fuckbyond)
		returnToPool(fuckbyond)
		fuckbyond = null

/obj/abstract/screen/draggable/MouseDown(turf/location,control,params)
	mouse_opacity = 0 //Because dragging wont occur when you are inside of your own src, we hide the src to mouses
	fuckbyond.mouse_opacity = 2 //It is now this little bastards responsibility to tell us if someone finishes a single click

	var/list/modifiers = params2list(params)
	var/turf/origin = screen_loc2turf(modifiers["screen-loc"], get_turf(attachedmob), attachedmob)

	if(istype(origin)) //Find start click location so we have initial centerdist coordinates
		centerdist_x = origin.x - attachedmob.x
		centerdist_y = origin.y - attachedmob.y

	attachedobject.drag_mousedown(attachedmob, origin)

	while(attachedmob && attachedmob.client)
		if(isnum(centerdist_x)) //prevent automatically laying down rods below us if we have no centerdist
			var/turf/T = locate(attachedmob.x + centerdist_x, attachedmob.y + centerdist_y, attachedmob.z)
			if(T && attachedobject.can_drag_use(attachedmob, T))
				if(attachedobject.drag_use(attachedmob, T)) //cancel our continuous use
					returnToPool(src)
					break
		sleep(world.tick_lag)

/obj/abstract/screen/draggable/MouseDrag(over_object,src_location,turf/over_location,src_control,over_control,params)
	if(istype(over_location) && attachedmob) //null when over black space
		centerdist_x = over_location.x - attachedmob.x //maintains distance from usr in case usr moves
		centerdist_y = over_location.y - attachedmob.y
	if(fuckbyond) //This isn't a single click, therefore we can remove the FUCK BYOND object
		returnToPool(fuckbyond)
		fuckbyond = null

/obj/abstract/screen/draggable/MouseDrop(over_object,src_location,over_location,src_control,over_control,params)
	if(attachedobject)
		attachedobject.drag_success(attachedmob, over_location)
	returnToPool(src) //releasing the drag ends the usage

/obj/proc/drag_mousedown()

/obj/proc/can_drag_use()

/obj/proc/drag_use()

/obj/proc/start_drag_use()

/obj/proc/end_drag_use()

/obj/proc/drag_success()