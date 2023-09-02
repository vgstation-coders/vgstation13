/datum/role/changeling
	name = "Changeling"
	id = CHANGELING
	required_pref = CHANGELING
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain",
						"Chief Engineer", "Chief Medical Officer", "Research Director")
	protected_traitor_prob = PROB_PROTECTED_RARE
	logo_state = "change-logoa"
	default_admin_voice = "Changeling Hivemind"
	admin_voice_style = "borer"
	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/list/absorbed_chems = list()
	var/absorbedcount = 0
	var/splitcount = 0
	//chem points
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0

	powerpoints = 4	//evolve points

	var/mimicing = ""
	var/disease_immunity = 0 //If on, the changeling doesn't suffer any symptoms from diseases

/datum/role/changeling/OnPostSetup(var/laterole = FALSE)
	. = ..()
	power_holder = new /datum/power_holder/changeling(src)
	antag.current.add_spell(new /spell/changeling/evolve, "changeling_spell_ready", /obj/abstract/screen/movable/spell_master/changeling	)

	//load in available powers
	for(var/P in subtypesof(/datum/power/changeling))
		available_powers += new P()
	//purchase the free powers!
	for(var/datum/power/changeling/P in available_powers)
		if(!P.cost) // Is it free?
			if(!(P in current_powers)) // Do we not have it already?
				power_holder.purchasePower(P.name)// Purchase it.

	antag.current.make_changeling()
	var/honorific
	if(antag.current.gender == FEMALE)
		honorific = "Ms."
	else
		honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/role/changeling/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Changeling.</span>")
	to_chat(antag.current, "<span class='danger'>Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</span>")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	if (antag.current.mind && antag.current.mind.assigned_role == "Clown")
		to_chat(antag.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
		antag.current.mutations.Remove(M_CLUMSY)

	antag.current << sound('sound/effects/ling_intro.ogg')

/datum/role/changeling/ForgeObjectives()
	if(!antag.current.client.prefs.antag_objectives)
		AppendObjective(/datum/objective/freeform/changeling)
		return
	AppendObjective(/datum/objective/absorb)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/target/steal)
	if(prob(50))
		AppendObjective(/datum/objective/chem_sample)
	if(prob(50))
		AppendObjective(/datum/objective/escape)
	else
		AppendObjective(/datum/objective/hijack)

/datum/role/changeling/proc/changelingRegen()
	if(antag && antag.current && antag.current.stat == DEAD)
		return
	var/changes = FALSE
	var/changeby = chem_charges
	chem_charges = clamp(chem_charges + chem_recharge_rate, 0, chem_storage)
	if(chem_charges != changeby)
		changes = TRUE
	changeby = geneticdamage
	geneticdamage = max(0, geneticdamage-1)
	if(geneticdamage != changeby)
		changes = TRUE
	if(antag && changes)
		antag.current.updateChangelingHUD()

/datum/role/changeling/proc/GetDNA(var/dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna

/datum/role/changeling/process()
	if(antag.current)
		changelingRegen()
	..()

// READ: Don't use the apostrophe in name or desc. Causes script errors.

var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/role/changeling/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	if (!power_holder) // This is for when you spawn as a new_player
		return
	if(isbrain(new_character))
		removespells()		//The changeling spells will get removed if you get decapitated. Removing this line will allow changelings to use their 'regenerative stasis' skill while decapitated, giving them a brand new body after it completes.
		return

	new_character.make_changeling() // Will also restore any & all genomes/powers we have
