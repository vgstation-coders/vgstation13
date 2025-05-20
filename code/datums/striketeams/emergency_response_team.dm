//ERT

var/list/response_team_members = list()

/datum/striketeam/ert
	striketeam_name = TEAM_ERT
	faction_name = "Nanotrasen"
	mission = "Ensure the station's return to working order, or organize its evacuation if judged necessary."
	team_size = 6
	min_size_for_leader = 0//set to 0 so there's always a designated team leader or to -1 so there is no leader.
	spawns_name = "ERT"
	can_customize = TRUE
	logo = "ert-logo"
	outfit_datum = /datum/outfit/striketeam/ert

/datum/striketeam/ert/failure()
	command_alert(/datum/command_alert/ert_fail)
	if(antag_madness != ANTAG_MADNESS_OFF)
		var/datum/faction/nanotrasen/nanotrasen = find_active_faction_by_type(/datum/faction/nanotrasen)
		if (!nanotrasen)
			nanotrasen = ticker.mode.CreateFaction(/datum/faction/nanotrasen, null, 1)
		nanotrasen.delta = 2
		//latejoin traitors now know that antag madness is underway
		//latejoin heads are told "best of luck!"

/datum/striketeam/ert/extras()
	command_alert(/datum/command_alert/ert_success)
	if(antag_madness != ANTAG_MADNESS_OFF)
		var/datum/faction/nanotrasen/nanotrasen = find_active_faction_by_type(/datum/faction/nanotrasen)
		if (!nanotrasen)
			nanotrasen = ticker.mode.CreateFaction(/datum/faction/nanotrasen, null, 1)
		nanotrasen.delta = 1
		//latejoin traitors now know that antag madness is underway
		//latejoin heads are told to try and find the ERT

/datum/striketeam/ert/greet_commando(var/mob/living/carbon/human/H)
	if(H.key == leader_key)
		to_chat(H, "<span class='danger'>You are [H.real_name], the Commander of the Emergency Response Team. You answer only to Central Command and are expected to follow Space Law. Assist your assigned station to the best of your abilities.</span>")
	else
		to_chat(H, "<span class='danger'>You are [H.real_name], an Emergency Responder. You answer only to Central Command and are expected to follow Space Law. Assist your assigned station to the best of your abilities.</span>")
	for (var/role in H.mind.antag_roles)
		var/datum/role/R = H.mind.antag_roles[role]
		R.AnnounceObjectives()

/datum/striketeam/ert/create_commando(obj/spawn_location, leader_selected = 0, key = "")
	var/mob/living/carbon/human/M = new(spawn_location)

	var/obj/machinery/ert_cryo_cell/spawner = locate() in get_step(spawn_location,NORTH)

	if(spawner)
		spawner.occupant = M
		M.forceMove(spawner)
		spawner.update_icon()

	response_team_members |= M

	var/mob/user = null
	for(var/mob/MO in player_list)
		if(MO.key == key)
			user = MO

	if (spawner)
		user.forceMove(spawner.loc)
	else
		user.forceMove(spawn_location.loc)

	to_chat(user, "<span class='notice'>Congratulations, you've been selected to be part of an ERT. You can customize your character, but don't take too long, time is of the essence!</span>")
	user << 'sound/music/ERT.ogg'

	var/commando_name = copytext(sanitize(input(user, "Pick a name","Name") as null|text), 1, 2*MAX_NAME_LEN)
	M.real_name = commando_name
	M.name = commando_name
	M.age = !leader_selected ? rand(23,35) : rand(35,45)
	M.pick_gender(user)
	M.pick_appearance(user)
	M.dna.ready_dna(M)//Creates DNA.

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"

	var/datum/faction/ert = find_active_faction_by_type(/datum/faction/strike_team/ert)
	if(ert)
		ert.HandleRecruitedMind(M.mind)
	else
		ert = ticker.mode.CreateFaction(/datum/faction/strike_team/ert)
		ert.forgeObjectives(mission)
		if(ert)
			ert.HandleNewMind(M.mind) //First come, first served

	var/datum/outfit/striketeam/concrete_outfit = new outfit_datum
	if (leader_selected)
		concrete_outfit.is_leader = TRUE
	concrete_outfit.equip(M)

	if(spawner)
		spawner.occupant = null
		spawner.update_icon()

	M.forceMove(spawn_location.loc)

	return M

//stealing that sweet bobbing animation from cryo.dm
/obj/machinery/ert_cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod0"
	density = 1
	anchored = 1.0
	layer = ABOVE_WINDOW_LAYER
	plane = OBJ_PLANE
	light_color = LIGHT_COLOR_HALOGEN
	light_range_on = 1
	light_power_on = 2
	use_auto_lights = 1
	machine_flags = null
	var/mob/living/carbon/occupant = null
	var/running_bob_animation = 0

/obj/machinery/ert_cryo_cell/examine(mob/user)
	..()
	if(Adjacent(user))
		if(occupant)
			to_chat(user, "A figure floats in the depths, they appear to be [occupant.real_name]")
		else
			to_chat(user, "<span class='info'>The chamber appears devoid of anything but its biotic fluids.</span>")
	else
		to_chat(user, "<span class='notice'>Too far away to view contents.</span>")


/obj/machinery/ert_cryo_cell/update_icon()
	overlays.len = 0

	if(!occupant)
		overlays += "lid0"
		return

	if(occupant)
		var/image/pickle = image(occupant.icon, occupant.icon_state)
		pickle.overlays = occupant.overlays
		pickle.pixel_y = 20

		overlays += pickle
		overlays += "lid1"
		if(!running_bob_animation)
			var/up = 0
			spawn()
				running_bob_animation = 1
				while(occupant)
					overlays.len = 0

					switch(pickle.pixel_y)
						if(21)
							switch(up)
								if(2)
									pickle.pixel_y = 22

								if(1)
									pickle.pixel_y = 20
						if(20)
							pickle.pixel_y = 21
							up = 2
						if(22)
							pickle.pixel_y = 21
							up = 1

					pickle.overlays = occupant.overlays
					overlays += pickle
					overlays += "lid1"
					sleep(7)
				running_bob_animation = 0
