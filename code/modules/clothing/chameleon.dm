#define EMP_RANDOMISE_TIME 300

/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/Trigger()
	if(!IsAvailable())
		return

	// Damn our lack of abstract interfeces
	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		var/obj/item/clothing/head/chameleon/drone/X = target
		X.chameleon_action.random_look(owner)
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		var/obj/item/clothing/mask/chameleon/drone/Z = target
		Z.chameleon_action.random_look(owner)

	return 1


/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New()
	..()

	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/Trigger()
	if(!IsAvailable())
		return

	// No point making the code more complicated if no non-drone
	// is ever going to use one of these

	var/mob/living/simple_animal/drone/D

	if(istype(owner, /mob/living/simple_animal/drone))
		D = owner
	else
		return

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone()
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone()
	else
		to_chat(owner, "<span class='warning'>You shouldn't be able to toggle a camogear helmetmask if you're not wearing it</span>")
	if(new_headgear)
		// Force drop the item in the headslot, even though
		// it's NODROP_1
		D.dropItemToGround(target, TRUE)
		qdel(old_headgear)
		// where is `slot_head` defined? WHO KNOWS
		D.equip_to_slot(new_headgear, slot_head)
	return 1


/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	var/list/chameleon_blacklist = list() //This is a typecache
	var/list/chameleon_list = list()
	var/chameleon_type = null
	var/chameleon_name = "Item"

	var/emp_timer

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	if(button)
		button.name = "Change [chameleon_name] Appearance"

	chameleon_blacklist |= typecacheof(target.type)
	for(var/V in typesof(chameleon_type))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if(chameleon_blacklist[V] || (initial(I.flags_1) & ABSTRACT_1))
				continue
			if(!initial(I.icon_state) || !initial(I.item_state))
				continue
			var/chameleon_item_name = "[initial(I.name)] ([initial(I.icon_state)])"
			chameleon_list[chameleon_item_name] = I


/datum/action/item_action/chameleon/change/proc/select_look(mob/user)
	var/obj/item/picked_item
	var/picked_name
	picked_name = input("Select [chameleon_name] to change into", "Chameleon [chameleon_name]", picked_name) as null|anything in chameleon_list
	if(!picked_name)
		return
	picked_item = chameleon_list[picked_name]
	if(!picked_item)
		return
	update_look(user, picked_item)

/datum/action/item_action/chameleon/change/proc/random_look(mob/user)
	var/picked_name = pick(chameleon_list)
	// If a user is provided, then this item is in use, and we
	// need to update our icons and stuff

	if(user)
		update_look(user, chameleon_list[picked_name])

	// Otherwise, it's likely a random initialisation, so we
	// don't have to worry

	else
		update_item(chameleon_list[picked_name])

/datum/action/item_action/chameleon/change/proc/update_look(mob/user, obj/item/picked_item)
	if(istype(target, /obj/item/gun/energy/laser/chameleon))
		var/obj/item/gun/energy/laser/chameleon/CG = target
		CG.get_chameleon_projectile(picked_item)
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return

		update_item(picked_item)
		var/obj/item/thing = target
		thing.update_slot_icon()
	UpdateButtonIcon()

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item)
	target.name = initial(picked_item.name)
	target.desc = initial(picked_item.desc)
	target.icon_state = initial(picked_item.icon_state)
	if(isitem(target))
		var/obj/item/I = target
		I.item_state = initial(picked_item.item_state)
		I.item_color = initial(picked_item.item_color)
		if(istype(I, /obj/item/clothing) && istype(initial(picked_item), /obj/item/clothing))
			var/obj/item/clothing/CL = I
			var/obj/item/clothing/PCL = picked_item
			CL.flags_cover = initial(PCL.flags_cover)
	target.icon = initial(picked_item.icon)

/datum/action/item_action/chameleon/change/Trigger()
	if(!IsAvailable())
		return

	select_look(owner)
	return 1

/datum/action/item_action/chameleon/change/proc/emp_randomise(var/amount = EMP_RANDOMISE_TIME)
	if(istype(target, /obj/item/gun/energy/laser/chameleon))
		return	//Please no crash!
	START_PROCESSING(SSprocessing, src)
	random_look(owner)

	var/new_value = world.time + amount
	if(new_value > emp_timer)
		emp_timer = new_value

/datum/action/item_action/chameleon/change/process()
	if(world.time > emp_timer)
		STOP_PROCESSING(SSprocessing, src)
		return
	random_look(owner)

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/under/chameleon/ratvar
	name = "ratvarian engineer's jumpsuit"
	desc = "A tough jumpsuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	icon_state = "engine"
	item_state = "engi_suit"
	item_color = "engine"

/obj/item/clothing/under/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/under, /obj/item/clothing/under/color, /obj/item/clothing/under/rank, /obj/item/clothing/under/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/under/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/under/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/suit/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/suit/armor/abductor, /obj/item/clothing/suit/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/suit/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/suit/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/gloves/chameleon
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"

	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/gloves/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/gloves, /obj/item/clothing/gloves/color, /obj/item/clothing/gloves/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/gloves/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/gloves/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_color = "grey"

	resistance_flags = NONE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/head/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/head/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/head/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon/drone
	// The camohat, I mean, holographic hat projection, is part of the
	// drone itself.
	flags_1 = NODROP_1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	// which means it offers no protection, it's just air and light

/obj/item/clothing/head/chameleon/drone/Initialize()
	. = ..()
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.UpdateButtonIcon()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.UpdateButtonIcon()

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	item_state = "gas_alt"
	resistance_flags = NONE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	flags_1 = BLOCK_GAS_SMOKE_EFFECT_1 | MASKINTERNALS_1
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH

	var/vchange = 1

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/mask/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/mask/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/mask/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	vchange = !vchange
	to_chat(user, "<span class='notice'>The voice changer is now [vchange ? "on" : "off"]!</span>")


/obj/item/clothing/mask/chameleon/drone
	//Same as the drone chameleon hat, undroppable and no protection
	flags_1 = NODROP_1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	// Can drones use the voice changer part? Let's not find out.
	vchange = 0

/obj/item/clothing/mask/chameleon/drone/Initialize()
	. = ..()
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.UpdateButtonIcon()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.UpdateButtonIcon()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, "<span class='notice'>[src] does not have a voice changer.</span>")

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_color = "black"
	desc = "A pair of black shoes."
	permeability_coefficient = 0.05
	resistance_flags = NONE
	pockets = /obj/item/storage/internal/pocket/shoes
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/shoes/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/shoes/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/clothing/shoes/chameleon/noslip
	name = "black shoes"
	icon_state = "black"
	item_color = "black"
	desc = "A pair of black shoes."
	flags_1 = NOSLIP_1

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/gun/energy/laser/chameleon
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/chameleon)
	clumsy_check = 0
	item_flags = NONE
	pin = /obj/item/device/firing_pin
	cell_type = /obj/item/stock_parts/cell/bluespace

	var/datum/action/item_action/chameleon/change/chameleon_action
	var/list/chameleon_projectile_vars
	var/list/chameleon_ammo_vars
	var/list/chameleon_gun_vars
	var/list/projectile_copy_vars
	var/list/ammo_copy_vars
	var/list/gun_copy_vars
	var/badmin_mode = FALSE
	var/can_hitscan = FALSE
	var/hitscan_mode = FALSE
	var/static/list/blacklisted_vars = list("locs", "loc", "contents", "x", "y", "z")

/obj/item/gun/energy/laser/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/gun
	chameleon_action.chameleon_name = "Gun"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/gun/magic, ignore_root_path = FALSE)
	chameleon_action.initialize_disguises()

	projectile_copy_vars = list("name", "icon", "icon_state", "item_state", "speed", "color", "hitsound", "forcedodge", "impact_effect_type", "range", "suppressed", "hitsound_wall", "impact_effect_type", "pass_flags", "tracer_type", "muzzle_type", "impact_type")
	chameleon_projectile_vars = list("name" = "practice laser", "icon" = 'icons/obj/projectiles.dmi', "icon_state" = "laser")
	gun_copy_vars = list("fire_sound", "burst_size", "fire_delay")
	chameleon_gun_vars = list()
	ammo_copy_vars = list("firing_effect_type")
	chameleon_ammo_vars = list()
	recharge_newshot()
	get_chameleon_projectile(/obj/item/gun/energy/laser)

/obj/item/gun/energy/laser/chameleon/emp_act(severity)
	return

/obj/item/gun/energy/laser/chameleon/proc/reset_chameleon_vars()
	chameleon_ammo_vars = list()
	chameleon_gun_vars = list()
	chameleon_projectile_vars = list()
	if(chambered)
		for(var/v in ammo_copy_vars)
			if(v in blacklisted_vars)	//Just in case admins go crazy.
				continue
			chambered.vars[v] = initial(chambered.vars[v])
	for(var/v in gun_copy_vars)
		if(v in blacklisted_vars)
			continue
		vars[v] = initial(vars[v])
	QDEL_NULL(chambered.BB)
	chambered.newshot()

/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_ammo(obj/item/ammo_casing/AC, passthrough = TRUE, reset = FALSE)
	if(!istype(AC))
		CRASH("[AC] is not /obj/item/ammo_casing!")
		return FALSE
	for(var/V in ammo_copy_vars)
		if(AC.vars[V])
			chameleon_ammo_vars[V] = AC.vars[V]
			if(chambered && chambered.vars[V])
				chambered.vars[V] = AC.vars[V]
	if(passthrough)
		var/obj/item/projectile/P = AC.BB
		set_chameleon_projectile(P)

/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_projectile(obj/item/projectile/P)
	if(!istype(P))
		CRASH("[P] is not /obj/item/projectile!")
		return FALSE
	chameleon_projectile_vars = list("name" = "practice laser", "icon" = 'icons/obj/projectiles.dmi', "icon_state" = "laser", "nodamage" = TRUE)
	for(var/V in projectile_copy_vars)
		if(P.vars[V])
			chameleon_projectile_vars[V] = P.vars[V]
	if(istype(chambered, /obj/item/ammo_casing/energy/chameleon))
		var/obj/item/ammo_casing/energy/chameleon/AC = chambered
		AC.projectile_vars = chameleon_projectile_vars.Copy()
	if(!P.tracer_type)
		can_hitscan = FALSE
		set_hitscan(FALSE)
	else
		can_hitscan = TRUE
	if(badmin_mode)
		qdel(chambered.BB)
		chambered.projectile_type = P.type
		chambered.newshot()

/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_gun(obj/item/gun/G , passthrough = TRUE)
	if(!istype(G))
		CRASH("[G] is not /obj/item/gun!")
		return FALSE
	for(var/V in gun_copy_vars)
		if(vars[V] && G.vars[V])
			chameleon_gun_vars[V] = G.vars[V]
			vars[V] = G.vars[V]
	if(passthrough)
		if(istype(G, /obj/item/gun/ballistic))
			var/obj/item/gun/ballistic/BG = G
			var/obj/item/ammo_box/AB = new BG.mag_type(G)
			qdel(BG)
			if(!istype(AB)||!AB.ammo_type)
				qdel(AB)
				return FALSE
			var/obj/item/ammo_casing/AC = new AB.ammo_type(G)
			set_chameleon_ammo(AC)
		else if(istype(G, /obj/item/gun/magic))
			var/obj/item/gun/magic/MG = G
			var/obj/item/ammo_casing/AC = new MG.ammo_type(G)
			set_chameleon_ammo(AC)
		else if(istype(G, /obj/item/gun/energy))
			var/obj/item/gun/energy/EG = G
			if(islist(EG.ammo_type) && EG.ammo_type.len)
				var/obj/item/ammo_casing/AC = EG.ammo_type[1]
				set_chameleon_ammo(AC)
		else if(istype(G, /obj/item/gun/syringe))
			var/obj/item/ammo_casing/AC = new /obj/item/ammo_casing/syringegun(src)
			set_chameleon_ammo(AC)

/obj/item/gun/energy/laser/chameleon/attack_self(mob/user)
	. = ..()
	if(!can_hitscan)
		to_chat(user, "<span class='warning'>[src]'s current disguised gun does not allow it to enable high velocity mode!</span>")
		return
	if(!chambered)
		to_chat(user, "<span class='warning'>Unknown error in energy lens: Please reset chameleon disguise and try again.</span>")
		return
	set_hitscan(!hitscan_mode)
	to_chat(user, "<span class='notice'>You toggle [src]'s high velocity beam mode to [hitscan_mode? "on" : "off"].</span>")

/obj/item/gun/energy/laser/chameleon/proc/set_hitscan(hitscan)
	var/obj/item/ammo_casing/energy/chameleon/AC = chambered
	AC.hitscan_mode = hitscan
	hitscan_mode = hitscan

/obj/item/gun/energy/laser/chameleon/proc/get_chameleon_projectile(guntype)
	reset_chameleon_vars()
	var/obj/item/gun/G = new guntype(src)
	set_chameleon_gun(G)
	qdel(G)

/obj/item/storage/backpack/chameleon
	name = "backpack"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/backpack/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.initialize_disguises()

/obj/item/storage/backpack/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/storage/backpack/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	silent = TRUE
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()

/obj/item/storage/belt/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/storage/belt/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/device/radio/headset/chameleon
	name = "radio headset"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/device/radio/headset/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/device/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()

/obj/item/device/radio/headset/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/device/radio/headset/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/device/pda/chameleon
	name = "PDA"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/device/pda/chameleon/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/device/pda
	chameleon_action.chameleon_name = "PDA"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/device/pda/heads, /obj/item/device/pda/ai, /obj/item/device/pda/ai/pai), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/device/pda/chameleon/emp_act(severity)
	chameleon_action.emp_randomise()

/obj/item/device/pda/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

