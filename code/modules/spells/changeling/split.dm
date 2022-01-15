/spell/changeling/split
	name = "Split (50)"
	desc = "Split your body into two lifeforms."
	abbreviation = "SP"
	hud_state = "split"
	charge_max = 300
	cooldown_min = 30 SECONDS
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"
	chemcost = 50
	required_dna = 1
	max_genedamage = 0
	horrorallowed = 0
	var/datum/mind/owner = null // The mind of the user, to be used by the recruiter
	var/datum/recruiter/recruiter = null
	var/polling_ghosts = FALSE
	
/spell/changeling/split/Destroy()
	owner = null
	//qdel(recruiter)
	recruiter = null
	..()
	
/spell/changeling/split/cast(var/list/targets, var/mob/living/carbon/human/user)
	owner = user.mind
	var/datum/role/changeling/changeling = owner.GetRole(CHANGELING)
	if (changeling.splitcount < 2 && !issilicon(user)) //<2 is two splits max
		user.visible_message("[user] is preparing to generate a new form.")
		Splitting()
	else
		user.visible_message("You are unable to split again.")
	return

/spell/changeling/split/proc/Splitting()
	if(polling_ghosts)
		return
	polling_ghosts = TRUE
	if(!recruiter)
		recruiter = new(owner.current)
		recruiter.display_name = "Changeling"
		recruiter.jobban_roles = list("Syndicate")
		recruiter.recruitment_timeout = 30 SECONDS
	// Role set to Yes or Always
	recruiter.player_volunteering = new /callback(src, .proc/recruiter_recruiting)
	// Role set to No or Never
	recruiter.player_not_volunteering = new /callback(src, .proc/recruiter_not_recruiting)

	recruiter.recruited = new /callback(src, .proc/recruiter_recruited)
	recruiter.request_player()

/spell/changeling/split/proc/checkSplit(var/success)
	var/datum/role/changeling/changeling = owner.GetRole(CHANGELING)
	if (success)
		changeling.splitcount += 1
		changeling.absorbedcount = max(0,changeling.absorbedcount-1)
		(owner.current).visible_message("<span class='danger'>[(owner.current)] splits!</span>")
		playsound(owner.current, 'sound/effects/flesh_squelch.ogg', 30, 1)
	else
		(owner.current).visible_message("[(owner.current)] was unable to split at this time.")

/spell/changeling/split/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\ A changeling is splitting. You have been added to the list of potential ghosts. ([controls])</span>")

/spell/changeling/split/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\ A changeling is splitting. ([controls])</span>")

/spell/changeling/split/proc/recruiter_recruited(mob/dead/observer/player)
	if(!player)
		checkSplit(FALSE) 
		polling_ghosts = FALSE
		nanomanager.update_uis(src)
		return
	var/turf/this_turf = get_turf(owner.current.loc)
	var/mob/living/carbon/human/newbody = new(this_turf)
	
	newbody.ckey = player.ckey
	var/oldspecies = newbody.dna.species
	newbody.dna = owner.current.dna.Clone()
	newbody.real_name = owner.current.real_name
	newbody.name = owner.current.name
	newbody.flavor_text = owner.current.flavor_text
	newbody.mind.memory = owner.memory
	newbody.UpdateAppearance()
	if(oldspecies != newbody.dna.species)
		newbody.set_species(newbody.dna.species, 0)
	domutcheck(newbody, null)
	
	var/datum/role/changeling/newChangeling = new(newbody.mind)
	newChangeling.OnPostSetup()
	newChangeling.geneticdamage = 50

	//Assign to the hivemind faction
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	if(!hivemind)
		hivemind = ticker.mode.CreateFaction(/datum/faction/changeling)
		hivemind.OnPostSetup()
	checkSplit(TRUE) //handles counting splits
	hivemind?.HandleRecruitedRole(newChangeling)
	newChangeling.ForgeObjectives()
	newChangeling.Greet(GREET_DEFAULT)
	
	newbody.updateChangelingHUD()
	newbody.regenerate_icons()
	update_faction_icons()
	nanomanager.close_uis(src)
	feedback_add_details("changeling_powers","SP")
	recruiter.Destroy()


