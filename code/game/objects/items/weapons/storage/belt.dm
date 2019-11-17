/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags = FPRINT
	slot_flags = SLOT_BELT
	attack_verb = list("whips", "lashes", "disciplines")
	restraint_resist_time = 30 SECONDS
	restraint_apply_sound = "rustle"

/obj/item/weapon/storage/belt/can_quick_store(var/obj/item/I)
	return can_be_inserted(I,1)

/obj/item/weapon/storage/belt/quick_store(var/obj/item/I)
	return handle_item_insertion(I,0)

/obj/item/weapon/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "It has a tag that rates it for compatibility with standard tools, device analyzers, flashlights, cables, engineering tape, small fire extinguishers, compressed matter cartridges, light replacers, and fuel cans."
	icon_state = "utilitybelt"
	item_state = "utility"
	w_class = W_CLASS_LARGE
	storage_slots = 14
	max_combined_w_class = 200 //This actually doesn't matter as long as it is arbitrarily high, bar will be set by storage slots
	fits_ignoring_w_class = list(
		"/obj/item/device/lightreplacer"
		)
	can_only_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/solder",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering",
		"/obj/item/taperoll/syndie/engineering",
		"/obj/item/taperoll/atmos",
		"/obj/item/taperoll/syndie/atmos",
		"/obj/item/weapon/extinguisher",
		"/obj/item/weapon/rcd_ammo",
		"/obj/item/weapon/reagent_containers/glass/fuelcan",
		"/obj/item/device/lightreplacer",
		"/obj/item/device/device_analyser",
		"/obj/item/device/silicate_sprayer",
		"/obj/item/device/geiger_counter"
		)

/obj/item/weapon/storage/belt/utility/complete/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))

/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)

/obj/item/weapon/storage/belt/utility/chief
	name = "advanced tool-belt"
	desc = "The ancestral belt of Many-APCs-Charging, the original chief engineer from Space Native America. It's made out of the skins of the ancient enemy of engineers, giant spiders."
	icon_state = "utilitychief"
	item_state = "utilitychief"
	fits_max_w_class = 5
	can_only_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/solder",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/stack/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering",
		"/obj/item/taperoll/syndie/engineering",
		"/obj/item/taperoll/atmos",
		"/obj/item/taperoll/syndie/atmos",
		"/obj/item/weapon/extinguisher",
		"/obj/item/device/rcd/matter/engineering",
		"/obj/item/device/rcd/rpd",
		"/obj/item/device/rcd/tile_painter",
		"/obj/item/weapon/storage/component_exchanger",
		"/obj/item/weapon/rcd_ammo",
		"/obj/item/weapon/reagent_containers/glass/fuelcan",
		"/obj/item/blueprints",
		"/obj/item/device/lightreplacer",
		"/obj/item/device/device_analyser",
		"/obj/item/weapon/rcl",
		"/obj/item/device/silicate_sprayer",
		"/obj/item/device/geiger_counter",
		"/obj/item/weapon/inflatable_dispenser"
		)

/obj/item/weapon/storage/belt/utility/chief/full/New() //This is mostly for testing I guess
	..()
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/weldingtool/hugetank(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/weapon/solder/pre_fueled(src)
	new /obj/item/device/silicate_sprayer(src)
	new /obj/item/device/rcd/rpd(src)
	new /obj/item/device/rcd/matter/engineering/pre_loaded(src)


/obj/item/weapon/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	storage_slots = 21
	max_combined_w_class = 21
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	use_to_pickup = TRUE
	can_only_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/latex",
		"/obj/item/weapon/reagent_containers/hypospray/autoinjector",
		"/obj/item/device/mass_spectrometer",
		"/obj/item/device/reagent_scanner",
		"/obj/item/device/gps/paramedic",
		"/obj/item/device/antibody_scanner",
		"/obj/item/weapon/switchtool/surgery",
		"/obj/item/weapon/grenade/chem_grenade",
		"/obj/item/weapon/electrolyzer"
	)

/obj/item/weapon/storage/belt/slim
	name = "slim-belt"
	desc = "Grey belt that holds less and matches certain jumpsuits.  It looks like it can fit in a backpack."
	icon_state = "greybelt"
	item_state = "grey"

/obj/item/weapon/storage/belt/slim/pro/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)

/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	fits_max_w_class = 3
	max_combined_w_class = 21
	can_only_hold = list(
		"/obj/item/weapon/grenade",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_storage",
		"/obj/item/weapon/reagent_containers/food/snacks/donut",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/lighter",
		"/obj/item/weapon/cigpacket",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/melee/baton",
		"/obj/item/taperoll/police",
		"/obj/item/taperoll/syndie/police",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/gun/energy/stunrevolver",
		"/obj/item/weapon/gun/projectile/glock",
		"/obj/item/weapon/legcuffs/bolas",
		"/obj/item/device/hailer",
		"/obj/item/weapon/melee/telebaton",
		"/obj/item/device/gps/secure",
		"/obj/item/clothing/accessory/holobadge",
		"/obj/item/weapon/autocuffer",
		"/obj/item/weapon/depocket_wand",
		)

/obj/item/weapon/storage/belt/detective
	name = "hard-worn belt"
	desc = "There's a lot you can tell about a man from his clothes - sometimes it's all he can afford, or maybe he chooses to wear something as a message... this belt, then, is a statement. Classy, but not too drab. Fashionable, but still useful. People look at this belt and think, 'My god. That belt is frighteningly well placed. The shades of beige that seem to flood over themselves, splayed across every notch... I fear many things, but I fear most the man who possesses such an incredible belt.'"
	max_combined_w_class = 200 //Some of their stuff is pretty large and they have a lot of crap so lets just be safe.
	can_only_hold = list(
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_storage",
		"/obj/item/weapon/reagent_containers/food/snacks/donut",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/lighter",
		"/obj/item/weapon/cigpacket",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/taperoll/police",
		"/obj/item/taperoll/syndie/police",
		"/obj/item/device/hailer",
		"/obj/item/device/gps/secure",
		"/obj/item/clothing/accessory/holobadge",
		"/obj/item/weapon/reagent_containers/spray",
		"/obj/item/weapon/storage/evidencebag",
		"/obj/item/device/detective_scanner",
		"/obj/item/binoculars",
		"/obj/item/weapon/storage/box/surveillance",
		"/obj/item/device/handtv",
		"/obj/item/device/camera_film",
		"/obj/item/weapon/photo",
		"/obj/item/weapon/storage/photo_album",
		"/obj/item/device/camera",
		"/obj/item/weapon/folder",
		"/obj/item/weapon/f_card",
		"/obj/item/device/vampirehead",
		"/obj/item/weapon/switchtool/switchblade",
		)

/obj/item/weapon/storage/belt/security/batmanbelt
	name = "batbelt"
	desc = "For all your crime-fighting bat needs."
	icon_state = "bmbelt"
	item_state = "bmbelt"

/obj/item/weapon/storage/belt/security/batmanbelt/New()
	..()
	can_only_hold |= "/obj/item/weapon/gun/hookshot"

/obj/item/weapon/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_only_hold = list(
		"/obj/item/device/soulstone"
		)

/obj/item/weapon/storage/belt/soulstone/full/New()
	..()
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)


/obj/item/weapon/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_only_hold = list(
		"/obj/item/clothing/mask/luchador",
		"/obj/item/weapon/disk/nuclear",
		"/obj/item/weapon/reagent_containers/food/drinks/golden_cup"
		)


/obj/item/weapon/storage/belt/skull
	name = "trophy-belt" //FATALITY
	desc = "Excellent for holding the heads of your fallen foes."
	icon_state = "utilitybelt"
	item_state = "utility"
	fits_max_w_class = 4
	max_combined_w_class = 28
	can_only_hold = list(
 		"/obj/item/organ/external/head"
 	)

/obj/item/weapon/storage/belt/silicon
	name = "cyber trophy belt"
	desc = "Contains intellicards, posibrains, and MMIs. Those contained within can only speak to the wearer."
	icon_state = "securitybelt"
	item_state = "security"
	fits_max_w_class = 4
	max_combined_w_class = 28
	can_only_hold = list(
 		"/obj/item/device/aicard",
 		"/obj/item/device/mmi",
		"/obj/item/organ/external/head"
 	)

/obj/item/weapon/storage/belt/silicon/New()
	..()
	new /obj/item/device/aicard(src) //One freebie card

/obj/item/weapon/storage/belt/silicon/proc/GetCyberbeltMobs()
	var/list/mobs = list()
	for(var/obj/item/device/mmi/M in contents)
		if(M.brainmob)
			mobs += M.brainmob
	for(var/obj/item/device/aicard/A in contents)
		for(var/mob/living/silicon/ai/AI in A)
			mobs += AI
	return mobs

/proc/RenderBeltChat(var/obj/item/weapon/storage/belt/silicon/B,var/mob/living/C,var/message)
	var/list/listeners = observers
	if(istype(B.loc,/mob))
		var/mob/M = B.loc
		listeners += M
	listeners += B.GetCyberbeltMobs()
	listeners = uniquelist(listeners)
	var/turf/T = get_turf(B)
	log_say("[key_name(C)] (@[T.x],[T.y],[T.z]) Trophy Belt: [message]")
	for(var/mob/L in listeners)
		to_chat(L,"<span class='binaryradio'>[C], Cyber Trophy Belt: [message]</span>")

/obj/item/weapon/storage/belt/mining
	name = "mining gear belt"
	desc = "Can hold various mining gear like pickaxes or drills."
	icon_state = "miningbelt"
	item_state = "mining"
	w_class = W_CLASS_LARGE
	fits_max_w_class = 4
	max_combined_w_class = 28
	can_only_hold = list(
		"/obj/item/weapon/storage/bag/ore",
		"/obj/item/weapon/pickaxe/shovel",
		"/obj/item/weapon/storage/box/samplebags",
		"/obj/item/device/core_sampler",
		"/obj/item/device/beacon_locator",
		"/obj/item/beacon",
		"/obj/item/device/gps",
		"/obj/item/device/measuring_tape",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/pickaxe",
		"/obj/item/device/depth_scanner",
		"/obj/item/weapon/paper",
		"/obj/item/weapon/pen",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/wrench",
		"/obj/item/device/mining_scanner",
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/storage/box/excavation",
		"/obj/item/weapon/gun/energy/kinetic_accelerator",
		"/obj/item/weapon/resonator",
		"/obj/item/device/wormhole_jaunter",
		"/obj/item/weapon/lazarus_injector",
		"/obj/item/weapon/anobattery",
		"/obj/item/weapon/mining_drone_cube")

/obj/item/weapon/storage/belt/lazarus
	name = "trainer's belt"
	desc = "For the pokemo- mining master, holds your lazarus capsules."
	icon_state = "lazarusbelt_0"
	item_state = "lazbelt"
	w_class = W_CLASS_LARGE
	fits_max_w_class = 4
	max_combined_w_class = 28
	storage_slots = 6
	can_only_hold = list(
		"/obj/item/device/mobcapsule",
		"/obj/item/weapon/lazarus_injector")

/obj/item/weapon/storage/belt/lazarus/New()
	..()
	update_icon()


/obj/item/weapon/storage/belt/lazarus/update_icon()
	..()
	icon_state = "lazarusbelt_[contents.len]"

/obj/item/weapon/storage/belt/lazarus/attackby(obj/item/W, mob/user)
	var/amount = contents.len
	. = ..()
	if(amount != contents.len)
		update_icon()

/obj/item/weapon/storage/belt/lazarus/remove_from_storage(obj/item/W as obj, atom/new_location, var/force = 0, var/refresh = 1)
	. = ..()
	update_icon()

/obj/item/weapon/storage/belt/lazarus/antag
	icon_state = "lazarusbelt"

/obj/item/weapon/storage/belt/lazarus/antag/New(loc, mob/user)

	var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - (existing_typesof_list(blacklisted_mobs) + existing_typesof_list(boss_mobs)) // list of possible hostile mobs
	critters = shuffle(critters)
	while(contents.len < 6)
		var/obj/item/device/mobcapsule/MC = new /obj/item/device/mobcapsule(src)
		var/chosen = pick(critters)
		critters -= chosen
		var/mob/living/simple_animal/hostile/NM = new chosen(MC)
		if(istype(NM, /mob/living/simple_animal/hostile/humanoid))
			var/mob/living/simple_animal/hostile/humanoid/H = NM
			H.items_to_drop = list()
		NM.faction = "lazarus \ref[user]"
		NM.friends += user
		MC.contained_mob = NM
		MC.name = "lazarus capsule - [NM.name]"
	..()

/obj/item/weapon/storage/belt/thunderdome
	name = "Thunderdome Belt"
	desc = "Can hold the thunderdome IDs of your fallen foes."
	item_state = ""
	storage_slots = 30
	can_only_hold = list("/obj/item/weapon/card/id/thunderdome")

/obj/item/weapon/storage/belt/thunderdome/green
	icon_state = "td_belt-green"

/obj/item/weapon/storage/belt/thunderdome/red
	icon_state = "td_belt-red"

/obj/item/weapon/storage/belt/security/doomguy
	name = "Doomguy's belt"
	desc = ""
	icon_state = "doom"
	item_state = "doom"

/obj/item/weapon/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	storage_slots = 8
	fits_max_w_class = 5
	can_only_hold = list(
		"/obj/item/weapon/grenade/chem_grenade",
		"/obj/item/device/lightreplacer",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/reagent_containers/spray",
		"/obj/item/weapon/soap",
		"/obj/item/key/janicart",
		"/obj/item/clothing/gloves",
		"/obj/item/weapon/caution",
		"/obj/item/weapon/mop",
		"/obj/item/weapon/storage/bag/trash")

