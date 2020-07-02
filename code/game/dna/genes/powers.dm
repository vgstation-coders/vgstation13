///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name = "No Breathing"
	activation_messages = list("You feel no need to breathe.")
	deactivation_messages = list("The need to breathe returns.")
	mutation = M_NO_BREATH

/datum/dna/gene/basic/nobreath/New()
	block = NOBREATHBLOCK

/datum/dna/gene/basic/grant_spell/remoteview
	name = "Remote Viewing"
	activation_messages = list("Your mind expands.")
	deactivation_messages = list("Your mind is no longer expanded.")

	drug_activation_messages = list("You feel in touch with the cosmos.")
	drug_deactivation_messages = list("You no longer feel in touch with the cosmos.")

	mutation = M_REMOTE_VIEW

	spelltype = /spell/targeted/remoteobserve

/datum/dna/gene/basic/grant_spell/remoteview/New()
	block = REMOTEVIEWBLOCK

/spell/targeted/remoteobserve
	name = "Remote View"
	desc = "Lets you see through the eyes of others."
	panel = "Mutant Powers"

	charge_type = Sp_RECHARGE
	charge_max = 50

	invocation_type = SpI_NONE
	range = GLOBALCAST
	max_targets = 1
	spell_flags = SELECTABLE | INCLUDEUSER | TALKED_BEFORE

	override_base = "genetic"
	hud_state = "gen_rmind"
	mind_affecting = 1

/spell/targeted/remoteobserve/cast(var/list/targets, mob/living/carbon/human/user)
	if(!targets || !targets.len || !user || !istype(user))
		return

	if(user.isUnconscious())
		user.remoteview_target = null
		user.reset_view(0)
		return

	if(user.find_held_item_by_type(/obj/item/tk_grab))
		to_chat(user, "<span class='warning'>Your mind is too busy with that telekinetic grab.</span>")
		user.remoteview_target = null
		user.reset_view(0)
		return

	if(user.client.eye != user.client.mob)
		user.remoteview_target = null
		user.reset_view(0)
		return

	for(var/mob/living/target in targets)
		if(target)
			if(target == user)
				user.remoteview_target = null
				user.reset_view(0)
			else if(!user.can_mind_interact(target))
				user.remoteview_target = null
				user.reset_view(0)
			else
				user.remoteview_target = target
				user.reset_view(target)
			break

/datum/dna/gene/basic/regenerate
	name = "Regenerate"
	activation_messages = list("You feel better.")
	deactivation_messages = list("You stop feeling better.")
	mutation = M_REGEN

/datum/dna/gene/basic/regenerate/New()
	block=REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name = "Super Speed"
	activation_messages = list("Your leg muscles pulsate.")
	deactivation_messages = list("Your leg muscles no longer pulsate.")
	mutation = M_RUN

/datum/dna/gene/basic/increaserun/New()
	block = INCREASERUNBLOCK

/datum/dna/gene/basic/grant_spell/remotetalk
	name = "Telepathy"
	activation_messages = list("You feel your voice can penetrate other minds.")
	deactivation_messages = list("Your mind can no longer project your voice onto others.")

	drug_activation_messages = list("You feel your voice can reach the astral plane now.")
	drug_deactivation_messages = list("Your voice can no longer reach the astral plane.")

	mutation = M_REMOTE_TALK

	spelltype = /spell/targeted/remotesay

/datum/dna/gene/basic/grant_spell/remotetalk/New()
	..()
	block = REMOTETALKBLOCK

/spell/targeted/remotesay
	name = "Project Mind"
	desc = "Speak into the minds of others. You must either hear them speak or examine them to make contact."
	panel = "Mutant Powers"

	charge_type = Sp_RECHARGE
	charge_max = 50

	invocation_type = SpI_NONE
	range = GLOBALCAST //the world
	max_targets = 1
	selection_type = "view"
	spell_flags = SELECTABLE|TALKED_BEFORE

	override_base = "genetic"
	hud_state = "gen_project"

	compatible_mobs = list(/mob/living/carbon/human)
	mind_affecting = 1

/spell/targeted/remotesay/cast(var/list/targets, mob/living/carbon/human/user)
	if(!user || !istype(user))
		return

	if(user.mind.miming)
		to_chat(user, "<span class = 'warning'>You find yourself unable to convey your thoughts outside of gestures.</span>")
		return

	var/say = stripped_input(user, "What do you wish to say?", "Project Mind")

	if(!say)
		return 1

	for(var/T in targets)
		var/mob/living/carbon/human/target = T

		if(!T || !istype(target) || tinfoil_check(target) || !user.can_mind_interact(target))
			user.show_message("<span class='notice'>You project your mind towards [believed_name]: [say]</span>")
			return

		if(M_REMOTE_TALK in target.mutations)
			target.show_message("<span class='notice'>You hear [user.real_name]'s voice: [say]</span>")
		else
			target.show_message("<span class='notice'>You hear a voice that seems to echo around the room: [say]</span>")
		user.show_message("<span class='notice'>You project your mind towards [believed_name]: [say]</span>")
		log_admin("[key_name(user)] projects his mind towards (believed:[believed_name]/actual:[key_name(target)]: [say]</span>")
		message_admins("[key_name(user)] projects his mind towards (believed:[believed_name]/actual:[key_name(target)]: [say]</span>")
		for(var/mob/dead/observer/G in dead_mob_list)
			G.show_message("<i>Telepathic message from <b>[user]</b> to <b>[target]</b>: [say]</i>")

/datum/dna/gene/basic/morph
	name = "Morph"
	activation_messages = list("Your skin feels strange.")
	deactivation_messages = list("Your skin no longer feels strange.")

	drug_activation_messages = list("You feel like a chameleon.")
	drug_deactivation_messages = list("You no longer feel like a chameleon.")

	mutation = M_MORPH

/datum/dna/gene/basic/morph/New()
	block = MORPHBLOCK

/datum/dna/gene/basic/morph/activate(var/mob/M)
	..()
	M.verbs += /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name = "Heat Resistance"
	activation_messages = list("Your skin is icy to the touch.")
	deactivation_messages = list("Your skin stops feeling icy.")

	drug_activation_messages = list()
	drug_deactivation_messages = list()

	mutation = M_RESIST_HEAT

/datum/dna/gene/basic/heat_resist/New()
	block = COLDBLOCK

/datum/dna/gene/basic/heat_resist/can_activate(var/mob/M,var/flags)
	if(flags & MUTCHK_FORCED)
		return !(/datum/dna/gene/basic/cold_resist in M.active_genes)
	// Probability check
	var/_prob = 15
	if(M_RESIST_COLD in M.mutations)
		_prob=5
	if(probinj(_prob,(flags&MUTCHK_FORCED)))
		return 1

/datum/dna/gene/basic/heat_resist/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	if(isvox(M) || isskelevox(M))
		return "coldvox_s"
	else
		return "cold[fat]_s"

/datum/dna/gene/basic/cold_resist
	name = "Cold Resistance"
	activation_messages = list("Your body is filled with warmth.")
	deactivation_messages = list("Your body is no longer filled with warmth.")

	drug_activation_messages = list()
	drug_deactivation_messages = list()

	mutation = M_RESIST_COLD

/datum/dna/gene/basic/cold_resist/New()
	block = FIREBLOCK

/datum/dna/gene/basic/cold_resist/can_activate(var/mob/M,var/flags)
	if(flags & MUTCHK_FORCED)
		return !(/datum/dna/gene/basic/heat_resist in M.active_genes)
	// Probability check
	var/_prob=30
	if(M_RESIST_HEAT in M.mutations)
		_prob=5
	if(probinj(_prob,(flags&MUTCHK_FORCED)))
		return 1

/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	if(isvox(M) || isskelevox(M))
		return "firevox_s"
	else
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name = "No Prints"
	activation_messages = list("Your fingers feel numb.")
	deactivation_messages = list("Your fingers stop feeling numb.")
	mutation = M_FINGERPRINTS

/datum/dna/gene/basic/noprints/New()
	block = NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name = "Shock Immunity"
	activation_messages = list("Your skin feels electric.")
	deactivation_messages = list("Your skin no longer feels electric.")
	mutation = M_NO_SHOCK

/datum/dna/gene/basic/noshock/New()
	block = SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name = "Midget"
	activation_messages = list("You feel small.")
	deactivation_messages = list("You stop feeling small.")
	mutation = M_DWARF

/datum/dna/gene/basic/midget/New()
	block = SMALLSIZEBLOCK

/datum/dna/gene/basic/midget/activate(var/mob/M, var/connected, var/flags)
	..()
	M.pass_flags |= PASSTABLE

/datum/dna/gene/basic/midget/deactivate(var/mob/M, var/connected, var/flags)
	if(..())
		M.pass_flags &= ~PASSTABLE

/datum/dna/gene/basic/xray
	name = "X-Ray Vision"
	activation_messages = list("The walls suddenly disappear.")
	deactivation_messages = list("The walls suddenly appear.")

	drug_activation_messages = list("You see so much clearer now!")
	drug_deactivation_messages = list("Your vision is obstructed again.")

	mutation = M_XRAY

/datum/dna/gene/basic/xray/New()
	block = XRAYBLOCK

/datum/dna/gene/basic/tk
	name = "Telekinesis"
	activation_messages = list("You feel smarter.")
	deactivation_messages = list("You feel less smart.")

	drug_activation_messages = list("You feel like a nerd.")
	drug_deactivation_messages = list("You feel normal again.")

	mutation = M_TK
	activation_prob = 15

/datum/dna/gene/basic/tk/New()
	block = TELEBLOCK

/datum/dna/gene/basic/tk/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	if(isvox(M) || isskelevox(M))
		return "telekinesisheadvox_s"
	else
		return "telekinesishead[fat]_s"
