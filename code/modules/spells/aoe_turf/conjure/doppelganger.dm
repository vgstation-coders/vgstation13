/spell/aoe_turf/conjure/doppelganger
	name = "Doppelganger"
	desc = "This spell summons a construct with your appearance."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	summon_type = list(/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/melee)

	price = SP_BASE_PRICE / 2
	level_max = list(SP_TOTAL = 2, SP_SPEED = 2)
	charge_cooldown_max = 30 SECONDS
	cooldown_reduc = 10 SECONDS
	cooldown_min = 10 SECONDS
	invocation = "MY O'N CLO'N"
	invocation_type = SP_INV_SHOUT
	spell_flags = NEEDSCLOTHES | IS_HARMFUL
	hud_state = "wiz_doppelganger"
	var/spell_duration = 8 MINUTES


var/list/doppelgangers_count_by_wizards = list()
var/list/doppelgangers = list()
#define MAX_DOPPLES 15

// Sanity : don't copy more than one guy
/spell/aoe_turf/conjure/doppelganger/cast_check(skipcharge = 0,mob/user = usr)
	if (doppelgangers_count_by_wizards[user] > MAX_DOPPLES) // We summoned too much doppels :(
		to_chat(user, "<span class = 'warning'>We have duplicated ourselves too much in this plane.</span>")
		return FALSE
	var/list/L = view(user, 0)
	L -= user
	for (var/mob/M in L)
		return FALSE // If there is even one mob, we ABORT
	return ..()

/spell/aoe_turf/conjure/doppelganger/summon_object(var/type, var/location)
	var/mob/living/simple_animal/hostile/humanoid/wizard/doppelganger/D = new type(location)
	if(ismob(holder))
		doppelgangers[D] = holder
	D.appearance = holder.appearance
	D.alpha = OPAQUE // No more invisible doppels
	doppelgangers_count_by_wizards[holder]++ // Update the counts of doppels we summoned
	spawn (spell_duration)
		if(D.stat != DEAD)
			D.death()

/spell/aoe_turf/conjure/doppelganger/on_holder_death(mob/user)
	if(!user)
		user = holder
	if(doppelgangers)
		for(var/mob/M in doppelgangers)
			if(doppelgangers[M] == user)
				doppelgangers[M] = null
				doppelgangers -= M