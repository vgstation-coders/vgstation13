/obj/machinery/computer/security/advanced
	name = "Advanced Security Cameras"
	desc = "Used to access the various cameras on the station with an interactive user interface."
	circuit = "/obj/item/weapon/circuitboard/security/advanced"

/obj/machinery/computer/security/advanced/New()
	..()
	html_machines += src

/obj/item/weapon/circuitboard/security/advanced
	name = "Circuit board (Advanced Security)"
	build_path = /obj/machinery/computer/security/advanced

/obj/machinery/computer/security/advanced/attack_hand(var/mob/user as mob)
	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	if(stat & (NOPOWER|BROKEN))
		return
	adv_camera.show(user, (current ? current.z : z))
	if(current && current.can_use())
		user.reset_view(current)
	user.machine = src
	return

/obj/machinery/computer/security/advanced/check_eye(var/mob/user as mob)
	if (( ( get_dist(user, src) > 1 ) || !( user.canmove ) || ( user.blinded )) && (!istype(user, /mob/living/silicon)))
		if(user.machine == src)
			user.machine = null
		return null
	if(stat & (NOPOWER|BROKEN))
		return null
	user.reset_view(current)
	return 1

var/global/datum/interactive_map/camera/adv_camera = new

/*
/client/verb/lookatdatum()
	set category = "Debug"
	debug_variables(adv_camera)
*/

/datum/interactive_map/camera
	var/list/zlevels
	var/list/camerasbyzlevel
	var/initialized = 0

/datum/interactive_map/camera/New()
	. = ..()
	zlevels = list(1,5)
	for(var/i in zlevels)
		data["[i]"] = new/list()

/obj/machinery/computer/camera/Destroy()
	..()
	html_machines -= src

/datum/interactive_map/camera/show(mob/mob, z, datum/html_interface/currui)
	z = text2num(z)
	if (!z)
		z = mob.z
	sendResources(mob.client)

	if (!(z in zlevels))
		to_chat(mob, "<span class='danger'>Unable to establish a connection: </span>Target is too far away from the station!")
		return

	if(!src.interfaces)
		to_chat(mob, "<span class='danger'>BUG: /datum/interactive_map/camera/show() had no interfaces! Please make a bug report!</span>")
		return

	var/datum/html_interface/hi
	if (!src.interfaces["[z]"])
		src.interfaces["[z]"] = new/datum/html_interface/nanotrasen(src, "Security Cameras", 900, 800, \
		"[MAPHEADER] </script><script type=\"text/javascript\">\
		var mapname = \"[map.nameShort]\"; \
		var z = [z]; \
		var tile_size = [WORLD_ICON_SIZE]; \
		var maxx = [world.maxx]; \
		var maxy = [world.maxy];</script>\
		<script type=\"text/javascript\" src=\"advcamera.js\"></script>")

		hi = src.interfaces["[z]"]

		hi.updateContent("content", \
		"<div id='switches'><a href=\"javascript:switchTo(0);\">Switch to mini map</a> \
		<a href=\"javascript:switchTo(1);\">Switch to text-based</a> \
		[get_zlevel_ui_buttons_js()] \
		<a href='byond://?src=\ref[hi]&cancel=1'>Cancel Viewing</a></div> \
		<div id=\"uiMapContainer\"><div id=\"uiMap\" unselectable=\"on\"></div></div>\
		<div id=\"textbased\"></div>")

		initializeZLevel("[z]")

	updateMovableCameras(z)

	hi = src.interfaces["[z]"]
	hi.show(mob, currui)
	src.updateFor(mob, hi, z)

/datum/interactive_map/camera/proc/initializeZLevel(z)
	return src.update(z, TRUE, camerasbyzlevel["[z]"], TRUE)

//Cameras are updated in two ways: Stationary cameras are updated only when something about them changes, like wires being cut.
//To avoid having to update all of them every time the interface is shown, their updates go to our local data even if nobody's watching the console.
//Movable cameras, like cyborgs, are updated periodically, but ONLY if someone's watching the cameras, for optimization's sake.
//This will cause outdated local data when updates happen and nobody was watching. So we gotta update them here.
/datum/interactive_map/camera/proc/updateMovableCameras(z)
	var/list/movableCameras = list()
	for(var/mob/living/silicon/robot/R in mob_list)
		if(R.camera)
			movableCameras |= R.camera
	return src.update(z, TRUE, movableCameras, TRUE)

/datum/interactive_map/camera/updateFor(hclient_or_mob, datum/html_interface/hi, z, var/list/updateData = list(), var/deleting = FALSE)
	if(updateData.len <= 0)
		hi.callJavaScript("clearAll", new/list(), hclient_or_mob)
		updateData = data["[z]"]

	for(var/i in updateData) //you can't just do "var/list/L in list" for associated lists
		var/list/L
		if(islist(i))
			L = i
		else
			L = updateData[i]

		if(!deleting)
			hi.callJavaScript("updateCamera", L, hclient_or_mob)
		else
			hi.callJavaScript("deleteCamera", L, hclient_or_mob)

//Update our local records, if necessary, send the updates to the HTMLUI clients.
//z: z-level to update (only 1 z-level at a time)
//ignore_unused: If FALSE, proc will abort unless someone is actively watching the cameras at the time.
//camerasToUpdate: List of /obj/machinery/camera/ that will be updated at this time. If no list, you fucked up.
//silent: Update local records only, don't send updates to clients that are watching.
//If updating these parameters please update queueUpdate() down below.
/datum/interactive_map/camera/update(z, ignore_unused = TRUE, var/list/camerasToUpdate = list(), var/silent = FALSE)
	//is this even necessary?
	var/zz = text2num(z)
	if(!zz)
		zz = z

	if(!src.interfaces["[zz]"])
		return //Nobody has looked at the cameras yet so there's no point updating, we'll catch any changes later when we initialize them

	var/datum/html_interface/hi = src.interfaces["[zz]"]
	var/ID
	var/status
	var/name
	var/area
	var/icon
	var/pos_x
	var/pos_y
	var/pos_z
	var/see_x
	var/see_y

	if(!ignore_unused && !(hi.isUsed()))
		return

	for(var/obj/machinery/camera/C in camerasToUpdate)
		var/deleting = FALSE
		var/turf/pos = get_turf(C)
		if(!pos)
			camerasbyzlevel["[zz]"] -= C
			deleting = TRUE
		if(pos.z != zz)
			camerasbyzlevel["[zz]"] -= C //bad zlevel
			deleting = TRUE
			if(pos.z == map.zMainStation || pos.z == map.zAsteroid)
				camerasbyzlevel["[zz]"] |= C //try to fix the zlevel list.

		if(!C.can_use() || C.network.len < 1) //I originally checked if CAMERANET_SS13 was in the camera's networks but apparently sec cameras can see into engi cameras just fine or whatever.
			deleting = TRUE

		ID = "\ref[C]"

		if(deleting == TRUE)
			if(ID in data["[zz]"])
				data["[zz]"] -= data["[zz]"][ID]
			if(hi.isUsed() && !silent)
				var/list/finishedCamera = list(ID)
				src.updateFor(null, hi, z, list(finishedCamera), TRUE)
			continue

		status = C.alarm_on //1 = alarming 0 = all is well
		name = C.c_tag
		var/area/AA = get_area(C)
		area = format_text(AA.name)
		if(CAMERANET_ROBOTS in C.network)
			icon = "icon-android"
		else
			icon = "icon-camera"
		pos_x = pos.x
		pos_y = pos.y
		pos_z = pos.z
		see_x = pos.x - WORLD_X_OFFSET[z]
		see_y = pos.y - WORLD_Y_OFFSET[z]

		//now updating
		var/list/finishedCamera = list(ID, status, name, area, icon, pos_x, pos_y, pos_z, see_x, see_y)
		data["[zz]"][ID] = finishedCamera
		if(hi.isUsed() && !silent)
			src.updateFor(null, hi, z, list(finishedCamera))

/datum/interactive_map/camera/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	. = ..()

	var/los = hclient.client.mob.html_mob_check(/obj/machinery/computer/security/advanced)
	if(!los)
		hclient.client.mob.reset_view(hclient.client.mob)

	return (. && los)

/datum/interactive_map/camera/Topic(href, href_list[], datum/html_interface_client/hclient)
	if(..())
		return // Our parent handled it the topic call
	if (istype(hclient))
		if (hclient && hclient.client && hclient.client.mob && isliving(hclient.client.mob))
			var/mob/living/L = hclient.client.mob
			usr = L
			for(var/obj/machinery/computer/security/advanced/A in html_machines)
				if(usr.machine == A)
					A.Topic(href, href_list, hclient)
					break

/datum/interactive_map/camera/queueUpdate(z, ignore_unused = TRUE, var/list/camerasToUpdate = list())
	SShtml_ui.queue(adv_camera, "update", z, ignore_unused, camerasToUpdate)

/datum/interactive_map/camera/sendResources(client/C)
	..()
	C << browse_rsc('advcamera.js')

/obj/machinery/computer/security/advanced/Topic(href, href_list)
	if(..())
		return 0

	if(href_list["cancel"])
		usr.reset_view(null)
		current = null
	if(href_list["view"])
		var/obj/machinery/camera/cam = locate(href_list["view"])
		if(cam && cam.can_use())
			if(isAI(usr))
				var/mob/living/silicon/ai/A = usr
				A.eyeobj.forceMove(get_turf(cam))
				A.client.eye = A.eyeobj
			else
				var/mob/M = usr
				use_power(50)
				current = cam
				M.change_sight(copying = cam.vision_flags)
				M.reset_view(current)
	return 1
