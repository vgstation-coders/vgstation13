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
	var/datum/recruiter/recruiter
	var/polling_ghosts = FALSE
	//var/datum/mind/owner // The mind of the user, to be used by the recruiter
	
/spell/changeling/split/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if (changeling.splitcount < 3)
		if(polling_ghosts)
			return
		//owner = user.mind
		polling_ghosts = TRUE
		user.visible_message("You are preparing to generate a new form.")
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
		var/success = recruiter.request_player()
		
		
		if (success)
			changeling.splitcount += 1
		else
			user.visible_message("You are unable to split at the moment.")
		changeling.geneticdamage = 30
	else
		user.visible_message("You are unable to split again.")
	
	..()			

/spell/changeling/split/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A [src] is looking for candidates. You have been added to the list of potential ghosts. ([controls])</span>")

/spell/changeling/split/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A [src] is looking for candidates. ([controls])</span>")

/spell/changeling/split/proc/recruiter_recruited(mob/user, mob/dead/observer/player)
	polling_ghosts = FALSE
	var/turf/this_turf = get_turf(src)
	var/mob/living/carbon/human/newbody = new(this_turf)
	newbody.set_species(user,1)
	newbody.ckey = player.ckey
	
	var/datum/role/changeling/newChangeling = new
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
	
	user.visible_message("<span class='danger'>[user] splits!</span>")
	user.regenerate_icons()
	user.updateChangelingHUD()
	update_faction_icons()
	nanomanager.close_uis(src)
	//update_icon()	
	//chosen_setup = null
	
	return 1
