/spell/targeted/disease
	name = "Diseased Touch (50)"
	desc = "Touches your victim with infected blood giving them the Shutdown Syndrome which quickly shuts down their major organs resulting in a quick painful death."
	abbreviation = "HN"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN
	cooldown_min = 3 MINUTES
	selection_type = "range"

	override_base = "vamp"
	hud_state = "vampire_disaese"

	var/blood_cost = 50

/spell/targeted/disease/cast_check(skipcharge = 0,mob/user = usr)
	. = ..()
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/targeted/disease/is_valid_target(var/target, var/mob/user, var/list/options)
	if (!ismob(target))
		return FALSE

	var/mob/M = target

	var/success = M.vampire_affected(user.mind)
	switch (success)
		if (TRUE)
			return ..()
		if (FALSE)
			return FALSE
		if (VAMP_FAILURE)
			critfail(target, user)
			return FALSE

/spell/targeted/disease/cast(var/list/targets, var/mob/user)
	if (targets.len > 1)
		return FALSE

	var/datum/role/vampire/V = isvampire(user)
	if(!V)
		return FALSE

	var/mob/living/carbon/target = targets[1]

	log_admin("[key_name(user)] has death-touched [key_name(target)]. The latter will die in moments.")
	message_admins("[key_name(user)] has death-touched [key_name(target)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</A>). The latter will die in moments.")
	var/datum/disease2/disease/S = new ()
	S.form = "Virus"//Because the form is given away by the Health Analyser and we don't want to out the vampire right away.
	S.infectionchance = 100
	S.infectionchance_base = 100
	S.stageprob = 0//single-stage
	S.stage_variance = 0
	S.max_stage = 1
	S.can_kill = list()
	var/datum/disease2/effect/organs/vampire/O = new /datum/disease2/effect/organs/vampire
	O.chance = 10
	O.max_chance = 10
	S.strength = rand(70,100)
	S.robustness = 100
	S.antigen = list(pick(all_antigens))
	S.antigen |= pick(all_antigens)
	S.spread = SPREAD_BLOOD
	S.uniqueID = rand(0,9999)
	S.subID = rand(0,9999)
	S.effects += O
	S.origin = "Vampire Touch"
	S.mutation_modifier = 0
	S.color = "#777777"
	S.pattern = 5
	S.pattern_color = "#555555"

	S.update_global_log()

	target.infect_disease2(S, notes="(Spell, from [key_name(user)])")

	V.remove_blood(blood_cost)

/spell/targeted/disease/critfail(var/list/targets, var/mob/user)
	to_chat(user, "<span class='danger'>It feels like your dead blood met with molten silver.</span>")
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		H.drip(50) // Coughing up quite some blood.
	var/datum/role/vampire/V = isvampire(user)
	if(V)
		V.remove_blood(3*blood_cost)
