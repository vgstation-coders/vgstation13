/datum/map_element/dungeon/holodeck
	name = "holodeck"
	file_path = "maps/misc/holodeck.dmm"

/obj/machinery/computer/HolodeckControl
	name = "Holodeck Control Computer"
	desc = "A computer used to control a nearby holodeck."
	icon_state = "holocontrol"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = 0
	var/list/holographic_items = list()
	var/damaged = 0
	var/last_change = 0
	var/list/connected_holopeople = list()
	var/maximum_holopeople = 4

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/HolodeckControl/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/HolodeckControl/attack_paw(var/mob/user as mob)
	return

/obj/machinery/computer/HolodeckControl/proc/spawn_holoperson(mob/dead/observer/user)
	if(stat & (NOPOWER|BROKEN|MAINT))
		return
	if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
		to_chat(user, "<span class='notice'>You can't do this until the game has started.</span>")
		return
	if(!linkedholodeck)
		return
	if(connected_holopeople.len >= maximum_holopeople)
		to_chat(user, "<span class='notice'>\The [src] cannot sustain any additional advanced holograms. Please try again when there are fewer advanced holograms on the holodeck.</span>")
		return
	var/turf/spawnturf
	var/list/L = get_area_turfs(linkedholodeck.type)
	var/turf/T = pick(L)
	while(is_blocked_turf(T))
		T = pick(L)
	if(spawnturf)
		user.forceMove(spawnturf)
		var/mob/living/simple_animal/hologram/advanced/H = user.transmogrify(/mob/living/simple_animal/hologram/advanced, TRUE)
		connected_holopeople.Add(H)
		H.connected_holoconsole = src
		var/list/N = hologram_names.Copy()
		for(var/mob/M in connected_holopeople)
			N.Remove(M.name)
		H.name = capitalize(pick(N))
		H.real_name = H.name

/obj/machinery/computer/HolodeckControl/attack_hand(var/mob/user as mob)

	if(..())
		return
	user.set_machine(src)
	var/dat

	dat += {"<B>Holodeck Control System</B><BR>"}
//	if(isobserver(user))
//		dat += {"<HR><A href='?src=\ref[src];spawn_holoperson=1'>\[Become Advanced Hologram\]</font></A><BR>"}
	dat += {"<HR>Current Loaded Programs:<BR>
		<A href='?src=\ref[src];basketball=1'>((Basketball Court)</font>)</A><BR>
		<A href='?src=\ref[src];beach=1'>((Beach)</font>)</A><BR>
		<A href='?src=\ref[src];boxingcourt=1'>((Boxing Court)</font>)</A><BR>
		<A href='?src=\ref[src];checkers=1'>((Checkers Board)</font>)</A><BR>
		<A href='?src=\ref[src];chess=1'>((Chess Board)</font>)</A><BR>
		<A href='?src=\ref[src];desert=1'>((Desert)</font>)</A><BR>
		<A href='?src=\ref[src];dining=1'>((Dining Hall)</font>)</A><BR>
		<A href='?src=\ref[src];emptycourt=1'>((Empty Court)</font>)</A><BR>
		<A href='?src=\ref[src];firingrange=1'>((Firing Range)</font>)</A><BR>
		<A href='?src=\ref[src];gym=1'>((Gym)</font>)</A><BR>
		<A href='?src=\ref[src];lasertag=1'>((Laser Tag Arena)</font>)</A><BR>
		<A href='?src=\ref[src];maze=1'>((Maze)</font>)</A><BR>
		<A href='?src=\ref[src];meetinghall=1'>((Meeting Hall)</font>)</A><BR>
		<A href='?src=\ref[src];panic=1'>((Panic Bunker)</font>)</A><BR>
		<A href='?src=\ref[src];picnicarea=1'>((Picnic Area)</font>)</A><BR>
		<A href='?src=\ref[src];snowfield=1'>((Snow Field)</font>)</A><BR>
		<A href='?src=\ref[src];theatre=1'>((Theatre)</font>)</A><BR>
		<A href='?src=\ref[src];thunderdomecourt=1'>((Thunderdome Court)</font>)</A><BR>
		<A href='?src=\ref[src];wildride=1'>((Wild Ride)</font>)</A><BR>
		<A href='?src=\ref[src];zoo=1'>((Zoo)</font>)</A><BR>"}
//	dat += "<A href='?src=\ref[src];turnoff=1'>((Shutdown System)</font>)</A><BR>"
	dat += "Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.<BR>"

	if(emagged)
		dat += {"<A href='?src=\ref[src];burntest=1'>(<font color=red>Begin Atmospheric Burn Simulation</font>)</A><BR>
			Ensure the holodeck is empty before testing.<BR>
			<BR>
			<A href='?src=\ref[src];wildlifecarp=1'>(<font color=red>Begin Wildlife Simulation</font>)</A><BR>
			Ensure the holodeck is empty before testing.<BR>
			<BR>
			<A href='?src=\ref[src];catnip=1'>(<font color=red>Club Catnip</font>)</A><BR>
			Ensure the holodeck is full before testing.<BR>
			<BR>
			<A href='?src=\ref[src];ragecage=1'>(<font color=red>Combat Arena</font>)</A><BR>
			Safety protocols disabled - weapons are not for recreation.<BR>
			<BR>
			<A href='?src=\ref[src];medieval=1'>(<font color=red>Medieval Tournament</font>)</A><BR>
			Safety protocols disabled - weapons are not for recreation.<BR>
			<BR>"}
		if(issilicon(user))
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=green>Re-Enable Safety Protocols?</font>)</A><BR>"
		dat += "Safety Protocols are <font color=red> DISABLED </font><BR>"
	else
		if(issilicon(user))
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=red>Override Safety Protocols?</font>)</A><BR>"

		dat += {"<BR>
			Safety Protocols are <font color=green> ENABLED </font><BR>"}
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/HolodeckControl/Topic(href, href_list)
	usr.set_machine(src)

	if(href_list["spawn_holoperson"])
		spawn_holoperson(usr)

	if(..())
		return 1
	else
		if(href_list["emptycourt"])
			target = locate(/area/holodeck/source_emptycourt)
			if(target)
				loadProgram(target)

		else if(href_list["boxingcourt"])
			target = locate(/area/holodeck/source_boxingcourt)
			if(target)
				loadProgram(target)

		else if(href_list["panic"])
			target = locate(/area/holodeck/source_panic)
			if(target)
				loadProgram(target)

		else if(href_list["gym"])
			target = locate(/area/holodeck/source_gym)
			if(target)
				loadProgram(target)

		else if(href_list["medieval"])
			target = locate(/area/holodeck/source_medieval)
			if(target)
				loadProgram(target)

		else if(href_list["catnip"])
			target = locate(/area/holodeck/source_catnip)
			if(target)
				loadProgram(target)

		else if(href_list["checkers"])
			target = locate(/area/holodeck/source_checkers)
			if(target)
				loadProgram(target)

		else if(href_list["basketball"])
			target = locate(/area/holodeck/source_basketball)
			if(target)
				loadProgram(target)

		else if(href_list["thunderdomecourt"])
			target = locate(/area/holodeck/source_thunderdomecourt)
			if(target)
				loadProgram(target)

		else if(href_list["beach"])
			target = locate(/area/holodeck/source_beach)
			if(target)
				loadProgram(target)

		else if(href_list["desert"])
			target = locate(/area/holodeck/source_desert)
			if(target)
				loadProgram(target)

		else if(href_list["picnicarea"])
			target = locate(/area/holodeck/source_picnicarea)
			if(target)
				loadProgram(target)

		else if(href_list["snowfield"])
			target = locate(/area/holodeck/source_snowfield)
			if(target)
				loadProgram(target)

		else if(href_list["theatre"])
			target = locate(/area/holodeck/source_theatre)
			if(target)
				loadProgram(target)

		else if(href_list["meetinghall"])
			target = locate(/area/holodeck/source_meetinghall)
			if(target)
				loadProgram(target)

		else if(href_list["firingrange"])
			target = locate(/area/holodeck/source_firingrange)
			if(target)
				loadProgram(target)

		else if(href_list["wildride"])
			target = locate(/area/holodeck/source_wildride)
			if(target)
				loadProgram(target)

		else if(href_list["chess"])
			target = locate(/area/holodeck/source_chess)
			if(target)
				loadProgram(target)

		else if(href_list["maze"])
			target = locate(/area/holodeck/source_maze)
			if(target)
				loadProgram(target)

		else if(href_list["dining"])
			target = locate(/area/holodeck/source_dining)
			if(target)
				loadProgram(target)

		else if(href_list["lasertag"])
			target = locate(/area/holodeck/source_lasertag)
			if(target)
				loadProgram(target)

		else if(href_list["zoo"])
			target = locate(/area/holodeck/source_zoo)
			if(target)
				loadProgram(target)

		else if(href_list["turnoff"])
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)

		else if(href_list["burntest"])
			if(!emagged)
				return
			target = locate(/area/holodeck/source_burntest)
			if(target)
				loadProgram(target)

		else if(href_list["ragecage"])
			if(!emagged)
				return
			target = locate(/area/holodeck/source_ragecage)
			if(target)
				loadProgram(target)

		else if(href_list["wildlifecarp"])
			if(!emagged)
				return
			target = locate(/area/holodeck/source_wildlife)
			if(target)
				loadProgram(target)

		else if(href_list["AIoverride"])
			if(!issilicon(usr))
				return
			emagged = !emagged
			if(emagged)
				message_admins("[key_name_admin(usr)] overrode the holodeck's safeties")
				log_game("[key_name(usr)] overrode the holodeck's safeties")
				visible_message("<span class='warning'>Warning: Holodeck safeties overriden. Please contact Nanotrasen maintenance and cease all operation if you are not source of that command.</span>")
			else
				message_admins("[key_name_admin(usr)] restored the holodeck's safeties")
				log_game("[key_name(usr)] restored the holodeck's safeties")
				visible_message("<span class='notice'>Holodeck safeties have been restored. Simulation programs are now safe to use again.</span>")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/HolodeckControl/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	..() //This still allows items to unrez even if the computer is deconstructed
	return

/obj/machinery/computer/HolodeckControl/emag(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
	if(emagged)
		return //No spamming
	emagged = 1
	if(user)
		visible_message("<span class='warning'>[user] swipes a card into the holodeck reader.</span>","<span class='notice'>You swipe the electromagnetic card into the holocard reader.</span>")
	visible_message("<span class='warning'>Warning: Power surge detected. Automatic shutoff and derezing protocols have been corrupted. Please contact Nanotrasen maintenance and cease all operation immediately.</span>")
	log_game("[key_name(usr)] emagged the Holodeck Control Computer")
	src.updateUsrDialog()

/obj/machinery/computer/HolodeckControl/New()
	..()
	linkedholodeck = locate(/area/holodeck/alphadeck)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Destroy()
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/blob_act()
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/process()
	//Note : This was moved BEFORE the process() parent that deals with power and co. to avoid item cheesing from cutting off equipment power !
	for(var/item in holographic_items)
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if(!..())
		return
	if(active)
		if(!checkInteg(linkedholodeck))
			damaged = 1
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = 0
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")

			for(var/turf/T in linkedholodeck)
				if(prob(30))
					spark(src)
				T.ex_act(3)
				T.hotspot_expose(1000,500,1,surfaces=1)

/obj/machinery/computer/HolodeckControl/proc/derez(var/obj/obj , var/silent = 1)


	holographic_items.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.u_equip(obj, 0)
			M.update_icons()	//so their overlays update

	if(!silent)
		var/obj/oldobj = obj
		visible_message("The [oldobj.name] fades away!")
	qdel(obj)

/obj/machinery/computer/HolodeckControl/proc/checkInteg(var/area/A)


	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0
	return 1

/obj/machinery/computer/HolodeckControl/proc/togglePower(var/toggleOn = 0)


	if(toggleOn)
		var/area/targetsource = locate(/area/holodeck/source_emptycourt)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

		spawn(30)
			for(var/obj/effect/landmark/L in linkedholodeck)
				if(L.name=="Atmospheric Test Start")
					spawn(20)
						var/turf/T = get_turf(L)
						spark(T, 2)
						if(T)
							T.temperature = 5000
							T.hotspot_expose(50000,50000,1,surfaces=1)

		active = 1
	else
		for(var/item in holographic_items)
			derez(item)
		var/area/targetsource = locate(/area/holodeck/source_plating)
		targetsource.copy_contents_to(linkedholodeck , 1)
		active = 0

/obj/machinery/computer/HolodeckControl/proc/loadProgram(var/area/A)


	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("<B>ERROR. Recalibrating projetion apparatus.</B>")
			last_change = world.time
			return

	last_change = world.time
	active = 1

	for(var/item in holographic_items)
		derez(item)

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		returnToPool(B)

	for(var/mob/living/simple_animal/hostile/carp/holocarp/holocarp in linkedholodeck)
		qdel(holocarp)

	holographic_items = A.copy_contents_to(linkedholodeck , 1)

	if(emagged)
		for(var/obj/item/weapon/holo/esword/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
			if(L.name=="Atmospheric Test Start")
				spawn(20)
					var/turf/T = get_turf(L)
					spark(T, 2)
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1,surfaces=1)
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)

/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	for(var/mob/living/simple_animal/hologram/advanced/H in connected_holopeople)
		H.dissipate()
	//Turn it back to the regular non-holographic room
	target = locate(/area/holodeck/source_plating)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holodeck/source_plating)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = 0

// Holographic Items!

/turf/simulated/floor/holofloor/
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/grass
	name = "lush Grass"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			update_icon()
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding get updated properly

/turf/simulated/floor/holofloor/light
	name = "light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile

/turf/simulated/floor/holofloor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK

/obj/structure/table/holotable
	parts = null

/obj/structure/table/holotable/can_disassemble()
	return FALSE

/obj/structure/table/holotable/wood
	name = "table"
	desc = "A square piece of wood standing on four wooden legs. It cannot move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodtable"

/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxingred"
	item_state = "boxingred"

/obj/structure/window/reinforced/holo/spawnBrokenPieces()
	return

/obj/structure/window/reinforced/holo/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isscrewdriver(W))
		to_chat(user, "It's a holowindow! It has no frame!")
		return

	return ..()

/obj/structure/window/reinforced/holo/spawnBrokenPieces()
	return

/obj/structure/window/holo/spawnBrokenPieces()
	return

/obj/structure/window/holo/attackby(obj/item/weapon/W, mob/user)
	if(isscrewdriver(W))
		to_chat(user, "It's a holowindow! It has no frame!")
		return

	return ..()

/obj/structure/window/holo/spawnBrokenPieces()
	return

/obj/structure/rack/holo
	parts = null

/obj/structure/rack/holo/can_disassemble()
	return FALSE


/obj/item/weapon/holo
	damtype = HALLOSS

/obj/item/weapon/holo/esword
	name = "energy sword"
	desc = "May the force be within you. Sorta"
	icon_state = "sword0"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = W_CLASS_SMALL
	flags = FPRINT | NOBLOODY
	var/active = 0

/obj/item/weapon/holo/esword/green
	New()
		..()
		_color = "green"

/obj/item/weapon/holo/esword/red
	New()
		..()
		_color = "red"

/obj/item/weapon/holo/esword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/holo/esword/New()
	AddToProfiler()
	_color = pick("red","blue","green","purple")

/obj/item/weapon/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if(active)
		force = 30
		icon_state = "sword[_color]"
		w_class = W_CLASS_LARGE
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		w_class = W_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)
	return

//BASKETBALL OBJECTS

/obj/item/weapon/beach_ball/holoball
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	name = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = W_CLASS_LARGE //Stops people from hiding it in their bags/pockets

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = 1
	density = 1
	throwpass = 1

/obj/structure/holohoop/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return

		G.affecting.forceMove(src.loc)
		G.affecting.Knockdown(5)
		visible_message("<span class='warning'>[G.assailant] dunks [G.affecting] into the [src]!</span>")
		qdel(W)
		return
	else if (istype(W, /obj/item) && get_dist(src,user)<2)
		if(user.drop_item(W, src.loc))
			visible_message("<span class='notice'>[user] dunks [W] into the [src]!</span>")
			return

/obj/structure/holohoop/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/weapon/dummy) || istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.forceMove(src.loc)
			visible_message("<span class='notice'>Swish! \the [I] lands in \the [src].</span>")
		else
			visible_message("<span class='warning'>\The [I] bounces off of \the [src]'s rim!</span>")
		return 0
	else
		return ..(mover, target, height, air_group)


/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	ghost_read = 0

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	if(issilicon(user))
		to_chat(user, "<span='warning'>The station's silicons are not to interact with these devices.</span>")
		return
	..()

/obj/machinery/readybutton/attack_paw(mob/user as mob)
	to_chat(user, "<span='warning'>You are too primitive to use this device.</span>")

/obj/machinery/readybutton/New()
	..()

/obj/machinery/readybutton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	to_chat(user, "<span='warning'>The device is a solid button, there's nothing you can do with it!</span>")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(..())
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "<span='notice'>The event has already begun!</span>")
		return

	ready = !ready
	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()


	eventstarted = 1

	for(var/obj/structure/window/reinforced/holo/W in currentarea)
		qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")
