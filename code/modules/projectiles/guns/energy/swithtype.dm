/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
	icon_state = "egunstun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'

	charge_cost = 100 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/energy/electrode"
	origin_tech = "combat=3;magnets=2"
	modifystate = "energystun"

	var/mode = 0 //0 = stun, 1 = kill

	attack_self(mob/living/user as mob)
		switch(mode)
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to kill.</span>")
				projectile_type = "/obj/item/projectile/beam"
				modifystate = "egunkill"
			if(1)
				mode = 0
				charge_cost = 100
				fire_sound = 'sound/weapons/Taser.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to stun.</span>")
				projectile_type = "/obj/item/projectile/energy/electrode"
				modifystate = "egunstun"
		update_icon()

/obj/item/weapon/gun/energy/gun/shockrifle
	name = "Shock Rifle"
	desc = "The Pacificer energy shock rifle, two modes, laser and taser"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	icon_state = "shockrifle"
	item_state = "erttaser"
	cell_type = "/obj/item/weapon/cell/ammo"
	slot_flags = SLOT_BACK
	scope_allowed = 1
	two_handed = 1
	cell_removing = 1
	w_class = 4
	force = 10

	charge_cost = 500
	fire_delay = 3
	fire_sound = 'sound/weapons/Laser.ogg'
	projectile_type = "/obj/item/projectile/beam/captain"

	var/mode = 1

	attack_self(mob/living/user as mob)
		if(user.a_intent == "help")
			switch(mode)
				if(0)
					mode = 1
					charge_cost = 500
					fire_sound = 'sound/weapons/Laser.ogg'
					to_chat(user, "<span class='warning'>[src.name] is now set to kill.</span>")
					projectile_type = "/obj/item/projectile/beam/captain"
				if(1)
					mode = 0
					charge_cost = 1000
					fire_sound = 'sound/weapons/Taser.ogg'
					to_chat(user, "<span class='warning'>[src.name] is now set to stun.</span>")
					projectile_type = "/obj/item/projectile/energy/electrode"
			update_icon()

/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A heavy-duty, pulse-based energy weapon, preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state = null	//so the human update icon uses the icon_state instead.
	force = 10
	fire_sound = 'sound/weapons/pulse.ogg'
	charge_cost = 200
	projectile_type = "/obj/item/projectile/beam/pulse"
	cell_type = "/obj/item/weapon/cell/super"
	var/mode = 2
	fire_delay = 2

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 100
				fire_sound = 'sound/weapons/Taser.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to stun.</span>")
				projectile_type = "/obj/item/projectile/energy/electrode"
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to kill.</span>")
				projectile_type = "/obj/item/projectile/beam"
			if(1)
				mode = 2
				charge_cost = 200
				fire_sound = 'sound/weapons/pulse.ogg'
				to_chat(user, "<span class='warning'>[src.name] is now set to DESTROY.</span>")
				projectile_type = "/obj/item/projectile/beam/pulse"
		return

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/sniper //old and more multipurpose version
	name = "Sniper Rifle"
	desc = "pulse-based energy sniper rifle, stable model - Mark 8"
	icon_state = "sniper"
	item_state = null
	cell_type = "/obj/item/weapon/cell/ammo"
	slot_flags = SLOT_BACK
	two_handed = 1
	w_class = 4
	force = 10
	cell_removing = 1
	//mode settings
	charge_cost = 500
	fire_delay = 20
	projectile_type = "/obj/item/projectile/beam"
	fire_sound = 'sound/weapons/pulse.ogg'

	var/mode = 2

	attack_self(mob/living/user as mob)
		..()
		if(user.a_intent == "help")
			switch(mode)
				if(2)
					mode = 0
					charge_cost = 500
					fire_delay = 10 //������� �������� �������!!
					fire_sound = 'sound/weapons/pulse.ogg'
					user << "\red [src.name] is now set to shock beam mode."
					projectile_type = "/obj/item/projectile/beam/xsniper"
				if(0)
					mode = 1
					charge_cost = 250
					fire_delay = 5
					fire_sound = 'sound/weapons/Laser.ogg'
					user << "\red [src.name] is now set to laser mode."
					projectile_type = "/obj/item/projectile/beam"
				if(1)
					mode = 2
					charge_cost = 500
					fire_delay = 20 //��������� �� ��������������, �� ��������� �� ����.
					fire_sound = 'sound/weapons/pulse.ogg'
					user << "\red [src.name] is now set to high power sniper mode."
					projectile_type = "/obj/item/projectile/beam/deathlaser"
			return

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/pulse_rifle/cyborg/process_chambered()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0


/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	cell_type = "/obj/item/weapon/cell/infinite"

	attack_self(mob/living/user as mob)
		to_chat(user, "<span class='warning'>[src.name] has three settings, and they are all DESTROY.</span>")

/obj/item/weapon/gun/energy/pulse_rifle/M1911
	name = "m1911-P"
	desc = "It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911-p"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	cell_type = "/obj/item/weapon/cell/infinite"

	isHandgun()
		return 1

/obj/item/weapon/gun/energy/gun/nuclear
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/lightfail = 0
	var/charge_tick = 0

	New()
		..()
		processing_objects.Add(src)

	Destroy()
		processing_objects.Remove(src)
		..()

	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		if((power_supply.charge / power_supply.maxcharge) != 1)
			if(!failcheck())	return 0
			power_supply.give(100)
			update_icon()
		return 1

	proc
		failcheck()
			lightfail = 0
			if (prob(src.reliability)) return 1 //No failure
			if (prob(src.reliability))
				for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
					if (src in M.contents)
						to_chat(M, "<span class='warning'>Your gun feels pleasantly warm for a moment.</span>")
					else
						to_chat(M, "<span class='warning'>You feel a warm sensation.</span>")
					M.apply_effect(rand(3,120), IRRADIATE)
				lightfail = 1
			else
				for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
					if (src in M.contents)
						to_chat(M, "<span class='warning'>Your gun's reactor overloads!</span>")
					to_chat(M, "<span class='warning'>You feel a wave of heat wash over you.</span>")
					M.apply_effect(300, IRRADIATE)
				crit_fail = 1 //break the gun so it stops recharging
				processing_objects.Remove(src)
				update_icon()
			return 0

		update_charge()
			if (crit_fail)
				overlays += "nucgun-whee"
				return
			var/ratio = power_supply.charge / power_supply.maxcharge
			ratio = round(ratio, 0.25) * 100
			overlays += "nucgun-[ratio]"

		update_reactor()
			if(crit_fail)
				overlays += "nucgun-crit"
				return
			if(lightfail)
				overlays += "nucgun-medium"
			else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
				overlays += "nucgun-light"
			else
				overlays += "nucgun-clean"


		update_mode()
			if (mode == 0)
				overlays += "nucgun-stun"
			else if (mode == 1)
				overlays += "nucgun-kill"

	emp_act(severity)
		..()
		reliability -= round(15/severity)

	update_icon()
		overlays.len = 0
		update_charge()
		update_reactor()
		update_mode()




