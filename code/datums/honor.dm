/**
 * Honor 2.0
 *  by N3X15
 *
 * Mobs get a /datum/honor, which enforces rules for some gamemodes and events.
 *
 * May eventually be used for duels.
 */

/**
 * Reagents should use a modified version of this, too.
 */
/proc/dehulkify(var/mob/M, var/fatal_creatine=FALSE, var/remove_gene_too=FALSE)
	// if hulk, dehulk
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.has_reagent_in_blood(COMNANOBOTS))
				var/datum/reagent/comnanobots/her_nanites = H.reagents.get_reagent(COMNANOBOTS)
				her_nanites.dehulk(H) // The args for this don't actually do anything.
			if(H.has_reagent_in_blood(CREATINE))
				var/datum/reagent/creatine/liquid_punchbeast = H.reagents.get_reagent(CREATINE)
				if(fatal_creatine)
					liquid_punchbeast.dehulk(H)
				else
					liquid_punchbeast.dehulk(H, damage=0, override_remove=TRUE, gib=0)
		if(remove_gene_too)
			M.dna.SetSEState(HULKBLOCK, FALSE)
		if(M_HULK in H.mutations) // Still somehow hulk
			H.mutations.Remove(M_HULK)
			H.hulk_time = 0 //Just to be sure.
			H.update_mutations()		//update our mutation overlays
			H.update_body()

/datum/honor
	var/mob/holder = null
	var/dishonors = 0 // bitfield of DISHONOR_*, indicates what would be considered dishonorable.
	var/disable_dishonorable_chems=FALSE
	var/disable_grab=FALSE // Blocks grabbing, as opposed to punishing you for using it.
	var/punishment = 0 // DISHON_PUNISH_*, indicates the type of punishment if the dishonor occurs.

	var/max_marks = 0  // maximum number of warnings (marks) before the Punishment.
	var/marks = 0 // Number of marks on honor.  AKA: warnings. Manifest as stuns.

/datum/honor/proc/setup(var/mob/new_holder, var/silent=FALSE)
	holder=new_holder
	if(!silent)
		to_chat(holder,"<span class='danger'>You are now entering an honor battle.  Your intent has automatically been set to hurt, and you have stopped pulling things.</span>")
	holder.stop_pulling()
	holder.a_intent_change(I_HURT)
	var/obj/item/weapon/grab/G = holder.get_active_hand()
	if(istype(G))
		returnToPool(G)

	if(!silent)
		var/rules = "<span class='notice'>The rules of this battle: <ol>"
		if(DISHONOR_FIREARMS & dishonors)
			rules += "<li>No firearms or other ranged weapons.</li>"
		if(DISHONOR_MELEE & dishonors)
			rules += "<li>No unarmed melee attacks.</li>"
		if(DISHONOR_DISARM & dishonors)
			rules += "<li>No pushing or disarming.</li>"
		if(DISHONOR_GRAB & dishonors)
			rules += "<li>No grabbing.</li>"
		if(DISHONOR_PULL & dishonors)
			rules += "<li>No pulling.</li>"
		rules += "</ol> This fight will be monitored by [ticker.Bible_deity_name].</span>"
		if(max_marks==0)
			rules += " <span class='danger'>There will be no warnings for infractions.</span>"
		switch(punishment)
			if(DISHON_PUNISH_EYE4EYE,DISHON_PUNISH_DEATH)
				rules += " <span class='danger'>Dishonor will be met with death.</span>"
			if(DISHON_PUNISH_CATBEAST,DISHON_PUNISH_CLUWNE)
				rules += " <span class='sinister'>Dishonor will be met with a fate worse than death.</span>"
		to_chat(holder, rules)

/* Acts like a flash without the eyecheck. */
/datum/honor/proc/stun()
	to_chat(holder, "<span class='sinister'>You have acted dishonorably.  You feel the disapproval of [ticker.Bible_deity_name], which weighs heavily on your soul!</span>")
	// Preventing cheesing via creatine/combat nanos/HULKBLOCK
	dehulkify(holder, fatal_creatine=FALSE, remove_gene_too=FALSE)
	// From flash.dm:
	//if(holder.eyecheck() <= 0)
	holder.Knockdown(/*holder.eyecheck() * 5 * -1 +10 */ 5)

/datum/honor/proc/death()
	if(isliving(holder))
		var/mob/living/L=holder
		to_chat(L, "<span class='sinister'>You have acted dishonorably.  In anger, [ticker.Bible_deity_name] strikes you down!</span>")
		if(L.health > 0)
			L.death(FALSE)
			// Do lightning or something here.

/datum/honor/proc/catbeast()
	to_chat(holder, "<span class='sinister'>You have acted dishonorably. Disappointed, [ticker.Bible_deity_name] turns their back on you! You feel dark forces warp your form, toying with your abandoned soul...")
	if(!ishuman(holder))
		var/mob/living/carbon/human/tajaran/catbeast = new(holder.loc)
		holder.mind.transfer_to(catbeast)
	else
		var/mob/living/carbon/human/H=holder
		if(H.species.name != "Tajaran")
			if(H.set_species("Tajaran"))
				H.regenerate_icons()

/datum/honor/proc/cluwne()
	to_chat(holder, "<span class='sinister'>You have acted dishonorably. Disappointed, [ticker.Bible_deity_name] turns their back on you! You feel dark forces warp your form, laughter filling your frightened mind...</span>")
	if(!ishuman(holder))
		var/mob/living/carbon/human/tajaran/catbeast = new(holder.loc)
		holder.mind.transfer_to(catbeast)
	else
		var/mob/living/carbon/human/H=holder
		H.Cluwneize()

/datum/honor/proc/apply_punishment(var/dishonor, var/act_verb, var/mob/target=null)
	// If dishonor was considered dishonorable, apply a punishment.
	// :param dishonor:
	//   One of DISHONOR_* - The dishonor performed.
	// :param act_verb:
	///  String with a verb describing the dishonorable action.
	// :param target: (null|/mob)
	//   The target of the dishonor that holder performed. For instance, the guy we tried to disarm.
	// :return: returns true if punishment is EYE4EYE, and act was considered dishonorable.
	if((dishonors & dishonor) || (dishonor == DISHONOR_ALWAYS))
		var/bad_action=""
		if(!target)
			bad_action="[holder] tried to [act_verb]"
		else
			bad_action="[holder] tried to [act_verb] [target]"

		if(marks < max_marks)
			marks++
			to_chat(holder, "<span class='sinister'>You have acted dishonorably and have received a black mark upon your soul. [max_marks] marks will result in a deadly punishment. You have [marks] marks.</span>")
			holder.visible_message("<span class='sinister'>[bad_action] and has earned a <span style='color:black;'>Black Mark</span> upon their souls!</span>", ignore_self=TRUE)
			stun()
			message_admins("[holder] tried to [act_verb] target=[target] and was marked ([marks]/[max_marks]).")
		else
			if(max_marks)
				to_chat(holder, "<span class='sinister'>You have received your final Mark, and you shall be punished accordingly.</span>")
			holder.visible_message("<span class='sinister'>[bad_action]! [ticker.Bible_deity_name] has frowned upon the disgrace!</span>", ignore_self=TRUE)
			switch(punishment)
				if(DISHON_PUNISH_STUN)
					message_admins("[holder] tried to [act_verb] target=[target] and was stunned.")
					stun()
					return FALSE
				if(DISHON_PUNISH_DEATH)
					message_admins("[holder] tried to [act_verb] target=[target] and was killed.")
					death()
					return FALSE
				if(DISHON_PUNISH_CLUWNE)
					message_admins("[holder] tried to [act_verb] target=[target] and was CLUWNED.")
					cluwne()
					return FALSE
				if(DISHON_PUNISH_CATBEAST)
					message_admins("[holder] tried to [act_verb] target=[target] and was CATBEASTED.")
					catbeast()
					return FALSE
				if(DISHON_PUNISH_EYE4EYE)
					//to_chat(holder, "<span class='sinister'>You have acted dishonorably.  [ticker.Bible_deity_name] metes out an appropriate punishment!</span>")
					return TRUE // Handled by caller.
				else
					stun() // ???
