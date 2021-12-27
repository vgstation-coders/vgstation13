/spell/changeling/split
	name = "Split (50)"
	desc = "Split your body into two lifeforms."
	abbreviation = "SP"
	hud_state = "split"
	cooldown_min = 30 SECONDS
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"
	chemcost = 50
	required_dna = 1
	max_genedamage = 0
	horrorallowed = 0
	var/success = FALSE
	var/datum/mind/owner = null // The mind of the user, to be used by the recruiter
	var/datum/recruiter/recruiter = null
	var/polling_ghosts = FALSE
	
/spell/changeling/split/cast(var/list/targets, var/mob/living/carbon/human/user)
	owner = user.mind
	var/datum/role/changeling/changeling = owner.GetRole(CHANGELING)
	if (changeling.splitcount < 3)
		user.visible_message("You are preparing to generate a new form.")
		Splitting()
		changeling.geneticdamage = 30
		if (success)
			changeling.splitcount += 1
			user.visible_message("<span class='danger'>[user] splits!</span>")
			playsound(user, 'sound/effects/flesh_squelch.ogg', 30, 1)
			success = FALSE
	else
		user.visible_message("You are unable to split again.")
	owner = null

/spell/changeling/split/proc/Splitting()
	if(polling_ghosts)
		return
	polling_ghosts = TRUE
	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "Changeling"
		recruiter.jobban_roles = list("Syndicate")
		recruiter.recruitment_timeout = 30 SECONDS
	// Role set to Yes or Always
	recruiter.player_volunteering = new /callback(src, .proc/recruiter_recruiting)
	// Role set to No or Never
	recruiter.player_not_volunteering = new /callback(src, .proc/recruiter_not_recruiting)

	recruiter.recruited = new /callback(src, .proc/recruiter_recruited)
	recruiter.request_player()
	recruiter.Destroy()

/spell/changeling/split/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A changeling is splitting. You have been added to the list of potential ghosts. ([controls])</span>")

/spell/changeling/split/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A changeling is splitting. ([controls])</span>")

/spell/changeling/split/proc/recruiter_recruited(mob/dead/observer/player)
	if(!player)
		polling_ghosts = FALSE
		nanomanager.update_uis(src)
		return
	var/turf/this_turf = get_turf(src)
	var/mob/living/carbon/human/newbody = new(this_turf)
	var/datum/role/changeling/newChangeling = new
	newbody.ckey = player.ckey
	
	var/datum/role/changeling/changeling = owner.GetRole(CHANGELING)
	if(!changeling)
		return 0
	var/datum/dna/split_dna = changeling.GetDNA(owner)
	if(!split_dna)
		return 0

	var/oldspecies = newbody.dna.species
	newbody.dna = split_dna.Clone()
	newbody.real_name = split_dna.real_name
	newbody.flavor_text = split_dna.flavor_text
	newbody.UpdateAppearance()
	if(oldspecies != newbody.dna.species)
		newbody.set_species(newbody.dna.species, 0)
	domutcheck(newbody, null)
	feedback_add_details("changeling_powers","TR")	//no idea what this does
	//activate(player)
	newChangeling.AssignToRole(player.mind,1)
	newChangeling.geneticdamage = 30
	
	//Assign to the hivemind faction
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		hivemind = ticker.mode.CreateFaction(/datum/faction/changeling)
		hivemind.OnPostSetup()
	hivemind?.HandleRecruitedRole(newChangeling)
	newChangeling.ForgeObjectives()
	newChangeling.Greet(GREET_DEFAULT)
	
	success = TRUE
	player.regenerate_icons()
	player.updateChangelingHUD()
	update_faction_icons()
	nanomanager.close_uis(src)
	qdel(src)


