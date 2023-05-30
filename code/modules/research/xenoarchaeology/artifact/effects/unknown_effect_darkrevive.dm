/datum/artifact_effect/darkrevive
	effecttype = "darkrevive"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ELDRITCH, ARTIFACT_STYLE_WIZARD)
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
			if(!head || head.status & ORGAN_DESTROYED || (M_NOCLONE in H.mutations) || !H.has_brain())
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
		if(target.ghost_reenter_alert("Someone is trying to revive your body. Return to it if you want to be resurrected!"))
			target.visible_message("<span class='warning'>[target] seems to shudder a bit.</span>")
		return

	target.visible_message("<span class='warning'>[target] shudders, and starts breathing.</span>")
	target.limitedrevive()

	to_chat(user, "<span_class='sinister'>You feel drained...</span>")
	user.mutations |= M_NOCLONE
	user.dna.mutantrace = "shadow"
	user.update_mutantrace()
