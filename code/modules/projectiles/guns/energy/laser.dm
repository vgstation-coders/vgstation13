/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	desc = "A basic weapon designed to kill with concentrated energy bolts."
	icon_state = "laser"
	item_state = "laser"
	fire_sound = 'sound/weapons/Laser.ogg'
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_COMBAT + "=3;" + Tc_MAGNETS + "=2"
	projectile_type = "/obj/item/projectile/beam"

/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	projectile_type = "/obj/item/projectile/beam/practice"
	clumsy_check = 0
	mech_flags = null // So it can be scanned by the Device Analyser

/obj/item/weapon/gun/energy/laser/pistol
	name = "laser pistol"
	desc = "A laser pistol issued to high ranking members of a certain shadow corporation."
	icon_state = "xcomlaserpistol"
	item_state = null
	w_class = W_CLASS_TINY
	projectile_type = /obj/item/projectile/beam/lightlaser
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	charge_cost = 100 // holds less "ammo" then the rifle variant.

/obj/item/weapon/gun/energy/laser/pistol/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/laser/rifle
	name = "laser rifle"
	desc = "A laser rifle issued to high ranking members of a certain shadow corporation."
	icon_state = "xcomlasergun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	projectile_type = /obj/item/projectile/beam
	charge_cost = 50

/obj/item/weapon/gun/energy/laser/failure_check(var/mob/living/carbon/human/M)
	if(istext(projectile_type))
		projectile_type = text2path(projectile_type)
	switch(projectile_type)
		if(/obj/item/projectile/beam/captain)
			if(prob(5))
				downgradelaser(M)
				return 1
		if(/obj/item/projectile/beam/heavylaser)
			if(prob(15))
				downgradelaser(M)
				return 1
		if(/obj/item/projectile/beam, /obj/item/projectile/beam/retro)
			if(prob(10))
				downgradelaser(M)
				return 1
		if(/obj/item/projectile/beam/lightlaser)
			if(prob(8))
				downgradelaser(M)
				return 1
		if(/obj/item/projectile/beam/weaklaser)
			if(prob(5))
				downgradelaser(M)
				return 1
	if(prob(1))
		to_chat(M, "<span class='danger'>\The [src] explodes!.</span>")
		explosion(get_turf(loc), -1, 0, 2)
		M.drop_item(src, force_drop = 1)
		qdel(src)
		return 0
	return ..()

/obj/item/weapon/gun/energy/laser/proc/downgradelaser(var/mob/living/carbon/human/M)
	switch(projectile_type)
		if(/obj/item/projectile/beam/heavylaser)
			projectile_type = /obj/item/projectile/beam
			fire_sound = 'sound/weapons/Laser.ogg'
		if(/obj/item/projectile/beam/captain, /obj/item/projectile/beam, /obj/item/projectile/beam/retro)
			projectile_type = /obj/item/projectile/beam/lightlaser
		if(/obj/item/projectile/beam/lightlaser)
			projectile_type = /obj/item/projectile/beam/weaklaser
		if(/obj/item/projectile/beam/weaklaser)
			projectile_type = /obj/item/projectile/beam/veryweaklaser
	in_chamber = null
	in_chamber = new projectile_type(src)
	fire_delay +=3
	to_chat(M, "<span class='warning'>Something inside \the [src] pops.</span>")

/obj/item/weapon/gun/energy/laser/admin
	name = "infinite laser gun"
	desc = "Spray and /pray."
	icon_state = "laseradmin"
	item_state = "laseradmin"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	projectile_type = /obj/item/projectile/beam
	charge_cost = 0

/obj/item/weapon/gun/energy/laser/admin/update_icon()
	return

/obj/item/weapon/gun/energy/laser/blaster
	name = "blaster rifle"
	desc = "An E-11 blaster rifle, made by BlasTech on the cheap."
	icon_state = "blaster"
	fire_sound = "sound/weapons/blaster-storm.ogg"

/obj/item/weapon/gun/energy/laser/blaster/New()
	..()
	if(prob(50))
		charge_cost = 0
		projectile_type = /obj/item/projectile/beam/practice/stormtrooper
		desc = "Don't expect to hit anything with this."

/obj/item/weapon/gun/energy/laser/blaster/update_icon()

/obj/item/weapon/gun/energy/laser/retro
	name ="retro laser"
	icon_state = "retro"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	projectile_type = /obj/item/projectile/beam/retro

/obj/item/weapon/gun/energy/laser/retro/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/laser/captain
	icon_state = "caplaser"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = null
	var/charge_tick = 0
	projectile_type = "/obj/item/projectile/beam/captain"

/obj/item/weapon/gun/energy/laser/captain/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/laser/captain/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/laser/captain/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/laser/captain/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1



/*/obj/item/weapon/gun/energy/laser/cyborg/load_into_chamber()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(100)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0*/

/obj/item/weapon/gun/energy/laser/cyborg
	var/charge_tick = 0

/obj/item/weapon/gun/energy/laser/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/laser/cyborg/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/laser/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	charge_tick++
	if(charge_tick < 3)
		return 0
	charge_tick = 0

	if(!power_supply)
		return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost) 		//Take power from the borg...
			power_supply.give(charge_cost)	//... to recharge the shot

	update_icon()
	return 1

/obj/item/weapon/gun/energy/laser/cyborg/restock()
	if(power_supply.charge < power_supply.maxcharge)
		power_supply.give(charge_cost)
		update_icon()
	else
		charge_tick = 0


/obj/item/weapon/gun/energy/laser/cannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=3;" + Tc_POWERSTORAGE + "=3"
	projectile_type = "/obj/item/projectile/beam/heavylaser"

	fire_delay = 2

/obj/item/weapon/gun/energy/laser/cannon/empty/New()
	..()

	if(power_supply)
		power_supply.charge = 0
		update_icon()

/obj/item/weapon/gun/energy/laser/cannon/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(250)
			in_chamber = new/obj/item/projectile/beam/heavylaser(src)
			return 1
	return 0

/obj/item/weapon/gun/energy/laser/cannon/cyborg/restock()
	if(power_supply.charge < power_supply.maxcharge)
		power_supply.give(charge_cost)
		update_icon()

/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon_state = "xray"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/laser3.ogg'
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=2;" + Tc_SYNDICATE + "=2"
	projectile_type = "/obj/item/projectile/beam/xray"
	charge_cost = 50


/obj/item/weapon/gun/energy/plasma
	name = "plasma gun"
	desc = "A high-power plasma gun. You shouldn't ever see this."
	icon_state = "xray"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/elecfire.ogg'
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=2"
	projectile_type = /obj/item/projectile/energy/plasma
	charge_cost = 50

/obj/item/weapon/gun/energy/plasma/failure_check(var/mob/living/carbon/human/M)
	if(prob(15))
		fire_delay += rand(2, 6)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		to_chat(M, "<span class='warning'>\The [src] sparks violently.</span>")
		return 1
	if(prob(5))
		M.drop_item()
		M.emote("scream",,, 1)
		M.adjustFireLossByPart(rand(5, 10), LIMB_LEFT_HAND, src)
		M.adjustFireLossByPart(rand(5, 10), LIMB_RIGHT_HAND, src)
		to_chat(M, "<span class='danger'>\The [src] burns your hands!.</span>")
		return 0
	if(prob(max(0, fire_delay/2-5)))
		var/turf/T = get_turf(loc)
		explosion(T, 0, 1, 3, 5)
		M.drop_item(src, force_drop = 1)
		qdel(src)
		to_chat(M, "<span class='danger'>\The [src] explodes!.</span>")
		return 0
	return ..()

/obj/item/weapon/gun/energy/plasma/pistol
	name = "plasma pistol"
	desc = "A state of the art pistol utilizing plasma in a uranium-235 lined core to output searing bolts of energy."
	icon_state = "alienpistol"
	item_state = null
	w_class = W_CLASS_TINY
	projectile_type = /obj/item/projectile/energy/plasma/pistol
	charge_cost = 100

/obj/item/weapon/gun/energy/plasma/pistol/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/plasma/light
	name = "plasma rifle"
	desc = "A state of the art rifle utilizing plasma in a uranium-235 lined core to output radiating bolts of energy."
	icon_state = "lightalienrifle"
	item_state = null
	projectile_type = /obj/item/projectile/energy/plasma/light
	charge_cost = 50

/obj/item/weapon/gun/energy/plasma/rifle
	name = "plasma cannon"
	desc = "A state of the art cannon utilizing plasma in a uranium-235 lined core to output hi-power, radiating bolts of energy."
	icon_state = "alienrifle"
	item_state = null
	w_class = W_CLASS_LARGE
	slot_flags = null
	projectile_type = /obj/item/projectile/energy/plasma/rifle
	charge_cost = 150

/obj/item/weapon/gun/energy/plasma/MP40k
	name = "Plasma MP40k"
	desc = "A plasma MP40k. Ich liebe den geruch von plasma am morgen."
	icon_state = "PlasMP"
	item_state = null
	projectile_type = /obj/item/projectile/energy/plasma/MP40k
	charge_cost = 75

/obj/item/weapon/gun/energy/laser/LaserAK
	name = "Laser AK470"
	desc = "A laser AK. Death solves all problems -- No man, no problem."
	icon_state = "LaserAK"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	projectile_type = /obj/item/projectile/beam
	charge_cost = 75

/obj/item/weapon/gun/energy/megabuster
	name = "Mega-buster"
	desc = "An arm-mounted buster toy!"
	icon_state = "megabuster"
	item_state = null
	w_class = W_CLASS_SMALL
	projectile_type = "/obj/item/projectile/energy/megabuster"
	charge_states = 0
	charge_cost = 5
	fire_sound = 'sound/weapons/megabuster.ogg'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/megabusters.dmi', "right_hand" = 'icons/mob/in-hand/right/megabusters.dmi')

/obj/item/weapon/gun/energy/megabuster/proto
	name = "Proto-buster"
	icon_state = "protobuster"

/obj/item/weapon/gun/energy/mmlbuster
	name = "Buster Cannon"
	desc = "An antique arm-mounted buster cannon."
	icon_state = "mmlbuster"
	item_state = null
	w_class = W_CLASS_SMALL
	charge_states = 0
	projectile_type = "/obj/item/projectile/energy/buster"
	charge_cost = 25
	fire_sound = 'sound/weapons/mmlbuster.ogg'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/megabusters.dmi', "right_hand" = 'icons/mob/in-hand/right/megabusters.dmi')

/obj/item/weapon/gun/energy/laser/smart
	name = "smart laser gun"
	desc = "An upgraded model of the basic laser gun. There seems to be some sort of slot in the handle."
	can_take_pai = TRUE
	origin_tech = Tc_COMBAT + "=3;" + Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=4"

/obj/item/weapon/gun/energy/laser/rainbow

	name = "rainbow laser"
	desc = "A fearsome gun used by clown special forces. Its design is flawed however as clumsy users find it hard to operate."
	projectile_type = "/obj/item/projectile/beam/white"
	var/current_color = 1
	var/static/list/color_list = list("#FF0000","#FF8C00","#FFFF00","#00FF00","#00BFFF","#0000FF","#9400D3")
	var/fire_mode = 1 // 1 = laser, 0 = braindamage.
	icon_state = "rainbow_laser"
/obj/item/weapon/gun/energy/laser/rainbow/attack_self(mob/living/user)

	switch(fire_mode)
		if(0)
			fire_mode = 1
			to_chat(user, "<span class='warning'>\The [src.name] is now set to kill.</span>")
			projectile_type = "/obj/item/projectile/beam/white"
			playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
			fire_sound = 'sound/weapons/Laser.ogg'
		if(1)
			fire_mode = 0
			to_chat(user, "<span class='warning'>\The [src.name] is now set to mindflay.</span>")
			projectile_type = "/obj/item/projectile/beam/rainbow/braindamage"
			playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
			fire_sound = 'sound/items/quack.ogg'



/obj/item/weapon/gun/energy/laser/rainbow/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)

	projectile_color = color_list[current_color]
	if(current_color < color_list.len )
		current_color+=1
	else
		current_color = 1
	..()
