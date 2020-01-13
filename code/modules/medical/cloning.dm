//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150
#define BIOMASS_CHUNK 50

/obj/machinery/cloning/clonepod
	anchored = TRUE
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	var/mob/living/occupant
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = FALSE
	var/frequency = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = FALSE //Need to clean out it if it's full of exploded clone.
	var/working = FALSE //One clone attempt at a time thanks
	var/eject_wait = FALSE //Don't eject them as soon as they are created fuckkk
	var/biomass = 0
	var/time_coeff = 1 //Upgraded via part upgrading
	var/resource_efficiency = 1
	var/id_tag = "clone_pod"
	var/obj/machinery/computer/cloning/cloning_computer = null


	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU

	light_color = LIGHT_COLOR_CYAN
	use_auto_lights = 1
	light_range_on = 3
	light_power_on = 2

/obj/machinery/cloning/clonepod/full
	biomass = CLONE_BIOMASS // * 3 - N3X

/obj/machinery/cloning/clonepod/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/cloning/clonepod/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/clonepod,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/cloning/clonepod/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T += SM.rating //First rank is two times more efficient, second rank is two and a half times, third is three times. For reference, there's TWO scanning modules
	time_coeff = T/2
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/MA in component_parts)
		T += MA.rating //Ditto above
	resource_efficiency = T/2
	T = 0

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "cloning data disk"
	desc = "A disk for storing DNA data, and to transfer it between a cloning console and a DNA modifier."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_cloning" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/datum/dna2/record/buf=null
	var/list/datum/block_label/labels[DNA_SE_LENGTH] //This is not related to cloning, these are colored tabs for Genetics machinery. Multipurpose floppies, why not?
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/New()
	for(var/i=1;i<=DNA_SE_LENGTH;i++)
		labels[i] = getFromPool(/datum/block_label)

/obj/item/weapon/disk/data/Destroy()
	for(var/datum/block_label/label in labels)
		returnToPool(label)
	labels.Cut()
	..()

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna = new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

/obj/item/weapon/disk/data/demo/New()
	..()
	Initialize()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	//data = "066000033000000000AF00330660FF4DB002690"
	//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
	//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
	buf.dna.UpdateUI()

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = TRUE

/obj/item/weapon/disk/data/monkey/New()
	..()
	Initialize()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)


//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/living/M in player_list)
		//Dead people only thanks!
		if ((M.stat != 2) || (!M.client))
			continue
		//They need a brain!
		if ((istype(M, /mob/living/carbon/human)) && !M.has_brain())
			continue

		if (M.ckey == find_key)
			selected = M
			break
	return selected

//Disk stuff.
/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/weapon/disk/data/examine(mob/user)
	..()
	to_chat(user, "The write-protect tab is set to [read_only ? "protected" : "unprotected"].")

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if (!implanted)
		return "ERROR"
	else
		if(isliving(implanted))
			var/mob/living/L = implanted
			healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if (!healthstring)
			healthstring = "ERROR"
		return healthstring

/obj/machinery/cloning/clonepod/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)
/obj/machinery/cloning/clonepod/attack_paw(mob/user as mob)
	return attack_hand(user)
/obj/machinery/cloning/clonepod/attack_hand(mob/user as mob)
	if ((isnull(occupant)) || (stat & NOPOWER))
		return
	if ((!isnull(occupant)) && (occupant.stat != 2))
		var/completion = (100 * ((occupant.health + 100) / (heal_level + 100)))
		to_chat(user, "Current clone cycle is [round(completion)]% complete.")
	return

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/cloning/clonepod/proc/growclone(var/datum/dna2/record/R)
	if(mess || working)
		return FALSE
	var/datum/mind/clonemind = locate(R.mind)
	if(!istype(clonemind,/datum/mind))	//not a mind
		return FALSE
	if( clonemind.current && clonemind.current.stat != DEAD )	//mind is associated with a non-dead body
		return FALSE
	if(clonemind.active)	//somebody is using that mind
		if( ckey(clonemind.key)!=R.ckey )
			return FALSE
	else
		for(var/mob/G in player_list)
			if(G.ckey == R.ckey)
				if(isobserver(G))
					if(G:can_reenter_corpse)
						break
					else
						return FALSE
				else
					if((G.mind && (G.mind.current.stat != DEAD) ||  G.mind != clonemind))
						return FALSE

	heal_level = rand(10,40) //Randomizes what health the clone is when ejected
	working = TRUE //One at a time!!
	locked = TRUE

	eject_wait = TRUE
	spawn(30)
		eject_wait = FALSE

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species, delay_ready_dna = TRUE)
	occupant = H
	H.times_cloned = R.times_cloned +1
	H.talkcount = R.talkcount

	if(!connected.emagged)
		icon_state = "pod_1"
	else
		icon_state = "pod_e"

	connected.update_icon()

	if(isplasmaman(H))
		H.fire_sprite = "Plasmaman"

	//Get the clone body ready
	H.dna = R.dna.Clone()
	H.dna.flavor_text = R.dna.flavor_text
	H.dna.species = R.dna.species
	if(H.dna.species != "Human")
		H.set_species(H.dna.species, TRUE)

	H.adjustCloneLoss(150) //new damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	H.adjustBrainLoss(heal_level + 50 + rand(10, 30)) // The rand(10, 30) will come out as extra brain damage
	H.Paralyse(4)
	H.stat = UNCONSCIOUS //There was a bug which allowed you to talk for a few seconds after being cloned, because your stat wasn't updated until next Life() tick. This is a fix for this!

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	has_been_shade.Remove(clonemind)
	clonemind.transfer_to(H)

	H.ckey = R.ckey
	to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	if (H.mind.miming)
		H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
		if (H.mind.miming == MIMING_OUT_OF_CHOICE)
			H.add_spell(new /spell/targeted/oathbreak/)

	H.UpdateAppearance()
	H.set_species(R.dna.species)
	randmutb(H) // sometimes the clones come out wrong.
	H.dna.mutantrace = R.dna.mutantrace
	H.update_mutantrace()
	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
	H.real_name = H.dna.real_name
	H.flavor_text = H.dna.flavor_text

	H.suiciding = FALSE
	return TRUE

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/cloning/clonepod/process()

	if(stat & NOPOWER) //Autoeject if power is lost
		if (occupant)
			locked = FALSE
			go_out()
		return

	if((occupant) && (occupant.loc == src))
		if((occupant.stat == DEAD) || (occupant.suiciding) || !occupant.key)  //Autoeject corpses and suiciding dudes.
			locked = FALSE
			go_out()
			connected_message("Clone Rejected: Deceased.")
			return

		else if(occupant.health < heal_level)
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-1*time_coeff) //Very slow, new parts = much faster

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-1*time_coeff) //Ditto above

			var/mob/living/carbon/human/H = occupant

			if(isvox(H))
				if(occupant.reagents.get_reagent_amount(NITROGEN) < 30)
					occupant.reagents.add_reagent(NITROGEN, 60)

			//So clones don't die of oxyloss in a running pod.
			else if(occupant.reagents.get_reagent_amount(INAPROVALINE) < 30) //Done like this because inaprovaline is toxic to vox
				occupant.reagents.add_reagent(INAPROVALINE, 60)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((occupant.health >= heal_level) && (!eject_wait))
			connected_message("Cloning Process Complete.")
			locked = FALSE
			go_out()
			return

	else if ((!occupant) || (occupant.loc != src))
		occupant = null
		if (locked)
			locked = FALSE
		if (!mess)
			icon_state = "pod_0"
		use_power(200)
		return

	return

/obj/machinery/cloning/clonepod/emag(mob/user as mob)
	if(isnull(occupant))
		return
	if(user)
		to_chat(user, "You force an emergency ejection.")
	locked = FALSE
	go_out()
	return

/obj/machinery/cloning/clonepod/crowbarDestroy(mob/user)
	if(occupant)
		to_chat(user, "<span class='warning'>You cannot disassemble \the [src], it's occupado.</span>")
		return
	for(biomass; biomass > 0;biomass -= BIOMASS_CHUNK)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(loc)
	return..()

/obj/machinery/cloning/clonepod/Destroy()
	if(connected)
		if(connected.pod1 == src)
			connected.pod1 = null
		connected = null
	go_out() //Eject everything

	. = ..()

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/cloning/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	. = ..()
	if(.)
		return .
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (!check_access(W))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		else if ((!locked) || (isnull(occupant)))
			return
		else
			locked = FALSE
			to_chat(user, "System unlocked.")
	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		if(user.drop_item(W))
			playsound(src, 'sound/machines/juicerfast.ogg', 30, 1)
			to_chat(user, "<span class='notice'>\The [src] processes \the [W].</span>")
			biomass += BIOMASS_CHUNK
			qdel(W)
			return

//Put messages in the connected computer's temp var for display.
/obj/machinery/cloning/clonepod/proc/connected_message(var/message)
	if ((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return FALSE
	if (!message)
		return FALSE

	connected.temp = message
	connected.updateUsrDialog()
	return TRUE

/obj/machinery/cloning/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cloning/clonepod/proc/go_out(var/exit = loc)
	if (locked)
		return

	if (mess) //Clean that mess and dump those gibs!
		mess = FALSE
		working = FALSE //NOW we're done.
		gibs(loc)
		icon_state = "pod_0"
		return

	if (!(occupant))
		return

	if (occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.forceMove(exit)
	icon_state = "pod_0"
	eject_wait = FALSE //If it's still set somehow.
	domutcheck(occupant) //Waiting until they're out before possible monkeyizing.
	occupant.add_side_effect("Bad Stomach") // Give them an extra side-effect for free.
	occupant = null
	if(biomass > 0)
		biomass -= CLONE_BIOMASS/resource_efficiency //Improve parts to use less biomass
	else
		biomass = 0

	connected.update_icon()
	working = FALSE //NOW we're done.

	return TRUE

/obj/machinery/cloning/clonepod/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(!occupant || occupant == usr || (!ishigherbeing(usr) && !isrobot(usr)) || usr.incapacitated() || usr.lying)
		return
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location) || !Adjacent(usr) || !usr.Adjacent(over_location))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(isrobot(usr))
		var/mob/living/silicon/robot/robit = usr
		if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
			to_chat(usr, "<span class='warning'>You do not have the means to do this!</span>")
			return

	var/_occupant = occupant // occupant is null after go_out()
	if(go_out(over_location))
		visible_message("[usr] removes \the [_occupant] from \the [src].")
		add_fingerprint(usr)

/obj/machinery/cloning/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		mess = TRUE
		icon_state = "pod_g"
		occupant.ghostize()
		spawn(5)
			qdel(occupant)
	return

/obj/machinery/cloning/clonepod/relaymove(mob/user as mob)
	if (user.stat)
		return
	go_out()
	return

/obj/machinery/cloning/clonepod/emp_act(severity)
	if(prob(100/severity))
		malfunction()
	..()

/obj/machinery/cloning/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/cloning/clonepod/MouseDropTo(obj/item/weapon/reagent_containers/food/snacks/meat/M, mob/living/user)
	var/busy = FALSE
	var/visible_message = FALSE

	if(!istype(M))
		return

	if(issilicon(user))
		return //*buzz

	if(!Adjacent(user) || !user.Adjacent(src) || !user.Adjacent(M) || M.loc == user || !isturf(M.loc) || !isturf(user.loc) || user.loc==null)
		return

	if(user.incapacitated() || user.lying)
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!busy)
		busy = TRUE
		for(var/obj/item/weapon/reagent_containers/food/snacks/meat/meat in M.loc)
			biomass += BIOMASS_CHUNK
			qdel(meat)
			visible_message = TRUE // Prevent chatspam when multiple meat are near

		if(visible_message)
			playsound(src, 'sound/machines/juicer.ogg', 30, 1)
			visible_message("<span class = 'notice'>[src] sucks in and processes the nearby biomass.</span>")
		busy = FALSE

/obj/machinery/cloning/clonepod/kick_act()
	..()

	if(occupant && prob(5))
		visible_message("<span class='notice'>[src] buzzes.</span>","<span class='warning'>You hear a buzz.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		locked = FALSE
		go_out()

/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"

/obj/item/weapon/storage/box/disks/New()
	. = ..()
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}
