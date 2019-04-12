////////Laser Tag////////////////////
/obj/item/weapon/gun/energy/tag
	name = "laser tag gun"
	desc = "Standard issue weapon of the Imperial Guard."
	item_state = null
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_ELECTRONIC
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = Tc_MAGNETS + "=2"
	mech_flags = null // So it can be scanned by the Device Analyser
	clumsy_check = 0
	advanced_tool_user_check = 0
	nymph_check = 0
	hulk_check = 0
	golem_check = 0
	var/charge_tick = 0
	var/score = 0

	icon_state = "bluetag"
	fire_sound = 'sound/weapons/Laser.ogg'
	var/laser_projectile = /obj/item/projectile/beam/lasertag/blue
	var/taser_projectile = /obj/item/projectile/beam/lasertag/omni
	var/needed_vest = /obj/item/clothing/suit/tag/bluetag

/obj/item/weapon/gun/energy/tag/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/tag/proc/score()
    playsound(src, 'sound/weapons/quake.ogg', 60)
    score++

/obj/item/weapon/gun/energy/tag/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>This gun has scored [score] points against the enemy team!</span>")

/obj/item/weapon/gun/energy/tag/verb/clear_score()
	set name = "Clear Laser Tag Score"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	usr.visible_message("<span class='warning'>\The [usr] is resetting \the [src]'s score!</span>")
	if(do_after(usr, src, 2 SECONDS))
		score = 0
		to_chat(usr, "<span class='info'>[bicon(src)] You reset the score.</span>")

/obj/item/weapon/gun/energy/tag/blue
	icon_state = "bluetag"
	laser_projectile = /obj/item/projectile/beam/lasertag/blue
	taser_projectile = /obj/item/projectile/energy/tag/blue
	needed_vest = /obj/item/clothing/suit/tag/bluetag

/obj/item/weapon/gun/energy/tag/red
	icon_state = "redtag"
	laser_projectile = /obj/item/projectile/beam/lasertag/red
	taser_projectile = /obj/item/projectile/energy/tag/red
	needed_vest = /obj/item/clothing/suit/tag/redtag

/obj/item/weapon/gun/energy/tag/proc/makeLaser(var/mob/user)
	projectile_type = laser_projectile
	fire_sound = 'sound/weapons/Laser.ogg'
	if(user)
		to_chat(user, "<span class='warning'>[bicon(src)] Set to laser tag!</span>")

/obj/item/weapon/gun/energy/tag/proc/makeTaser(var/mob/user)
	projectile_type = taser_projectile
	fire_sound = 'sound/weapons/Taser.ogg'
	if(user)
		to_chat(user, "<span class='warning'>[bicon(src)] Set to taser tag!</span>")

/obj/item/weapon/gun/energy/tag/attack_self(var/mob/user)
    if(projectile_type != laser_projectile)
        makeLaser(user)
    else
        makeTaser(user)

/obj/item/weapon/gun/energy/tag/special_check(var/mob/living/M)
	if(istype(get_tag_armor(M), needed_vest))
		return 1
	to_chat(M, "<span class='warning'>You need to be wearing your laser tag vest!</span>")
	return 0

/obj/item/weapon/gun/energy/tag/New()
	..()
	processing_objects.Add(src)
	makeLaser()

/obj/item/weapon/gun/energy/tag/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/tag/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1
