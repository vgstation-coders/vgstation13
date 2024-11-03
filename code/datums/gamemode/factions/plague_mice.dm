
/datum/faction/plague_mice
	name = PLAGUEMICE
	ID = PLAGUEMICE
	logo_state = "plague-logo"
	hud_icons = list("plague-logo")

	initroletype = /datum/role/plague_mouse
	initial_role = PLAGUEMOUSE

	roletype = /datum/role/plague_mouse
	late_role = PLAGUEMOUSE
	default_admin_voice = "Big Rat"
	admin_voice_style = "skeleton" // grey, bold and italic

	var/diseaseID = ""
	var/datum/disease2/disease/bacteria/plague
	var/turf/invasion


/datum/faction/plague_mice/New()
	..()
	SetupDisease()
	forgeObjectives()

/datum/faction/plague_mice/HandleRecruitedRole(var/datum/role/R)
	. = ..()
	if (!plague)
		SetupDisease()
	var/mob/living/simple_animal/mouse/plague/M = R.antag.current
	M.infect_disease2(plague,1, "Plague Mice")

	/* With the disease set-up, store the detials of the disease in the mouse's memory */
	var/datum/mind/mouse_mind = R.antag
	mouse_mind.store_memory(plague.get_info(TRUE), forced = 1)
	mouse_mind.store_memory("<hr>", forced = 1)
	var/dat = "<span class='notice'>You carry a deadly plague with the following traits:</span>"
	dat += "<br><span class='notice'>Strength / Robustness:</span> <b>[plague.strength]%</b> / <b>[plague.robustness]%</b>"
	dat += "<br><span class='notice'>Infection chance:</span> <b>[plague.infectionchance]%</b>"
	dat += "<br><span class='notice'>Chance of disease progressing:</span> <b>[plague.stageprob]%</b>"
	dat += "<br><br><span class='notice'>Symptoms:</span>"
	for(var/datum/disease2/effect/e in plague.effects)
		dat += "<br><span class='notice'>Stage [e.stage] - <b>[e.name]</b>: <i>[e.desc]</span></i>"
	dat += "<br><br><span class='notice'>The complete details of the disease are available in your memories, by opening your Notes.</span>"
	spawn() //So that it shows up after the message of being a plague mouse
		to_chat(M, dat)

/datum/faction/plague_mice/OnPostSetup()
	if (!plague || !invasion)
		SetupDisease()

	if (invasion)
		for(var/datum/role/plague_mouse/M in members)
			var/datum/mind/mouse_mind = M.antag
			mouse_mind.current.forceMove(invasion)

	spawn(1 MINUTES)
		if(members.len > 0)
			command_alert("A horde of black mice carriers of a dangerous bacteria have invaded the station. It is not clear how they got onboard, but they need to be either captured into small cages or exterminated, and any contaminated individual is to cooperate with the medical staff for the preparation of a cure.", "The Black Plague is upon us!",1)


/datum/faction/plague_mice/proc/SetupDisease()
	if (!plague)
		plague = new

		var/list/anti = list(
			ANTIGEN_BLOOD	= 0,
			ANTIGEN_COMMON	= 0,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 2,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 0,
			EFFECT_DANGER_FLAVOR	= 0,
			EFFECT_DANGER_ANNOYING	= 1,
			EFFECT_DANGER_HINDRANCE	= 1,
			EFFECT_DANGER_HARMFUL	= 3,
			EFFECT_DANGER_DEADLY	= 5,
			)
		if(prob(2)) //Dan's Discount products are notoriously bad
			plague.origin = "Discount Dan's Gas Station Sushi"
		else if(Holiday == APRIL_FOOLS_DAY)
			plague.origin = pick("Nurgle's Cauldron", "Deadly Africanized Water", "Public Bathroom", "Thrax",
								"A spaceman got a mouse disease, this is what happened to his body")
		else
			plague.origin = pick("Black Plague", "Javorian Pox", "Gray Death", "Doom of Pandyssia", "Thrassian Plague",
								"Redlight", "Khaara Bacterium", "MEV-1")

		plague.spread = SPREAD_BLOOD|SPREAD_CONTACT|SPREAD_AIRBORNE //gotta ensure that our mice can spread that disease

		plague.color = "#ADAEAA"
		plague.pattern = 3
		plague.pattern_color = "#EE9A9C"
		plague.max_stage = 4 //4 stages, unlocks the really dangerous symptoms rather than just DNA Degradation
		plague.speed = 2 //Takes about 100 seconds to advance to the next stage, max stage in 5 minutes

		plague.makerandom(list(90,100),list(40,75),anti,bad,null)
		for(var/datum/disease2/effect/e in plague.effects)
			e.chance *= 2 //More likely to trigger symptoms per tick

		diseaseID = "[plague.uniqueID]-[plague.subID]"

	if (!invasion)
		var/list/found_vents = list()
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in atmos_machines)
			if(!v.welded && v.z == map.zMainStation && v.canSpawnMice==1) // No more spawning in atmos.  Assuming the mappers did their jobs, anyway.
				found_vents.Add(v)
		if(found_vents.len)
			invasion = get_turf(pick(found_vents))
		else
			var/area/kitchen = locate(/area/crew_quarters/kitchen)
			var/list/turf/simulated/floor/floors = list()
			for(var/turf/simulated/floor/F in kitchen)
				floors += F
				if(!F.has_dense_content())
					invasion = F//if by some crazy chance there's no available vent where to spawn at, let's just pick the first empty floor in the kitchen
					return
			invasion = pick(floors)//or any floor really. And if your station has no kitchen then you don't deserve those mice.

/datum/faction/plague_mice/forgeObjectives()
	if (!plague)
		SetupDisease()

	if (AppendObjective(/datum/objective/plague))
		var/datum/objective/plague/O = locate() in objective_holder.objectives
		O.diseaseID = diseaseID

/datum/faction/plague_mice/update_hud_icons(var/offset = 0,var/factions_with_icons = 0)
	//let's remove every icons
	for(var/datum/role/R in members)
		if(R.antag && R.antag.current && R.antag.current.client)
			for(var/image/I in R.antag.current.client.images)
				if(I.icon_state in hud_icons)
					R.antag.current.client.images -= I

	//then re-add them
	for(var/datum/role/R in members)
		if(R.antag && R.antag.current && R.antag.current.client && R.antag.GetRole(R.id))
			for (var/mob/living/L in mob_list)//except instead of just tracking our fellow plague mice, let's track everyone that's been infected with our plague
				if (diseaseID in L.virus2)
					var/imageloc = L
					if(istype(L.loc,/obj/mecha))
						imageloc = L.loc
					var/image/I = image('icons/role_HUD_icons.dmi', loc = imageloc, icon_state = logo_state)
					I.pixel_x = 20 * PIXEL_MULTIPLIER
					I.pixel_y = 20 * PIXEL_MULTIPLIER
					I.plane = ANTAG_HUD_PLANE
					I.appearance_flags |= RESET_COLOR|RESET_ALPHA
					R.antag.current.client.images += I
