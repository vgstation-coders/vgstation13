/mob/living/simple_animal/hostile/fishing/eswordfish
	name = "eswordfish"
	desc = "While many space fish have evolved unique and interesting ways to hunt and defend themselves, the eswordfish's methods are a bit more direct."
	icon_state = "eswordfish"
	icon_living = "eswordfish"
	icon_dead = "eswordfish_dead"
	meat_type =
	butchering_drops = /obj/item/weapon/melee/energy/sword/eswordfish
	faction = "eswordfish"
	size = SIZE_NORMAL
	minCatchSize = 20
	maxCatchSize = 40 //Decides esword force. Base will always be weaker than esword, mutations + bait can make it much stronger.
	health = 80
	maxhealth = 80
	var/activatedSword = FALSE

/mob/living/simple_animal/hostile/fishing/eswordfish/Aggro()
	if(!activatedSword)
		spawn(5)
			eswordfishActivate()
	..()

/mob/living/simple_animal/hostile/fishing/eswordfish/LoseAggro()
	..()
	if(activatedSword)
		spawn(10)
			eswordfishDeactivate()

/mob/living/simple_animal/hostile/fishing/eswordfish/proc/eswordfishActivate()
	activatedSword = TRUE
	playsound(src, "sound/weapons/saberon.ogg", 100, 1)
	melee_damage_lower = catchSize
	melee_damage_upper = catchSize
	armor_modifier = 0.5
	environment_smash_flags = 1
	melee_damage_type = BURN

/mob/living/simple_animal/hostile/fishing/eswordfish/proc/eswordfishDeactivate()
	activatedSword = FALSE
	playsound(src, "sound/weapons/saberoff.ogg", 50, 1)
	melee_damage_lower = 1
	melee_damage_upper = 5
	armor_modifier = 1
	environment_smash_flags = 0
	melee_damage_type = BRUTE

/obj/item/weapon/melee/energy/sword/eswordfish
	name = "fish-e-sword"
	desc = "The organ of a eswordfish that produces its energy-snout, still attached to part of its skull for use as a handle"
	icon_state = "fishesword0"
	base_state = "fishesword"
	activeforce = 10
	origin_tech = Tc_BIOTECH + "=4", Tc_COMBAT + "=2"
	mech_flags = MECH_SCAN_FAIL
	duelsaber_type = null //maybe later
	var/mutation = null

/datum/butchering_product/fish_esword
	result = /obj/item/weapon/melee/energy/sword/eswordfish
	verb_name = "remove snout"
	verb_gerund = "removing the snout from "
	amount = 1
	butcher_time = 25

/datum/butchering_product/fish_esword/spawn_result(location, mob/parent)
	if(!amount)
		return
	amount--
	if(istype(/mob/living/simple_animal/hostile/fishing/eswordfish, parent))
	var/mob/living/simple_animal/hostile/fishing/eswordfish/F = parent
	F.mob_property_flags |= MOB_NO_LAZ
	var/obj/item/weapon/melee/energy/sword/eswordfish/eS = new /obj/item/weapon/melee/energy/sword/eswordfish(location)
	I.inheritESwordFish(F)

/obj/item/weapon/melee/energy/sword/eswordfish/proc/inheritESwordFish(/mob/living/simple_animal/hostile/fishing/eswordfish/F)
	activeforce = F.catchSize/2
	mutation = F.mutation

/obj/item/weapon/melee/energy/sword/eswordfish/attack(mob/target, mob/living/user)
	..()
	if(mutation && active && prob(activeforce))
		switch(mutation)
			if(FISH_CLOWN)
				playsound(target, 'sound/items/bikehorn.ogg', 50, 1)
				if(prob(activeforce))
					target.Knockdown(1)
			if(FISH_POISON)
				target.reagents.add_reagent(TOXIN, 5)
			if(FISH_BLUESPACE)
				do_teleport(target, target.loc, 1)
