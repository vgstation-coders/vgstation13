/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."
	abbreviation = "KN"
	user_type = USER_TYPE_WIZARD
	specialization = UTILITY

	school = "transmutation"
	charge_max = 100
	spell_flags = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = SpI_WHISPER
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	hud_state = "wiz_knock"

	price = 0.5 * Sp_BASE_PRICE //Half of the normal spell price

/spell/aoe_turf/knock/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn(1)
				if(istype(door,/obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/AL = door //casting is important
					AL.locked = 0
				door.open()
		for(var/obj/structure/closet/C in T.contents)
			spawn(1)
				if(istype(C,/obj/structure/closet))
					var/obj/structure/closet/LC = C
					LC.locked = 0
					LC.welded = 0
				C.open()
		for(var/obj/structure/safe/S in T.contents)
			spawn(1)
				if(istype(S,/obj/structure/safe))
					var/obj/structure/safe/SA = S
					SA.open = 1
				S.update_icon()
		for(var/obj/item/weapon/storage/lockbox/L in T.contents)
			spawn(1)
				if(istype(L,/obj/item/weapon/storage/lockbox))
					var/obj/item/weapon/storage/lockbox/LL = L
					LL.locked = 0
				L.update_icon()
	return


//Construct version
/spell/aoe_turf/knock/harvester
	name = "Disintegrate Doors"
	desc = "No door shall stop you."
	user_type = USER_TYPE_CULT

	spell_flags = CONSTRUCT_CHECK

	charge_max = 100
	invocation = ""
	invocation_type = "silent"
	range = 5

	hud_state = "const_knock"

/spell/aoe_turf/knock/harvester/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn door.cultify()
	return