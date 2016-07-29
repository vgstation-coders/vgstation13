/spell/targeted/shoesnatch

	name = "Shoe Snatching Charm"
	desc = "This spell allows you to steal somebody's shoes right off of their feet!"
	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	invocation = "H'NK!"
	invocation_type = SpI_SHOUT
	range = 7
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK
	cooldown_min = 30
	selection_type = "range"

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 1)
	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_shoes"

	var/spawn_shards = 0

/spell/targeted/shoesnatch/cast(list/targets, mob/user = user)
	..()
	for(var/mob/living/carbon/human/target in targets)
		var /obj/old_shoes = target.shoes
		if(old_shoes)
			sparks_spread = 1
			sparks_amt = 4
			target.drop_from_inventory(old_shoes)
			target.visible_message(	"<span class='danger'>[target]'s shoes suddenly vanish!</span>", \
									"<span class='danger'>Your shoes suddenly vanish!</span>")
			user.put_in_active_hand(old_shoes)

		if(spawn_shards)
			for(var/D in alldirs)
				var/obj/item/weapon/shard/S = new(get_turf(target))
				step(S, D)
				S.alpha = 0
				animate(S, alpha = 255, time = 10)

/spell/targeted/shoesnatch/empower_spell()
	spell_levels[Sp_POWER]++
	spawn_shards = 1

	name = "Shoe Snatching Scourge"
	desc = "This spell allows you to steal somebody's shoes right off of their feet and surround them with glass shards."
	return "You have improved Shoe Snatching Charm into [name]. It will now summon 8 glass shards around the victim in addition to stealing their shoes."
