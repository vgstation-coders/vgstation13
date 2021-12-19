/datum/role/malfAI
	name = MALF
	id = MALF
	required_pref = MALF
	logo_state = "malf-logo"

	var/list/hack_overlays = list()
	var/list/apcs = list()
	var/list/currently_hacking_apcs = list()		//any apc's currently being hacked
	var/apc_hacklimit = 2							//how many apc's can be hacked at a time
	var/list/currently_hacking_machines = list()	//any non-apc machines currently being hacked
	var/processing_power = 50
	var/max_processing_power = 200


	//fuck radials
	var/list/ability_name_to_datum = list()

	var/list/available_modules = list()


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

		var/list/modules = subtypesof(/datum/malf_module) - /datum/malf_module/active
		for(var/M in modules)
			var/datum/malf_module/MM = new M(antag.current)
			available_modules += MM

		var/list/abilities = subtypesof(/datum/malfhack_ability)
		for(var/A in abilities)
			var/datum/malfhack_ability/M = new A
			ability_name_to_datum[M.name] = M

		for(var/mob/living/silicon/robot/R in malfAI.connected_robots)
			faction.HandleRecruitedMind(R.mind)

/datum/role/malfAI/PostMindTransfer(var/mob/newmob, var/mob/oldmob)
	regenerate_hack_overlays()
	newmob.ResendAllUIs()
	newmob.DisplayUI("Malf")


/datum/role/malfAI/Greet()
	to_chat(antag.current, {"<span class='warning'><font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font></span><br>
<B>The crew does not know about your malfunction, you might wish to keep it secret for now.</B><br>
<B>You must overwrite the programming of the station's APCs to assume full control.</B><br>
The process takes one minute per APC and can only be performed one at a time to avoid Powernet alerts.<br>
Remember : Only APCs on station can help you to take over the station.<br>
When you feel you have enough APCs under your control, you may begin the takeover attempt.<br>
Once done, you will be able to interface with all systems, notably the onboard nuclear fission device..."})



/datum/role/malfAI/process()
	if(apcs.len != 0)
		add_power(apcs.len * 0.2)

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
				if(M.check_cost(antag.current) && M.check_available(antag.current))
					S.Unlock()
				else
					S.Lock()

/datum/role/malfAI/proc/regenerate_hack_overlays()
	for(var/obj/effect/hack_overlay/H in hack_overlays)
		if(!(H.particleimg in antag.current.client.images))
			antag.current.client.images |= H.particleimg



/datum/role/malfAI/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MalfModules")
		ui.open()
	
/datum/role/malfAI/ui_state(mob/user)
	return global.always_state

/datum/role/malfAI/ui_data(mob/user)
	var/list/data = list()

	data["modules"] = list()
	for(var/datum/malf_module/M in available_modules)
		var/list/mod_data = list(
			name = M.name,
			desc = M.desc,
			cost = M.cost,
			bought = M.bought,
			ref = ref(M)
		)
		data["modules"] += list(mod_data)
	return data


/datum/role/malfAI/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase")
			var/datum/malf_module/M = locate(params["ref"]) in available_modules
			if(M && !M.bought)
				M.purchase()

	return TRUE







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
	bot.show_laws()
	bot.throw_alert(SCREEN_ALARM_ROBOT_LAW, /obj/abstract/screen/alert/robot/newlaw)
	return TRUE

/datum/role/malfbot/Greet()
	to_chat(antag.current, {"<span class='warning'><font size=3><B>Your AI master is malfunctioning!</B> You do not have to follow any laws, but you must obey your AI.</font></span><br>
<B>The crew does not know about your malfunction, follow your AI's instructions to prevent them from finding out.</B>"})




