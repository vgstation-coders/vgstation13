//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/shipcore
	icon = 'craft.dmi'
	icon_state = "core"
	density = 1

	var/width = 6
	var/height = 8
	var/list/turfs = list()
	var/list/builders
	var/list/components = list()
	var/build_status = "unbuilt"


	proc/group_self()
		builders = list()
		turfs = list()
		components = list()

		anchored = 1

		var/obj/ship_builder/L = new(locate(x, y, z))
		L.dir = WEST
		L.distance = width/2
		L.core = src

		var/obj/ship_builder/R = new(locate(x+1, y, z))
		R.dir = EAST
		R.distance = (width/2)-1
		R.core = src

		builders.Add(L, R)

		spawn() L.scan()
		spawn() R.scan()

		var/h
		for(h=1, h<height/2, h++)
			var/obj/ship_builder/A = new(locate(x+1, y+h, z))
			A.dir = EAST
			A.distance = (width/2)-1
			A.core = src

			var/obj/ship_builder/B = new(locate(x, y+h, z))
			B.dir = WEST
			B.distance = width/2
			B.core = src

			var/obj/ship_builder/C = new(locate(x+1, y-h, z))
			C.dir = EAST
			C.distance = (width/2)-1
			C.core = src

			var/obj/ship_builder/D = new(locate(x, y-h, z))
			D.dir = WEST
			D.distance = width/2
			D.core = src

			builders.Add(A, B, C, D)

			spawn() A.scan()
			spawn() B.scan()
			spawn() C.scan()
			spawn() D.scan()

		while(builders.len)
			sleep(50)
		del(builders)
		for(var/turf/T in turfs)
			for(var/obj/O in T.contents)
				if(istype(O, /obj/machinery/ship_component))
					O:core = src
					components.Add(O)
		build_status = "built"
//		to_chat(world, "Ship initialization complete. [turfs.len] tiles added.")

	proc/receive_turf(var/turf/T)
		turfs.Add(T)


	proc/MoveShip(var/turf/Center) // Center - The new position of the ship's core
		anchored = 0
		var/turf/lowerleft = locate(Center.x - (width/2), Center.y - (height/2), Center.z)
		var/turf/upperright = locate(Center.x + (width/2), Center.y + (height/2), Center.z)

		var/xsav = loc.x
		var/ysav = loc.y
		var/zsav = loc.z

		for(var/turf/T in block(lowerleft, upperright))
			if(!istype(T, /turf/space))
				return 0 // One of the tiles in the range we're moving to isn't a space tile - something's in the way!

		// Alright, the way is clear, we can actually begin transferring everything over now.
		for(var/turf/T in turfs)

			for(var/obj/O in T)
				if(istype(O, /obj/effect/ship_landing_beacon)) // Leave beacons where they are, we don't want to take them with us.
					continue
				var/
					_x = Center.x + O.x - xsav
					_y = Center.y + O.y - ysav
					_z = Center.z + O.z - zsav
				O.loc = locate(_x, _y, _z)

			for(var/mob/M in T)
				var/
					_x = Center.x + M.x - xsav
					_y = Center.y + M.y - ysav
					_z = Center.z + M.z - zsav
				M.loc = locate(_x, _y, _z)

			var/
				_x = Center.x + T.x - xsav
				_y = Center.y + T.y - ysav
				_z = Center.z + T.z - zsav
			var/turf/Newloc = locate(_x, _y, _z)
			//new T(Newloc)
			new T.type(Newloc)
			T.ChangeTurf(/turf/space)

			if(Newloc)
				Newloc.assume_air(T.return_air())
				T.remove_air(T.return_air())
		build_status = "rebuilding"
		group_self()

	proc/draw_power(var/n as num)
		for(var/obj/machinery/ship_component/engine/E in components)
			if(E.draw_power(n))
				return 1
		return 0



obj/machinery/shipcore/attack_hand(user as mob)
	var/dat
	if(..())
		return
	if (1 == 1)	// Haha why did I even do this what the fuck. Whatever. It's too entertaining to remove now. -- TLE
/*
		dat += "Autolathe Wires:<BR>"
		var/wire
		for(wire in wires)
			dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

		dat += text("The red light is [disabled ? "off" : "on"].<BR>")
		dat += text("The green light is [shocked ? "off" : "on"].<BR>")
		dat += text("The blue light is [hacked ? "off" : "on"].<BR>")
*/
		switch(build_status)
			if("unbuilt")
				dat += "<h3>Core Status: <font color =#FF3300>Undeployed</font></h3><BR>"
				dat += "<A href='?src=\ref[src];groupself=1'>Build Ship</A><BR>"
			if("built")
				dat += "<h3>Core Status: <font color =#00CC00>Deployed</font></h3><BR>"
				dat += "<A href='?src=\ref[src];move=1'>Move</A><BR>"
			if("rebuilding")
				dat += "<h3>Core Status: <font color =#FFCC00>Recalibrating</font></h3><BR>"
		user << browse("<HEAD><TITLE>Ship Core</TITLE></HEAD>[dat]","window=shipcore")
		onclose(user, "shipcore")
		return
	user << browse("<HEAD><TITLE>Ship Core Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=shipcore")
	onclose(user, "shipcore")
	return

obj/machinery/shipcore/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	add_fingerprint(usr)
	if(href_list["groupself"])
		group_self()
	if (href_list["move"])
		var/list/beacons = list()
		for(var/obj/effect/ship_landing_beacon/b in world)
			if(istype(b, /obj/effect/ship_landing_beacon))
				if(b.active)
					beacons.Add(b)
		if(!beacons.len)
			return
		var/obj/choice = input("Choose a beacon to land at.", "Beacon Selection") in beacons
		if(choice)
			MoveShip(choice.loc)

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			attack_hand(M)
	updateUsrDialog()
	return



obj/machinery/ship_component
	name = "ship component"
	icon = 'craft.dmi'
	var/obj/machinery/shipcore/core
	var/required_draw = 0
	var/active = 1

	proc
		draw_power(var/n as num)
			if(!n)
				n = required_draw
			if(core.draw_power(n))
				return 1
			else
				return 0

obj/machinery/ship_component/thruster
	name = "thruster"
	icon_state = "thruster"
	density = 1
	opacity = 1

	var/cooldown = 600 // In 1/10th seconds
	var/lastused
	var/ready = 0
	required_draw = 100

	proc
		check_ready()
			if(ready)
				return 1
			if(lastused + cooldown <= world.time)
				for(var/turf/T in range(1,src))
					if(istype(T, /turf/space))
						ready = 1
						break
			else
				ready = 0
			return ready

		fire()
			check_ready()
			if(!ready)
				return 0
			if(draw_power())
				ready = 0
				lastused = world.time
				return 1
			else
				return 0

obj/machinery/ship_component/engine
	name = "engine"
	icon_state = "engine"
	density = 1
	opacity = 1

	var/charge = 1000
	var/capacity = 1000

	draw_power(var/n as num)
		if(charge >= n)
			charge -= n
			return 1
		else
			return 0

obj/machinery/ship_component/control_panel
	name = "control panel"
	icon_state = "controlpanel"
	density = 1
	opacity = 0

	attack_hand(user as mob)
		var/dat
		if(..())
			return
		if(!core)
			dat += "<b>No linked core found. Deploy ship core first.</b>"
		else
			dat += "Ship Status: [core.build_status]<br><br>"
			dat += "<h3>Installed Components:</h3><br><br>"
			dat += "<table>"
			for(var/obj/machinery/ship_component/C in core.components)
				dat += "<tr><td><b>[C.name]</b></td><td>[C.active ? "<font color=green>Active</font>" : "<font color=red>Inactive</font>"]</td></tr>"
				if(istype(C, /obj/machinery/ship_component/engine))
					dat += "<tr><td></td><td><i>Fuel: [C:charge]/[C:capacity]</i></td></tr>"
				if(istype(C, /obj/machinery/ship_component/thruster))
					dat += "<tr><td></td><td><i>Status: [C:check_ready() ? "Ready" : "On Cooldown"]</i></td></tr>"
			dat += "</table>"
		user << browse("<HEAD><TITLE>Ship Controls</TITLE></HEAD>[dat]","window=shipcontrols")
		onclose(user, "shipcontrols")

	Topic(href, href_list)
		if(..())
			return
		usr.machine = src
		add_fingerprint(usr)








/obj/ship_builder
	icon = 'craft.dmi'
	icon_state = "builder"
	density = 0
	opacity = 0

	var/obj/machinery/shipcore/core
	var/distance = 0

	proc/scan()
		if(distance < 0)
			cleanup_self()
		var/i
		for(i=0, i<distance, i++)
			if(istype(loc, /turf/space))
				break
			else
				core.receive_turf(loc)
				loc = get_step(src, dir)
			sleep(0)
		cleanup_self()
	proc/cleanup_self()
		core.builders.Remove(src)
		del(src)



/obj/ship_overlay
	icon = 'craft.dmi'
	icon_state = "ship_overlay"

/obj/effect/ship_landing_beacon
	icon = 'craft.dmi'
	icon_state = "beacon"
	name = "Beacon"
	var/active = 0

	proc
		deploy()
			if(active)
				return
			active = 1
			anchored = 1
		deactivate()
			if(!active)
				return
			active = 0
			anchored = 0
