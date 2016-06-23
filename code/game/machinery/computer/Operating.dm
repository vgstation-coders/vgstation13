//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = 1.0
	icon_state = "operating"
	circuit = "/obj/item/weapon/circuitboard/operating"
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/optable = null

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/operating/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/computer/operating/proc/updatemodules()
	optable = findoptable()

/obj/machinery/computer/operating/proc/findoptable()
	var/obj/machinery/optable/optablef = null

	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))

		// Try to find a scanner in that direction
		optablef = locate(/obj/machinery/optable, get_step(src, dir))

		// If found, then we break, and return the scanner
		if (!isnull(optablef))
			break

	// If no scanner was found, it will return null
	return optablef

/obj/machinery/computer/operating/attack_ai(user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/med_data/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/computer/operating/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	var/dat = {"<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>"}
	if(!isnull(optable) && (optable.check_victim()))
		victim = optable.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>Name:</B> [victim.real_name]<BR>
<B>Age:</B> [victim.age]<BR>
<B>Blood Type:</B> [victim.dna.b_type]<BR>
<BR>
<B>Health:</B> [victim.health]<BR>
<B>Brute Damage:</B> [victim.getBruteLoss()]<BR>
<B>Toxins Damage:</B> [victim.getToxLoss()]<BR>
<B>Fire Damage:</B> [victim.getFireLoss()]<BR>
<B>Suffocation Damage:</B> [victim.getOxyLoss()]<BR>
<B>Patient Status:</B> [victim.stat ? "Non-Responsive" : "Stable"]<BR>
<BR>
<A HREF='?src=\ref[user];mach_close=op'>Close</A>"}
	else
		victim = null
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>No Patient Detected</B><BR>
<BR>
<A HREF='?src=\ref[user];mach_close=op'>Close</A>"}
	user << browse(dat, "window=op")
	user.set_machine(src)
	onclose(user, "op")

/obj/machinery/computer/operating/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
	return

/obj/machinery/computer/operating/process()
	if(..())
		updateDialog()
	update_icon()

/obj/machinery/computer/operating/update_icon()
	..()
	if(!(stat & (BROKEN | NOPOWER)))
		updatemodules()
		if(!isnull(optable) && (optable.check_victim()))
			victim = optable.victim
			if(victim.stat == DEAD)
				icon_state = "operating-dead"
			else
				icon_state = "operating-living"
