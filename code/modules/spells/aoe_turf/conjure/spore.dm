/spell/aoe_turf/conjure/spore
	name = "Spawn Spores"
	desc = "It's nearly impossible to keep what is writhing inside you from breaking out. Release it."

	school = "conjuration"
	invocation_type = SpI_EMOTE
	invocation = "kneels down as their eyes roll back and creatures emerge from their mouth."
	still_recharging_msg = "<span class='notice'>You are still recovering.</span>"
	spell_flags = 0
	user_type = USER_TYPE_OTHER
	charge_max = 300
	summon_type = list(/mob/living/simple_animal/hostile/blobspore/small)
	summon_amt = 2

	hud_state = "spawn_spores"

/spell/aoe_turf/conjure/spore/cast_check(skipcharge = 0, mob/user = usr)
	if (user.reagents && !user.reagents.has_reagent(SPORE))
		var/spell/aoe_turf/conjure/spore/S
		user.remove_spell(S)
		return 0

	if (iscarbon(user))
		var/mob/living/carbon/host = user
		if (host.wear_mask?.is_muzzle || !host.hasmouth())
			to_chat(user, "You try to open your mouth, but something's in the way!")
			return 0

	return ..(skipcharge, user)

/spell/aoe_turf/conjure/spore/summon_object(var/type, var/location)
	var/mob/living/simple_animal/hostile/blobspore/small/B = new type(location)
	B.friends += makeweakref(src.holder)

/spell/aoe_turf/conjure/spore/after_cast(list/targets)
	if (iscarbon(src.holder))
		var/mob/living/carbon/host = src.holder
		host.Stun(2)
		host.Knockdown(2)
		if (host.reagents)
			host.reagents.remove_reagent(SPORE, 5)
	var/turf/simulated/pos = get_turf(src.holder)
	pos.add_blood_floor(src.holder)
	playsound(pos, 'sound/effects/splat.ogg', 50, 1)

/mob/living/simple_animal/hostile/blobspore/small
	pass_flags = PASSTABLE | PASSMOB | PASSBLOB
	size = SIZE_TINY
	flying = TRUE
	health = 15
	maxHealth = 15

/mob/living/simple_animal/hostile/blobspore/small/New(loc)
	..(loc)
	var/matrix/M = matrix()
	M.Scale(0.5, 0.5)
	transform = M
