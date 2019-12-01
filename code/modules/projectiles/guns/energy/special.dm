/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	icon_state = "ionrifle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/ion.ogg'
	origin_tech = Tc_COMBAT + "=2;" + Tc_MAGNETS + "=4"
	w_class = W_CLASS_LARGE
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	charge_cost = 100
	projectile_type = "/obj/item/projectile/ion"

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/weapon/gun/energy/ionrifle/ioncarbine
	name = "ion carbine"
	desc = "A stopgap ion weapon designed to disable smaller mechanical threats."
	icon_state = "ioncarbine"
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_BELT
	cell_type = "/obj/item/weapon/cell/crap/better"
	projectile_type = "/obj/item/projectile/ion/small"

/obj/item/weapon/gun/energy/ionrifle/ioncarbine/ionpistol
	name = "ion pistol"
	desc = "A small, low capacity ion weapon designed to disrupt smaller mechanical threats."
	icon_state = "ionpistol"
	cell_type = "/obj/item/weapon/cell/crap"

/obj/item/weapon/gun/energy/ionrifle/ioncarbine/ionpistol/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=4;" + Tc_POWERSTORAGE + "=3"
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/declone"

/obj/item/weapon/gun/energy/decloner/failure_check(var/mob/living/carbon/human/M)
	if(prob(15))
		M.apply_radiation(rand(15,30), RAD_EXTERNAL)
		to_chat(M, "<span class='warning'>\The [src] feels warm for a moment.</span>")
		return 1
	if(prob(15))
		M.adjustCloneLoss(rand(5,15))
		to_chat(M, "<span class='warning'>\The [src] feels warm for a moment.</span>")
		return 1
	if(prob(3))
		M.apply_radiation(rand(60,80), RAD_EXTERNAL)
		M.adjustCloneLoss(rand(30,50))
		to_chat(M, "<span class='danger'>\The [src] breaks apart!.</span>")
		M.drop_item(src, force_drop = 1)
		qdel(src)
		return 0
	return ..()

/obj/item/weapon/gun/energy/decloner/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/staff
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_sound = 'sound/weapons/radgun.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	w_class = W_CLASS_LARGE
	charge_cost = 200
	projectile_type = "/obj/item/projectile/change"
	origin_tech = null
	clumsy_check = 0
	var/charge_tick = 0


/obj/item/weapon/gun/energy/staff/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/staff/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/staff/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(200)
	return 1

/obj/item/weapon/gun/energy/staff/update_icon()
	return

/obj/item/weapon/gun/energy/staff/change
	var/changetype=null
	var/next_changetype=0

/obj/item/weapon/gun/energy/staff/change/process_chambered()
	if(!..())
		return 0
	var/obj/item/projectile/change/P=in_chamber
	if(P && istype(P))
		P.changetype=changetype
	return 1

/obj/item/weapon/gun/energy/staff/change/attack_self(var/mob/living/user)
	if(world.time < next_changetype)
		to_chat(user, "<span class='warning'>[src] is still recharging.</span>")
		return

	var/selected = input("You squint at the dial conspicuously mounted on the side of your staff.","Staff of Change") as null|anything in list("random")+available_staff_transforms
	if(!selected)
		return

	if (selected == "furry")
		to_chat(user, "<span class='danger'>You monster.</span>")
	else
		to_chat(user, "<span class='info'>You have selected to make your next victim have a [selected] form.</span>")
	add_gamelogs(user, "set \the [src] to \ [selected]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "warning")
	switch(selected)
		if("random")
			changetype=null
		else
			changetype=selected
	next_changetype=world.time+SOC_CHANGETYPE_COOLDOWN

/obj/item/weapon/gun/energy/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staffofanimation"
	item_state = "staffofanimation"
	projectile_type = "/obj/item/projectile/animate"
	charge_cost = 100

#define RAISE_TYPE_ZOMBIE 0
#define RAISE_TYPE_SKELETON 1
//#define RAISE_TYPE_FAITHLESS 2
/obj/item/weapon/gun/energy/staff/necro
	name = "staff of necromancy"
	desc = "A wicked looking staff that pulses with evil energy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostaff"
	item_state = "necrostaff"
	charge_tick = 0
	var/charges = 3
	var/raisetype = 0
	var/next_change = 0
/obj/item/weapon/gun/energy/staff/necro/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/staff/necro/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/staff/necro/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	charges++
	return 1

/obj/item/weapon/gun/energy/staff/necro/attack_self(mob/user)
	if(next_change > world.timeofday)
		to_chat(user, "<span class='warning'>You must wait longer to decide on a minion type.</span>")
		return
	/*if(raisetype < RAISE_TYPE_FAITHLESS)
		raisetype = !raisetype
	else
		raisetype = RAISE_TYPE_ZOMBIE*/
	raisetype = !raisetype

	to_chat(user, "<span class='notice'>You will now raise [raisetype < 2 ? (raisetype ? "skeletal" : "zombified") : "unknown"] minions from corpses.</span>")
	next_change = world.timeofday + 30

/obj/item/weapon/gun/energy/staff/necro/afterattack(atom/target, mob/user, proximity)
	if(!ishuman(target) || !charges || get_dist(target, user) > 7)
		return 0
	var/mob/living/carbon/human/H = target
	if(!H.stat || (H.stat < DEAD && H.health > config.health_threshold_crit))
		to_chat(user, "<span class = 'warning'>[!H.stat?"\The [target] needs to be dead or in a critical state first.":H.health>config.health_threshold_crit?"\The [target] has not received enough damage.":"Something went wrong with the conversion process."]</span>")
		return 0

	//Pretty particles
	make_tracker_effects(get_turf(H), user)
	//Not so pretty manical laughter
	if(iswizard(user) || isapprentice(user))
		user.say(pick("ARISE, [pick("MY CREATION","MY MINION","CH'KUN")].",\
		"BOW BEFORE [pick("MY POWER","ME, [uppertext(H.real_name)]")].",\
		"G'T T'FUK UP.",\
		"IF YOU DIE, YOU DIE FOR ME.",\
		"EVEN IN DEATH YOU MAY SERVE.",\
		"YOUR SUFFERING IS MY ENJOYMENT.",\
		"A NEW PLAYTHING FOR MY COLLECTION.",\
		"YOUR TIME HAS NOT COME, YET.",\
		"YOUR SOUL MAY BELONG TO [uppertext(ticker.Bible_deity_name)] BUT YOU BELONG TO ME."))

	playsound(src, get_sfx("soulstone"), 50,1)

	switch(raisetype)
		if(RAISE_TYPE_ZOMBIE)
			var/mob/living/simple_animal/hostile/necro/zombie/turned/T = new(get_turf(target), user, H)
			T.get_clothes(H, T)
			T.name = H.real_name
			T.host = H
			H.loc = null
		if(RAISE_TYPE_SKELETON)
			new /mob/living/simple_animal/hostile/necro/skeleton(get_turf(target), user, H)
			H.gib()
	charges--



/obj/item/weapon/gun/energy/staff/necro/attack(mob/living/target as mob, mob/living/user as mob)
	afterattack(target,user,1)

#undef RAISE_TYPE_ZOMBIE
#undef RAISE_TYPE_SKELETON

/obj/item/weapon/gun/energy/staff/destruction_wand
	name = "wand of destruction"
	desc = "A wand imbued with raw destructive force, capable of erasing nearly anything from existence."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "deathwand"
	item_state = "deathwand"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = W_CLASS_TINY
	charge_cost = 1000
	var/lifekiller = 0
	var/power_notice = 0

/obj/item/weapon/gun/energy/staff/destruction_wand/lifekiller
	lifekiller = 1

/obj/item/weapon/gun/energy/staff/destruction_wand/process()
	..()
	if(power_supply.charge == power_supply.maxcharge && !lifekiller && !power_notice)
		if(istype(src.loc, /mob/living/carbon))
			var/mob/living/carbon/C = src.loc
			to_chat(C, "<span class='notice'>[src] pulses, full of energy.</span>")
			power_notice = 1
	else if(power_supply.charge < power_supply.maxcharge)
		power_notice = 0

/obj/item/weapon/gun/energy/staff/destruction_wand/attack(atom/target as mob|obj|turf|area, mob/living/user as mob, def_zone)
	if(target == user && !mouthshoot)
		if(!(power_supply.charge == charge_cost || lifekiller))
			if(!lifekiller)
				to_chat(user, "<span class='notice'>[src] fizzles quietly.</span>")
			else
				to_chat(user, "<span class='warning'>[src] is not ready to fire again!</span>")
			return
		mouthshoot = 1
		target.visible_message("<span class='warning'>[user] turns [src] on themself, ready to invoke its power...</span>")
		if(!do_after(user,src, 40))
			target.visible_message("<span class='notice'>[user] decided life was worth living</span>")
			mouthshoot = 0
			return
		user.visible_message("<span class = 'warning'>[user] destroys themself!</span>")
		playsound(user, fire_sound, 50, 1)
		user.gib()
		power_supply.use(charge_cost)
		mouthshoot = 0
		return
	else
		src.Fire(target,user,0,0,0)

/obj/item/weapon/gun/energy/staff/destruction_wand/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(power_supply.charge == charge_cost || lifekiller)
		if(!istype(target, /turf/simulated/wall) && !istype(target, /turf/simulated/floor))
			if(!istype(target, /mob/living))
				if(!target.singularity_act())
					to_chat(user, "<span class='notice'>This entity is too powerful to be destroyed!</span>")
					return
			else if(target.flags & INVULNERABLE)
				to_chat(user, "<span class='notice'>This entity is too powerful to be destroyed!</span>")
				return
		if(istype(target, /mob/living))
			if(!lifekiller)
				to_chat(user, "<span class='notice'>[src] fizzles quietly.</span>")
				return
			var/mob/living/L = target
			log_attack("[user.name] ([user.ckey]) gibbed [target] [ismob(target) ? "([target:ckey])" : ""] with [src] at ([target.x],[target.y],[target.z])[struggle ? " due to being disarmed." :""]" )
			L.gib()
			user.visible_message("<span class='warning'>[user] destroys [target] with [src]!</span>", \
								 "<span class='warning'>You destroy [target] with [src]!</span>")
			playsound(user, fire_sound, 50, 1)
			power_supply.use(charge_cost)
		else if(istype(target, /turf))
			if(istype(target, /turf/simulated/wall))
				user.visible_message("<span class='warning'>[user] erases the [target.name] with [src]!</span>", \
									 "<span class='warning'>You erase the [target.name] with [src]!</span>")
				playsound(user, fire_sound, 50, 1)
				power_supply.use(charge_cost)
				if(istype(target, /turf/simulated/wall/r_wall))
					target.ex_act(1.0)
				else
					var/turf/simulated/wall/W = target
					W.dismantle_wall(1,1)
			else if(istype(target, /turf/simulated/floor) || istype(target, /turf/simulated/shuttle))
				to_chat(user, "<span class='notice'>[src] fizzles quietly.</span>")
				return
			else
				return
		else
			user.visible_message("<span class='warning'>[user] erases the [target.name] with [src]!</span>", \
								 "<span class='warning'>You erase the [target.name] with [src]!</span>")
			playsound(user, fire_sound, 50, 1)
			power_supply.use(charge_cost)
			qdel(target)
	else
		to_chat(user, "<span class='warning'>[src] is not ready to fire again!</span>")

/obj/item/weapon/gun/energy/staff/swapper
	name = "staff of swip-swap"
	desc = "The head and handle of this strange device keep switching places."
	icon = 'icons/obj/wizard.dmi'
	inhand_states = list(
	"left_hand" = 'icons/mob/in-hand/left/guns.dmi',
	"right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	item_state = "staffswap"
	icon_state = "staff_swap"
	projectile_type = "/obj/item/projectile/swap"
	flags = FPRINT | TWOHANDABLE

/obj/item/weapon/gun/energy/staff/swapper/update_wield(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>[wielded?"Holding \the [src] in both hands grants it more power!":"As you hold \the [src] in one hand, it sighs."]</span>")
	if(wielded)
		projectile_type = "/obj/item/projectile/swap/advanced"
	else
		projectile_type = initial(projectile_type)

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "floramut100"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/effects/stealthoff.ogg'
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/floramut"
	origin_tech = Tc_MATERIALS + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=3"
	mech_flags = null // So it can be scanned by the Device Analyser
	modifystate = "floramut"
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost, 2 = emag-mutate
	var/mutstrength = 10 //how many units of mutagen will the mutation projectile act as

/obj/item/weapon/gun/energy/floragun/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/floragun/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/floragun/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/floragun/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/floragun/process_chambered()
	. = ..()
	if(istype(in_chamber, /obj/item/projectile/energy/floramut))
		var/obj/item/projectile/energy/floramut/P = in_chamber
		P.mutstrength = src.mutstrength

/obj/item/weapon/gun/energy/floragun/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			mode = 1
			charge_cost = 100
			to_chat(user, "<span class='warning'>\The [src] is now set to improve harvests.</span>")
			projectile_type = "/obj/item/projectile/energy/florayield"
			modifystate = "florayield"
		if(1)
			mode = 0
			charge_cost = mutstrength * 10
			to_chat(user, "<span class='warning'>\The [src] is now set to induce mutations.</span>")
			projectile_type = "/obj/item/projectile/energy/floramut"
			modifystate = "floramut"
		if(2)
			to_chat(user, "<span class='warning'>\The [src] appears to be locked into one mode.</span>")
			return
	update_icon()
	return

/obj/item/weapon/gun/energy/floragun/verb/SetMutationStrength()
	set name = "Set mutation strength"
	set category = "Object"
	if(mode == 2)
		mutstrength = input(usr, "Enter new mutation strength level (15-25):", "Somatoray Gamma Ray Threshold", mutstrength) as num
		mutstrength = clamp(round(mutstrength), 15, 25)
	else
		mutstrength = input(usr, "Enter new mutation strength level (1-15):", "Somatoray Alpha Ray Threshold", mutstrength) as num
		mutstrength = clamp(round(mutstrength), 1, 15)

/obj/item/weapon/gun/energy/floragun/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isEmag(W) || issolder(W))
		if (mode == 2)
			to_chat(user, "The safeties are already de-activated.")
		else
			mode = 2
			mutstrength = 25
			charge_cost = mutstrength * 10
			projectile_type = "/obj/item/projectile/energy/floramut/emag"
			to_chat(user, "<span class='warning'>You short out the safety limit of the [src.name]!</span>")
			desc += " It seems to have it's safety features de-activated."
			playsound(user, 'sound/effects/sparks4.ogg', 50, 1)
			modifystate = "floraemag"
			update_icon()

/obj/item/weapon/gun/energy/floragun/afterattack(obj/target, mob/user, flag)
	if(flag && istype(target,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = target
		if(process_chambered())
			user.visible_message("<span class='danger'> \The [user] fires \the [src] into \the [tray]!</span>")
			Fire(target,user)
		return
	..()

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = W_CLASS_LARGE
	projectile_type = "/obj/item/projectile/meteor"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/meteorgun/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/meteorgun/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/meteorgun/process()
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)

/obj/item/weapon/gun/energy/meteorgun/update_icon()
	return


/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	w_class = W_CLASS_TINY


/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	projectile_type = "/obj/item/projectile/beam/mindflayer"
	fire_sound = 'sound/weapons/Laser.ogg'

obj/item/weapon/gun/energy/staff/focus
	name = "mental focus"
	desc = "An artifact that channels the will of the user into destructive bolts of force. If you aren't careful with it, you might poke someone's brain out.\n Has two modes: Single and AoE"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "focus"
	item_state = "focus"
	projectile_type = "/obj/item/projectile/forcebolt"
	charge_cost = 100

obj/item/weapon/gun/energy/staff/focus/attack_self(mob/living/user as mob)
	if(projectile_type == "/obj/item/projectile/forcebolt")
		charge_cost = 250
		to_chat(user, "<span class='warning'>The [src.name] will now strike a small area.</span>")
		projectile_type = "/obj/item/projectile/forcebolt/strong"
	else
		charge_cost = 100
		to_chat(user, "<span class='warning'>The [src.name] will now strike only a single person.</span>")
		projectile_type = "/obj/item/projectile/forcebolt"

/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	fire_sound = 'sound/weapons/kinetic_accelerator.ogg'
	projectile_type = "/obj/item/projectile/kinetic"
	cell_type = "/obj/item/weapon/cell/crap"
	charge_cost = 50
	icon_charge_multiple = 20
	var/overheat = 0
	var/recent_reload = 1
/*
/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	overheat = 1
	spawn(20)
		overheat = 0
		recent_reload = 0
	..()
*/
/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(var/mob/living/user)
	if(overheat || recent_reload)
		return
	power_supply.give(500)
	playsound(src.loc, 'sound/weapons/shotgunpump.ogg', 60, 1)
	recent_reload = 1
	update_icon()
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	projectile_type = "/obj/item/projectile/kinetic"
	cell_type = "/obj/item/weapon/cell/miningborg"
	charge_cost = 50
	var/charge_tick = 0

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
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

/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/restock()
	if(power_supply.charge < power_supply.maxcharge)
		power_supply.give(charge_cost)
		update_icon()
	else
		charge_tick = 0

/obj/item/weapon/gun/energy/radgun
	name = "radgun"
	desc = "An experimental energy gun that fires radioactive projectiles that deal toxin damage, irradiate, and scramble DNA, giving the victim a different appearance and name, and potentially harmful or beneficial mutations. Recharges automatically."
	icon_state = "radgun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/radgun.ogg'
	charge_cost = 100
	var/charge_tick = 0
	projectile_type = "/obj/item/projectile/energy/rad"

/obj/item/weapon/gun/energy/radgun/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/radgun/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/radgun/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/radgun/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/ricochet
	name = "ricochet rifle"
	desc = "They say that these were originally designed for duck games. Not that there's any duck in this part of space."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "ricochet"
	item_state = null
	origin_tech = Tc_MATERIALS + "=3;" + Tc_POWERSTORAGE + "=3;" + Tc_COMBAT + "=3"
	slot_flags = SLOT_BELT
	projectile_type = "/obj/item/projectile/ricochet"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')

obj/item/weapon/gun/energy/ricochet/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(defective && prob(30))
		target = get_ranged_target_turf(user, pick(diagonal), 7)
	..()

/obj/item/weapon/gun/energy/bison
	name = "\improper Righteous Bison"
	desc = "A replica of Lord Cockswain's very own personal ray gun."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "bison"
	item_state = null
	origin_tech = Tc_MATERIALS + "=3;" + Tc_POWERSTORAGE + "=3;" + Tc_COMBAT + "=3"
	slot_flags = SLOT_BELT
	projectile_type = "/obj/item/projectile/beam/bison"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	fire_delay = 8
	fire_sound = 'sound/weapons/bison_fire.ogg'
	var/pumping = 0

/obj/item/weapon/gun/energy/bison/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/bison/New()
	..()
	power_supply.charge = 0

/obj/item/weapon/gun/energy/bison/attack_self(mob/user as mob)
	if(pumping || !power_supply)
		return
	pumping = 1
	power_supply.charge = min(power_supply.charge + 200,power_supply.maxcharge)
	if(power_supply.charge >= power_supply.maxcharge)
		playsound(src, 'sound/machines/click.ogg', 25, 1)
		to_chat(user, "<span class='rose'>You pull the pump at the back of the gun. Looks like the inner battery is fully charged now.</span>")
	else
		playsound(src, 'sound/weapons/bison_reload.ogg', 25, 1)
		to_chat(user, "<span class='rose'>You pull the pump at the back of the gun.</span>")
	sleep(5)
	pumping = 0
	update_icon()

/obj/item/weapon/gun/energy/bison/update_icon()
	if(power_supply.charge >= power_supply.maxcharge)
		icon_state = "bison100"
	else if (power_supply.charge > 0)
		icon_state = "bison50"
	else
		icon_state = "bison0"
	return

#define SPUR_FULL_POWER 4
#define SPUR_HIGH_POWER 3
#define SPUR_MEDIUM_POWER 2
#define SPUR_LOW_POWER 1
#define SPUR_NO_POWER 0

/obj/item/weapon/gun/energy/polarstar
	name = "\improper Polar Star"
	desc = "Despite being incomplete, the severe wear on this gun shows to which extent it's been used already."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "polarstar"
	item_state = null
	slot_flags = SLOT_BELT
	fire_delay = 1
	origin_tech = Tc_MATERIALS + "=4;" + Tc_POWERSTORAGE + "=3;" + Tc_COMBAT + "=3"
	projectile_type = "/obj/item/projectile/spur/polarstar"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	var/firelevel = SPUR_FULL_POWER

/obj/item/weapon/gun/energy/polarstar/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/polarstar/New()
	..()
	playsound(src, 'sound/weapons/spur_spawn.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)

/obj/item/weapon/gun/energy/polarstar/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	levelChange()
	..()

/obj/item/weapon/gun/energy/polarstar/proc/levelChange()
	var/maxlevel = power_supply.maxcharge
	var/level = power_supply.charge
	var/newlevel = 0
	if(level == maxlevel)
		newlevel = SPUR_FULL_POWER
	else if(level >= ((maxlevel/3)*2))
		newlevel = SPUR_HIGH_POWER
	else if(level >= (maxlevel/3))
		newlevel = SPUR_MEDIUM_POWER
	else if(level >= charge_cost)
		newlevel = SPUR_LOW_POWER
	else
		newlevel = SPUR_NO_POWER

	if(firelevel >= newlevel)
		firelevel = newlevel
		set_firesound()
		return

	firelevel = newlevel
	set_firesound()
	var/levelupsound = null
	switch(firelevel)
		if(SPUR_LOW_POWER)
			levelupsound = 'sound/weapons/spur_chargelow.ogg'
		if(SPUR_MEDIUM_POWER)
			levelupsound = 'sound/weapons/spur_chargemed.ogg'
		if(SPUR_HIGH_POWER)
			levelupsound = 'sound/weapons/spur_chargehigh.ogg'
		if(SPUR_FULL_POWER)
			levelupsound = 'sound/weapons/spur_chargefull.ogg'

	if(levelupsound)
		for(var/mob/M in get_turf(src))
			M.playsound_local(M, levelupsound, 100, 0, null, FALLOFF_SOUNDS, 0)
			spawn(1)
				M.playsound_local(M, levelupsound, 75, 0, null, FALLOFF_SOUNDS, 0)


/obj/item/weapon/gun/energy/polarstar/proc/set_firesound()
	switch(firelevel)
		if(SPUR_HIGH_POWER,SPUR_FULL_POWER)
			fire_sound = 'sound/weapons/spur_high.ogg'
			recoil = 1
		if(SPUR_MEDIUM_POWER)
			fire_sound = 'sound/weapons/spur_medium.ogg'
			recoil = 0
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			fire_sound = 'sound/weapons/spur_low.ogg'
			recoil = 0
	return

/obj/item/weapon/gun/energy/polarstar/update_icon()
	return

/obj/item/weapon/gun/energy/polarstar/spur
	name = "\improper Spur"
	desc = "A masterpiece crafted by the legendary gunsmith of a far-away planet."
	icon_state = "spur"
	item_state = null
	origin_tech = Tc_MATERIALS + "=5;" + Tc_POWERSTORAGE + "=4;" + Tc_COMBAT + "=5"
	fire_delay = 0
	projectile_type = "/obj/item/projectile/spur"
	var/charge_tick = 0

/obj/item/weapon/gun/energy/polarstar/spur/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/polarstar/spur/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/polarstar/spur/process()
	charge_tick++
	if(charge_tick < 2)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	levelChange()
	return 1

#undef SPUR_FULL_POWER
#undef SPUR_HIGH_POWER
#undef SPUR_MEDIUM_POWER
#undef SPUR_LOW_POWER
#undef SPUR_NO_POWER
