/obj/machinery/mob_printer/deathmatch
	name = "deathmatch spawner"
	desc = "Will summon bloodthirsty murderers at random"
	cooldown_duration = 10 SECONDS
	print_path = /mob/living/carbon/human
	var/obj/abstract/loadout/to_load = /obj/abstract/loadout/deathmatch

/obj/machinery/mob_printer/deathmatch/finalize_spawn(var/mob/living/M)
	new to_load(loc, M)
	return M

/obj/abstract/loadout/deathmatch
	items_to_spawn = list(
		/obj/item/clothing/under/color/grey,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/gloves/fyellow,
		/obj/item/weapon/storage/toolbox,
		/obj/item/weapon/gun/projectile/pistol,
		/obj/item/ammo_storage/magazine/mc9mm
		)

/obj/machinery/patient_processor/EW
	input_dir = EAST
	output_dir = WEST

/obj/machinery/patient_processor/WE
	input_dir = WEST
	output_dir = EAST

/datum/map_element/dungeon/deathmatch/load(x,y,z)
	.=..()
	if(.)
		var/area/A = location.loc
		new /datum/map_handler(A)

/datum/map_element/dungeon/deathmatch/fountain
	file_path = "maps/misc/de_fountain.dmm"

/area/vault/automap/nolight
	dynamic_lighting = FALSE