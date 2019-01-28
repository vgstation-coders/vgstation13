var/list/labor_console_categories = list(
	"Command" = command_positions,
	"Civilian" = civilian_positions,
	"Security" = security_positions,
	"Engineering" = engineering_positions,
	"Medical" = medical_positions,
	"Science" = science_positions,
	"Cargo" = cargo_positions,
	)

/obj/machinery/computer/labor
	name = "Labor Administration Console"
	desc = "According to the manual, you need to take a six-week Labor Administration Associate Training Course before you're qualified to navigate this console's complex interface. Being a HoP is hard work."
	icon = 'icons/obj/computer.dmi'
	icon_state = "comm_logs"
	light_color = LIGHT_COLOR_GREEN
	req_access = list(access_hop)
	circuit = "/obj/item/weapon/circuitboard/labor"

	var/freeing = "" //If this variable is set with a job's title, the user will be prompted to swipe to free up a job slot.
	var/toggling_priority = "" //If this variable is set with a job's title, the user will be prompted to swipe to prioritize/deprioritize.
	var/selected_category = "Civilian"
	var/list/swipe_sounds = list('sound/effects/cardswipe1.ogg', 'sound/effects/cardswipe2.ogg', 'sound/effects/cardswipe3.ogg')

/obj/machinery/computer/labor/New()
	..()
	job_master.labor_consoles += src

/obj/machinery/computer/labor/Destroy()
	job_master.labor_consoles -= src
	..()

/obj/machinery/computer/labor/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/labor/attack_paw(var/mob/user as mob)
	return

/obj/machinery/computer/labor/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = list()
	dat += "<center>"

	if(freeing != "" || toggling_priority != "")
		dat += "<div class='modal'><div class='modal-content'><div class='line'>Swipe a valid ID to confirm:</div><br>"
		if(freeing != "")
			dat += "<b>Freeing</b> <div class='line'>[uppertext(freeing)]</div> Job Slot"
		else if(toggling_priority != "")
			dat += "<b>[job_master.IsJobPrioritized(toggling_priority) ? "Deprioritizing" : "Prioritizing"]</b> <div class='line'>[uppertext(toggling_priority)]</div> Job Slot"
		dat += "<br><br><A href='?src=\ref[src];cancel=1'>CANCEL</A></div></div>"

	var/i = 0
	for(var/cat_index in labor_console_categories)
		dat += "<A href='?src=\ref[src];category=[cat_index]'>[cat_index]</A>"
		i++
		if(i%4 == 0)
			dat += "<br>"

	dat += "<hr>"

	dat += "<table>"
	for(var/job_string in labor_console_categories[selected_category])
		var/datum/job/job_datum = job_master.GetJob(job_string)
		if(job_datum.priority)
			continue
		dat += "<tr><td>[job_datum.title]</td> <td>([job_datum.current_positions]/[job_datum.total_positions])</td> <td>"
		if(job_datum.current_positions >= job_datum.total_positions)
			dat += "<A href='?src=\ref[src];free=[job_datum.title]'>(Free Slot!)</A>"
		else
			dat += "<A [job_master.priority_jobs_remaining < 1 ? "class='linkOff'" : "href='?src=\ref[src];priority=[job_datum.title]'"]>&emsp14;(Prioritize)&emsp14;</A>"
		dat += "</td></tr>"
	dat += "</table>"

	dat += "<div class='footer'><h3>Prioritized Jobs</h3>[job_master.priority_jobs_remaining] more job\s can prioritized.<br>"
	dat += "<table>"
	for(var/datum/job/job_datum in job_master.GetPrioritizedJobs())
		dat += "<tr><td>[job_datum.title]</td> <td>([job_datum.current_positions]/[job_datum.total_positions])</td> <td><A href='?src=\ref[src];priority=[job_datum.title]'>(Remove)</A></td></tr>"
	dat += "</table>"
	dat += "</div>"

	dat += "</center>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "labor_admin", "Labor Administration Console", 325, 500, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "labor_admin")

/obj/machinery/computer/labor/proc/verified(mob/user)
	if(toggling_priority != "")
		if(job_master.TogglePriority(toggling_priority, user))
			spawn(1 SECONDS)
				playsound(src, 'sound/machines/ping.ogg', 35, 0, -2)
				updateUsrDialog()
	toggling_priority = "" //clear it even if it doesn't work

	if(freeing != "")
		if(job_master.FreeRole(freeing, user))
			spawn(1 SECONDS)
				playsound(src, 'sound/machines/ping.ogg', 35, 0, -2)
				updateUsrDialog()
	freeing = "" //clear it even if it doesn't work

/obj/machinery/computer/labor/proc/cancel_swipe()
	toggling_priority = ""
	freeing = ""

/obj/machinery/computer/labor/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(.)
		return .
	if(toggling_priority != "" || freeing != "")
		if(isID(W) || isPDA(W))
			if(!check_access(W))
				to_chat(user, "<span class='warning'>[bicon(src)] Access denied.</span>")
				return
			playsound(src, pick(swipe_sounds), 60, 1, -5)
			verified(user)
		if(isEmag(W))
			playsound(src, pick(swipe_sounds), 60, 1, -5)
			verified(user)

/obj/machinery/computer/labor/kick_act(mob/user)
	..()
	if(prob(5))
		verified(user)

/obj/machinery/computer/labor/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)

		if(href_list["category"])
			selected_category = sanitize_inlist(href_list["category"], labor_console_categories, labor_console_categories[1]) //hey isn't it funny how lists start at 1

		else if(href_list["free"])
			if(!is_valid_job(href_list["free"]))
				to_chat(usr,"<span class='warning'>That's odd. You could've sworn the [href_list["free"]] button was there just a second ago!")
				return
			if(job_master.GetJob(href_list["free"]))
				freeing = href_list["free"]

		else if(href_list["priority"])
			if(!is_valid_job(href_list["priority"]))
				to_chat(usr,"<span class='warning'>That's odd. You could've sworn the [href_list["priority"]] button was there just a second ago!")
				return
			if(job_master.GetJob(href_list["priority"]))
				toggling_priority = href_list["priority"]

		else if(href_list["cancel"])
			cancel_swipe()

		add_fingerprint(usr)
		updateUsrDialog()

/obj/machinery/computer/labor/proc/is_valid_job(title)
	for(var/cat in labor_console_categories)
		for(var/job_string in labor_console_categories[cat])
			var/datum/job/job_datum = job_master.GetJob(job_string)
			if(job_datum && job_datum.title == title)
				return TRUE
	return FALSE
