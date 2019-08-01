/spell/targeted/buttbots_revenge
	name = "Butt-Bot's Revenge"
	desc = "This spell removes the target's ass in a firey explosion."
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE
	abbreviation = "AN"

	school = "evocation"
	charge_max = 500
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK
	invocation = "ARSE NATH"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank
	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)
	sparks_spread = 1
	sparks_amt = 4

	amt_knockdown = 8
	amt_stunned = 8

	hud_state = "wiz_butt"

	var/summon_bot = 0

/spell/targeted/buttbots_revenge/cast(var/list/targets)
	..()
	for(var/mob/living/target in targets)
		if(ishuman(target) || ismonkey(target))
			var/mob/living/carbon/C = target
			if(C.op_stage.butt != 4) // does the target have an ass
				if(summon_bot)
					new /obj/machinery/bot/buttbot(C.loc)
				else
					var/obj/item/clothing/head/butt/B = new(C.loc)
					B.transfer_buttdentity(C)
				C.op_stage.butt = 4 //No having two butts.
				to_chat(C, "<span class='warning'>Your ass just blew up!</span>")
			playsound(src, 'sound/effects/superfart.ogg', 50, 1)
			C.apply_damage(40, BRUTE, LIMB_GROIN)
			C.apply_damage(10, BURN, LIMB_GROIN)
			score["assesblasted"]++
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
