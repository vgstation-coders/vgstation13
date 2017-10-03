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

var/global/list/all_dishonors = list(
	"ALWAYS" = DISHONOR_ALWAYS,
	"DISARM" = DISHONOR_DISARM,
	"MELEE" = DISHONOR_MELEE,
	"FIREARMS" = DISHONOR_FIREARMS,
	"PULL" = DISHONOR_PULL,
	"GRAB" = DISHONOR_GRAB,
)
var/global/list/all_dishonor_punishments = list(
	"STUN" = DISHON_PUNISH_STUN,
	"DEATH" = DISHON_PUNISH_DEATH,
	"EYE4EYE" = DISHON_PUNISH_EYE4EYE,
	//FATES WORSE THAN DEATH:
	"CATBEAST" = DISHON_PUNISH_CATBEAST,
	"CLUWNE" = DISHON_PUNISH_CLUWNE,
)

var/global/datum/honor/honor_bomberman = new /datum/honor/bomberman()
var/global/datum/honor/honor_highlander = new /datum/honor/highlander()

/datum/honor
	var/battle_name = "this battle" // Used in get_rules()
	var/dishonors = 0 // bitfield of DISHONOR_*, indicates what would be considered dishonorable.
	var/disable_dishonorable_chems=FALSE
	var/disable_grab=FALSE // Blocks grabbing, as opposed to punishing you for using it.
	var/punishment = 0 // DISHON_PUNISH_*, indicates the type of punishment if the dishonor occurs.

	var/max_marks = 0  // maximum number of warnings (marks) before the Punishment.

/datum/honor/proc/setup(var/mob/M, var/silent=FALSE)
	if(!silent)
		to_chat(M,"<span class='danger'>You are now entering an honor battle.  Your intent has automatically been set to hurt, and you have stopped pulling things.</span>")
	M.stop_pulling()
	M.a_intent_change(I_HURT)
	var/obj/item/weapon/grab/G = M.get_active_hand()
	if(istype(G))
		returnToPool(G)

	if(!silent)
		to_chat(M, get_rules())

/datum/honor/proc/get_rules()
	var/rules = "<span class='notice'>The rules of [battle_name]: <ol>"
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
	return rules

/* Acts like a flash without the eyecheck. */
/datum/honor/proc/stun(var/mob/M)
	to_chat(M, "<span class='sinister'>You have acted dishonorably.  You feel the disapproval of [ticker.Bible_deity_name], which weighs heavily on your soul!</span>")
	// Preventing cheesing via creatine/combat nanos/HULKBLOCK
	dehulkify(M, fatal_creatine=FALSE, remove_gene_too=FALSE)
	// From flash.dm:
	//if(M.eyecheck() <= 0)
	M.Knockdown(/*M.eyecheck() * 5 * -1 +10 */ 5)

/datum/honor/proc/death(var/mob/M)
	if(isliving(M))
		var/mob/living/L=M
		to_chat(L, "<span class='sinister'>You have acted dishonorably.  In anger, [ticker.Bible_deity_name] strikes you down!</span>")
		if(L.health > 0)
			L.death(FALSE)
			// Do lightning or something here.

/datum/honor/proc/catbeast(var/mob/M)
	to_chat(M, "<span class='sinister'>You have acted dishonorably. Disappointed, [ticker.Bible_deity_name] turns their back on you! You feel dark forces warp your form, toying with your abandoned soul...")
	if(!ishuman(M))
		var/mob/living/carbon/human/tajaran/catbeast = new(M.loc)
		M.mind.transfer_to(catbeast)
	else
		var/mob/living/carbon/human/H=M
		if(H.species.name != "Tajaran")
			if(H.set_species("Tajaran"))
				H.regenerate_icons()

/datum/honor/proc/cluwne(var/mob/M)
	to_chat(M, "<span class='sinister'>You have acted dishonorably. Disappointed, [ticker.Bible_deity_name] turns their back on you! You feel dark forces warp your form, laughter filling your frightened mind...</span>")
	if(!ishuman(M))
		var/mob/living/carbon/human/tajaran/catbeast = new(M.loc)
		M.mind.transfer_to(catbeast)
	else
		var/mob/living/carbon/human/H=M
		H.Cluwneize()

/datum/honor/proc/apply_punishment(var/mob/M, var/dishonor, var/act_verb, var/mob/target=null)
	// If dishonor was considered dishonorable, apply a punishment.
	// :param M:
	//  Dishonorable mob.
	// :param dishonor:
	//   One of DISHONOR_* - The dishonor performed.
	// :param act_verb:
	///  String with a verb describing the dishonorable action.
	// :param target: (null|/mob)
	//   The target of the dishonor that M performed. For instance, the guy we tried to disarm.
	// :return: returns true if punishment is EYE4EYE, and act was considered dishonorable.
	if((dishonors & dishonor) || (dishonor == DISHONOR_ALWAYS))
		var/bad_action=""
		if(!target)
			bad_action="[M] tried to [act_verb]"
		else
			bad_action="[M] tried to [act_verb] [target]"

		if(M.marks < max_marks)
			M.marks++
			to_chat(M, "<span class='sinister'>You have acted dishonorably and have received a Black Mark upon your soul. [max_marks] marks will result in a deadly punishment. You have [M.marks] marks.</span>")
			M.visible_message("<span class='sinister'>[bad_action] and has earned a <span style='color:black;'>Black Mark</span> upon their souls!</span>", ignore_self=TRUE)
			stun(M)
			message_admins("[M] tried to [act_verb] target=[target] and was marked ([M.marks]/[max_marks]).")
		else
			if(max_marks)
				to_chat(M, "<span class='sinister'>You have received your final Mark, and you shall be punished accordingly.</span>")
			M.visible_message("<span class='sinister'>[bad_action]! [ticker.Bible_deity_name] has frowned upon the disgrace!</span>", ignore_self=(max_marks>0))
			switch(punishment)
				if(DISHON_PUNISH_STUN)
					message_admins("[M] tried to [act_verb] target=[target] and was stunned.")
					stun(M)
					return FALSE
				if(DISHON_PUNISH_DEATH)
					message_admins("[M] tried to [act_verb] target=[target] and was killed.")
					death(M)
					return FALSE
				if(DISHON_PUNISH_CLUWNE)
					message_admins("[M] tried to [act_verb] target=[target] and was CLUWNED.")
					cluwne(M)
					return FALSE
				if(DISHON_PUNISH_CATBEAST)
					message_admins("[M] tried to [act_verb] target=[target] and was CATBEASTED.")
					catbeast(M)
					return FALSE
				if(DISHON_PUNISH_EYE4EYE)
					//to_chat(M, "<span class='sinister'>You have acted dishonorably.  [ticker.Bible_deity_name] metes out an appropriate punishment!</span>")
					return TRUE // Handled by caller.
				else
					stun(M) // ???

// DEFAULTS FOR VARIOUS MODES
// honor_bomberman
/datum/honor/bomberman
	dishonors = DISHONOR_PULL|DISHONOR_FIREARMS|DISHONOR_DISARM|DISHONOR_GRAB|DISHONOR_MELEE
	punishment = DISHON_PUNISH_DEATH
	disable_dishonorable_chems = TRUE

// honor_highlander
/datum/honor/highlander
	dishonors = DISHONOR_PULL|DISHONOR_FIREARMS|DISHONOR_DISARM
	punishment = DISHON_PUNISH_EYE4EYE
	disable_dishonorable_chems = TRUE


/datum/honor/proc/edit(var/mob/user)
	if(!istype(user))
		return
	if(!user.check_rights(R_ADMIN))
		return
	var/c=""
	var/html = {"
<h1>Honor Battle Settings</h1>
<fieldset>
	<legend>Presets</legend>
	<ul>
		<li><a href="?src=\ref[src];preset=none">None (No honor)</a></li>
		<li><a href="?src=\ref[src];preset=bomberman">Bomberman</a></li>
		<li><a href="?src=\ref[src];preset=highlander">Highlander</a></li>
	</ul>
</fieldset>
<fieldset>
<legend>Dishonors</legend>
<p>Checked items are considered dishonorable and will be punished.</p>
<ul>"}
	for(var/key in all_dishonors)
		c = (dishonors & all_dishonors[key]) ? "#006600" : "#ff0000"
		html += {"<li><a href="?src=\ref[src];toggledishonor=[all_dishonors[key]]" style="color:[c];">[key]</a></li>"}
	html += {"
	</ul>
</fieldset>
<fieldset>
	<legend>Toggles</legend>
	<ul>"}
	c = (disable_dishonorable_chems) ? "#006600" : "#ff0000"
	html += {"<li><a href="?src=\ref[src];togglechems=1" style="color:[c];">Disable Chems</a></li>"}
	c = (disable_grab) ? "#006600" : "#ff0000"
	html += {"<li><a href="?src=\ref[src];togglegrabs=1" style="color:[c];">Disable Grabs</a></li>
	</ul>
</fieldset>
<fieldset>
	<legend>Punishment</legend>
	<p>The selected item will be the punishment applied to the dishonorable.</p>
	<ul>"}
	for(var/key in all_dishonor_punishments)
		c = (punishment == all_dishonor_punishments[key]) ? "#006600" : "#ff0000"
		html += {"<li><a href="?src=\ref[src];setpunishment=[all_dishonor_punishments[key]]" style="color:[c];">[key]</a></li>"}
	html += {"
	</ul>
</fieldset>
<fieldset>
	<legend>Marks</legend>
	<p>AKA Warnings</p>
	<a href="?src=\ref[src];incmaxwarns=1">+</a>[max_marks]<a href="?src=\ref[src];incmaxwarns=-1">-</a>
</fieldset>"}
	if(html)
		user.set_machine(src)
	var/datum/browser/popup = new(user, "honor", battle_name, 400, 300)
	popup.set_content(html)
	//popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
	popup.open()

/datum/honor/Topic(href, href_list)
	if(!usr.check_rights(R_ADMIN))
		return
	if(href_list["preset"])
		switch(href_list["preset"])
			if("none")
				dishonors = 0
				punishment = 0
				disable_dishonorable_chems = FALSE
				disable_grab = FALSE
			if("bomberman")
				dishonors = DISHONOR_PULL|DISHONOR_FIREARMS|DISHONOR_DISARM|DISHONOR_GRAB|DISHONOR_MELEE
				punishment = DISHON_PUNISH_DEATH
				disable_dishonorable_chems = TRUE
				disable_grab = TRUE
			if("highlander")
				dishonors = DISHONOR_PULL|DISHONOR_FIREARMS|DISHONOR_DISARM
				punishment = DISHON_PUNISH_EYE4EYE
				disable_dishonorable_chems = TRUE
				disable_grab = TRUE
	else if(href_list["toggledishonor"])
		dishonors ^= text2num(href_list["toggledishonor"])
	else if(href_list["setpunishment"])
		punishment = text2num(href_list["setpunishment"])
	else if(href_list["incmaxwarns"])
		max_marks += text2num(href_list["incmaxwarns"])
	else if(href_list["togglechems"])
		disable_dishonorable_chems = !disable_dishonorable_chems
	else if(href_list["togglegrabs"])
		disable_grab = !disable_grab
	edit(usr)
