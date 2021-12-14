/mob/living/simple_animal/hostile/arcane_golem
	name = "arcane golem"
	desc = "A soulless construct forged by a wizard. It's linked to its master's magic powers, and it casts spells simultaneously with them. If one of them dies, the other's spellcasting abilities will be affected."

	icon = 'icons/mob/critter.dmi'
	icon_state = "arcane_golem"
	icon_living = "arcane_golem"
	treadmill_speed = 0

	mob_property_flags = MOB_CONSTRUCT
	health = 200
	maxHealth = 200

	speak = list("Servio.", "Magister?", "Ego enim arcana.")
	speak_emote = list("vocalizes")

	speak_chance = 0.25
	move_to_delay = 20

	melee_damage_lower = 15
	melee_damage_upper = 25
	attacktext = "smashes its gauntlet into"
	attack_sound = 'sound/weapons/heavysmash.ogg'

	aggro_vision_range = 2
	idle_vision_range = 2

	var/spell/aoe_turf/conjure/arcane_golem/master_spell

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	stop_automated_movement = 1


/mob/living/simple_animal/hostile/arcane_golem/Destroy()
	..()

	if(master_spell)
		master_spell.golems.Remove(src)
		master_spell = null

/mob/living/simple_animal/hostile/arcane_golem/MoveToTarget()
	//This proc has been slightly modified to prevent the golem from chasing its targets
	//It will follow the master, and attack enemies when the opportunity arises
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return

	if(isturf(loc))
		var/target_distance = get_dist(src,target)
		if(ranged)//We ranged? Shoot at em
			if(target_distance >= 2 && ranged_cooldown <= 0)//But make sure they're a tile away at least, and our range attack is off cooldown
				OpenFire(target)
		if(target.Adjacent(src))	//If they're next to us, attack
			AttackingTarget()

/mob/living/simple_animal/hostile/arcane_golem/Life()
	..()

	if(!master_spell)
		return
	if(!master_spell.holder)
		master_spell = null
		return
	if(ckey)
		return

	var/mob/master = master_spell.holder
	if(istype(master))
		if(master.isDead() || isnull(master.loc))
			death()
			return

		//Alive - follow the master
		if(!isDead())
			if(canmove)
				Goto(master, move_to_delay)

/mob/living/simple_animal/hostile/arcane_golem/death(var/gibbed = FALSE)
	..(gibbed)

	//Punish the master by putting all of his spells on cooldown
	if(master_spell)
		var/mob/master = master_spell.holder

		if(istype(master))
			to_chat(master, "<span class='warning'>As your golem is destroyed, your mana leaks away!</span>")
			for(var/spell/S in master.spell_list)
				if(S.charge_type & Sp_RECHARGE)
					if(S.charge_counter == S.charge_max) //Spell is fully charged - let the proc handle everything
						S.take_charge()
					else //Spell is on cooldown and already recharging - there's no need to call S.process(), just reset charges to 0
						S.charge_counter = 0

	visible_message("<span class='warning'>\The <b>[src]</b> shatters into pieces!</span>")
	new /obj/item/weapon/ectoplasm (src.loc)
	qdel(src)
