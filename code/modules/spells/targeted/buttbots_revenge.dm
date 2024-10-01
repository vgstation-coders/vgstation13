/spell/targeted/buttbots_revenge
	name = "Butt-Bot's Revenge"
	desc = "This spell removes the target's ass in a firey explosion."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE
	abbreviation = "AN"

	school = "evocation"
	charge_max = 500
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK | IS_HARMFUL
	invocation = "ARSE NATH"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank
	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)
	sparks_spread = 1
	sparks_amt = 4
	valid_targets = list(/mob/living/carbon/human,/mob/living/carbon/monkey)

	amt_knockdown = 8
	amt_stunned = 8

	hud_state = "wiz_butt"

	var/summon_bot = 0

/spell/targeted/buttbots_revenge/cast(var/list/targets)
	..()
	for(var/mob/living/target in targets)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.butt_blast()
			if(summon_bot)
				var/obj/machinery/bot/buttbot/assbot = new /obj/machinery/bot/buttbot(H.loc)
				for(var/obj/item/clothing/head/butt/B in H.loc)
					assbot.stored_ass = B
					B.forceMove(assbot)
					break
	return

/spell/targeted/buttbots_revenge/empower_spell()
	spell_levels[Sp_POWER]++
	summon_bot = 1

	var/upgrade_desc = "You have upgraded [name] into Butt-Bot's Legacy. When successfully cast on someone it will turn their butt into a working butt-bot."
	name = "Butt-Bot's Legacy"
	desc = "This spell removes the target's ass in a firey explosion, turning it into a fully functioning butt-bot."

	return upgrade_desc

/spell/targeted/buttbots_revenge/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Make the spell instead summon a butt-bot at the target's location."
	return ..()
