#define SPAWN_SHARDS_DISABLED 0
#define SPAWN_SHARDS_WEAK 1
#define SPAWN_SHARDS_STRONG 2

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

	level_max = list(Sp_TOTAL = 6, Sp_SPEED = 4, Sp_POWER = 2)
	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_shoes"

	var/spawn_shards = SPAWN_SHARDS_DISABLED

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

		switch(spawn_shards)
			if(SPAWN_SHARDS_WEAK) //Spawn 4 shards if shoes were stolen
				if(old_shoes)
					summon_shards(get_turf(target), cardinal)
			if(SPAWN_SHARDS_STRONG) //Spawn 8 shards always
				summon_shards(get_turf(target), alldirs)

/spell/targeted/shoesnatch/proc/summon_shards(turf/T, list/dirlist)
	for(var/D in dirlist)
		var/obj/item/weapon/shard/S = new(T)
		step(S, D)
		S.alpha = 0
		animate(S, alpha = 255, time = 10)

/spell/targeted/shoesnatch/empower_spell()
	spell_levels[Sp_POWER]++
	spawn_shards++

	var/upgrade_desc = "You have upgraded [name]."
	switch(spawn_shards)
		if(SPAWN_SHARDS_WEAK)
			upgrade_desc = "You have upgraded [name] into Shoe Snatching Scourge. Whenever it successfully removes shoes from the victim, it will also surround them with 4 glass shards."
			name = "Shoe Snatching Scourge"
			desc = "This spell allows you to steal somebody's shoes right off of their feet. If you successfully steal the shoes, 4 glass shards will surround the victim."
		if(SPAWN_SHARDS_STRONG)
			upgrade_desc = "You have upgraded [name] into Super Shoe Snatching Scourge. The amount of summoned glass shards has been increased to 8, and they will always appear - even if the victim wasn't wearing any shoes."
			name = "Super Shoe Snatching Scourge"
			desc = "This spell allows you to steal somebody's shoes right off of their feet. In addition, 8 glass shards will surround the victim - even if they weren't wearing any shoes."

	return upgrade_desc

#undef SPAWN_SHARDS_DISABLED
#undef SPAWN_SHARDS_WEAK
#undef SPAWN_SHARDS_STRONG
