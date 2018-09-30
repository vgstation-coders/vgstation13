/obj/abstract/loadout
	var/list/items_to_spawn = list()

/obj/abstract/loadout/New(turf/T, var/mob/M, var/unequip_current = TRUE)
	..(T)
	if(istype(M))
		if(unequip_current)
			M.unequip_everything()	//unequip everything before equipping loadout
		equip_items(M)
	spawn(10)	//to allow its items to be manually spawned and accessed, for the purposes of obtaining references
		if(!gcDestroyed)
			get_items()
			qdel(src)

/obj/abstract/loadout/proc/get_items()
	. = spawn_items()
	qdel(src)

/obj/abstract/loadout/proc/equip_items(var/mob/M)
	var/list/spawned_items = spawn_items()
	alter_items(spawned_items, M)
	M.recursive_list_equip(spawned_items)
	qdel(src)

/obj/abstract/loadout/proc/spawn_items()
	var/list/to_return = list()
	for(var/T in items_to_spawn)
		if(ispath(T, /obj/item))
			var/obj/item/I = new T(loc)
			to_return.Add(I)
	return to_return

/obj/abstract/loadout/proc/alter_items(var/list/items, var/mob/M)

/obj/abstract/loadout/gemsuit
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/rig/wizard,
						/obj/item/clothing/suit/space/rig/wizard,
						/obj/item/clothing/gloves/purple,
						/obj/item/clothing/shoes/sandal)

/obj/abstract/loadout/nazi_rigsuit
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/rig/nazi,
						/obj/item/clothing/suit/space/rig/nazi)

/obj/abstract/loadout/soviet_rigsuit
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/rig/soviet,
						/obj/item/clothing/suit/space/rig/soviet)

/obj/abstract/loadout/dredd_gear
	items_to_spawn = list(/obj/item/clothing/under/darkred,
						/obj/item/clothing/suit/armor/xcomsquaddie/dredd,
						/obj/item/clothing/glasses/hud/security,
						/obj/item/clothing/mask/gas/swat,
						/obj/item/clothing/head/helmet/dredd,
						/obj/item/clothing/gloves/combat,
						/obj/item/clothing/shoes/combat,
						/obj/item/weapon/storage/belt/security,
						/obj/item/weapon/gun/lawgiver)

/obj/abstract/loadout/standard_space_gear
	items_to_spawn = list(/obj/item/clothing/shoes/black,
						/obj/item/clothing/under/color/grey,
						/obj/item/clothing/suit/space,
						/obj/item/clothing/head/helmet/space,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/engineer_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig,
						/obj/item/clothing/head/helmet/space/rig,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/CE_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/elite,
						/obj/item/clothing/head/helmet/space/rig/elite,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/mining_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/mining,
						/obj/item/clothing/head/helmet/space/rig/mining,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/syndi_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/syndi,
						/obj/item/clothing/head/helmet/space/rig/syndi,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/wizard_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/wizard,
						/obj/item/clothing/head/helmet/space/rig/wizard,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/medical_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/medical,
						/obj/item/clothing/head/helmet/space/rig/medical,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/atmos_RIG
	items_to_spawn = list(/obj/item/clothing/suit/space/rig/atmos,
						/obj/item/clothing/head/helmet/space/rig/atmos,
						/obj/item/weapon/tank/jetpack/oxygen,
						/obj/item/clothing/mask/breath)

/obj/abstract/loadout/tournament_standard_red
	items_to_spawn = list(/obj/item/clothing/under/color/red,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/head/helmet/thunderdome,
						/obj/item/weapon/gun/energy/pulse_rifle/destroyer,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/grenade/smokebomb)

/obj/abstract/loadout/tournament_standard_green
	items_to_spawn = list(/obj/item/clothing/under/color/green,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/head/helmet/thunderdome,
						/obj/item/weapon/gun/energy/pulse_rifle/destroyer,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/grenade/smokebomb)

/obj/abstract/loadout/tournament_gangster
	items_to_spawn = list(/obj/item/clothing/under/det,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/suit/storage/det_suit,
						/obj/item/clothing/glasses/thermal/monocle,
						/obj/item/clothing/head/det_hat,
						/obj/item/weapon/cloaking_device,
						/obj/item/weapon/gun/projectile,
						/obj/item/ammo_storage/box/a357)

/obj/abstract/loadout/tournament_chef
	items_to_spawn = list(/obj/item/clothing/under/rank/chef,
						/obj/item/clothing/suit/chef,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/head/chefhat,
						/obj/item/weapon/kitchen/rollingpin,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/kitchen/utensil/knife/large)

/obj/abstract/loadout/tournament_janitor
	items_to_spawn = list(/obj/item/clothing/under/rank/janitor,
						/obj/item/clothing/shoes/black,
						/obj/item/weapon/storage/backpack,
						/obj/item/weapon/mop,
						/obj/item/weapon/reagent_containers/glass/bucket/water_filled,
						/obj/item/weapon/grenade/chem_grenade/cleaner,
						/obj/item/weapon/grenade/chem_grenade/cleaner,
						/obj/item/stack/tile/plasteel,
						/obj/item/stack/tile/plasteel,
						/obj/item/stack/tile/plasteel,
						/obj/item/stack/tile/plasteel,
						/obj/item/stack/tile/plasteel,
						/obj/item/stack/tile/plasteel,
						/obj/item/stack/tile/plasteel)

/obj/abstract/loadout/pirate
	items_to_spawn = list(/obj/item/clothing/under/pirate,
						/obj/item/clothing/shoes/brown,
						/obj/item/clothing/head/bandana,
						/obj/item/clothing/glasses/eyepatch,
						/obj/item/weapon/melee/energy/sword/pirate)

/obj/abstract/loadout/space_pirate
	items_to_spawn = list(/obj/item/clothing/under/pirate,
						/obj/item/clothing/shoes/brown,
						/obj/item/clothing/suit/space/pirate,
						/obj/item/clothing/head/helmet/space/pirate,
						/obj/item/clothing/glasses/eyepatch,
						/obj/item/weapon/melee/energy/sword/pirate)

/obj/abstract/loadout/soviet_soldier
	items_to_spawn = list(/obj/item/clothing/under/soviet,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/head/ushanka)

/obj/abstract/loadout/tunnel_clown
	items_to_spawn = list(/obj/item/clothing/under/rank/clown,
						/obj/item/clothing/shoes/clown_shoes,
						/obj/item/clothing/gloves/black,
						/obj/item/clothing/mask/gas/clown_hat,
						/obj/item/clothing/head/chaplain_hood,
						/obj/item/device/radio/headset,
						/obj/item/clothing/glasses/thermal/monocle,
						/obj/item/clothing/suit/chaplain_hoodie,
						/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
						/obj/item/weapon/bikehorn,
						/obj/item/weapon/card/id/tunnel_clown,
						/obj/item/weapon/fireaxe)

/obj/abstract/loadout/tunnel_clown/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name

/obj/abstract/loadout/masked_killer
	items_to_spawn = list(/obj/item/clothing/under/overalls,
						/obj/item/clothing/shoes/white,
						/obj/item/clothing/gloves/latex,
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/head/welding,
						/obj/item/device/radio/headset,
						/obj/item/clothing/glasses/thermal/monocle,
						/obj/item/clothing/suit/apron,
						/obj/item/weapon/kitchen/utensil/knife/large,
						/obj/item/weapon/scalpel,
						/obj/item/weapon/fireaxe)

/obj/abstract/loadout/masked_killer/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/I in items)
		I.add_blood(M)

/obj/abstract/loadout/assassin
	items_to_spawn = list(/obj/item/clothing/under/suit_jacket,
						/obj/item/clothing/shoes/black,
						/obj/item/clothing/gloves/black,
						/obj/item/device/radio/headset,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/clothing/suit/wcoat,
						/obj/item/weapon/melee/energy/sword,
						/obj/item/weapon/cloaking_device,
						/obj/item/weapon/storage/secure/briefcase/assassin,
						/obj/item/device/pda/heads/assassin,
						/obj/item/weapon/card/id/syndicate/assassin)

/obj/abstract/loadout/assassin/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name
	for(var/obj/item/device/pda/P in items)
		P.owner = M.real_name
		P.name = "PDA-[M.real_name] ([P.ownjob])"

/obj/abstract/loadout/death_commando
	items_to_spawn = list(/obj/item/device/radio/headset/deathsquad,
						/obj/item/clothing/under/deathsquad,
						/obj/item/weapon/melee/energy/sword,
						/obj/item/weapon/gun/projectile/mateba,
						/obj/item/clothing/shoes/magboots/deathsquad,
						/obj/item/clothing/gloves/combat,
						/obj/item/clothing/glasses/thermal,
						/obj/item/clothing/head/helmet/space/rig/deathsquad,
						/obj/item/clothing/mask/gas/swat,
						/obj/item/clothing/suit/space/rig/deathsquad,
						/obj/item/weapon/tank/emergency_oxygen/double,
						/obj/item/weapon/storage/backpack/security,
						/obj/item/weapon/storage/box,
						/obj/item/ammo_storage/box/a357,
						/obj/item/weapon/storage/firstaid/regular,
						/obj/item/weapon/pinpointer,
						/obj/item/weapon/shield/energy,
						/obj/item/weapon/plastique,
						/obj/item/weapon/gun/energy/pulse_rifle,
						/obj/item/weapon/card/id/death_commando)

/obj/abstract/loadout/death_commando/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name

/obj/abstract/loadout/death_commando/equip_items(var/mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.equip_death_commando()
	else
		var/list/spawned_items = spawn_items()
		alter_items(spawned_items, M)
		M.recursive_list_equip(spawned_items)
	qdel(src)

/obj/abstract/loadout/syndicate_commando
	items_to_spawn = list(/obj/item/device/radio/headset/syndicate/commando,
						/obj/item/clothing/under/syndicate/commando,
						/obj/item/weapon/melee/energy/sword,
						/obj/item/weapon/grenade/empgrenade,
						/obj/item/weapon/gun/projectile/silenced,
						/obj/item/clothing/shoes/swat,
						/obj/item/clothing/gloves/swat,
						/obj/item/clothing/glasses/thermal,
						/obj/item/clothing/mask/gas/syndicate,
						/obj/item/clothing/head/helmet/space/syndicate/black,
						/obj/item/clothing/suit/space/syndicate/black,
						/obj/item/weapon/tank/emergency_oxygen,
						/obj/item/weapon/storage/backpack/security,
						/obj/item/weapon/storage/box,
						/obj/item/ammo_storage/box/c45,
						/obj/item/weapon/storage/firstaid/regular,
						/obj/item/weapon/plastique,
						/obj/item/osipr_core,
						/obj/item/weapon/plastique,
						/obj/item/energy_magazine/osipr,
						/obj/item/weapon/gun/osipr,
						/obj/item/weapon/card/id/syndicate/commando)

/obj/abstract/loadout/syndicate_commando/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name

/obj/abstract/loadout/syndicate_commando/equip_items(var/mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.equip_syndicate_commando()
	else
		var/list/spawned_items = spawn_items()
		alter_items(spawned_items, M)
		M.recursive_list_equip(spawned_items)
	qdel(src)

/obj/abstract/loadout/nanotrasen_representative
	items_to_spawn = list(/obj/item/clothing/under/rank/centcom/representative,
						/obj/item/clothing/shoes/centcom,
						/obj/item/clothing/gloves/white,
						/obj/item/device/radio/headset/heads/hop,
						/obj/item/device/pda/heads/nt_rep,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/weapon/storage/bag/clipboard,
						/obj/item/weapon/card/id/nt_rep)

/obj/abstract/loadout/nanotrasen_representative/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name
	for(var/obj/item/device/pda/P in items)
		P.owner = M.real_name
		P.name = "PDA-[M.real_name] ([P.ownjob])"

/obj/abstract/loadout/nanotrasen_officer
	items_to_spawn = list(/obj/item/clothing/under/rank/centcom/officer,
						/obj/item/clothing/shoes/centcom,
						/obj/item/clothing/gloves/white,
						/obj/item/device/radio/headset/heads/captain,
						/obj/item/clothing/head/beret/centcom/officer,
						/obj/item/device/pda/heads/nt_officer,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/weapon/gun/energy,
						/obj/item/weapon/card/id/centcom/nt_officer)

/obj/abstract/loadout/nanotrasen_officer/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name
	for(var/obj/item/device/pda/P in items)
		P.owner = M.real_name
		P.name = "PDA-[M.real_name] ([P.ownjob])"

/obj/abstract/loadout/nanotrasen_captain
	items_to_spawn = list(/obj/item/clothing/under/rank/centcom/captain,
						/obj/item/clothing/shoes/centcom,
						/obj/item/clothing/gloves/white,
						/obj/item/device/radio/headset/heads/captain,
						/obj/item/clothing/head/beret/centcom/captain,
						/obj/item/device/pda/heads/nt_captain,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/weapon/gun/energy,
						/obj/item/weapon/card/id/centcom/nt_officer)

/obj/abstract/loadout/nanotrasen_captain/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name
	for(var/obj/item/device/pda/P in items)
		P.owner = M.real_name
		P.name = "PDA-[M.real_name] ([P.ownjob])"

/obj/abstract/loadout/nanotrasen_supreme_commander
	items_to_spawn = list(/obj/item/clothing/under/rank/centcom/captain,
						/obj/item/clothing/shoes/centcom,
						/obj/item/clothing/gloves/centcom,
						/obj/item/device/radio/headset/heads/captain,
						/obj/item/clothing/head/centhat,
						/obj/item/clothing/suit/armor/centcomm,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/weapon/gun/energy/laser/captain,
						/obj/item/device/pda/heads/nt_supreme,
						/obj/item/weapon/card/id/admin/nt_supreme)

/obj/abstract/loadout/nanotrasen_supreme_commander/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name
	for(var/obj/item/device/pda/P in items)
		P.owner = M.real_name
		P.name = "PDA-[M.real_name] ([P.ownjob])"

/obj/abstract/loadout/emergency_response_team
	items_to_spawn = list(/obj/item/device/radio/headset/ert,
						/obj/item/clothing/under/ert,
						/obj/item/device/flashlight,
						/obj/item/weapon/gun/energy/gun,
						/obj/item/clothing/glasses/sunglasses/sechud,
						/obj/item/clothing/shoes/swat,
						/obj/item/clothing/gloves/swat,
						/obj/item/weapon/storage/backpack/security,
						/obj/item/weapon/storage/box/survival/ert,
						/obj/item/weapon/storage/firstaid/regular,
						/obj/item/weapon/card/id/emergency_responder)

/obj/abstract/loadout/emergency_response_team/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name

/obj/abstract/loadout/emergency_response_team/equip_items(var/mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.equip_response_team()
	else
		var/list/spawned_items = spawn_items()
		alter_items(spawned_items, M)
		M.recursive_list_equip(spawned_items)
	qdel(src)

/obj/abstract/loadout/special_ops_officer
	items_to_spawn = list(/obj/item/clothing/under/syndicate/combat,
						/obj/item/clothing/suit/armor/swat/officer,
						/obj/item/clothing/shoes/combat,
						/obj/item/clothing/gloves/combat,
						/obj/item/device/radio/headset/heads/captain,
						/obj/item/clothing/glasses/thermal/eyepatch,
						/obj/item/clothing/mask/cigarette/cigar/havana,
						/obj/item/clothing/head/beret/centcom,
						/obj/item/weapon/gun/energy/pulse_rifle/M1911,
						/obj/item/weapon/lighter/zippo,
						/obj/item/weapon/storage/backpack/satchel,
						/obj/item/weapon/card/id/special_operations)

/obj/abstract/loadout/special_ops_officer/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name

/obj/abstract/loadout/blue_wizard
	items_to_spawn = list(/obj/item/clothing/under/lightpurple,
						/obj/item/clothing/suit/wizrobe,
						/obj/item/clothing/shoes/sandal,
						/obj/item/device/radio/headset,
						/obj/item/clothing/head/wizard,
						/obj/item/weapon/storage/backpack,
						/obj/item/weapon/storage/box,
						/obj/item/weapon/teleportation_scroll,
						/obj/item/weapon/spellbook,
						/obj/item/weapon/staff)

/obj/abstract/loadout/red_wizard
	items_to_spawn = list(/obj/item/clothing/under/lightpurple,
						/obj/item/clothing/suit/wizrobe/red,
						/obj/item/clothing/shoes/sandal,
						/obj/item/device/radio/headset,
						/obj/item/clothing/head/wizard/red,
						/obj/item/weapon/storage/backpack,
						/obj/item/weapon/storage/box,
						/obj/item/weapon/teleportation_scroll,
						/obj/item/weapon/spellbook,
						/obj/item/weapon/staff)

/obj/abstract/loadout/marisa_wizard
	items_to_spawn = list(/obj/item/clothing/under/lightpurple,
						/obj/item/clothing/suit/wizrobe/marisa,
						/obj/item/clothing/shoes/sandal/marisa,
						/obj/item/device/radio/headset,
						/obj/item/clothing/head/wizard/marisa,
						/obj/item/weapon/storage/backpack,
						/obj/item/weapon/storage/box,
						/obj/item/weapon/teleportation_scroll,
						/obj/item/weapon/spellbook,
						/obj/item/weapon/staff)

/obj/abstract/loadout/soviet_admiral
	items_to_spawn = list(/obj/item/clothing/head/hgpiratecap,
						/obj/item/clothing/shoes/combat,
						/obj/item/clothing/gloves/combat,
						/obj/item/device/radio/headset/heads/captain,
						/obj/item/clothing/glasses/thermal/eyepatch,
						/obj/item/clothing/suit/hgpirate,
						/obj/item/weapon/storage/backpack/satchel,
						/obj/item/weapon/gun/projectile/mateba,
						/obj/item/clothing/under/soviet,
						/obj/item/weapon/card/id/soviet_admiral)

/obj/abstract/loadout/soviet_admiral/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/weapon/card/id/I in items)
		I.name = "[M.real_name]'s ID Card"
		I.registered_name = M.real_name

/obj/abstract/loadout/bomberman
	items_to_spawn = list(/obj/item/clothing/under/darkblue,
						/obj/item/clothing/shoes/purple,
						/obj/item/clothing/head/helmet/space/bomberman,
						/obj/item/clothing/suit/space/bomberman,
						/obj/item/clothing/gloves/purple,
						/obj/item/weapon/bomberman)

/obj/abstract/loadout/arena_bomberman
	items_to_spawn = list(/obj/item/clothing/under/darkblue,
						/obj/item/clothing/shoes/purple,
						/obj/item/clothing/head/helmet/space/bomberman,
						/obj/item/clothing/suit/space/bomberman,
						/obj/item/clothing/gloves/purple,
						/obj/item/weapon/bomberman)

/obj/abstract/loadout/arena_bomberman/alter_items(var/list/items, var/mob/M)
	for(var/obj/item/clothing/C in items)
		C.canremove = 0
		if(istype(C, /obj/item/clothing/suit/space/bomberman))
			var/obj/item/clothing/suit/space/bomberman/B = C
			B.slowdown = HARDSUIT_SLOWDOWN_LOW
	var/list/randomhexes = list("7","8","9","a","b","c","d","e","f",)
	M.color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	M.name = "Bomberman #[rand(1,999)]"
	M.mind.special_role = BOMBERMAN // NEEDED FOR CHEAT CHECKS!
