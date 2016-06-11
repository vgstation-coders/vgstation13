/mob/living/simple_animal/hostile/humanoid/nazi
	name = "Nazi Trooper"
	desc = "Sieg Heil!"
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "nazigun"
	icon_living = "nazigun"
	icon_dead = "nazidead"
	icon_gib = "syndicate_gib"

	speak = list("Ze healing is not as revarding as ze hurting.","Schweinhunds!","Can you feel ze Schadenfreude?","Ach, was ist los?")
	speak_emote = list("says")
	emote_hear = list("says")
	emote_see = list("hums")
	attacktext = "stabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_chance = 5

	health = 200
	maxHealth = 200

	melee_damage_lower = 20
	melee_damage_upper = 20

	corpse = null
	items_to_drop = list(
		/obj/item/weapon/kitchen/utensil/knife/large,
		)

	faction = "nazi"
	persist = 1

	ranged = 1
	retreat_distance = 4
	minimum_distance = 2
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = null

	light_range = 4
	light_color = "#FF2222"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000

	environment_smash = 0

	var/ammo = 6
	var/reloads = 2
	var/datum/effect/effect/system/trail/ion_trail

/mob/living/simple_animal/hostile/humanoid/nazi/New()
	. = ..()
	ion_trail = new /datum/effect/effect/system/trail()
	ion_trail.set_up(src)
	ion_trail.start()

/mob/living/simple_animal/hostile/humanoid/nazi/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/humanoid/nazi/Die()
	..()

	var/obj/item/weapon/gun/projectile/mateba/M = new(loc)
	M.loaded = list()
	for(var/i=1;i<=ammo;i++)
		M.loaded += new /obj/item/ammo_casing/a357(M)

	for(var/i=1;i<=reloads;i++)
		new /obj/item/ammo_storage/speedloader/a357(loc)

/mob/living/simple_animal/hostile/humanoid/nazi/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	..()
	ammo--
	new /obj/item/ammo_casing/a357(loc,1)// empty casing, for some reason using casingtype wasn't working
	if(ammo <= 0)
		if(reloads > 0)
			spawn(10)
				playsound(user, 'sound/weapons/revolver_spin.ogg', 100, 1)
			reloads--
			new /obj/item/ammo_storage/speedloader/a357/empty(loc)
			ammo = 6
		else
			//we be going berserker
			emote("me",1,"puts away his mateba and tighten the grip on his knife.")
			icon_state = "naziknife"
			icon_living = "naziknife"
			melee_damage_lower = 40
			melee_damage_upper = 40
			retreat_distance = 0
			minimum_distance = 0
			ranged = 0
			spawn(10)
				say("Come over here. I promise I will heal you!")
