
//Global list of generated hostile mobs. Utilize these lists in future panels to look up what mobs this system has generated.
var/list/procgen_mob_datums = list()
var/list/megabeast_datums = list() //example of super generated ones

//Global lists for general useful mob data
var/list/breath_list = list(
	list("steam breath", BURN, "WHITE", list("CHEM"), /datum/reagent/water),
	list("firey breath", BURN, "#FFAC1C", list("IGNITE")),
	list("plasmafire breath", BURN, "#844A97", list("PLASMA", "IGNITE")),
	list("dark flame", BURN, "#000066", list("IGNITE")),
	list("acidic spray", TOXIN, "GREEN", list("CHEM"),/datum/reagent/pacid),
	list("toxic breath", TOXIN, "YELLOW", list("CHEM"), /datum/reagent/toxin),
	list("mysterious sludge", TOXIN, "#5E02F8", list("CHEM"), /datum/reagent/phazon),
	list("petrifying breath", BRUTE, "GREY", list("CHEM"), /datum/reagent/petritricin),
	list("plasma dust", BRUTE,"#733B97", list("PLASMA", "COUGH")),
	list("radioactive dust", BRUTE, "YELLOW", list("RADIATION", "COUGH")),
	list("dust cloud", BRUTE,"GREY", list("PUSH", "COUGH")),
	list("sand breath", BRUTE,"#EOE8C5", list("PUSH", "BLIND")),
	list("water cannon", BRUTE,"#DEF7F5", list("PUSH", "CHEM"), /datum/reagent/water),
	list("booze blast", BRUTE,"#664300", list("PUSH", "CHEM"), /datum/reagent/ethanol),
	list("color spray", BRUTE,"#DEF7F5", list("PUSH", "CHEM"), /datum/reagent/colorful_reagent)
	)
var/list/appendage_modifier = list(
	"gaunt",
	"pale",
	"rusty",
	"molten",
	"scorched",
	"thin",
	"ugly",
	"translucent",
	"warty",
	"mutated",
	"twisted",
	"hairy",
	"feathery",
	"tentacled",
	)
var/list/procgen_loot = list(//path, # of items
	list(/obj/item/weapon/gun/energy/bison/alien, 1) = 100,//guns
	list(/obj/item/weapon/gun/energy/laser/captain, 1) = 100,
	list(/obj/item/weapon/gun/projectile/roulette_revolver, 2) = 100,
	list(/obj/item/weapon/gun/energy/laser/captain/alien, 2) = 50,
	list(/obj/item/weapon/gun/gravitywell, 1) = 50,
	list(/obj/item/weapon/gun/portalgun, 1) = 50,
	list(/obj/item/stack/sheet/mineral/clown, 20) = 200,//sheets
	list(/obj/item/stack/sheet/mineral/adamantine, 5) = 200,
	list(/obj/item/stack/sheet/mineral/phazon, 5) = 100,
	list(/obj/machinery/sleeper/mancrowave/galo, 1) = 50,//machines
	list(/obj/machinery/chem_dispenser/scp_294, 1) = 10,
	list(/obj/mecha/combat/durand/old, 1) = 10,//mechs
	list(/obj/mecha/combat/phazon, 1) = 5,
	list(/obj/mecha/medical/odysseus/murdysseus, 1) = 5,
	list(/obj/item/weapon/storage/box/syndie_kit/mech_killdozer, 1) = 5,//syndie packs
	list(/obj/item/weapon/storage/box/syndie_kit/emags_and_glue/, 1) = 25,
	list(/obj/item/clothing/accessory/medal/participation, 1) = 10,//trash
	list(/obj/item/weapon/paper/iou, 1) = 10
	)

/*
//PROC GENNED MEGABEASTS
//Datum that stores generated data for a procgenned mob. You can spawn a mob by TODO picking a datum from the above global list and calling a .gen_monster(location)
//
//big break
*/
/datum/procedural_mobspawn
	var/name = "Forgotten Beast"
	var/mob/living/simple_animal/hostile/mymob
	var/health
	var/maxHealth
	var/desc
	var/icon
	var/icon_state
	var/icon_dead
	var/pixel_x
	var/pixel_y
	var/melee_damage_lower
	var/melee_damage_upper
	var/ranged
	var/rapid
	var/obj/item/projectile/projectiletype
	var/move_to_delay
	var/matrix/size_matrix
	var/color
	var/radioactive
	var/datum/reagent/vapors
	var/rad_cooldown
	var/special_cooldown
	var/breath_string
	var/breath_damage
	var/breath_damage_type
	var/datum/custom_breath/mybreath
	var/datum/reagent/mypoison
	var/list/appendage_types = list(
		"head",
		"eye",
		"mouth",
		"arm",
		"leg",
		"tail",
		"wing",
		)
	var/list/randomloot
//Generate datum variables on creation
/datum/procedural_mobspawn/New(var/mob/living/simple_animal/hostile/mobtype)
	PickMob(mobtype)
	if(!ranged)
		if(prob(30))
			PickProjectile()
		else if(prob(30))
			PickBreath()
	//When finished, add self to the global list of generated mobs for future reference
	procgen_mob_datums += src

//Assign general mob data
/datum/procedural_mobspawn/proc/PickMob(var/mob/living/simple_animal/hostile/mobtype)
	mymob = mobtype
	if(!mymob)
		var/list/mob_types = existing_typesof(/mob/living/simple_animal/hostile)
		mymob = pick(mob_types)
	health = clamp((mymob.health * 10), 200, 1000)
	maxHealth = clamp((mymob.maxHealth * 10), 200, 1000)
	GenerateDesc()
	if(prob(90))
		AddFlavorText()
	if(prob(50))
		AddFlavorText(TRUE)
	icon = mymob.icon
	icon_state = mymob.icon_state
	icon_dead = mymob.icon_dead
	pixel_x = mymob.pixel_x
	pixel_y = mymob.pixel_y
	melee_damage_lower = clamp((mymob.melee_damage_lower * 2), 15, 60)
	melee_damage_upper = clamp((mymob.melee_damage_upper * 2), 35, 80)
	breath_damage = clamp(rand(15), 5, 15)
	if(mymob.projectiletype)
		ranged = TRUE
		rapid = mymob.rapid
		projectiletype =  mymob.projectiletype
		var/obj/item/projectile/P = projectiletype
		desc += " Beware of its deadly [P.name]s!"
	var/scaling_x = rand(1.5, 2)
	var/scaling_y = rand(1.5, 2)
	move_to_delay = mymob.move_to_delay
	size_matrix = matrix()
	size_matrix.Scale(scaling_x, scaling_y)
	randomloot = pickweight(procgen_loot)
	if(prob(33))
		color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	if(prob(10))
		radioactive = TRUE
		desc += " It has a spooky green glow around it!"
	else if(prob(20))
		PickVapors()

/datum/procedural_mobspawn/proc/GenerateDesc()//can be done much better
	var/list/mydesc = list(
		"A great [mymob.name].",
		"An abominable [mymob.name].",
		"An enormous [mymob.name].",
		)
	desc = pick(mydesc)

/datum/procedural_mobspawn/proc/AddFlavorText(randompart = FALSE)
	var/modifier = pick(appendage_modifier)
	if(randompart)
		var/appendage = pick(appendage_types)
		appendage_types -= appendage
		var/number = roll(1, 10)
		var/amount = num2text(number)
		desc += " Its [amount] [appendage][number <= 1 ? " is" : "s are"] [modifier]."
		return
	desc += " It is [modifier]."

/datum/procedural_mobspawn/proc/PickProjectile()
	ranged = TRUE
	if(prob(20))
		projectiletype = /obj/item/projectile/web
		desc += " Beware of its webs!"
		return
	var/list/available_projectiles = existing_typesof(/obj/item/projectile) - restricted_roulette_projectiles
	for(var/type in restrict_with_subtypes)
		for(var/subtype in subtypesof(type))
			available_projectiles -= subtype
		available_projectiles -= type
	var/obj/item/projectile/P = pick(available_projectiles)
	if(!P.name)
		PickProjectile()
		return
	projectiletype = P
	desc += " Beware of its deadly [P.name]s!"//needs some variation

/datum/procedural_mobspawn/proc/PickBreath(breath_string)
	var/list/breath_type = list()
	if(breath_string)
		for (var/list/x in breath_list)
			if (breath_string in x)
				breath_type = x
	else
		breath_type = pick(breath_list)
	if(breath_type.len < 4)
		return
	ranged = TRUE
	breath_string = breath_type[1]
	breath_damage_type = breath_type[2]
	mybreath = new()
	mybreath.name = breath_string
	mybreath.color = breath_type[3]
	mybreath.special = breath_type[4]//this is a list
	mybreath.damage = breath_damage
	if(length(breath_type)>= 5)
		mybreath.reagent_type = breath_type[5]
	desc += " Beware its deadly [breath_string]!"
	switch(breath_damage_type)
		if(BRUTE)
			mybreath.damage_type = BRUTE
		if(TOXIN)
			mybreath.damage_type = TOX

/datum/procedural_mobspawn/proc/PickVapors(var/datum/reagent/my_chemical)
	if(!my_chemical)
		var/list/all_reagents = subtypesof(/datum/reagent)
		vapors = pick(all_reagents)
	else
		vapors = my_chemical
	var/vapornoun = pick("vapors", "gas", "smoke", "mist", "fog", "clouds")
	desc += (" Beware its deadly [vapors.name] [vapornoun]!")

/datum/procedural_mobspawn/proc/gen_monster(var/target)
	new /mob/living/simple_animal/hostile/forgotten_beast(target, src)

/datum/procedural_mobspawn/megabeast
//Alternative, more dangerous procs. You can replace PickMob() and other such procs in this datum and use it for your more powerful stuff.

/*
//Accessory datums and functions used in forgotten beasts
*/

/datum/custom_breath
	var/name = ""
	var/damage = 0
	var/color = "#FFAC1C"
	var/damage_type = BURN
	var/pressure = ONE_ATMOSPHERE * 4.5
	var/temperature = T0C + 175
	var/special
	var/datum/reagent/reagent_type

/obj/item/projectile/custom_breath
	name = "fiery breath"
	icon_state = ""
	damage = 0
	penetration = -1
	phase_type = PROJREACT_MOBS|PROJREACT_BLOB|PROJREACT_OBJS
	bounce_sound = null
	custom_impact = 1
	penetration_message = 0
	grillepasschance = 100
	color = "#FFAC1C"

	var/stepped_range = 0
	var/max_range = 9
	var/pressure = ONE_ATMOSPHERE * 4.5
	var/temperature = T0C + 175
	var/fire_duration
	var/special
	var/datum/reagent/reagent_type

/obj/item/projectile/custom_breath/New(turf/T, var/direction, var/Dam, var/P, var/Temp, var/F_Dur)
	..(T,direction)
	if(damage)
		damage = Dam
	if(P)
		pressure = P
	if(Temp)
		temperature = Temp
	if(F_Dur)
		fire_duration = F_Dur

/obj/item/projectile/custom_breath/process_step()
	..()
	if(stepped_range <= max_range)
		stepped_range++
	else
		bullet_die()
		return
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/obj/effect/fire_blast/custom/F = new(T, damage, stepped_range, 1, pressure, temperature, fire_duration)
	F.color = color
	F.damage_type = damage_type
	F.special = special
	F.reagent_type = reagent_type

/obj/effect/fire_blast/custom
	icon_state = "key1"
	spread_chance = 100
	var/damage_type = BURN
	var/damage = 10
	var/special
	var/datum/reagent/reagent_type

/obj/effect/fire_blast/custom/New(atom/A, var/damage = 0, var/current_step = 0, var/age = 1, var/pressure = 0, var/blast_temperature = 0, var/fire_duration, var/origin, color, damage_type, special, reagent_type)
	..()
	icon_state = "key[rand(1,3)]"

/obj/effect/fire_blast/custom/burn_mob(mob/living/L, var/adjusted_fire_damage)
	if(special)
		ApplyStatus(L, special, adjusted_fire_damage)
	if(L.mutations.Find(M_RESIST_HEAT) && damage_type == BURN)
		return
	L.apply_damage(adjusted_fire_damage, damage_type)

/obj/effect/fire_blast/custom/proc/ApplyStatus(mob/living/L, special, adjusted_fire_damage)
	var/mob/living/carbon/H = L
	if(adjusted_fire_damage < 1)
		adjusted_fire_damage++
	for(var/status in special)
		if(status == "IGNITE")
			if(!L.on_fire)
				L.ignite()
		if(status == "RADIATION")
			L.apply_radiation((damage), RAD_EXTERNAL)
		if(status == "PLASMA")//contaminate equipment with plasma
			if(!ishuman(L))
				return
			if(H.flags & PLASMA_IMMUNE)
				return
			H.contaminate()
		if(status == "CHEM")
			var/datum/reagents/R = L.reagents
			R.add_reagent(reagent_type.id, 10)
		if(status == "PUSH")
			var/randomdir = pick(alldirs)
			L.Move(get_turf(src), randomdir)
		if(status == "COUGH")
			if(ishuman(H))
				if(H.has_breathing_mask())
					return
			L.audible_cough()
			var/obj/item/I = H.get_active_hand()
			if(I && I.w_class < W_CLASS_MEDIUM)
				H.drop_item(I)
		if(status == "BLIND")
			L.apply_effects(0, 0, 0, 0,  0, 10)

/obj/effect/fire_blast/custom/blast_spread(current_step, pressure, blast_temperature)//needs to transfer the new vars
	if(spread && current_step >= spread_start && blast_age < 4)
		var/turf/TS = get_turf(src)
		for(var/turf/TU in range(1, TS))
			if(TU != get_turf(src))
				var/tilehasfire = 0
				var/obstructed = 0
				for(var/obj/effect/E in TU)
					if(istype(E, /obj/effect/fire_blast))
						tilehasfire = 1
				for(var/obj/machinery/door/D in TU)
					if(istype(D, /obj/machinery/door/airlock) || istype(D, /obj/machinery/door/mineral))
						if(D.density)
							obstructed = 1
				if(prob(spread_chance) && TS.Adjacent(TU) && !TU.density && !tilehasfire && !obstructed)
					var/obj/effect/fire_blast/custom/breath = new type(TU, fire_damage, current_step, blast_age+1, pressure, blast_temperature, duration, damage)
					breath.color = color
					breath.damage_type = damage_type
					breath.special = special
					breath.reagent_type = reagent_type
			sleep(1)
