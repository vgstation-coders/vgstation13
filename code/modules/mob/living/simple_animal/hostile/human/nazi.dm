/mob/living/simple_animal/hostile/humanoid/nazi
	name = "\improper Nazi"
	desc = "Sieg Heil!"
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "nazi"
	icon_living = "nazi"
	icon_dead = "nazi"
	icon_gib = "syndicate_gib"

	speak = list("Schweinhunds!","Can you feel ze Schadenfreude?","Ach, was ist los?")
	speak_emote = list("says")
	emote_hear = list("hums")
	emote_see = list("goose-steps", "heils")
	attacktext = "punches"
	attack_sound = "punch"
	speak_chance = 5

	health = 100
	maxHealth = 100

	melee_damage_lower = 5
	melee_damage_upper = 5

	corpse = /obj/effect/landmark/corpse/nazi

	items_to_drop = list(
		/obj/item/weapon/kitchen/utensil/knife/nazi,
		)

	faction = "nazi"

	ranged = 1
	retreat_distance = 7
	minimum_distance = 4
	projectiletype = /obj/item/projectile/bullet/midbullet2
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = /obj/item/ammo_casing/c9mm

	environment_smash_flags = 0

	var/ammo = 8
	var/reloads = 1
	ranged_cooldown_cap = 1

/mob/living/simple_animal/hostile/humanoid/nazi/Life()
	..()
	overlays.len = 0
	if(stance != HOSTILE_STANCE_IDLE)
		if(ranged)
			overlays += icon('icons/mob/in-hand/right/items_righthand.dmi',"gun")
			if(melee_damage_upper > 10)
				overlays += icon('icons/mob/in-hand/left/swords_axes.dmi',"knifenazi")
		else
			overlays += icon('icons/mob/belt.dmi',"gun")
			if (melee_damage_upper > 10)
				overlays += icon('icons/mob/in-hand/right/swords_axes.dmi',"knifenazi")

/mob/living/simple_animal/hostile/humanoid/nazi/death(var/gibbed = FALSE)
	droploot()
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/nazi/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	if(..())
		afterShoot()
		return 1
	return 0

/mob/living/simple_animal/hostile/humanoid/nazi/proc/afterShoot()
	ammo--
	if(ammo <= 0)
		if(reloads > 0)
			reloads--
			new /obj/item/ammo_storage/magazine/mc9mm/empty(loc)
			ammo = 8
		else
			melee_damage_lower = 15
			melee_damage_upper = 15
			attack_sound = 'sound/weapons/bladeslice.ogg'
			attacktext = "stabs"
			retreat_distance = 0
			minimum_distance = 0
			ranged = 0

/mob/living/simple_animal/hostile/humanoid/nazi/proc/droploot()
	var/obj/item/weapon/gun/projectile/luger/dropgun = new(loc)
	if(!ammo)
		qdel(dropgun.chambered)
		dropgun.chambered = null
		qdel(dropgun.stored_magazine)
	else
		ammo--
		var/removeAmmo = -1 * (ammo - 6)
		for(var/i=1;i<=removeAmmo;i++)
			var/obj/item/ammo_casing/C = pick(dropgun.stored_magazine.stored_ammo)
			dropgun.stored_magazine.stored_ammo -= C
			qdel(C)

	for(var/i=1;i<=reloads;i++)
		new /obj/item/ammo_storage/magazine/mc9mm(loc)

///////////////////////////////////////////////////////////////////SOLDIER///////////

/mob/living/simple_animal/hostile/humanoid/nazi/soldier
	name = "\improper Nazi Soldier"

	icon_state = "nazisoldier"
	icon_living = "nazisoldier"
	icon_dead = "nazisoldier"

	health = 150
	maxHealth = 150

	corpse = /obj/effect/landmark/corpse/nazi/soldier

	melee_damage_lower = 5
	melee_damage_upper = 5

	retreat_distance = 4
	minimum_distance = 3

	projectiletype = /obj/item/projectile/energy/plasma/MP40k
	projectilesound = 'sound/weapons/elecfire.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	ammo = 13
	ranged_cooldown_cap = 1
	casingtype = null

/mob/living/simple_animal/hostile/humanoid/nazi/soldier/Life()
	..()
	overlays.len = 0
	if(stance != HOSTILE_STANCE_IDLE)
		if(ranged)
			overlays += icon('icons/mob/in-hand/right/guninhands_right.dmi',"PlasMP100")
			if(melee_damage_upper > 10)
				overlays += icon('icons/mob/in-hand/left/swords_axes.dmi',"knifenazi")
		else
			overlays += icon('icons/mob/in-hand/left/guninhands_left.dmi',"PlasMP0")
			if (melee_damage_upper > 10)
				overlays += icon('icons/mob/in-hand/right/swords_axes.dmi',"knifenazi")

/mob/living/simple_animal/hostile/humanoid/nazi/soldier/afterShoot()
	ammo--
	if(ammo <= 0)
		melee_damage_lower = 15
		melee_damage_upper = 15
		attack_sound = 'sound/weapons/bladeslice.ogg'
		attacktext = "stabs"
		retreat_distance = 0
		minimum_distance = 0
		ranged = 0
		spawn(200)
			if(health > 0)
				ammo = 13
				melee_damage_lower = 5
				melee_damage_upper = 5
				retreat_distance = 4
				minimum_distance = 2
				attacktext = "punches"
				attack_sound = "punch"
				ranged = 1

/mob/living/simple_animal/hostile/humanoid/nazi/soldier/droploot()
	var/obj/item/weapon/gun/energy/plasma/MP40k/dropgun = new(loc)
	var/obj/item/weapon/cell/guncell = dropgun.power_supply
	guncell.charge = min(guncell.maxcharge,25+(75 * ammo))


///////////////////////////////////////////////////////////////////OFFICER///////////

/mob/living/simple_animal/hostile/humanoid/nazi/officer
	name = "\improper Nazi Officer"

	corpse = /obj/effect/landmark/corpse/nazi/officer

	icon_state = "naziofficer"
	icon_living = "naziofficer"
	icon_dead = "naziofficer"
	ammo = 6
	ranged_cooldown_cap = 2

/mob/living/simple_animal/hostile/humanoid/nazi/officer/afterShoot()
	ammo--
	new /obj/item/ammo_casing/a357(loc,1)
	if(ammo <= 0)
		if(reloads > 0)
			spawn(10)
				playsound(src, 'sound/weapons/revolver_spin.ogg', 100, 1)
			reloads--
			new /obj/item/ammo_storage/speedloader/a357/empty(loc)
			ammo = 6
		else
			melee_damage_lower = 20
			melee_damage_upper = 20
			attack_sound = 'sound/weapons/bladeslice.ogg'
			attacktext = "stabs"
			retreat_distance = 0
			minimum_distance = 0
			ranged = 0
			spawn(10)
				if(health > 0)
					say("Come over here. I promise I will kill you!")

/mob/living/simple_animal/hostile/humanoid/nazi/officer/droploot()
	var/obj/item/weapon/gun/projectile/mateba/M = new(loc)
	M.loaded = list()
	for(var/i=1;i<=ammo;i++)
		M.loaded += new /obj/item/ammo_casing/a357(M)

	for(var/i=1;i<=reloads;i++)
		new /obj/item/ammo_storage/speedloader/a357(loc)

///////////////////////////////////////////////////////////////////SPACE TROOPER///////////

/mob/living/simple_animal/hostile/humanoid/nazi/spacetrooper
	name = "\improper Nazi Trooper"

	corpse = /obj/effect/landmark/corpse/nazi/spacetrooper

	icon_state = "nazitrooper"
	icon_living = "nazitrooper"
	icon_dead = "nazitrooper"

	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "stabs"
	health = 200
	maxHealth = 200
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/weapons/Gunshot.ogg'

	melee_damage_lower = 20
	melee_damage_upper = 20
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


	retreat_distance = 4
	minimum_distance = 3

	light_range = 4
	light_color = "#FF2222"

	ammo = 6
	reloads = 2
	ranged_cooldown_cap = 2

	var/datum/effect/effect/system/trail/ion_trail

/mob/living/simple_animal/hostile/humanoid/nazi/spacetrooper/New()
	. = ..()
	ion_trail = new /datum/effect/effect/system/trail()
	ion_trail.set_up(src)
	ion_trail.start()

/mob/living/simple_animal/hostile/humanoid/nazi/spacetrooper/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/humanoid/nazi/spacetrooper/afterShoot()
	ammo--
	new /obj/item/ammo_casing/a357(loc,1)
	if(ammo <= 0)
		if(reloads > 0)
			spawn(10)
				playsound(src, 'sound/weapons/revolver_spin.ogg', 100, 1)
			reloads--
			new /obj/item/ammo_storage/speedloader/a357/empty(loc)
			ammo = 6
		else
			//we be going berserker
			emote("me",1,"puts away his mateba and tightens the grip on his knife.")
			melee_damage_lower = 40
			melee_damage_upper = 40
			retreat_distance = 0
			minimum_distance = 0
			ranged = 0
			spawn(10)
				if(health > 0)
					say("Come over here. I promise I will kill you!")


///////////////////////////////////////////////////////////////////HOLYSHIT/////////////

/mob/living/simple_animal/hostile/mechahitler
	name = "Mecha Hitler"
	desc = "Heil Myself!"
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "mechahitler"
	icon_living = "mechahitler"
	icon_dead = "mechahitler"
	icon_gib = "syndicate_gib"

	move_to_delay = 20

	speak = list("Die, Allied schweinhund!","Die Welt ist unser!","Guten Tag!" ,"Scheise!")
	speak_emote = list("says")
	emote_hear = list("hums")
	emote_see = list("stomps")
	attacktext = "crushes"
	attack_sound = 'sound/weapons/heavysmash.ogg'
	speak_chance = 20

	health = 1000
	maxHealth = 1000

	melee_damage_lower = 40
	melee_damage_upper = 80

	faction = "nazi"

	ranged = 1
	rapid = 1
	retreat_distance = 0
	minimum_distance = 2
	projectiletype = /obj/item/projectile/bullet/gatling
	projectilesound = 'sound/weapons/gatling_fire.ogg'
	casingtype = null
	ranged_cooldown_cap = 1

	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH|UNPACIFIABLE
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | SMASH_RWALLS

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 5000

	light_range = 2
	light_color = "#88BB88"

	var/datum/effect/effect/system/trail/ion_trail

/mob/living/simple_animal/hostile/mechahitler/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	if(..())
		new /obj/item/ammo_casing_gatling(loc)

/mob/living/simple_animal/hostile/mechahitler/New()
	. = ..()
	ion_trail = new /datum/effect/effect/system/trail()
	ion_trail.set_up(src)
	ion_trail.start()

/mob/living/simple_animal/hostile/mechahitler/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/mechahitler/death(var/gibbed = FALSE)
	set waitfor = 0
	..(TRUE)
	dir = 2
	say("Eva, auf wiedersehen!")
	ranged = 0
	sleep(10)
	var/turf/eloc = get_turf(loc)
	qdel(src)
	explosion(eloc,1,2,3)
	new /obj/item/weapon/gun/gatling(eloc)
