/obj/item/weapon/gun/hookshot/harpoon
	name = "harpoon"
	desc = ""
	icon_state = "hookshot"
	item_state = "hookshot"
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=2;" + Tc_COMBAT + "=3;" + Tc_MAGNETS + "=2"
	clumsy_check = 1
	hooktype = /obj/item/projectile/hookshot/harpoon
	maxlength = 5
	var/shotTier = 0
	var/maxTier = 4

/obj/item/weapon/gun/hookshot/harpoon/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/gun/hookshot/harpoon/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/hookshot/harpoon/process()
	if(shotTier < maxTier)
		shotTier++

/obj/item/weapon/gun/hookshot/harpoon/Fire()
	if(shotTier <1)
		playsound()	//Like a clang or something
	else
		..()


/obj/item/weapon/gun/hookshot/harpoon/syndicate
	name = "harpoon"
	desc = ""
	icon_state = "hookshot"
	item_state = "hookshot"
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=2;" + Tc_COMBAT + "=4;" + Tc_MAGNETS + "=2;" + Tc_SYNDICATE + "=4"
	hooktype = /obj/item/projectile/hookshot/harpoon/syndicate
	maxlength = 6
	maxTier = 8


/obj/item/projectile/hookshot/harpoon
	name = "harpoon"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = ""
	damage = 5
	nodamage = FALSE
	kill_count = 15
	failure_message = "With a CLANG noise, the chain mysteriously snaps and rewinds back into the harpoon."
	icon_name = "harpoon"
	var/shotTier = 0
	var/slowShot = 1.2
	var/fastShot = 0.6
	var/speedUpTier = 2
	var/effectUpTier = 4

/obj/item/projectile/hookshot/harpoon/OnFired()
	..()
	var/obj/item/weapon/gun/hookshot/harpoon/H = shot_from
	shotTier = H.shotTier
	H.shotTier = 0
	if(shotTier <= speedUpTier)
		projectile_speed = slowShot
	else
		projectile_speed = fastShot
	damage = damage*shotTier

/obj/item/projectile/hookshot/harpoon/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	if(isanimal(atarget))
		harpoonAnimal(atarget)
	if(isfish(atarget))	//affecting both animal and fish is intentional
		harpoonFish(atarget)
	else if(ishuman(atarget))
		harpoonHuman(atarget)

/obj/item/projectile/hookshot/harpoon/proc/harpoonAnimal(var/mob/living/simple_animal/theAnimal)
	if(shotTier >= effectUpTier)
		theAnimal.Stun(5)
		if(theAnimal.stunned)
			theAnimal.visible_message("<span class='notice'>\The [theAnimal] is stunned by intense pain!</span>")

/obj/item/projectile/hookshot/harpoon/proc/harpoonFish(var/mob/living/simple_animal/hostile/fishing/theFish)
	theFish.adjustBruteLoss(damage)	//effectively double damage to fish

/obj/item/projectile/hookshot/harpoon/proc/harpoonHuman(var/mob/living/carbon/human/theHuman)
	if(shotTier >= effectUpTier)
		theHuman.adjustHalloss(damage)	//Hurts real bad but not the murder kind of hurt


/obj/item/projectile/hookshot/harpoon/syndicate
	damage = 4
	slowShot = 1.5	//Slower than a taser
	speedUpTier = 6
	effectUpTier = 8

/obj/item/projectile/hookshot/harpoon/syndicate/OnFired()
	..()
	if(shotTier >= effectUpTier)
		penetration = -1
	else
		penetration = 0

/obj/item/projectile/hookshot/harpoon/syndicate/harpoonHuman(var/mob/living/carbon/human/theHuman)
	theHuman.Knockdown(3)
	if(shotTier >= effectUpTier)
		theHuman.Stun(1)
		if(shotTier >= effectUpTier)
			if(theHuman.can_butcher && theHuman.meat_type)
			var/manTheHarpoons = 1
			manTheHarpoons += theHuman.overeatduration/195
				for(var/M in manTheHarpoons)
					if(theHuman.meat_amount > theHuman.meat_taken)
						new theHuman.meat_type(theHuman.loc)
						theHuman.meat_taken++
					else
						var/list/O = theHuman.get_organs(LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
						var/toDrop = null	//Needs typecasting
						if(O.len)
							toDrop = pick(O)
							toDrop.droplimb(1)
//overeatduration is effectively maxed at 600 and humans have 3 meat to start.
//Essentially a maxfat person will lose a limb to start but less than that will just lose meat.
//195 for rounding purposes and to avoid every other tick making you have 599 overeat, saving you a limb.
