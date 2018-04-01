/datum/game_mode/nuclear/clown_ops
	name = "clown ops"
	config_tag = "clownops"

	announce_span = "danger"
	announce_text = "Clown empire forces are approaching the station in an attempt to HONK it!\n\
	<span class='danger'>Operatives</span>: Secure the nuclear authentication disk and use your bananium fission explosive to HONK the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	operative_antag_datum_type = /datum/antagonist/nukeop/clownop
	leader_antag_datum_type = /datum/antagonist/nukeop/leader/clownop

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/clown_ops/pre_setup()
	. = ..()
	if(.)
		for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
			var/turf/T = get_turf(S)
			if(T)
				qdel(S)
				new /obj/machinery/nuclearbomb/syndicate/bananium(T)
		for(var/V in pre_nukeops)
			var/datum/mind/the_op = V
			the_op.assigned_role = "Clown Operative"
			the_op.special_role = "Clown Operative"

/datum/game_mode/nuclear/clown_ops/generate_report()
	return "One of Central Command's trading routes was recently disrupted by a raid carried out by the Gorlex Marauders. They seemed to only be after one ship - a highly-sensitive \
			transport containing a bananium fission explosive, although it is useless without the proper code and authorization disk. While the code was likely found in minutes, the only disk that \
			can activate this explosive is on your station. Ensure that it is protected at all times, and remain alert for possible intruders."


/datum/outfit/syndicate/clownop
	name = "Clown Operative - Basic"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/clown
	ears = /obj/item/device/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id/syndicate
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/kitchen/knife/combat/survival,
		/obj/item/reagent_containers/spray/waterflower/lube)
	implants = list(/obj/item/implant/sad_trombone)

	uplink_type = /obj/item/device/radio/uplink/clownop

/datum/outfit/syndicate/clownop/no_crystals
	tc = 0

/datum/outfit/syndicate/clownop/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.dna.add_mutation(CLOWNMUT)

/datum/outfit/syndicate/clownop/leader
	name = "Clown Operative Leader - Basic"
	id = /obj/item/card/id/syndicate/nuke_leader
	r_hand = /obj/item/device/nuclear_challenge/clownops
	command_radio = TRUE
