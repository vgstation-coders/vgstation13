//CULT 4.0 BY DEITY LINK (2021)
//BASED ON CULT 3.0 ALSO BY DEITY LINK (2018)
//BASED ON THE ORIGINAL GAME MODE BY URIST MCDORF (somewhere before 2013)


/datum/faction/bloodcult
	name = "Cult of Nar-Sie"
	ID = BLOODCULT
	initial_role = CULTIST
	late_role = CULTIST
	desc = "A group of shady blood-obsessed individuals whose souls are devoted to Nar-Sie, the Geometer of Blood.\
	From his teachings, they were granted the ability to perform blood magic rituals allowing them to grow their ranks and cause chaos.\
	Nar-Sie's goal is to toy with the crew, before tearing open a breach through reality so he can pull the station into his realm and feast on the crew's blood."
	initroletype = /datum/role/cultist
	roletype = /datum/role/cultist
	logo_state = "cult-logo"
	hud_icons = list("cult-apprentice-logo", "cult-logo", "cult-master-logo", "shade-blade")
	default_admin_voice = "<span class='danger'>Nar-Sie</span>" // Nar-Sie's name always appear in red in the chat, makes it stand out.
	admin_voice_style = "sinister"
	admin_voice_say = "murmurs..."
	var/list/bloody_floors = list()
	var/cult_win = FALSE

	var/list/cult_reminders = list()

	var/list/bindings = list()

	var/list/cultist_cap = 1	//clamped between 5 and 9 depending on crew size. once the cap goes up it cannot go down.

	var/mentor_count = 0 	//so we don't loop through the member list if we already know there are no mentors in there

	var/list/arch_cultists = list()
	var/list/departments_left = list("Security", "Medical", "Engineering", "Science", "Cargo")

	var/mob/living/sacrifice_target = null
	var/datum/mind/sacrifice_mind = null
	var/target_sacrificed = FALSE



/datum/faction/bloodcult/check_win()
	if(stage <= FACTION_DEFEATED)
		return FALSE
	if(stage < FACTION_ENDGAME)
		if(departments_left.len < 5)
			stage(FACTION_ENDGAME)
			//command_alert(/datum/command_alert/cult_eclipse_start)
			return FALSE
	if(stage == FACTION_ENDGAME)
		if(departments_left.len == 0)
			stage(FACTION_VICTORY)
			cult_win = TRUE
			return TRUE

/datum/faction/bloodcult/IsSuccessful()
	return cult_win


/datum/faction/bloodcult/GetScoreboard()
	. = ..()
	. += "<BR>Total Veil Weakness:[veil_weakness]<BR>"


/datum/faction/bloodcult/process()
	..()
	if (cultist_cap > 1) //The first call occurs in OnPostSetup()
		UpdateCap()

#define HUDICON_BLINKDURATION 10
/datum/faction/bloodcult/update_hud_icons(var/offset = 0,var/factions_with_icons = 0)
	..()
	for(var/mob/living/simple_animal/astral_projection/AP in astral_projections)
		for(var/datum/role/R_target in members)
			if(R_target.antag && R_target.antag.current)
				var/imageloc = R_target.antag.current
				if(istype(R_target.antag.current.loc,/obj/mecha))
					imageloc = R_target.antag.current.loc
				var/hud_icon = R_target.logo_state//the icon is based on the member's role
				if (!(R_target.logo_state in hud_icons))
					hud_icon = hud_icons[1]//if the faction doesn't recognize the role, it'll just give it a default one.
				var/image/I = image('icons/role_HUD_icons.dmi', loc = imageloc, icon_state = hud_icon)
				I.pixel_x = 20 * PIXEL_MULTIPLIER
				I.pixel_y = 20 * PIXEL_MULTIPLIER
				I.plane = ANTAG_HUD_PLANE
				I.appearance_flags |= RESET_COLOR|RESET_ALPHA
				if (factions_with_icons > 1)
					animate(I, layer = 1, time = 0.1 + offset * HUDICON_BLINKDURATION, loop = -1)
					animate(layer = 0, time = 0.1)
					animate(layer = 0, time = HUDICON_BLINKDURATION)
					animate(layer = 1, time = 0.1)
					animate(layer = 1, time = 0.1 + HUDICON_BLINKDURATION*(factions_with_icons - 1 - offset))
				if (AP.client)
					AP.client.images += I
				if (R_target.antag.current.client)
					R_target.antag.current.client.images += AP.hudicon
		for(var/mob/living/simple_animal/astral_projection/PA in astral_projections)
			if (AP.client)
				AP.client.images += PA.hudicon
			if ((AP != PA) && PA.client)
				PA.client.images += AP.hudicon

#undef HUDICON_BLINKDURATION


/datum/faction/bloodcult/proc/UpdateCap()
	var/living_players = 0
	var/new_cap = 0
	for (var/mob/M in player_list)
		if (!M.client)
			continue
		if (istype(M,/mob/new_player))
			continue
		if (M.stat != DEAD)
			living_players++
	new_cap =  clamp(round(living_players / 3),5,9)
	if (new_cap > cultist_cap)
		cultist_cap = new_cap
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			to_chat(M, "<span class='sinister'>The station population is now large enough for <span class='userdanger'>[cultist_cap]</span> cultists.</span>")

/datum/faction/bloodcult/proc/CanConvert()
	var/cultist_count = 0
	for (var/datum/role/R in members)
		var/mob/M = R.antag.current
		if (isliving(M)) //humans, shades and constructs all count. The dead count for half a member (unless they have no body left).
			if (M.isDead())
				cultist_count += 0.5
			else
				cultist_count += 1

	return (cultist_count < cultist_cap)

/datum/faction/bloodcult/HandleRecruitedRole(var/datum/role/R)
	. = ..()
	if (cult_reminders.len)
		to_chat(R.antag.current, "<span class='notice'>Other cultists have shared some of their knowledge. It will be stored in your memory (check your Notes under the IC tab).</span>")
	for (var/reminder in cult_reminders)
		R.antag.store_memory("Shared Cultist Knowledge: [reminder].")

/datum/faction/bloodcult/AdminPanelEntry(var/datum/admins/A)
	var/list/dat = ..()

	dat += "<br>"
	dat += "<a href='?src=\ref[src];unlockRitual=1'>\[Unlock Ritual\]</A><br>"
	dat += "<br>"

	return dat

/datum/faction/bloodcult/Topic(href, href_list)
	..()

	if(!usr.check_rights(R_ADMIN))
		message_admins("[usr] tried to access bloodcult faction Topic() without permissions.")
		return

	if(href_list["unlockRitual"])
		var/datum/bloodcult_ritual/R = input(usr,"Select a ritual to unlock.", "Unlock", null) as null|anything in locked_rituals
		if(R)
			R.Unlock(TRUE)


/datum/faction/bloodcult/HandleNewMind(var/datum/mind/M)
	. = ..()
	M.special_role = "Cultist"

/datum/faction/bloodcult/OnPostSetup()
	initialize_rune_words()
	AppendObjective(/datum/objective/bloodcult)
	initialize_rituals()
	for (var/datum/role/R in members)
		var/mob/M = R.antag.current
		to_chat(M, "<span class='sinister'>Our communion must remain small and secretive.</span>")
	UpdateCap()
	if (cultist_cap < 9)
		for (var/datum/role/R in members)
			var/mob/M = R.antag.current
			to_chat(M, "<span class='sinister'>This number might rise up to 9 as more people arrive aboard the station.</span>")
	AnnounceObjectives()
	..()


/datum/faction/bloodcult/proc/add_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	if(T && (T.z == map.zMainStation))//F I V E   T I L E S
		if(!(locate("\ref[T]") in bloody_floors))
			bloody_floors[T] = T
			for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
				B.update_icon()
			TriggerCultRitual(/datum/bloodcult_ritual/spill_blood)


/datum/faction/bloodcult/proc/remove_bloody_floor(var/turf/T)
	if (!istype(T))
		return
	for (var/obj/structure/cult/bloodstone/B in bloodstone_list)
		B.update_icon()
	bloody_floors -= T


/datum/faction/bloodcult/proc/FindSacrificeTarget()
	var/list/possible_targets = list()
	var/list/backup_targets = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(iscultist(player))
			continue
		//They may be dead, but we only need their flesh
		var/turf/player_turf = get_turf(player)
		if(player_turf.z != map.zMainStation)//We only look for people currently aboard the station
			continue
		var/is_implanted = player.is_loyalty_implanted()
		if(is_implanted || isReligiousLeader(player))
			possible_targets += player
		else
			backup_targets += player

	if(possible_targets.len <= 0) // If there are only non-implanted players left on the station, we'll have to sacrifice one of them
		if (backup_targets.len <= 0)
			message_admins("Blood Cult: Could not find a suitable sacrifice target.")
			log_admin("Blood Cult: Could not find a suitable sacrifice target.")
			return null
		else
			sacrifice_target = pick(backup_targets)
	else
		sacrifice_target = pick(possible_targets)
	return sacrifice_target