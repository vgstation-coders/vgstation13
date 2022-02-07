/spell/changeling/split
	name = "Split (40)"
	desc = "Split your body into two lifeforms."
	abbreviation = "SP"
	hud_state = "split"
	charge_max = 300
	cooldown_min = 30 SECONDS
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"
	chemcost = 40
	required_dna = 2
	max_genedamage = 0
	horrorallowed = 0
	var/datum/mind/owner // The mind of the user, to be used by the recruiter
	var/datum/recruiter/recruiter = null
	var/polling_ghosts = FALSE

/spell/changeling/split/cast(var/list/targets, var/mob/living/carbon/human/user)
	owner = user.mind
	var/datum/role/changeling/changeling = owner.GetRole(CHANGELING)
	if (changeling.splitcount < 2) //two splits max
		user.visible_message("[user] is preparing to generate a new form.")
		Splitting()
	else
		user.visible_message("You are unable to split again.")

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
		(owner.current).visible_message("<span class='danger'>[(owner.current)] splits!</span>")
		playsound(owner.current, 'sound/effects/flesh_squelch.ogg', 30, 1)
	else
		(owner.current).visible_message("[(owner.current)] was unable to split at this time.")
		changeling.chem_charges = max(40, changeling.chem_charges)

/spell/changeling/split/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\ A changeling is splitting. You have been added to the list of potential ghosts. ([controls])</span>")

/spell/changeling/split/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\ A changeling is splitting. ([controls])</span>")

/spell/changeling/split/proc/recruiter_recruited(mob/dead/observer/player)
	if(!player)
		checkSplit(FALSE) 
		polling_ghosts = FALSE
		qdel(recruiter)
		return FALSE
		
	var/turf/this_turf = get_turf(owner.current.loc)
	var/mob/living/carbon/human/newbody = new(this_turf)
	var/datum/role/changeling/newChangeling = new(newbody.mind)

	polling_ghosts = FALSE
	newbody.ckey = player.ckey
	newbody.dna = owner.current.dna.Clone()
	newbody.set_species(newbody.dna.species, 0)
	newbody.real_name = owner.current.real_name
	newbody.name = owner.current.name
	newbody.flavor_text = owner.current.flavor_text
	newbody.mind.memory = owner.memory
	newbody.UpdateAppearance()

	domutcheck(newbody, null)
	
	newChangeling.OnPostSetup()
	newChangeling.geneticdamage = 50

	//Assign to the hivemind faction
	var/datum/faction/changeling/hivemind = find_active_faction_by_type(/datum/faction/changeling)
	hivemind.HandleRecruitedRole(newChangeling)
	newChangeling.ForgeObjectives()
	newChangeling.Greet(GREET_DEFAULT)
	
	checkSplit(TRUE) //handles counting splits
	update_faction_icons()

	feedback_add_details("changeling_powers","SP")
	qdel(recruiter)


