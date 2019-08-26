/obj/item/shuttle_license
	name = "shuttle verification license"
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	desc = "Required for turning a dull room with some engines in the back into something that can move through space!"

/obj/item/shuttle_license/attack_self(mob/user)
	to_chat(user, "<span class = 'notice'>Checking current area...</span>")
	var/area/A = get_area(user)
	if(!istype(A, /area/station/custom))
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: Custom areas only.</span>")
		return

	var/datum/shuttle/conflict = A.get_shuttle()

	if(conflict)
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: This area is already marked as a shuttle.</span>")
		return

	var/area_size = A.area_turfs.len
	var/active_engines = 0
	for(var/obj/structure/shuttle/engine/propulsion/DIY/D in A)
		if(D.heater && D.anchored)
			active_engines++

	if(active_engines < 2 || area_size/active_engines > 12.5) //2 engines per 25 tiles, with a minimum of 2 engines.
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: Insufficient engine count.</span>")
		to_chat(user, "<span class = 'notice'> Active engine count: [active_engines]. Area size: [area_size] meters squared.</span>")
		return

	var/turf/check_turf = get_step(user, user.dir)

	if(get_area(check_turf) == A)
		to_chat(user, "<span class = 'warning'>This area is not a viable shuttle. Reason: Unable to create docking port at current user location.</span>")
		return

	to_chat(user, "<span class = 'notice'>Checks complete. Turning area into shuttle.</span>")

	var/name = input(user, "Please name the new shuttle", "Shuttlify", A.name) as text|null

	if(!name)
		to_chat(user, "Shuttlifying cancelled.")
		return

	var/obj/docking_port/shuttle/DP = new /obj/docking_port/shuttle(get_turf(src))
	DP.dir = user.dir


	var/datum/shuttle/custom/S = new(starting_area = A)
	S.initialize()
	S.name = name

	to_chat(user, "Shuttle created!")


	message_admins("<span class='notice'>[key_name_admin(user)] has turned [A.name] into a shuttle named [S.name]. [formatJumpTo(get_turf(user))]</span>")
	log_admin("[key_name(user)]  has turned [A.name] into a shuttle named [S.name].")
	qdel(src)