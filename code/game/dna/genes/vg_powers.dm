/*
This is /vg/'s nerf for hulk.  Feel free to steal it.

Obviously, requires DNA2.
*/

// When hulk was first applied (world.time).
/mob/living/carbon/human/var/hulk_time = 0

// In decaseconds.
#define HULK_DURATION 300 // How long the effects last
#define HULK_COOLDOWN 600 // How long they must wait to hulk out.

/datum/dna/gene/basic/grant_spell/hulk
	name = "Hulk"
	desc = "Allows the subject to become the motherfucking Hulk."
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles quit tensing.")

	drug_activation_messages = list("You feel strong! You must've been working out lately.")
	drug_deactivation_messages = list("You return to your old lifestyle.")

	flags = GENE_UNNATURAL // Do NOT spawn on roundstart.

	spelltype = /spell/targeted/genetic/hulk

/datum/dna/gene/basic/grant_spell/hulk/deactivate(var/mob/M, var/connected, var/flags)
	M.mutations.Remove(M_HULK)
	M.update_mutations()
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_body()
	return ..()

/datum/dna/gene/basic/grant_spell/hulk/New()
	..()
	block = HULKBLOCK

/datum/dna/gene/basic/grant_spell/hulk/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(M_HULK in M.mutations)
		var/timeleft = M.hulk_time - world.time
		if(M.health <= 25 || timeleft <= 0)
			M.hulk_time=0 // Just to be sure.
			M.mutations.Remove(M_HULK)
			M.update_mutations()		//update our mutation overlays
			M.update_body()
			to_chat(M, "<span class='warning'>You suddenly feel very weak.</span>")
			M.Knockdown(3)
			M.Stun(3)
			M.emote("collapse")

/spell/targeted/genetic/hulk
	name = "Hulk Out"
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = SELFCAST

	charge_type = Sp_RECHARGE
	charge_max = HULK_COOLDOWN

	duration = HULK_DURATION

	spell_flags = INCLUDEUSER

	invocation_type = SpI_NONE

	override_base = "genetic"
	hud_state = "gen_hulk"

/spell/targeted/genetic/hulk/New()
	desc = "Get mad!  For [duration/10] seconds, anyway."
	..()

/spell/targeted/genetic/hulk/cast(list/targets, mob/user)
	if (istype(user.loc,/mob))
		to_chat(usr, "<span class='warning'>You can't hulk out right now!</span>")
		return 1
	for(var/mob/living/carbon/human/M in targets)
		M.hulk_time = world.time + src.duration
		M.mutations.Add(M_HULK)
		M.update_mutations()		//update our mutation overlays
		M.update_body()
		//M.say(pick("",";")+pick("HULK MAD","YOU MADE HULK ANGRY")) // Just a note to security.
		log_admin("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
		message_admins("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
	return

/datum/dna/gene/basic/grant_spell/farsight
	name = "Farsight"
	desc = "Increases the subjects ability to see things from afar."
	activation_messages = list("Your eyes focus.")
	deactivation_messages = list("Your eyes return to normal.")
	drug_activation_messages = list("You start feeling like an eagle, man!")
	drug_deactivation_messages = list("You feel less like an eagle and more like the rabbit!")
	spelltype = /spell/targeted/farsight

/datum/dna/gene/basic/grant_spell/farsight/New()
	block = FARSIGHTBLOCK
	..()

/datum/dna/gene/basic/grant_spell/farsight/can_activate(var/mob/M,var/flags)
	// Can't be big AND small.
	if((M.sdisabilities & BLIND) || (M.disabilities & NEARSIGHTED))
		return 0
	return ..(M,flags)

/datum/dna/gene/basic/grant_spell/farsight/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		if(M.client && M.client.view == world.view + 2)
			M.client.changeView()

/spell/targeted/farsight
	name = "Far Sight"
	desc = "Allows you to toggle farther vision at will."
	user_type = USER_TYPE_GENETIC
	panel = "Mutant Powers"
	range = SELFCAST
	charge_type = Sp_RECHARGE
	charge_max = 50
	invocation_type = SpI_NONE
	spell_flags = INCLUDEUSER
	override_base = "genetic"
	hud_state = "wiz_sleepold"
	var/active = 0

/spell/targeted/farsight/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/F in targets)
		if(!active)
			F.client.changeView(max(F.client.view, world.view+2))
			to_chat(F, "<span class='notice'>You focus your eyes to see farther.</span>")
			active = 1
		else
			F.client.changeView()
			to_chat(F, "<span class='notice'>You no longer focus your eyes.</span>")
			active = 0

// NOIR

#define NOIR_ANIM_TIME 170

/datum/dna/gene/basic/noir
	name = "Noir"
	desc = "In recent years, there's been a real push towards 'Detective Noir' movies, but since the last black and white camera was lost many centuries ago, Scientists had to develop a way to turn any movie noir."
	activation_messages = list("The Station's bright coloured light hits your eyes for the last time, and fades into a more appropriate tone, something's different about this place, but you can't put your finger on it. You feel a need to check out the bar, maybe get to the bottom of what's going on in this godforsaken place.")
	deactivation_messages = list("You now feel soft boiled.")

	mutation = M_NOIR

/datum/dna/gene/basic/noir/New()
	block = NOIRBLOCK
	..()

/datum/dna/gene/basic/noir/activate(var/mob/M)
	..()
	M.update_colour(NOIR_ANIM_TIME)
	if(M.client) // wow it's almost like non-client mobs can get mutations!
		M.client.screen += noir_master
		M << sound('sound/misc/noirdarkcoffee.ogg')

/datum/dna/gene/basic/noir/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		M.update_colour(NOIR_ANIM_TIME)
		if(M.client)
			M.client.screen -= noir_master
