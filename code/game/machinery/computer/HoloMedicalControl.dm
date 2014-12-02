/obj/machinery/computer/HoloMedicalControl
	name = "Holomedical Control Computer"
	desc = "A computer used to control a nearby holodeck."
	icon_state = "holocontrol"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = 0
	var/list/holographic_items = list()
	var/damaged = 0
	var/last_change = 0

	l_color = "#7BF9FF"


	attack_ai(var/mob/user as mob)
		src.add_hiddenprint(user)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return

	attack_hand(var/mob/user as mob)

		if(..())
			return
		user.set_machine(src)
		var/dat

		dat += {"<B>Holomedical Control System</B><BR>
			<HR>Current Loaded Programs:<BR>
			<A href='?src=\ref[src];scanner=1'>((Scanner)</font>)</A><BR>
			<A href='?src=\ref[src];sleeper=1'>((Sleeper)</font>)</A><BR>
			<A href='?src=\ref[src];surgery=1'>((Surgery)</font>)</A><BR>
			<A href='?src=\ref[src];off=1'>((Shutdown)</font>)</A><BR>"}

		//if(emagged)
			//Future?
		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return


	Topic(href, href_list)
		if(..())
			return
		if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
			usr.set_machine(src)

			if(href_list["scanner"])
				target = locate(/area/holomed/source_scanner)
				if(target)
					loadProgram(target)

			else if(href_list["sleeper"])
				target = locate(/area/holomed/source_sleeper)
				if(target)
					loadProgram(target)

			else if(href_list["surgery"])
				target = locate(/area/holomed/source_surgery)
				if(target)
					loadProgram(target)

			else if(href_list["off"])
				target = locate(/area/holomed/source_off)
				if(target)
					loadProgram(target)

			src.add_fingerprint(usr)
		src.updateUsrDialog()
		return



/obj/machinery/computer/HoloMedicalControl/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	..() //See HolodeckControl for notes
	return

/*/obj/machinery/computer/HoloMedicalControl/emag(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
	emagged = 1
	user << "\blue You vastly increase projector power and override the safety and security protocols."
	user << "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator."
	log_game("[key_name(usr)] emagged the Holodeck Control Computer")
	src.updateUsrDialog()*/
	//Future?

/obj/machinery/computer/HoloMedicalControl/New()
	..()
	linkedholodeck = locate(/area/holomed/alphadeck)

/obj/machinery/computer/HoloMedicalControl/Destroy()
	emergencyShutdown()
	..()

/obj/machinery/computer/HoloMedicalControl/meteorhit(var/obj/O as obj)
	emergencyShutdown()
	..()


/obj/machinery/computer/HoloMedicalControl/emp_act(severity)
	emergencyShutdown()
	..()


/obj/machinery/computer/HoloMedicalControl/ex_act(severity)
	emergencyShutdown()
	..()


/obj/machinery/computer/HoloMedicalControl/blob_act()
	emergencyShutdown()
	..()


/obj/machinery/computer/HoloMedicalControl/process()

	if(!..())
		return
	if(active)

		if(!checkInteg(linkedholodeck))
			damaged = 1
			target = locate(/area/holomed/source_off)
			if(target)
				loadProgram(target)
			active = 0
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, T)
					s.start()
				T.ex_act(3)
				T.hotspot_expose(1000,500,1,surfaces=1)


		for(var/item in holographic_items)
			if(!(get_turf(item) in linkedholodeck))
				derez(item, 0)



/obj/machinery/computer/HoloMedicalControl/proc/derez(var/obj/obj , var/silent = 1)
	holographic_items.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.u_equip(obj)
			M.update_icons()	//so their overlays update

	if(!silent)
		var/obj/oldobj = obj
		visible_message("The [oldobj.name] fades away!")
	del(obj)

/obj/machinery/computer/HoloMedicalControl/proc/checkInteg(var/area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

/obj/machinery/computer/HoloMedicalControl/proc/togglePower(var/toggleOn = 0)

	if(toggleOn)
		var/area/targetsource = locate(/area/holomed/source_off)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

		active = 1
	else
		for(var/item in holographic_items)
			derez(item)
		var/area/targetsource = locate(/area/holomed/source_off)
		targetsource.copy_contents_to(linkedholodeck , 1)
		active = 0


/obj/machinery/computer/HoloMedicalControl/proc/loadProgram(var/area/A)

	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("\b ERROR. Recalibrating projection apparatus.")
			last_change = world.time
			return

	last_change = world.time
	active = 1

	for(var/item in holographic_items)
		derez(item)

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		del(B)

	holographic_items = A.copy_contents_to(linkedholodeck , 1)


/obj/machinery/computer/HoloMedicalControl/proc/emergencyShutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	//Turn it back to the regular non-holographic room
	target = locate(/area/holomed/source_off)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holomed/source_off)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = 0



// Holographic items

/obj/item/weapon/holo/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	flags = FPRINT | TABLEPASS
	w_class = 1.0

/obj/item/weapon/holo/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	flags = FPRINT | TABLEPASS
	w_class = 1.0
	attack_verb = list("attacked", "pinched")

/obj/item/weapon/holo/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	flags = FPRINT | TABLEPASS
	w_class = 1.0
	attack_verb = list("burnt")

/obj/item/weapon/holo/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags = FPRINT | TABLEPASS
	force = 15.0
	w_class = 1.0
	attack_verb = list("drilled")

/obj/item/weapon/holo/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	hitsound = "sound/weapons/bladeslice.ogg"
	flags = FPRINT | TABLEPASS
	force = 10.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/holo/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags = FPRINT | TABLEPASS
	force = 15.0
	w_class = 1.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacked", "slashed", "sawed", "cut")

/obj/item/weapon/holo/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	throwforce = 1.0


/obj/item/weapon/holo/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	var/usage_amount = 10

/obj/item/weapon/holo/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attacked", "hit", "bludgeoned")