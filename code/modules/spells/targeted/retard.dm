//Brain damage spell. Gives 30 brain damage to whoever is targeted. Triples brain damage (90) when power-upgraded.
/spell/targeted/retard
	name = "Brain Damage"
	desc = "Give an unlucky person brain damage."
	abbreviation = "BD"
	user_type = USER_TYPE_WIZARD //So that it appears in the spellbook
	school = "evocation"
	charge_max = 200 // 20 seconds
	//Invocation is noted below
	invocation_type = SpI_WHISPER //Wizard will whisper what they say instead of shouting
	range = 3 // Target anyone within 3 tiles of you
	cooldown_min = 80 //Minimum of 8 seconds cooldown. Decreased by 4 seconds per rank (3 ranks)
	amt_dam_brain = 30 //30 brain damage
	max_targets = 1 // Can only target one person
	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey) // Only works on humans and monkeys
	spell_flags = WAIT_FOR_CLICK //Click on whoever you want to get brain damaged
	message = "<span class='danger'>You feel dumber!<span>" //What the victim sees when affected
	mind_affecting = 1 //Blocked by tinfoil hat
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 3, Sp_POWER = 1) //Cooldown can be upgraded up to 3 times and the power only once. Also to show up in the spellbook.
	hud_state = "wiz_retard" //Icon is from screen_spells.dmi

/spell/targeted/retard/empower_spell()
	spell_levels[Sp_POWER]++ //Adds 1 to Sp_POWER if you buy a power upgrade
	switch(spell_levels[Sp_POWER]) //If 0 it's normal, if 1 it's upgraded
		if(0) //Not upgraded
			name = "Brain Damage" //Nothing happens. Everything is already written above.
		if(1) //Upgraded
			name = "Brian Damage"
			desc = "Give an unlucky person A LOT of brain damage."
			amt_dam_brain = 90 //90 brain damage
			message = "<span class='danger'>Yu fell dumb dumb!1!!<span>" //Message changes when upgraded
			hud_state = "wiz_retard1" //Icon changes when upgraded
	return "You drastically improve your ability to make people retarded." //Messages the wizard sees when upgrading the spell

/spell/targeted/retard/get_upgrade_info(upgrade_type, level) //So it shows up in the spellbook
	if(upgrade_type == Sp_POWER) //If upgrade_type is equal to Sp_POWER
		return "Triple the brain damage caused by your spell." //Description when pressing "power"
	return ..()

/spell/targeted/retard/invocation() //Allows multiple possible messages for invocation
	invocation = pick("SCRUN GL RITY", "BLO XYG EVO", "SAI AN SCRE", "PO NY NEEI", "MIE NIA PICE", "LOL 2 CAT") //Chooses between these messages at random
	..() //Invocation proc from spell_code.dm is run normally, but invocation is overwritten with a message picked from above
