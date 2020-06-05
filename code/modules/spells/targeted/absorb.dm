/spell/targeted/absorb
	name = "Absorb"
	desc = "This spell allows you to absorb the magical abilities from fallen wizards. You must be standing over their lifeless or mutilated body in order for the spell to work."
	abbreviation = "AB"
	user_type = USER_TYPE_SPELLBOOK

	school = "evocation"
	charge_max = 100
	spell_flags = IS_HARMFUL
	invocation_type = SpI_SHOUT
	range = 0
	cooldown_min = 200

	hud_state = "wiz_disint_old"


/spell/targeted/absorb/invocation()
	invocation = pick("B'TES TH' DUST", "H'STA LA V'STA", "S'AY'NARA", "G'ME 'VER")
	..()

/spell/targeted/absorb/cast(var/list/targets)
	..()
	var/mob/living/L = holder
	for(var/mob/living/target in targets)
		if(ishuman(target) || ismonkey(target))
			var/mob/living/carbon/C = target
			if(!C.mind)
				to_chat(holder, "<span class='warning'>This being is devoid of any magic.</span>")
			else if(!C.isDead() && !C.isInCrit())
				to_chat(holder, "<span class='warning'>Your enemy is still full of life! Kill or maim them!</span>")
			else if(isapprentice(target))	//So wizards with absorb don't abuse their own apprentices for double spells
				to_chat(holder, "<span class='warning'>Only a fool would steal magic from an apprentice.</span>")
			else
				var/obj/effect/cult_ritual/feet_portal/P = new (holder.loc, holder, src)
				if(do_after(holder, target, 5 SECONDS, use_user_turf = TRUE))
					qdel(P)
					var/hasAbsorbed = FALSE
					var/canAbsorb = TRUE
					for(var/spell/targetspell in C.spell_list)
						canAbsorb = TRUE
						for(var/spell/holderspell in L.spell_list)
							if(targetspell.user_type != USER_TYPE_WIZARD && targetspell.user_type != USER_TYPE_SPELLBOOK)
								continue
							if(targetspell.type == holderspell.type)
								canAbsorb = FALSE
						/*		if(holderspell.can_improve(Sp_POWER))
									to_chat(holder, "<span class='notice'>You asborb the magical energies from your foe and have empowered [targetspell.name]!</span>")
									holderspell.apply_upgrade(Sp_POWER)
									hasAbsorbed = TRUE
								if(holderspell.can_improve(Sp_SPEED))
									to_chat(holder, "<span class='notice'>You asborb the magical energies from your foe and have quickened [targetspell.name]!</span>")
									holderspell.apply_upgrade(Sp_SPEED)
									hasAbsorbed = TRUE	*/
						if(canAbsorb)
							to_chat(target, "<span class='warning'>You feel the magical energy being drained from you!</span>")
							to_chat(target, "<span class='warning'>You forget how to cast [targetspell.name]!</span>")
							to_chat(holder, "<span class='notice'>You asborb the magical energies from your foe and have learned [targetspell.name]!</span>")
							L.attack_log += text("\[[time_stamp()] <font color='orange'>[L.real_name] ([L.ckey]) absorbed the spell [targetspell.name] from [C.real_name] ([C.ckey]).</font>")
							C.remove_spell(targetspell)
							L.add_spell(targetspell)
							if(!hasAbsorbed)
								hasAbsorbed = TRUE
					if(!hasAbsorbed)
						to_chat(holder, "<span class='notice'>You find magical energy within your foe, but there is nothing new to learn.</span>")
					if(iswizard(target))	//Wizards aren't wizards without magic! Dust their asses if they're a wizard
						target.dust()
						L.visible_message("<span class='sinister'>[C.real_name] dissolves in a burst of light!</span>")
				if(P)		//Remove portal effect if the absorbtion is cancelled early.
					qdel(P)





