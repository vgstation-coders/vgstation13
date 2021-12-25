/spell/changeling/split
	name = "Split (5)"
	desc = "Split your body into two lifeforms."
	abbreviation = "SP"
	hud_state = "split"

	chemcost = 5
	required_dna = 1
	max_genedamage = 0
	horrorallowed = 0
	
/spell/changeling/split/cast(mob/user)
	if(polling_ghosts)
		return
	owner = user.mind
	polling_ghosts = TRUE
	visible_message("\You begin to generate a new form.")
	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = name
		recruiter.jobban_roles = list("Changeling")
		recruiter.recruitment_timeout = 30 SECONDS
	// Role set to Yes or Always
	recruiter.player_volunteering = new /callback(src, .proc/recruiter_recruiting)
	// Role set to No or Never
	recruiter.player_not_volunteering = new /callback(src, .proc/recruiter_not_recruiting)

	recruiter.recruited = new /callback(src, .proc/recruiter_recruited)
	recruiter.request_player()

	changeling.geneticdamage = 30

	..()

/spell/changeling/split/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A [src] is looking for candidates. You have been added to the list of potential ghosts. ([controls])</span>")

/spell/changeling/split/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A [src] is looking for candidates. ([controls])</span>")

/spell/changeling/split/proc/recruiter_recruited(mob/user, mob/dead/observer/player)
	if(!player)
		chosen_setup = null
		polling_ghosts = FALSE
		visible_message("<span class='notice'>\You stop generating your new form.</span>")
		nanomanager.update_uis(src)
		return
		
	var/turf/this_turf = get_turf(src)
	var/mob/living/carbon/human/newChangeling = new(this_turf)
	newChangeling.set_species(user,1)
	newChangeling.ckey = player.ckey
	
	//Assign to the hivemind faction
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		hivemind = ticker.mode.CreateFaction(/datum/faction/changeling)
		hivemind.OnPostSetup()
	hivemind?.HandleRecruitedRole(newChangeling)

	newChangeling.ForgeObjectives()
	newChangeling.Greet(GREET_DEFAULT)
	user.visible_message("<span class='danger'>[user] splits!</span>")
	user.regenerate_icons()
	user.updateChangelingHUD()
	update_faction_icons()
	nanomanager.close_uis(src)
	update_icon()
	
	return 1
