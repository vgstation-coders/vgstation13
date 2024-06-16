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
				var/has_spell_to_steal = FALSE //If false, will not go through the do_after()
				for(var/spell/targetspell in C.spell_list)
					if(targetspell.is_wizard_spell())
						has_spell_to_steal = TRUE
						break
				if(!has_spell_to_steal)
					to_chat(holder, "<span class='warning'>The target has no spells that you can steal!</span>")
					return
				var/obj/effect/absorb_effect/E = new (holder.loc, holder)
				if(do_after(holder, target, 5 SECONDS, use_user_turf = TRUE))
					qdel(E)
					var/hasAbsorbed = FALSE
					var/canAbsorb = TRUE
					for(var/spell/targetspell in C.spell_list)
						if(!targetspell.is_wizard_spell()) //Not a wizard spell, disregard
							continue
						canAbsorb = TRUE
						var/consumed_spell = FALSE //If consumed, will not give the absorber a new spell.
						for(var/spell/holderspell in L.spell_list)
							if(!holderspell.is_wizard_spell())
								continue
							if(targetspell.type == holderspell.type)
								canAbsorb = FALSE
								if(holderspell.can_improve(Sp_POWER)) //Prioritize empowerments over cooldown upgrades
									to_chat(holder, "<span class='notice'>You absorb the magical energies from your foe and have empowered [targetspell.name]!</span>")
									holderspell.apply_upgrade(Sp_POWER)
									hasAbsorbed = TRUE
									consumed_spell = TRUE
								else if(holderspell.can_improve(Sp_SPEED))
									to_chat(holder, "<span class='notice'>You absorb the magical energies from your foe and have quickened [targetspell.name]!</span>")
									holderspell.apply_upgrade(Sp_SPEED)
									hasAbsorbed = TRUE
									consumed_spell = TRUE
						if(canAbsorb)
							to_chat(target, "<span class='warning'>You feel the magical energy being drained from you!</span>")
							to_chat(target, "<span class='warning'>You forget how to cast [targetspell.name]!</span>")
							if(!consumed_spell)
								to_chat(holder, "<span class='notice'>You absorb the magical energies from your foe and have learned [targetspell.name]!</span>")
							L.attack_log += text("\[[time_stamp()] <font color='orange'>[L.real_name] ([L.ckey]) absorbed the spell [targetspell.name] from [C.real_name] ([C.ckey]).</font>")
							var/wizard_user = iswizard(L) //Wizards will steal and store it in their wizard spells
							C.remove_spell(targetspell)
							if(!consumed_spell)
								L.add_spell(targetspell, iswizard = wizard_user)
							if(!hasAbsorbed)
								hasAbsorbed = TRUE
					if(!hasAbsorbed)
						to_chat(holder, "<span class='notice'>You find magical energy within your foe, but there is nothing new to learn.</span>")
					if(iswizard(target))	//Wizards aren't wizards without magic! Dust their asses if they're a wizard
						C.visible_message("<span class='sinister'>[C.real_name] dissolves in a burst of light!</span>")
						target.dust()
				if(E)		//Remove portal effect if the absorbtion is cancelled early.
					qdel(E)

///////////////

/obj/effect/absorb_effect
	icon_state = "absorb" // I renamed it but the icon is still a duplicate from rune_rejoin, would be nice if some spriter tweaked it
	anchored = 1
	pixel_y = -10
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	flags = PROXMOVE
	var/mob/living/caster = null

/obj/effect/absorb_effect/New(var/turf/loc, var/mob/living/user)
	..()
	caster = user
	if (!caster)
		qdel(src)

/obj/effect/absorb_effect/Destroy()
	caster = null
	..()

/obj/effect/absorb_effect/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		forceMove(get_turf(caster))

/obj/effect/absorb_effect/cultify()
	return

/obj/effect/absorb_effect/ex_act()
	return

/obj/effect/absorb_effect/emp_act()
	return

/obj/effect/absorb_effect/blob_act()
	return

/obj/effect/absorb_effect/singularity_act()
	return



