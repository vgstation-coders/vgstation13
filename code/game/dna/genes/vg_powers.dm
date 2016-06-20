/*
This is /vg/'s nerf for hulk.  Feel free to steal it.

Obviously, requires DNA2.
*/

// When hulk was first applied (world.time).
/mob/living/carbon/human/var/hulk_time=0

// In decaseconds.
#define HULK_DURATION 300 // How long the effects last
#define HULK_COOLDOWN 600 // How long they must wait to hulk out.

/datum/dna/gene/basic/grant_spell/hulk
	name = "Hulk"
	desc = "Allows the subject to become the motherfucking Hulk."
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles quit tensing.")

	drug_activation_messages=list("You feel strong! You must've been working out lately.")
	drug_deactivation_messages=list("You return to your old lifestyle.")

	flags = GENE_UNNATURAL // Do NOT spawn on roundstart.

	spelltype = /spell/targeted/genetic/hulk

/datum/dna/gene/basic/grant_spell/hulk/New()
	..()
	block = HULKBLOCK

/datum/dna/gene/basic/grant_spell/hulk/can_activate(var/mob/M,var/flags)
	// Can't be big AND small.
	if(M_DWARF in M.mutations)
		return 0
	return ..(M,flags)

/datum/dna/gene/basic/grant_spell/hulk/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	if(M_HULK in M.mutations)
		if(fat)
			return "hulk_[fat]_s"
		else
			return "hulk_[g]_s"
	return 0

/datum/dna/gene/basic/grant_spell/hulk/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M)) return
	if(M_HULK in M.mutations)
		var/timeleft=M.hulk_time - world.time
		if(M.health <= 25 || timeleft <= 0)
			M.hulk_time=0 // Just to be sure.
			M.mutations.Remove(M_HULK)
			//M.dna.SetSEState(HULKBLOCK,0)
			M.update_mutations()		//update our mutation overlays
			M.update_body()
			to_chat(M, "<span class='warning'>You suddenly feel very weak.</span>")
			M.Weaken(3)
			M.emote("collapse")

/spell/targeted/genetic/hulk
	name = "Hulk Out"
	panel = "Mutant Powers"
	range = -1

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
		return
	for(var/mob/living/carbon/human/M in targets)
		M.hulk_time = world.time + src.duration
		M.mutations.Add(M_HULK)
		M.update_mutations()		//update our mutation overlays
		M.update_body()
		//M.say(pick("",";")+pick("HULK MAD","YOU MADE HULK ANGRY")) // Just a note to security.
		log_admin("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
		message_admins("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
	return

/datum/dna/gene/basic/farsight
	name = "Farsight"
	desc = "Increases the subjects ability to see things from afar."
	activation_messages = list("Your eyes focus.")
	deactivation_messages = list("Your eyes return to normal.")

	drug_activation_messages=list("The world becomes huge! You feel like an ant.")
	drug_deactivation_messages=list("You no longer feel like an insect.")

	mutation = M_FARSIGHT

/datum/dna/gene/basic/farsight/New()
	block=FARSIGHTBLOCK
	..()
/datum/dna/gene/basic/farsight/activate(var/mob/M)
	..()
	if(M.client)
		M.client.view = max(M.client.view, world.view+1)

/datum/dna/gene/basic/farsight/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		if(M.client && M.client.view == world.view + 1)
			M.client.view = world.view

/datum/dna/gene/basic/farsight/can_activate(var/mob/M,var/flags)
	// Can't be big AND small.
	if((M.sdisabilities & BLIND) || (M.disabilities & NEARSIGHTED))
		return 0
	return ..(M,flags)

// NOIR

/obj/screen/plane_master/noir_master
	plane = PLANE_NOIR_BLOOD
	color = list(1,0,0,0,
				 0,1,0,0,
				 0,0,1,0,
				 0,0,0,1)
	appearance_flags = NO_CLIENT_COLOR|PLANE_MASTER

/obj/screen/plane_master/noir_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	appearance_flags = 0
	plane = PLANE_NOIR_BLOOD

var/noir_master = list(new /obj/screen/plane_master/noir_master(),new /obj/screen/plane_master/noir_dummy())

/datum/dna/gene/basic/noir
	name="Noir"
	desc = "In recent years, there's been a real push towards 'Detective Noir' movies, but since the last black and white camera was lost many centuries ago, Scientists had to develop a way to turn any movie noir."
	activation_messages=list("The Station's bright coloured light hits your eyes for the last time, and fades into a more appropriate tone, something's different about this place, but you can't put your finger on it. You feel a need to check out the bar, maybe get to the bottom of what's going on in this godforsaken place.")
	deactivation_messages = list("You now feel soft boiled.")

	mutation=M_NOIR

/datum/dna/gene/basic/noir/New()
	block=NOIRBLOCK
	..()

/datum/dna/gene/basic/noir/activate(var/mob/M)
	..()
	M.update_colour()
	M.client.screen += noir_master

/datum/dna/gene/basic/noir/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		M.update_colour()
		M.client.screen -= noir_master