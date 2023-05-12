/spell/targeted/civilwarconvert
	name = "Conversion"
	desc = "This spell allows you to convert someone to your side of the civil war."
	abbreviation = "CF"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	price = 40
	school = "evocation"
	charge_max = 150
	invocation = "WOLOLO!"
	invocation_type = SpI_SHOUT
	range = 1
	spell_flags = WAIT_FOR_CLICK
	cooldown_min = 10
	civil_war_only = TRUE
	compatible_mobs = list(/mob/living/carbon/human)
	cast_sound = 'sound/effects/aoe2/30 wololo.ogg'
	hud_state = "apprentice-logo"
	override_icon = 'icons/logos.dmi'
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 3)

/spell/targeted/civilwarconvert/cast_check(skipcharge = 0,mob/user = usr)
	return ..() && find_active_faction_by_typeandmember(/datum/faction/wizard/civilwar, null, user.mind)

/spell/targeted/civilwarconvert/is_valid_target(var/target, var/mob/user, var/list/options)
	if(..())
		var/mob/living/carbon/human/H = target
		if(!istype(H))
			return FALSE
		for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
			if(L.imp_in == H) // a check if it's actually implanted
				return FALSE
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
				WC.ForgeObjectives()
			if(WC.faction && WC.faction != F)
				WC.faction.HandleRemovedRole(WC)
			F.HandleRecruitedRole(WC)
			WC.Greet()
			WC.OnPostSetup()
			WC.AnnounceObjectives()

/spell/targeted/civilwarconvert/on_added(mob/user)
	var/datum/faction/ourfact = find_active_faction_by_typeandmember(/datum/faction/wizard/civilwar, null, user.mind)
	var/datum/faction/enemyfaction = ourfact.enemy_faction
	for(var/datum/role/wizard/W in enemyfaction)
		alert(W.antag.current, "A memeber of [ourfact] has just purchased the Conversion spell! They will be able to send converted crew members to attack your team!", "Civil War Converter","Understood")
