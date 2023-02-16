/spell/targeted/civilwarconvert
	name = "Convert to faction"
	desc = "This spell allows you to convert someone to your side of the civil war."
	abbreviation = "CF"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	price = 40
	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	invocation = "WOLOLO!"
	invocation_type = SpI_SHOUT
	range = 7
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	cooldown_min = 10
	selection_type = "range"
	civil_war_only = TRUE
	compatible_mobs = list(/mob/living/carbon/human)
	cast_sound = 'sound/effects/aoe2/30 wololo.ogg'
	hud_state = ""

/spell/targeted/civilwarconvert/cast_check(skipcharge = 0,mob/user = usr)
	return ..() && find_active_faction_by_typeandmember(/datum/faction/wizard/civilwar, null, user.mind)

/spell/targeted/civilwarconvert/is_valid_target(var/target, var/mob/user, var/list/options)
	if(..())
		var/mob/living/carbon/human/H = target
		var/datum/faction/ourfact = find_active_faction_by_typeandmember(/datum/faction/wizard/civilwar, null, user.mind)
		var/datum/faction/theirfact = find_active_faction_by_typeandmember(/datum/faction/wizard/civilwar, null, H.mind)
		return !iswizard(H) && H.mind && ourfact != theirfact

/spell/targeted/civilwarconvert/cast(list/targets, mob/user = user)
	..()
	var/datum/faction/F = find_active_faction_by_typeandmember(/datum/faction/wizard/civilwar, null, user.mind)
	if(F)
		for(var/mob/living/carbon/human/target in targets)
			var/datum/role/wizard_convert/WC = target.mind.GetRole(WIZARD_CONVERT)
			if(!WC)
				WC = new
				WC.AssignToRole(target.mind,1)
			if(WC.faction != F)
				WC.faction.HandleRemovedRole(WC)
			F.HandleRecruitedRole(WC)
			WC.Greet()
			WC.OnPostSetup()
			WC.ForgeObjectives()
			WC.AnnounceObjectives()
