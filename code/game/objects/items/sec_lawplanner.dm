#define LAW_ASSAULT 1
#define LAW_DAMAGE 2
#define LAW_THEFT 3
#define LAW_CONTRABAND 4
#define LAW_TRESPASS 5
#define LAW_ESCAPE 6
#define LAW_INSUB 7

/obj/item/device/law_planner
	name = "law planning frame"
	desc = "A large data pad with buttons for crimes. Used for planning a brig sentence."
	w_class = W_CLASS_SMALL
	origin_tech = Tc_PROGRAMMING + "=6"
	icon = 'icons/obj/device.dmi'
	icon_state = "lawplanner"
	item_state = "electronic"
	req_access = list(access_brig)
	var/announce = 1 //If true, read crimes when you hit the cell timer
	var/start_timer = FALSE //If true, automatically start the timer on upload
	var/time_arrest = FALSE //If true, start counting time when the arrest is made, to subtract from the sentence.
	var/timing = 0	//Time of arrest.
	var/datum/data/record/upload_crimes = null //Will look for an associated datacore file and upload crimes
	var/list/rapsheet = list()
	var/total_time = 0
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/device/law_planner/attack_self(mob/user)
	ui_interact(user)

/obj/item/device/law_planner/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(user.stat && !isAdminGhost(user))
		return

	// this is the data which will be sent to the ui
	var/list/data = list()
	data["timer"] = total_time
	data["announce"] = announce
	data["starttimer"] = start_timer
	data["timearrest"] = time_arrest
	data["arresttime"] = worldtime2text(timing)
	if(upload_crimes)
		data["perp"] = upload_crimes.fields["name"]
	data["crimes"] = english_list(rapsheet)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "lawplanner.tmpl", "Law Planning Frame", 520, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/item/device/law_planner/Topic(href, href_list)
	if(..(href, href_list))
		return

	var/datum/law/L
	if(href_list["assault"])
		L = findlaw(LAW_ASSAULT,text2num(href_list["assault"]))
	else if(href_list["damage"])
		L = findlaw(LAW_DAMAGE,text2num(href_list["damage"]))
	else if(href_list["theft"])
		L = findlaw(LAW_THEFT,text2num(href_list["theft"]))
	else if(href_list["contraband"])
		L = findlaw(LAW_CONTRABAND,text2num(href_list["contraband"]))
	else if(href_list["trespass"])
		L = findlaw(LAW_TRESPASS,text2num(href_list["trespass"]))
	else if(href_list["escape"])
		L = findlaw(LAW_ESCAPE,text2num(href_list["escape"]))
	else if(href_list["insubordination"])
		L = findlaw(LAW_INSUB,text2num(href_list["insubordination"]))

	switch(href_list["toggle"])
		if("announce")
			announce = !announce
		if("starttimer")
			start_timer = !start_timer
		if("timearrest")
			time_arrest = !time_arrest

	switch(href_list["clear"])
		if("record")
			upload_crimes = null
		if("rapsheet")
			rapsheet.Cut()
			total_time = 0
		if("arresttime")
			timing = 0

	if(!L)
		updateUsrDialog()
		return 1
	rapsheet += initial(L.name)
	total_time += initial(L.penalty)
	if(initial(L.death))
		visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"This inmate is eligible for execution.\"")

	if(initial(L.demotion))
		visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"This inmate is eligible for demotion.\"")
	updateUsrDialog()
	return 1


/obj/item/device/law_planner/proc/announce()
	visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"Charges: [english_list(rapsheet)].\"")
	visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"[total_time] minutes.\"")

/obj/item/device/law_planner/preattack(var/atom/A, var/mob/user, var/proximity_flag)
	if(!proximity_flag)
		return 1
	if(!allowed(user))
		to_chat(user, "<span class='warning'>You must wear your ID!</span>")
		return 1
	if(ishuman(A)&&!(A==user))
		var/mob/living/carbon/human/H = A
		var/identity = H.get_face_name()
		if(identity == "Unknown")
			visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"Error. Subject's face was not readable.\"")
			return 1
		for(var/datum/data/record/E in data_core.security)
			if(E.fields["name"] == A.name)
				visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"Verified. Found record match for [A].")
				upload_crimes = E
				timing = 0
				return 1
		visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"Error. No security record found.\"")
		return 1
	if(istype(A,/obj/machinery/computer/secure_data))
		if(upload_crimes)
			upload_crimes(user)
			rapsheet.Cut()
			total_time = 0
		return 1
	if(istype(A,/obj/machinery/door_timer))
		if(!rapsheet.len)
			visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"Error. Zero charges have been issued.\"")
		if(announce)
			announce()
		if(upload_crimes)
			upload_crimes(user)
		var/apply = (total_time MINUTES) / (1 SECONDS)
		if(timing)
			visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"Deducting [round((world.time - timing)/(1 SECONDS))] seconds on time served.\"")
			apply -= round((world.time - timing)/(1 SECONDS))
			timing = 0
		var/obj/machinery/door_timer/D = A
		D.timeleft += apply
		D.timeleft = clamp(round(D.timeleft), 0, 3600)
		if(start_timer && !D.timing)
			D.timing = TRUE
			D.timer_start()
		rapsheet.Cut()
		total_time = 0
		return 1

	else
		return ..()

/obj/item/device/law_planner/proc/upload_crimes(mob/user)
	upload_crimes.fields["criminal"] = "Incarcerated"
	var/counter = 1
	while(upload_crimes.fields["com_[counter]"])
		counter++
	upload_crimes.fields["com_[counter]"] = "Made by [user] (Automated) at [worldtime2text()] [time_arrest? "(Arrested [worldtime2text(timing)])":""]<BR>[english_list(rapsheet)]"
	upload_crimes = null

//received signal from handcuffs
/obj/item/device/law_planner/proc/handcuff_signal()
	if(time_arrest)
		if(timing)
			visible_message("[bicon(src)] <B>\The [src]</B> beeps, \"An arrest timer is already running.\"")
		else
			timing = world.time
		updateUsrDialog()

/***********************************************************************
***                 SPACE LAW DATUMS								 ***
***********************************************************************/

#define LAW_A1 1
#define LAW_A2 2
#define LAW_B1 3
#define LAW_B2 4
#define LAW_C1 5
#define LAW_C2 6

/proc/findlaw(var/mother,var/code)
	var/list/possible_laws = subtypesof(/datum/law)
	for(var/possible in possible_laws)
		var/datum/law/L = possible
		if((initial(L.mothercrime) == mother) && (initial(L.code) == code))
			return L
	//otherwise, returns null

/datum/law
	var/name = "law"
	var/mothercrime = 0
	var/penalty = 0
	var/death = FALSE
	var/demotion = FALSE
	var/code = 0

/datum/law/assault
	mothercrime = LAW_ASSAULT

/datum/law/assault/minor
	name = "1A-1 MINOR ASSAULT"
	penalty = 1
	code = LAW_A1

/datum/law/assault/full
	name = "1A-2 ASSAULT"
	penalty = 3
	code = LAW_A2

/datum/law/assault/abduction
	name = "1B-1 ABDUCTION"
	penalty = 4
	code = LAW_B1

/datum/law/assault/manslaughter
	name = "1C-1 MANSLAUGHTER"
	penalty = 8
	code = LAW_C1

/datum/law/assault/murder
	name = "1C-2 MURDER"
	penalty = 10
	death = TRUE
	code = LAW_C2

/datum/law/damage
	mothercrime = LAW_DAMAGE

/datum/law/damage/vandalism
	name = "2A-1 VANDALISM"
	penalty = 1
	code = LAW_A1

/datum/law/damage/negligence
	name = "2B-1 NEGLIGENCE"
	penalty = 3
	code = LAW_B1
	demotion = TRUE

/datum/law/damage/sabotage
	name = "2B-2 SABOTAGE"
	penalty = 4
	code = LAW_B2

/datum/law/damage/illegalupload
	name = "2C-1 ILLEGAL UPLOAD"
	penalty = 5
	code = LAW_C1

/datum/law/damage/grandsabotage
	name = "2C-2 GRAND SABOTAGE"
	penalty = 8
	code = LAW_C2
	death = TRUE

/datum/law/theft
	mothercrime = LAW_THEFT

/datum/law/theft/petty
	name = "3A-1 PETTY THEFT"
	penalty = 1
	code = LAW_A1

/datum/law/theft/full
	name = "3B-1 THEFT"
	penalty = 3
	code = LAW_B1

/datum/law/theft/grand
	name = "3C-1 GRAND THEFT"
	penalty = 5
	code = LAW_C1

/datum/law/contraband
	mothercrime = LAW_CONTRABAND

/datum/law/contraband/makeshiftcons
	name = "4A-1 MAKESHIFT/CONSOLES"
	penalty = 1
	code = LAW_A1

/datum/law/contraband/weaponexpl
	name = "4B-1 WEAPONS/EXPLOSIVES"
	penalty = 4
	code = LAW_B1
	demotion = TRUE

/datum/law/contraband/mechs
	name = "4C-1 COMBAT GEAR/MECHS"
	penalty = 5
	code = LAW_C1
	demotion = TRUE

/datum/law/contraband/enemycontraband
	name = "4C-2 ENEMY CONTRABAND"
	penalty = 5
	code = LAW_C2
	demotion = TRUE

/datum/law/trespass
	mothercrime = LAW_TRESPASS

/datum/law/trespass/minor
	name = "5A-1 MINOR TRESPASS"
	penalty = 1
	code = LAW_A1

/datum/law/trespass/bande
	name = "5A-2 B&E"
	penalty = 4
	code = LAW_A2

/datum/law/trespass/full
	name = "5B-1 TRESPASS"
	penalty = 3
	code = LAW_B1

/datum/law/trespass/major
	name = "5C-1 MAJOR TRESPASS"
	penalty = 5
	code = LAW_C1

/datum/law/escape
	mothercrime = LAW_ESCAPE

/datum/law/escape/resist
	name = "6A-1 RESISTING"
	penalty = 1
	code = LAW_A1

/datum/law/escape/full
	name = "6B-1 ESCAPE"
	penalty = 1
	code = LAW_B1

/datum/law/escape/interfere
	name = "6B-2 INTERFERENCE"
	penalty = 2
	code = LAW_B2

/datum/law/escape/grand
	name = "6C-1 GRAND ESCAPE"
	penalty = 15
	code = LAW_C1
	death = TRUE

/datum/law/escape/deimplant
	name = "6C-2 DEIMPLANTING"
	penalty = 15
	code = LAW_C2

/datum/law/insub
	mothercrime = LAW_INSUB

/datum/law/insub/comms
	name = "7A-1 MISUSE COMMS"
	penalty = 0
	code = LAW_A1

/datum/law/insub/insub
	name = "7A-2 INSUBORD"
	penalty = 1
	demotion = TRUE
	code = LAW_A2

/datum/law/insub/framing
	name = "7B-1 FRAMING"
	penalty = 0
	code = LAW_B1

/datum/law/insub/abusepower
	name = "7C-1 ABUSE POWER"
	penalty = 0
	demotion = TRUE
	code = LAW_C1

/datum/law/insub/enemy
	name = "7C-2 ENEMY OF CORP"
	penalty = 15
	death = TRUE
	code = LAW_C2
