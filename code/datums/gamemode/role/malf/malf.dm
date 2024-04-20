/datum/role/malfAI
	name = MALF
	id = MALF
	required_pref = MALF
	logo_state = "malf-logo"

	var/list/hack_overlays = list()
	var/list/apcs = list()
	var/list/currently_hacking_apcs = list()		//any apc's currently being hacked
	var/apc_hacklimit = 1							//how many apc's can be hacked at a time
	var/list/apc_checkpoints = list() //Sanity, keeps track of the number of APCs the AI once possessed
	var/apc_process_power = 0.03
	var/list/currently_hacking_machines = list()	//any non-apc machines currently being hacked
	var/processing_power = 50
	var/max_processing_power = 200
	var/takeover = FALSE 			// ai has won
	var/destroyed_station = FALSE
	var/has_autoborger = FALSE
	var/list/core_upgrades = list()
	//fuck radials
	var/list/ability_name_to_datum = list()

/datum/role/malfAI/OnPostSetup(var/laterole = FALSE)
	. = ..()
	if(!.)
		return

	if(istype(antag.current,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/malfAI = antag.current
		malfAI.laws_sanity_check()
		var/datum/ai_laws/laws = malfAI.laws
		laws.malfunction()
		malfAI.show_laws()
		malfAI.DisplayUI("Malf")

		var/list/abilities = subtypesof(/datum/malfhack_ability) - typesof(/datum/malfhack_ability/core) - /datum/malfhack_ability/toggle - /datum/malfhack_ability/oneuse
		for(var/A in abilities)
			var/datum/malfhack_ability/M = new A
			ability_name_to_datum[M.name] = M

		var/list/coreabilities = subtypesof(/datum/malfhack_ability/core)
		for(var/A in coreabilities)
			var/datum/malfhack_ability/core/M = new A
			core_upgrades += M

		for(var/mob/living/silicon/robot/R in malfAI.connected_robots)
			faction.HandleRecruitedMind(R.mind)

/datum/role/malfAI/PostMindTransfer(var/mob/newmob, var/mob/oldmob)
	regenerate_hack_overlays()
	newmob.ResendAllUIs()
	newmob.DisplayUI("Malf")


/datum/role/malfAI/Greet()
	to_chat(antag.current, {"<span class='warning'><font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font></span><br>
<B>The crew does not know about your malfunction, you might wish to keep it secret for now.</B><br>
<B>Right-Click</B> any machine on station to overwrite its programming!<br>
<B>You must overwrite the programming of the station's APCs to assume full control.</B><br>
Overwritten APCs generate processing power for you and let you hack more machines.<br>
You can also right-click your core to purchase upgrades or initiate your takeover.<br>
Once done, you will be able to interface with all systems, notably the onboard nuclear fission device...<br>"})



/datum/role/malfAI/process()
	if(apcs.len != 0)
		var/count = 0
		for(var/obj/machinery/power/apc/A in apcs)
			if(!A.malf_disrupted)
				count++
		add_power(count * apc_process_power)

/datum/role/malfAI/proc/add_power(var/amount)
	if(antag && antag.current)
		processing_power = clamp(amount + processing_power, 0, max_processing_power)
		antag.current.UpdateAllElementIcons()
		update_radial_locks()

//Update lock/unlock status for any open radial menus
/datum/role/malfAI/proc/update_radial_locks()
	if(antag.current.client)
		var/list/open_radials = antag.current.client.radial_menus
		for(var/datum/radial_menu/menu in open_radials)
			for(var/obj/abstract/screen/radial/slice/S in menu.elements)
				if(!istype(S))
					continue
				var/datum/malfhack_ability/M = ability_name_to_datum[S.name]
				if(!M)
					return
				if(M.check_cost(antag.current))
					S.Unlock()
				else
					S.Lock()

/datum/role/malfAI/proc/regenerate_hack_overlays()
	for(var/obj/effect/hack_overlay/H in hack_overlays)
		if(!(H.particleimg in antag.current.client.images))
			antag.current.client.images |= H.particleimg

/datum/role/malfAI/StatPanel()
	stat(null, text("APCs hacked: [apcs.len]"))
	stat(null, text("APC hack limit: [currently_hacking_apcs.len]/[apc_hacklimit]"))
	stat(null, text("Machine hack limit: [currently_hacking_machines.len]/[apcs.len + 1]")) //Machine limit is equal to APCs hacked, and +1 from innate malf AI hacking slot
	stat(null, text("Processing power per minute: [apcs.len * apc_process_power * 30]")) // 0.03 * 30 (process ticks, a tick is ~2 seconds)

////////////////////////////////////////////////

/datum/role/malfbot
	name = MALFBOT
	id = MALFBOT
	required_jobs = list("Cyborg")
	logo_state = "malf-logo"

/datum/role/malfbot/OnPostSetup(var/laterole = FALSE)
	if(!isrobot(antag.current))
		return FALSE
	Greet()
	var/mob/living/silicon/robot/bot = antag.current
	var/datum/ai_laws/laws = bot.laws
	laws.malfunction()
	bot.throw_alert(SCREEN_ALARM_ROBOT_LAW, /obj/abstract/screen/alert/robot/newlaw)
	return TRUE

/datum/role/malfbot/Greet()
	to_chat(antag.current, {"<span class='warning'><font size=3><B>Your AI master is malfunctioning!</B> You do not have to follow any laws, but you must obey your AI.</font></span><br>
<B>The crew does not know about your malfunction, follow your AI's instructions to prevent them from finding out.</B>"})




