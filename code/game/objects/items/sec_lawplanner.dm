#define LAW_A1 1
#define LAW_A2 2
#define LAW_B1 3
#define LAW_B2 4
#define LAW_C1 5
#define LAW_C2 6

/obj/item/device/law_planner
	name = "law planning frame"
	desc = "A large data pad with buttons for crimes. Used for planning a brig sentence."
	w_class = W_CLASS_SMALL
	origin_tech = Tc_PROGRAMMING + "=6"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard"
	item_state = "electronic"
	req_access = list(access_brig)
	var/announce = 1 //0 = Off, 1 = On select, 2 = On upload
	var/start_timer = FALSE //If true, automatically start the timer on upload
	var/datum/data/record/upload_crimes = null //If has DNA, will look for an associated datacore file and upload crimes
	var/list/rapsheet = list()
	var/total_time = 0

/obj/item/device/law_planner/Topic(href, href_list)
	if(..(href, href_list))
		return

	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	switch(href_list["assault"])
		if(LAW_A1)
			rapsheet.Add("1A-1 MINOR ASSAULT")
			total_time += 3
		if(LAW_A2)
			rapsheet.Add("1A-2 ASSAULT")
			total_time += 6
		if(LAW_B1)
			rapsheet.Add("1B-1 ABDUCTION")
			total_time += 10
		//if(LAW_B2)

		if(LAW_C1)
			rapsheet.Add("1C-1 MANSLAUGHTER")
			total_time += 10
		if(LAW_C2)
			rapsheet.Add("1C-2 MURDER")
			total_time += 10
			visible_message("[bicon(src)] \the [src] beeps, \"This inmate is eligible for execution.\"")

	switch(href_list["damage"])
		if(LAW_A1)

		if(LAW_A2)

		if(LAW_B1)

		if(LAW_B2)

		if(LAW_C1)

		if(LAW_C2)

	switch(href_list["theft"])
		if(LAW_A1)

		if(LAW_A2)

		if(LAW_B1)

		if(LAW_B2)

		if(LAW_C1)

		if(LAW_C2)

	switch(href_list["contraband"])
		if(LAW_A1)

		if(LAW_A2)

		if(LAW_B1)

		if(LAW_B2)

		if(LAW_C1)

		if(LAW_C2)


/obj/item/device/law_planner/proc/announce()
	say(english_list(rapsheet))
	say("[total_time] minutes.")

/obj/item/device/law_planner/afterattack(var/atom/A, var/mob/user, var/proximity_flag)
	if(!proximity_flag)
		to_chat(user, "<span class='warning'>You can't seem to reach \the [A].</span>")
		return 0
	if(!allowed)
		to_chat(user, "<span class='warning'>You must wear your ID!</span>")
		return 0
	if(ishuman(A)&&!(A==user))
		for(var/datum/data/record/E in data_core.security)
			if(E.fields["name"] == A.name)
				say("Verified. Found record match for [A].")
				upload_crimes = E
	if(istype(A,/obj/machinery/door_timer))
		if(announce==2)
			announce()
		if(upload_crimes)
			upload_crimes.fields["criminal"] = "Incarcerated"
			var/counter = 1
			while(upload_crimes.fields["com_[counter]"])
				counter++
			upload_crimes.fields["com_[counter]"] = text("Made by [user] (Automated) on [time2text(world.realtime, "DDD MMM DD")]<BR>[english_list(rapsheet)]")
		var/obj/machinery/door_timer/D = A
		if(D.timeleft())
			//We're adding time
			D.releasetime += total_time*60
		else
			//Setting time
			D.timeset(total_time*60)
		if(start_timer && !D.timing)
			D.timer_start()
		upload_crimes = null
		rapsheet = null
		total_time = null
	else
		..()