/spell/targeted/spark
	name = "Spark"
	desc = "Creates a spark in the targeted location."
	abbreviation = "SP"

	school = "evocation"
	invocation = "M'tch st'ck"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "sparks"

/spell/targeted/spark/cast(var/list/targets, mob/user)
	for(var/A in targets)
		var/turf/T = get_turf(A)
		var/obj/effect/effect/sparks/S = new /obj/effect/effect/sparks(T)
		S.start()

/spell/targeted/clean
	name = "Clean item"
	desc = "Applies magic soap to a piece of clothing."
	abbreviation = "CI"

	school = "evocation"
	invocation = "s'ap s'ds"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "soap"

/spell/targeted/clean/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		A.clean_blood()
		if(isitem(A))
			var/obj/item/I = A
			I.decontaminate()


/spell/targeted/unclean
	name = "Bloody item"
	desc = "Drops an item into the realm of blood for just a moment, covering it in ichor."
	abbreviation = "BI"

	school = "evocation"
	invocation = "bl'odso'k"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "blood"

/spell/targeted/unclean/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		A.add_blood(user)

/spell/targeted/create_trinket
	name = "Create mundane temporary trinket"
	desc = "Creates a small trinket for a duration."
	abbreviation = "CT"

	school = "evocation"
	invocation = "Id'e h'nds m'k' l'ght w'rk"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER
	level_max = list()
	hud_state = "coin"

/spell/targeted/create_trinket/cast(var/list/targets, mob/user)
	var/static/list/available_trinkets = existing_typesof(/obj/item/weapon/coin)-list(/obj/item/weapon/coin/trader, /obj/item/weapon/coin/adamantine)
	var/choice = pick(available_trinkets)
	var/obj/item/I = new choice
	user.put_in_hands(I)
	spawn(300)
		if(istype(I.loc, /mob/living))
			var/mob/living/L = I.loc
			L.drop_item(I, force_drop = 1)
		qdel(I)

/spell/targeted/warm_object
	name = "Warm object"
	desc = "Warms an object."
	abbreviation = "WO"

	school = "evocation"
	invocation = "sp'cy k'ych'in"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "gen_immolate"

/spell/targeted/warm_object/cast(var/list/targets, mob/user)
	for(var/obj/item/I in targets)
		var/atom/fake_heater/FH = new /atom/fake_heater()
		I.attempt_heating(FH, user)
		qdel(FH)

/atom/fake_heater
	name = "fake heater"

/atom/fake_heater/is_hot()
	return 250

/atom/fake_heater/thermal_energy_transfer()
	return 3500

/spell/targeted/cool_object
	name = "Cool object"
	desc = "Cools an object."
	abbreviation = "WO"

	school = "evocation"
	invocation = "I'ce c'ld!"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "gen_ice"

/spell/targeted/cool_object/cast(var/list/targets, mob/user)
	for(var/obj/item/I in targets)
		var/atom/fake_cooler/FH = new /atom/fake_cooler()
		I.attempt_heating(FH, user)
		qdel(FH)

/atom/fake_cooler
	name = "fake cooler"

/atom/fake_cooler/is_hot()
	return -50

/atom/fake_cooler/thermal_energy_transfer()
	return -1500

/spell/targeted/extinguish
	name = "Extinguish"
	desc = "Extinguishes an object."
	abbreviation = "EO"

	school = "evocation"
	invocation = "Splash"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "extinguisher"

/spell/targeted/extinguish/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		A.extinguish()