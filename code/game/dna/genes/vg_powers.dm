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

/datum/dna/gene/basic/farsight
	name = "Farsight"
	desc = "Increases the subjects ability to see things from afar."
	activation_messages = list("Your eyes focus.")
	deactivation_messages = list("Your eyes return to normal.")

	drug_activation_messages = list("The world becomes huge! You feel like an ant.")
	drug_deactivation_messages = list("You no longer feel like an insect.")

	mutation = M_FARSIGHT

/datum/dna/gene/basic/farsight/New()
	block = FARSIGHTBLOCK
	..()

/datum/dna/gene/basic/farsight/activate(var/mob/M)
	..()
	if(M.client)
		M.client.changeView(max(M.client.view, world.view+1))

/datum/dna/gene/basic/farsight/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		if(M.client && M.client.view == world.view + 1)
			M.client.changeView()

/datum/dna/gene/basic/farsight/can_activate(var/mob/M,var/flags)
	// Can't be big AND small.
	if((M.sdisabilities & BLIND) || (M.disabilities & NEARSIGHTED))
		return 0
	return ..(M,flags)

// NOIR

/obj/abstract/screen/plane_master/noir_master
	plane = NOIR_BLOOD_PLANE
	color = list(1,0,0,0,
				 0,1,0,0,
				 0,0,1,0,
				 0,0,0,1)
	appearance_flags = NO_CLIENT_COLOR|PLANE_MASTER

/obj/abstract/screen/plane_master/noir_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = NOIR_BLOOD_PLANE

var/noir_master = list(new /obj/abstract/screen/plane_master/noir_master(),new /obj/abstract/screen/plane_master/noir_dummy())

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
	M.update_colour()
	if(M.client) // wow it's almost like non-client mobs can get mutations!
		M.client.screen += noir_master

/datum/dna/gene/basic/noir/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		M.update_colour()
		if(M.client)
			M.client.screen -= noir_master

/datum/dna/gene/basic/grant_spell/headcannon
	name = "Headcannon"
	desc = "Aggressively frees the brain through the forehead."
	activation_messages = list("It feels as if a spring in the back of your head is being compressed.", "You feel a strange pressure in the back of your head increasing.")
	deactivation_messages = list("The tension in the back of your head disappears.")

	flags = GENE_UNNATURAL // Do NOT spawn on roundstart.

	spelltype = /spell/targeted/genetic/headcannon

/datum/dna/gene/basic/grant_spell/headcannon/New()
	..()
	block = HEADCANNONBLOCK

/datum/dna/gene/basic/grant_spell/headcannon/activate(var/mob/M)
	if(ishuman(M)) // only humans with a brain can use this spell
		var/mob/living/carbon/human/H = M
		if(H.internal_organs_by_name["brain"])
			..()

/spell/targeted/genetic/headcannon
	name = "Free the Brain"
	desc = "Relieve the tension in the back of your head."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = SELFCAST

	duration = 1

	spell_flags = INCLUDEUSER

	invocation_type = SpI_NONE

	override_base = "genetic"
	hud_state = "headcannon"

/spell/targeted/genetic/headcannon/cast(list/targets, mob/user)
	if(istype(user.loc, /mob))
		to_chat(usr, "<span class='warning'>You can't launch your brain right now!</span>")
		return 1

	if(!ishuman(user))
		return // needs to be human

	var/mob/living/carbon/human/M = user

	if(!M.internal_organs_by_name["brain"])
		return // no brain means no explosion

	var/datum/organ/external/head/head_organ = M.get_organ(LIMB_HEAD)
	var/obj/item/organ/internal/brain/B = M.remove_internal_organ(M, M.internal_organs_by_name["brain"], head_organ)
	head_organ.explode()
	fire(M)
	qdel(B) // make sure the actual brain doesn't drop
	log_admin("[key_name(M)] has launched their brain! ([formatJumpTo(M)])")
	message_admins("[key_name(M)] has launched their brain! ([formatJumpTo(M)])")

/spell/targeted/genetic/headcannon/proc/fire(var/mob/living/carbon/human/user)
	// stolen/adapted from the wheelchair cannon
	var/target = get_ranged_target_turf(user, user.dir, 20)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	user.visible_message("<span class='danger'>Something explodes out of [user]'s forehead!</span>","<span class='danger'>You fire your brain from your head!</span>")
	log_attack("[user.name] ([user.ckey]) fired their brain (proj:[cannonbrain.name]) at coordinates ([user.x],[user.y],[user.z])" )

	// recoil body (copied from code/module/projectile/gun.dm)
	var/movementdirection = get_dir(target,user)
	spawn()
		shake_camera(user, 6, 5)
	user.throw_at(get_ranged_target_turf(user, movementdirection, 20), 20, 20)
	user.apply_inertia(movementdirection)

	// projectile stuff
	generic_projectile_fire(targloc, user, /obj/item/projectile/brain, 'sound/weapons/rocket.ogg')
