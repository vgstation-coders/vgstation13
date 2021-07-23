/datum/role/malfAI
	name = MALF
	id = MALF
	required_pref = MALF
	logo_state = "malf-logo"

	var/list/apcs = list()
	var/list/currently_hacking_apcs = list()		//any apc's currently being hacked
	var/apc_hacklimit = 1							//how many apc's can be hacked at a time
	var/list/currently_hacking_machines = list()	//any non-apc machines currently being hacked
	var/processing_power = 0

/datum/role/malfAI/OnPostSetup(var/laterole = FALSE)
	. = ..()
	if(!.)
		return

	if(istype(antag.current,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/malfAI = antag.current
		malfAI.add_spell(new /spell/aoe_turf/module_picker, "malf_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
		malfAI.add_spell(new /spell/aoe_turf/takeover, "malf_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
		malfAI.laws_sanity_check()
		var/datum/ai_laws/laws = malfAI.laws
		laws.malfunction()
		malfAI.show_laws()
		var/datum/action/malfview/malfview_action = new()
		malfview_action.Grant(malfAI)

		for(var/mob/living/silicon/robot/R in malfAI.connected_robots)
			faction.HandleRecruitedMind(R.mind)

/datum/role/malfAI/Greet()
	to_chat(antag.current, {"<span class='warning'><font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font></span><br>
<B>The crew does not know about your malfunction, you might wish to keep it secret for now.</B><br>
<B>You must overwrite the programming of the station's APCs to assume full control.</B><br>
The process takes one minute per APC and can only be performed one at a time to avoid Powernet alerts.<br>
Remember : Only APCs on station can help you to take over the station.<br>
When you feel you have enough APCs under your control, you may begin the takeover attempt.<br>
Once done, you will be able to interface with all systems, notably the onboard nuclear fission device..."})


/datum/role/malfAI/process()
	processing_power += apcs.len



/datum/action/malfview
	name = "toggle hackermode"
	desc = "sick hacking!"
	icon_icon = 'icons/mob/screen_spells.dmi'
	button_icon_state = "hackermode"

/datum/action/malfview/Trigger()
	var/mob/living/silicon/ai/malf = owner
	if(!malf.client)
		return
	if(malf.hackermode)
		malf.hackermode = FALSE
		malf.clear_fullscreen("hackoverlay", animate = 1)
		owner.client.hackview_turf_planemaster.alpha = 0
		owner.client.hackview_structure_planemaster.alpha = 0
	else
		malf.hackermode = TRUE
		malf.overlay_fullscreen("hackoverlay", /obj/abstract/screen/fullscreen/hackview_border)
		owner.client.hackview_turf_planemaster.alpha = 255
		owner.client.hackview_structure_planemaster.alpha = 255








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
