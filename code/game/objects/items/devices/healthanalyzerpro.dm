#define PRO_HEALTH_SCAN	"Health Scan"
#define PRO_HEALTH_SCAN_SIMPLE	"Simplified Health Scan"
#define PRO_BODY_SCAN	"Advanced Health Scan"
#define PRO_REAGENT_SCAN	"Reagents Scan"
#define PRO_IMMUNE_SCAN	"Immunity Scan"
#define PRO_AUTOPSY_SCAN	"Autopsy Scan"

/obj/item/weapon/autopsy_scanner/healthanalyzerpro
	name = "Health Analyzer Pro"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_health"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to precisely distinguish vital signs of the subject. This particular device is an experimental model outfitted with several modules that fulfill the roles of common scanning tools, memory function to record last made scan and a printer."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 4
	starting_materials = list(MAT_IRON = 700, MAT_PLASTIC = 200, MAT_URANIUM = 50, MAT_SILVER = 50, MAT_GOLD = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	autoignition_temperature = AUTOIGNITION_PLASTIC
	origin_tech = Tc_MAGNETS + "=4;" + Tc_BIOTECH + "=4"
	attack_delay = 0
	var/last_scantime = 0
	var/last_reading = null
	var/mode = PRO_HEALTH_SCAN
	var/list/modes = list(PRO_HEALTH_SCAN, PRO_HEALTH_SCAN_SIMPLE, PRO_BODY_SCAN, PRO_REAGENT_SCAN, PRO_IMMUNE_SCAN, PRO_AUTOPSY_SCAN)
	var/obj/item/device/antibody_scanner/immune
	var/last_print

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Current active mode: [mode].</span>")

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/verb/toggle_mode()
	set name = "Switch mode"
	set src in usr
	set category = "Object"

	mode = input(usr, "Please select module.", "Health Scanner Pro") in modes
	last_reading = null
	last_scantime = 0

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/AltClick()
	if(usr.is_holding_item(src))
		toggle_mode()

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/print_data() //verb from autopsy scanner changed to work differently here
	var/mob/user = usr
	if(mode == "Immunity Scan")
		to_chat(user, "<span class='warning'>Due to memory constraints, immunity scan doesn't provide printing function!</span>")
		return
	if(!last_reading)
		to_chat(user, "<span class='warning'>The memory is empty.</span>")
		return
	if(!user.dexterity_check()) //it's a complex thingy
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(last_print + 15 SECONDS > world.time)
		to_chat(user, "<span class='warning'>Printing energy spent, please wait a moment.</span>")
		return

	visible_message("<span class='warning'>\the [src] rattles and prints out a sheet of paper.</span>", 1)
	last_print = world.time
	sleep(1 SECONDS)
	var/obj/item/weapon/paper/R = new(loc)
	R.name = "paper - '[mode] results'"
	R.info = last_reading
	user.put_in_hands(R)

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/attack(mob/living/L, mob/living/user)
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(user.hallucinating())
		hallucinate_scan(L,user)
		return
	switch(mode)
		if(PRO_HEALTH_SCAN, PRO_HEALTH_SCAN_SIMPLE)
			health_scan(L,user)
		if(PRO_BODY_SCAN)
			if(istype(L,/mob/living/carbon/human))
				body_scan(L,user)
		if(PRO_AUTOPSY_SCAN)
			if(istype(L,/mob/living/carbon/human))
				autopsy_scan(L,user)
	add_fingerprint(user)

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/preattack(atom/O, mob/user) //snowlakes
	switch(mode)
		if(PRO_REAGENT_SCAN)
			reagent_scan(O,user)
		if(PRO_IMMUNE_SCAN)
			immune_scan(O,user)
	add_fingerprint(user)

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/attack_self(mob/living/user)
	if(..())
		return
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(last_reading)
		if(!user.hallucinating())
			to_chat(user, "<span class='bnotice'>Accessing Prior Scan Result</span>")
			if(mode == PRO_AUTOPSY_SCAN || mode == PRO_BODY_SCAN)
				user << browse(last_reading, "window=borerscan;size=430x600")
			else
				to_chat(user, last_reading)
		else
			hallucinate_scan(user)
	add_fingerprint(user)

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/proc/hallucinate_scan(mob/living/M, mob/living/user)
	if(M && M.isDead())
		user.show_message("<span class='game say'><b>\The [src] beeps</b>, \"It's dead, Jim.\"</span>", MESSAGE_HEAR ,"<span class='notice'>\The [src] glows black.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] glows [pick("red", "green", "blue", "pink")]! You wonder what that would mean.</span>")


//Health Scan and Simplified Health Scan

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/proc/health_scan(mob/living/M, mob/living/user)
	var/scan_detail
	if(mode == PRO_HEALTH_SCAN)
		scan_detail = 1
	else
		scan_detail = 0
	if(last_scantime + 1 SECONDS < world.time)
		last_reading = healthanalyze(M, user, scan_detail, silent = FALSE)
		last_scantime = world.time
	else
		last_reading = healthanalyze(M, user, scan_detail, silent = TRUE)

//Autopsy Function

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/proc/autopsy_scan(mob/living/carbon/human/M, mob/living/user)
	if(!istype(M))
		return
	if(!can_operate(M, user))
		to_chat(user, "<span class='warning'>Put the subject on a surgical unit.</span>")
		return
	to_chat(user, "<span class='info'>You start the advanced autopsy scan...</span>")
	if(do_mob(user, M, 10 SECONDS))
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
		if(target_name != M.name)
			target_name = M.name
			src.wdata = list()
			src.chemtraces = list()
			src.timeofdeath = null

			src.timeofdeath = M.timeofdeath
		var/scan_success
		for(var/organ_name in M.organs_by_name)
			var/datum/organ/external/O = M.get_organ(organ_name)
			if(O && O.open)
				src.add_data(O)
				scan_success += add_data(O)
		var/dat
		dat = format_autopsy_data()
		if(!scan_success)
			to_chat(user, "<span class='warning'>Insuffient data retrieved. Please ensure that subject has proper surgical incisions.</span>")
		else
			to_chat(user, "<span class='info'>Autopsy analysis of [M] concluded.</span>")
			user << browse(dat, "window=borerscan;size=430x600")
			last_reading = dat
			last_scantime = world.time

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/add_data(var/datum/organ/external/O)
	if(!O.autopsy_data.len && !O.trace_chemicals.len)
		return 0
	..()
	return 1

//Advanced Health Scanner functions, basicly advanced body scanner

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/proc/body_scan(mob/living/M as mob, mob/living/user as mob)
	if (!M)
		return
	if(!istype(M, /mob/living/carbon/human))
		to_chat(src, "<span class='warning'>This module can only scan compatible lifeforms.</span>")
		return
	to_chat(user, "<span class='info'>You start the advanced medical scanning procedure...</span>")
	if(do_mob(user, M, 5 SECONDS))
		playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
		to_chat(user, "<span class='info'>Showing medical statistics of [M]...</span>")
		var/dat
		dat = format_occupant_data(get_occupant_data(M),1) //basic scan in unupgraded body analyzer
		user << browse(dat, "window=borerscan;size=430x600")
		last_reading = dat
		last_scantime = world.time
	return

//Reagent Scan function

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/proc/reagent_scan(atom/O, mob/user)
	if(!O.Adjacent(user))
		return
	if(O.reagents)
		to_chat(user, "<span class='info'>You start the reagents scan...</span>")
		if(do_mob(user, O, 2 SECONDS))
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			var/chems = ""
			var/dat = ""
			if(O.reagents.reagent_list.len)
				for(var/datum/reagent/R in O.reagents.reagent_list)
					var/reagent_percent = (R.volume/O.reagents.total_volume)*100
					chems += "<br><span class='notice'>[R] ["([R.volume] units, [reagent_percent]%)"]</span>"
			if(chems)
				dat += "<span class='notice'>Chemicals found in \the [O]:[chems]</span>"
				to_chat(user, "[dat]")
			else
				dat = "<span class='notice'>No active chemical agents found in \the [O].</span>"
				to_chat(user, "[dat]")
			last_reading = dat
			last_scantime = world.time

//the fucking virology scanner part

/obj/item/weapon/autopsy_scanner/healthanalyzerpro/proc/immune_scan(atom/O, mob/user)
	if(!O.Adjacent(user))
		return
	if(!iscarbon(O))
		return
	if(!immune)
		immune = new
	to_chat(user, "<span class='info'>You start the immunity scan...</span>")
	if(do_mob(user, O, 1 SECONDS))
		immune.attack(O,user)
		last_scantime = world.time
		QDEL_NULL(immune)
