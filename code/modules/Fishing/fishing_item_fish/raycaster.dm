/obj/item/weapon/gun/projectile/raycaster
	name = "raycaster"
	desc = "A carnivorous creature resembling a sting ray. Metabolically it is extremely efficient, devoting most nutrient intake to the generation of projectile quills. It's rumored that upon its discovery and subsequent naming a astro-ichthyologist in attendance had to be removed after he threw a punch at the one who suggested 'raycaster'."
	icon = ''
	icon_state = "raycaster"
	item_state = "raycaster"
	starting_materials = list()
	w_type = RECYK_BIOLOGICAL
	origin_tech = null
	mech_flags = MECH_SCAN_FAIL //You can't print a fish
	fire_sound = 'sound/weapons/hivehand.ogg'
	empty_sound = 'sound/weapons/hivehand_empty.ogg'
	fire_volume = 25
	caliber = null
	ejectshell = 0
	clumsy_check = 0	//Has its own clumsy check, the fish doesn't explode
	conventional_firearm = 0
	var/meatBank = 0
	var/maxMeat = 30
	var/meatToAmmo = 3
	var/maxAmmo = 1
	var/currentAmmo = 1
	var/projModifier = 0

/obj/item/weapon/gun/projectile/raycaster/angler_effect(obj/item/weapon/bait/baitUsed)
	projModifier = baitUsed.catchPower/25	//Will require above average bait to get a base "intended" raycaster and ridiculous bait to get the penetrate effect
	maxMeat = (maxMeat + baitUsed.catchSizeAdd) * baitUsed.catchSizeMult
	maxAmmo = maxMeat*0.1

/obj/item/weapon/gun/projectile/raycaster/proc/enhanceSpine(/obj/item/projectile/bullet/raycaster/theSpine)
	theSpine.fishTox += min(projModifier, 5)
	theSpine.agony += min(projModifier, 10)
	theSpine.damage += min(projModifier, 10)
	if(projModifier >= 10)
		penetration += projModifier //Should allow it to penetrate through 1 mob or 1-2 non-reinforced walls except in extreme cases


/obj/item/weapon/gun/projectile/raycaster/New()
	processing_objects.Add(src)

/obj/item/weapon/gun/projectile/raycaster/attackby(obj/item/M, mob/user)
	..()
	if(istype(M, /obj/item/weapon/reagent_containers/food)
		var/obj/item/weapon/reagent_containers/food/theMeat = M
		if(theMeat.food_flags && FOOD_MEAT)
			if(meatBank < maxMeat)
				to_chat(user, "<span class='notice'>You feed \the [src] \the [theMeat].</span>")
				meatBank += theMeat.reagents.get_reagent_amount(NUTRIMENT)	//Letting it overeat is intentional
				qdel(theMeat)
			else
				to_chat(user, "<span class='notice'>\The [src] doesn't seem hungry.</span>")

/obj/item/weapon/gun/projectile/raycaster/process()
	if(currentAmmo < maxAmmo && meatToAmmo < meatBank)
		meatBank -= meatToAmmo
		currentAmmo++
		chamberSpine()

/obj/item/weapon/gun/projectile/raycaster/proc/chamberSpine()
	if(currentAmmo && !process_chambered())
		var/theSpine = new /obj/item/projectile/bullet/raycaster(src)
		in_chamber = theSpine
		enhanceSpine(theSpine)

/obj/item/weapon/gun/projectile/raycaster/process_chambered()
	return in_chamber

/obj/item/weapon/gun/raycaster/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return
	if(user.is_pacified(VIOLENCE_GUN,A,src))
		return
	if(clumsy_check(user))
		to_chat(user, "<span class='warning'>\The [src] flaps angrily before taking a large bite out of you!.</span>")
		adjustBruteLoss(meatToAmmo*3)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.species.anatomy_flags && !NO_SKIN)
				meatBank++	//Overfeeding via clown abuse is of course intentional, so is allowing the clown to fire anyway
	if(Fire(A,user,params, "struggle" = struggle))
		currentAmmo--
		chamberSpine()
	else
		to_chat(user, "<span class='notice'>\The [src] does not have a spine prepared to fire.</span>")



//The projectile
/obj/item/projectile/bullet/raycaster
	name = "raycaster spine"
	icon_state = "raycaster_spine"
	damage = 10
	damage_type = BRUTE
	flag = "bio"
	fire_sound = 'sound/weapons/hivehand.ogg'
	projectile_speed = 0.5
	var/fishTox = 0

/obj/item/projectile/bullet/raycaster/on_hit(var/atom/atarget, var/blocked = 0)
	if(..())
		if(isliving(atarget))
			var/mob/living/L = atarget
			L.reagents.add_reagent(FISHTOX, fishTox)
	////////////////MAYBE GO BACK AND CHANGE THE NAME I DUNNO////////////////////////////////////////////////////
