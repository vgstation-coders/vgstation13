/datum/artifact_effect/darkrevive
	effecttype = "darkrevive"
	effect = ARTIFACT_EFFECT_TOUCH

/datum/artifact_effect/darkrevive/New()
	..()
	effect_type = pick(0,2,5)

/datum/artifact_effect/darkrevive/DoEffectTouch(var/mob/living/carbon/human/user)
	if(holder && user.species && user.species.can_artifact_revive() && !user.isDead() && user.dna.mutantrace != "shadow")
		var/list/targets = list()
		FOR_DVIEW(var/mob/living/carbon/human/H,world.view,get_turf(holder),0)
			if(!H.mind)
				continue
			if(H.species && !H.species.can_artifact_revive())
				continue
			if(H.dna && H.dna.mutantrace == "shadow")
				continue
			var/datum/organ/external/head/head = H.get_organ(LIMB_HEAD)
			if(!head || head.status & ORGAN_DESTROYED || M_NOCLONE in H.mutations  || !H.has_brain())
				continue
			if(H.isDead())
				targets += H

		if(targets.len)
			var/mob/living/carbon/human/target = pick(targets)
			try_revive(user, target)

/datum/artifact_effect/darkrevive/proc/try_revive(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target)
	if(!istype(user) || !istype(target))
		return

	if(target.mind && !target.client)
		var/mob/dead/observer/ghost = mind_can_reenter(target.mind)
		if(ghost)
			var/mob/ghostmob = ghost.get_top_transmogrification()
			if(ghostmob)
				ghostmob << 'sound/effects/adminhelp.ogg'
				to_chat(ghostmob, "<span class='interface big'><span class='bold'>Someone is trying to revive your body. Return to it if you want to be resurrected!</span> \
					(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</span>")
				target.visible_message("<span class='warning'>[target] seems to shudder a bit.</span>")
				return
		return

	target.visible_message("<span class='warning'>[target] shudders, and starts breathing.</span>")
	target.limitedrevive()

	to_chat(user, "<span_class='sinister'>You feel drained...</span>")
	user.mutations |= M_NOCLONE
	user.dna.mutantrace = "shadow"
	user.update_mutantrace()
