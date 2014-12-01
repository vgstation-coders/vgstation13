
/**********************Shuttle Computer**************************/

//copy paste from the mining shuttle

var/research_shuttle_launchdelay = 100
var/research_shuttle_transitdelay = 200
var/research_shuttle_moving = 0
var/research_loc_expected // A simple helper to keep things sane, tells the shuttle where it'll arrive and hope it will
var/research_shuttle_location = 0 // 0 = station 13, 1 = research outpost, 2 = moving (transit)

proc/move_research_shuttle()
	if(research_shuttle_moving)
		return
	research_shuttle_moving = 1

	spawn(research_shuttle_launchdelay)
		var/area/fromArea
		var/area/transitArea
		var/area/toArea
		transitArea = locate(/area/shuttle/research/transit)
		if(research_shuttle_location == 1) //Currently at the research outpost
			fromArea = locate(/area/shuttle/research/outpost)
			toArea = locate(/area/shuttle/research/station)
			research_loc_expected = 0 //It's going to the station
		else if(research_shuttle_location == 0) //Currently at the station
			fromArea = locate(/area/shuttle/research/station)
			toArea = locate(/area/shuttle/research/outpost)
			research_loc_expected = 1 //It's going to the outpost

		for(var/obj/machinery/door/unpowered/shuttle/D in fromArea) //THE FUCKING DOORS YOU IDIOT
			D.close()
			D.locked = 1

		fromArea.move_contents_to(transitArea) //Entering transit
		research_shuttle_location = 2

		for(var/mob/M in transitArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 3, 1) // buckled, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		spawn(research_shuttle_transitdelay)
			var/list/dstturfs = list()
			var/throwy = world.maxy

			for(var/turf/T in toArea)
				dstturfs += T
				if(T.y < throwy)
					throwy = T.y

			// hey you, get out of the way!
			for(var/turf/T in dstturfs)
				// find the turf to move things to
				var/turf/D = locate(T.x, throwy - 1, 1)
				//var/turf/E = get_step(D, SOUTH)
				for(var/atom/movable/AM as mob|obj in T)
					AM.Move(D)

				if(istype(T, /turf/simulated))
					del(T)
			//Do I really need to explain this loop?
			for(var/atom/A in toArea)
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				// Weird things happen when this shit gets in the way.
				if(istype(A,/obj/structure/lattice) \
					|| istype(A, /obj/structure/window) \
					|| istype(A, /obj/structure/grille))
					qdel(A)

			transitArea.move_contents_to(toArea)
			research_shuttle_location = research_loc_expected

			for(var/mob/M in toArea)
				if(M.client)
					spawn(0)
						if(M.buckled)
							shake_camera(M, 3, 1) // buckled, not a lot of shaking
						else
							shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
				if(istype(M, /mob/living/carbon))
					if(!M.buckled)
						M.Weaken(3)

			research_shuttle_moving = 0
			for(var/obj/machinery/door/unpowered/shuttle/D in toArea) //Alright we're good
				D.open()
				D.locked = 0
	return

/obj/machinery/computer/research_shuttle
	name = "Research Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_research)
	circuit = "/obj/item/weapon/circuitboard/research_shuttle"
	var/hacked = 0
	var/location = 0 //0 = station, 1 = research base

	l_color = "#7BF9FF"

/obj/machinery/computer/research_shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat = "<center>Research shuttle:<br> <b><A href='?src=\ref[src];move=[1]'>Send</A></b></center>"
	user << browse("[dat]", "window=researchshuttle;size=200x100")

/obj/machinery/computer/research_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(ticker.mode.name == "blob")
			if(ticker.mode:declared)
				usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
				return

		if (!research_shuttle_moving)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			move_research_shuttle()
		else
			usr << "\blue Shuttle is already moving."

/obj/machinery/computer/research_shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		src.req_access = list()
		hacked = 1
		usr << "You disable the console's access requirement."

	else if(istype(W, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe(src.loc)
			var/obj/item/weapon/circuitboard/research_shuttle/M = new /obj/item/weapon/circuitboard/research_shuttle(A)
			for (var/obj/C in src)
				C.loc = src.loc
			A.circuit = M
			A.anchored = 1

			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				getFromPool(/obj/item/weapon/shard, loc)
				A.state = 3
				A.icon_state = "3"
			else
				user << "\blue You disconnect the monitor."
				A.state = 4
				A.icon_state = "4"

			del(src)
