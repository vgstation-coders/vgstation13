/spell/targeted/mind_transfer
	name = "Mind Transfer"
	desc = "Switch bodies with somebody adjacent to you. Both you and your target regain your mind and knowledge of spells."
	abbreviation = "MT"
	user_type = USER_TYPE_WIZARD
	specialization = UTILITY

	school = "transmutation"
	charge_max = 600
	spell_flags = 0
	invocation = "GIN'YU CAPAN"
	invocation_type = SpI_WHISPER
	max_targets = 1
	mind_affecting = 1
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank
	compatible_mobs = list(/mob/living/carbon/human,/mob/living/carbon/monkey) //which types of mobs are affected by the spell. NOTE: change at your own risk

	var/list/protected_roles = list("Wizard","Changeling","Cultist") //which roles are immune to the spell
	var/msg_wait = 500 //how long in deciseconds it waits before telling that body doesn't feel right or mind swap robbed of a spell
	amt_paralysis = 20 //how much the victim is paralysed for after the spell

	hud_state = "wiz_mindswap"

/spell/targeted/mind_transfer/cast(list/targets, mob/user)
	..()

	for(var/mob/living/target in targets)
		if(target.stat == DEAD)
			to_chat(user, "You didn't study necromancy back at the Space Wizard Federation academy.")
			continue

		else if(!target.key || !target.mind)
			to_chat(user, "They appear to be catatonic. Not even magic can affect their vacant mind.")
			continue

		else if(target.mind.special_role in protected_roles)
			to_chat(user, "Their mind is resisting your spell.")
			continue
		else
			var/mob/living/victim = target//The target of the spell whos body will be transferred to.
			var/mob/living/caster = user//The wizard/whomever doing the body transferring.

			//MIND TRANSFER BEGIN
			if(caster.mind.special_verbs.len)//If the caster had any special verbs, remove them from the mob verb list.
				for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
					caster.verbs -= V//But a safety nontheless.
			if(victim.mind.special_verbs.len)//Now remove all of the victim's verbs.
				for(var/V in victim.mind.special_verbs)
					victim.verbs -= V

			var/list/victim_spells = victim.spell_list.Copy()
			var/list/caster_spells = caster.spell_list.Copy()
			for(var/spell/S in caster_spells)
				caster.remove_spell(S)
			for(var/spell/S in victim_spells)
				victim.remove_spell(S)

			var/mob/living/dummy = new(caster.loc)
			caster.mind.transfer_to(dummy)
			victim.mind.transfer_to(caster)
			dummy.mind.transfer_to(victim)
			qdel(dummy)

			for(var/spell/S in caster_spells)
				victim.add_spell(S)
			for(var/spell/S in victim_spells)
				caster.add_spell(S)

			if(victim.mind.special_verbs.len)//To add all the special verbs for the original caster.
				for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
					caster.verbs += V
			if(caster.mind.special_verbs.len)//If they had any special verbs, we add them here.
				for(var/V in caster.mind.special_verbs)
					victim.verbs += V
			//ticker.mode.update_all_wizard_icons()
			//MIND TRANSFER END

			//Target is handled in ..(), so we handle the caster here
			caster.Paralyse(amt_paralysis)

			//After a certain amount of time the victim gets a message about being in a different body.
			spawn(msg_wait)
				to_chat(caster, "<span class='danger'>You feel woozy and lightheaded. Your body doesn't seem like your own.</span>")
