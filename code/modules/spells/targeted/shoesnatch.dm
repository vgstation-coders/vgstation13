/spell/targeted/shoesnatch
	name = "Shoe Snatching Charm"
	desc = "This spell allows you to steal somebody's shoes right off of their feet!"
	abbreviation = "SS"
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

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
	valid_targets = list(/mob/living/carbon/human)

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
			old_shoes.forceMove(user.loc)
			user.put_in_active_hand(old_shoes)
			score.shoesnatches++

		else if(spawn_shards) //Spawn shards if the target isn't wearing shoes
			to_chat(user, "<span class='danger'>You conjure several glass shards around \the [target].</span>")
			target.show_message("<span class='danger'>You are surrounded by glass shards!</span>", MESSAGE_SEE)
			summon_shards(get_turf(target), cardinal)

/spell/targeted/shoesnatch/proc/summon_shards(turf/T, list/dirlist)
	for(var/D in dirlist)
		var/obj/item/weapon/shard/S = new(T)
		step(S, D)
		S.alpha = 0
		animate(S, alpha = 255, time = 10)

/spell/targeted/shoesnatch/empower_spell()
	spell_levels[Sp_POWER]++
	spawn_shards = 1

	var/upgrade_desc = "You have upgraded [name] into Shoe Snatching Scourge. When cast on somebody who isn't wearing any shoes, it will summon 4 glass shards around them."
	name = "Shoe Snatching Scourge"
	desc = "This spell allows you to steal somebody's shoes right off of their feet. If they aren't wearing any shoes, 4 glass shards will be conjured around them."

	return upgrade_desc

/spell/targeted/shoesnatch/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Make the spell summon glass shards around targets who aren't wearing any shoes."
	return ..()
