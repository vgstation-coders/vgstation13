/obj/item/reagent_containers/spray/waterflower/lube
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist. A <i>slippery</i> twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 3
	spray_range = 1
	stream_range = 1
	volume = 30
	list_reagents = list("lube" = 30)

//COMBAT CLOWN SHOES
//Clown shoes with combat stats and noslip. Of course they still squeek.
/obj/item/clothing/shoes/clown_shoes/combat
	name = "combat clown shoes"
	desc = "advanced clown shoes that protect the wearer and render them nearly immune to slipping on their own peels. They also squeek at 100% capacity."
	flags_1 = NOSLIP_1
	slowdown = SHOES_SLOWDOWN
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 70, "acid" = 50)
	strip_delay = 70
	resistance_flags = NONE
	permeability_coefficient = 0.05
	pockets = /obj/item/storage/internal/pocket/shoes

//The super annoying version
/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	name = "mk-honk combat shoes"
	desc = "The culmination of years of clown combat research, these shoes leave a trail of chaos in their wake. They will slowly recharge themselves over time, or can be manually charged with bananium."
	slowdown = SHOES_SLOWDOWN
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 70, "acid" = 50)
	strip_delay = 70
	resistance_flags = NONE
	permeability_coefficient = 0.05
	pockets = /obj/item/storage/internal/pocket/shoes
	always_noslip = TRUE
	var/max_recharge = 3000 //30 peels worth
	var/recharge_rate = 34 //about 1/3 of a peel per tick

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/Initialize()
	. = ..()
	GET_COMPONENT(bananium, /datum/component/material_container)
	bananium.insert_amount(max_recharge, MAT_BANANIUM)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/process()
	GET_COMPONENT(bananium, /datum/component/material_container)
	var/bananium_amount = bananium.amount(MAT_BANANIUM)
	if(bananium_amount < max_recharge)
		bananium.insert_amount(min(recharge_rate, max_recharge - bananium_amount), MAT_BANANIUM)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/attack_self(mob/user)
	ui_action_click(user)

//BANANIUM SWORD

/obj/item/melee/transforming/energy/sword/bananium
	name = "bananium sword"
	desc = "An elegant weapon, for a more civilized age."
	force = 0
	throwforce = 0
	force_on = 0
	throwforce_on = 0
	hitsound = null
	attack_verb_on = list("slipped")
	clumsy_check = FALSE
	sharpness = IS_BLUNT
	item_color = "yellow"
	heat = 0
	light_color = "#ffff00"
	var/next_trombone_allowed = 0

/obj/item/melee/transforming/energy/sword/bananium/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 60, GALOSHES_DONT_HELP)
	GET_COMPONENT(slipper, /datum/component/slippery)
	slipper.enabled = active

/obj/item/melee/transforming/energy/sword/bananium/attack(mob/living/M, mob/living/user)
	..()
	if(active)
		GET_COMPONENT(slipper, /datum/component/slippery)
		slipper.Slip(M)

/obj/item/melee/transforming/energy/sword/bananium/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	if(active)
		GET_COMPONENT(slipper, /datum/component/slippery)
		slipper.Slip(hit_atom)

/obj/item/melee/transforming/energy/sword/bananium/attackby(obj/item/I, mob/living/user, params)
	if((world.time > next_trombone_allowed) && istype(I, /obj/item/melee/transforming/energy/sword/bananium))
		next_trombone_allowed = world.time + 50
		to_chat(user, "You slap the two swords together. Sadly, they do not seem to fit.")
		playsound(src, 'sound/misc/sadtrombone.ogg', 50)
		return TRUE
	return ..()

/obj/item/melee/transforming/energy/sword/bananium/transform_weapon(mob/living/user, supress_message_text)
	..()
	GET_COMPONENT(slipper, /datum/component/slippery)
	slipper.enabled = active

/obj/item/melee/transforming/energy/sword/bananium/ignition_effect(atom/A, mob/user)
	return ""

/obj/item/melee/transforming/energy/sword/bananium/suicide_act(mob/user)
	if(!active)
		transform_weapon(user, TRUE)
	user.visible_message("<span class='suicide'>[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku, but the blade slips off of them harmlessly!</span>")
	GET_COMPONENT(slipper, /datum/component/slippery)
	slipper.Slip(user)
	return SHAME

//BANANIUM SHIELD

/obj/item/shield/energy/bananium
	name = "bananium energy shield"
	desc = "A shield that stops most melee attacks, protects user from almost all energy projectiles, and can be thrown to slip opponents."
	throw_speed = 1
	clumsy_check = 0
	base_icon_state = "bananaeshield"
	force = 0
	throwforce = 0
	throw_range = 5
	on_force = 0
	on_throwforce = 0
	on_throw_speed = 1

/obj/item/shield/energy/bananium/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 60, GALOSHES_DONT_HELP)
	GET_COMPONENT(slipper, /datum/component/slippery)
	slipper.enabled = active

/obj/item/shield/energy/bananium/attack_self(mob/living/carbon/human/user)
	..()
	GET_COMPONENT(slipper, /datum/component/slippery)
	slipper.enabled = active

/obj/item/shield/energy/bananium/throw_at(atom/target, range, speed, mob/thrower, spin=1)
	if(active)
		if(iscarbon(thrower))
			var/mob/living/carbon/C = thrower
			C.throw_mode_on() //so they can catch it on the return.
	return ..()

/obj/item/shield/energy/bananium/throw_impact(atom/hit_atom)
	if(active)
		var/caught = hit_atom.hitby(src, 0, 0)
		if(iscarbon(hit_atom) && !caught)//if they are a carbon and they didn't catch it
			GET_COMPONENT(slipper, /datum/component/slippery)
			slipper.Slip(hit_atom)
		if(thrownby && !caught)
			throw_at(thrownby, throw_range+2, throw_speed, null, 1)
	else
		return ..()


//BOMBANANA

/obj/item/reagent_containers/food/snacks/grown/banana/bombanana
	trash = /obj/item/grown/bananapeel/bombanana
	bitesize = 1
	customfoodfilling = FALSE
	seed = null
	tastes = list("explosives" = 10)
	list_reagents = list("vitamin" = 1)

/obj/item/grown/bananapeel/bombanana
	desc = "A peel from a banana. Why is it beeping?"
	seed = null
	var/det_time = 50
	var/obj/item/grenade/syndieminibomb/bomb

/obj/item/grown/bananapeel/bombanana/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, det_time)
	bomb = new /obj/item/grenade/syndieminibomb(src)
	bomb.det_time = det_time
	if(iscarbon(loc))
		to_chat(loc, "[src] begins to beep.")
		var/mob/living/carbon/C = loc
		C.throw_mode_on()
	bomb.preprime(loc, null, FALSE)

/obj/item/grown/bananapeel/bombanana/Destroy()
	. = ..()
	QDEL_NULL(bomb)

/obj/item/grown/bananapeel/bombanana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is deliberately slipping on the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	bomb.preprime(user, 0, FALSE)
	return (BRUTELOSS)

//TEARSTACHE GRENADE

/obj/item/grenade/chem_grenade/teargas/moustache
	name = "tear-stache grenade"
	desc = "A handsomely-attired teargas grenade."
	icon_state = "moustacheg"
	clumsy_check = GRENADE_NONCLUMSY_FUMBLE

/obj/item/grenade/chem_grenade/teargas/moustache/prime()
	var/myloc = get_turf(src)
	. = ..()
	for(var/mob/living/carbon/M in view(6, myloc))
		if(!istype(M.wear_mask, /obj/item/clothing/mask/gas/clown_hat) && !istype(M.wear_mask, /obj/item/clothing/mask/gas/mime) )
			if(!M.wear_mask || M.dropItemToGround(M.wear_mask))
				var/obj/item/clothing/mask/fakemoustache/sticky/the_stash = new /obj/item/clothing/mask/fakemoustache/sticky()
				M.equip_to_slot_or_del(the_stash, slot_wear_mask, TRUE, TRUE, TRUE, TRUE)

/obj/item/clothing/mask/fakemoustache/sticky
	var/unstick_time = 600

/obj/item/clothing/mask/fakemoustache/sticky/Initialize()
	. = ..()
	flags_1 |= NODROP_1
	addtimer(CALLBACK(src, .proc/unstick), unstick_time)

/obj/item/clothing/mask/fakemoustache/sticky/proc/unstick()
	flags_1 &= ~NODROP_1

//DARK H.O.N.K. AND CLOWN MECH WEAPONS

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana
	name = "bombanana mortar"
	desc = "Equipment for clown exosuits. Launches exploding banana peels."
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel/bombanana
	projectiles = 8
	projectile_energy_cost = 1000

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/tearstache
	name = "\improper HONKeR-6 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed tear-stache grenades."
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/grenade/chem_grenade/teargas/moustache
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/tearstache/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/mecha/combat/honker/dark
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. This one has been painted black for maximum fun. HONK!"
	name = "\improper Dark H.O.N.K"
	icon_state = "darkhonker"
	max_integrity = 300
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 40, "laser" = 50, "energy" = 35, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	max_temperature = 35000
	operation_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/honker/dark
	max_equip = 3

/obj/mecha/combat/honker/dark/GrantActions(mob/living/user, human_occupant = 0)
	..()
	thrusters_action.Grant(user, src)


/obj/mecha/combat/honker/dark/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	thrusters_action.Remove(user)

/obj/mecha/combat/honker/dark/add_cell(obj/item/stock_parts/cell/C)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/hyper(src)

/obj/mecha/combat/honker/dark/loaded/Initialize()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/honker()
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana()//Needed more offensive weapons.
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/tearstache()//The mousetrap mortar was not up-to-snuff.
	ME.attach(src)

/obj/structure/mecha_wreckage/honker/dark
	name = "\improper Dark H.O.N.K wreckage"
	icon_state = "darkhonker-broken"
