

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
#define HUGS 0
#define BEAR 1
#define SHOCK 2
#define CRUSH 3

/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

obj/item/borg/stun/attack(mob/M as mob, mob/living/silicon/robot/user as mob)
	user.do_attack_animation(M, src)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <span class='danger'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")


	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	user.cell.charge -= 30

	M.Knockdown(5)
	if (M.stuttering < 5)
		M.stuttering = 5
	M.Stun(5)

	for(var/mob/O in viewers(M, null))
		if (O.client)
			O.show_message("<span class='danger'>[user] has prodded [M] with an electrically-charged arm!</span>", 1, "<span class='warning'>You hear someone fall</span>", 2)

/obj/item/borg/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	icon = 'icons/obj/borg_items.dmi'
	desc = "For when a someone really needs a hug."
	var/mode = HUGS
	var/crush_cooldown = 0
	var/shock_cooldown = 0

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged)
			if(mode < CRUSH)
				mode++
			else
				mode = HUGS
		else if(mode < BEAR)
			mode++
		else
			mode = HUGS
	switch(mode)
		if(HUGS)
			to_chat(user,"Power reset. Hugs!")
		if(BEAR)
			to_chat(user,"Power increased!")
		if(SHOCK)
			to_chat(user,"BZZT. Electrifying arms...")
		if(CRUSH)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user)
	if(M == user)
		return
	switch(mode)
		if(HUGS)
			if(M.health >= 0)
				if(user.zone_sel.selecting == "head")
					user.visible_message("<span class='notice'>[user] playfully boops [M] on the head!</span>", \
									"<span class='notice'>You playfully boop [M] on the head!</span>")
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
				else if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get them up!</span>", \
										"<span class='notice'>You shake [M] trying to get them up!</span>")
					else
						user.visible_message("<span class='notice'>[user] hugs [M] to make them feel better!</span>", \
								"<span class='notice'>You hug [M] to make them feel better!</span>")
						M.reagents.add_reagent(PARACETAMOL, 1)
					if(M.resting)
						M.resting = FALSE
						M.update_canmove()
				else
					user.visible_message("<span class='notice'>[user] pets [M]!</span>", \
							"<span class='notice'>You pet [M]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(BEAR)
			if(M.health >= 0)
				if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get them up!</span>", \
										"<span class='notice'>You shake [M] trying to get them up!</span>")
					else if(user.zone_sel.selecting == "head")
						user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
										"<span class='warning'>You bop [M] on the head!</span>")
					else
						user.visible_message("<span class='warning'>[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable...</span>", \
								"<span class='warning'>You hug [M] firmly to make them feel better! [M] looks uncomfortable...</span>")
					if(M.resting)
						M.resting = FALSE
						M.update_canmove()
				else
					user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
							"<span class='warning'>You bop [M] on the head!</span>")
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		if(SHOCK)
			if(!shock_cooldown)
				if(ishuman(M)||ismonkey(M))
					M.electrocute_act(15, user, 1)
					add_logs(user, M, "eletrocuted with \the [src]", admin = (user.ckey && M.ckey))
					user.visible_message("<span class='userdanger'>[user] electrocutes [M] with their touch!</span>", \
						"<span class='danger'>You electrocute [M] with your touch!</span>")
					M.update_canmove()
				else
					if(!isrobot(M))
						M.adjustFireLoss(15)
						add_logs(user, M, "shocked with \the [src]", admin = (user.ckey && M.ckey))
						user.visible_message("<span class='danger'>[user] shocks [M]!</span>", \
							"<span class='danger'>You shock [M]!</span>")
					else
						user.visible_message("<span class='danger'>[user] shocks [M]. It does not seem to have an effect</span>", \
							"<span class='danger'>You shock [M] to no effect.</span>")
				playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, -1)
				user.cell.charge -= 500
				shock_cooldown = TRUE
				spawn(2 SECONDS)
				shock_cooldown = FALSE
		if(CRUSH)
			if(!crush_cooldown)
				if(ishuman(M))
					user.visible_message("<span class='danger'>[user] crushes [M] in their grip!</span>", \
						"<span class='danger'>You crush [M] in your grip!</span>")
				else
					user.visible_message("<span class='danger'>[user] crushes [M]!</span>", \
							"<span class='danger'>You crush [M]!</span>")
				playsound(loc, 'sound/weapons/crushhug.ogg', 50, 1, -1)
				M.adjustBruteLoss(20)
				add_logs(user, M, "crushed with \the [src]", admin = (user.ckey && M.ckey))
				user.cell.charge -= 300
				crush_cooldown = TRUE
				spawn(2 SECONDS)
				crush_cooldown = FALSE

/obj/item/device/harmalarm
	name = "sonic harm prevention tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH"
	icon_state = "megaphone"
	var/cooldown = 0

/obj/item/device/harmalarm/attack_self(mob/user)
	var/safety = TRUE
	if(cooldown > world.time)
		to_chat(user,"<span class='warning'>The device is still recharging!</span>")
		return

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.charge < 1200)
			to_chat(user, "<span class='warning'>You don't have enough charge to do this!</span>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE
		if(R.connected_ai)
			to_chat(R.connected_ai,"<br><span class='bnotice'>NOTICE - [src] used by: [user]</span><br>")

	if(safety == TRUE)
		user.visible_message("<span class='big danger'>HUMAN HARM</span>")
		playsound(src, 'sound/AI/harmalarm.ogg', 70, 3)
		add_gamelogs(user, "used \the [src]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "notice")
		for(var/mob/living/carbon/M in hearers(9, user))
			if(M.earprot())
				continue
			to_chat(M, "<span class='warning'>[user] blares out a near-deafening siren from its speakers!</span>")
			to_chat(M, "<span class='danger'>The siren pierces your hearing!</span>")
			M.stuttering += 5
			M.ear_deaf += 1
			M.dizziness += 5
			M.confused +=  5
			M.Jitter(5)
			add_gamelogs(user, "alarmed [key_name(M)] with \the [src]", admin = FALSE, tp_link = FALSE)
		cooldown = world.time + 20 SECONDS
		return

	if(safety == FALSE)
		user.visible_message("<span class='big danger'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</span>")
		playsound(src, 'sound/machines/warning-buzzer.ogg', 130, 3)
		add_gamelogs(user, "used an emagged [name]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")
		for(var/mob/living/carbon/M in hearers(6, user))
			if(M.earprot())
				continue
			M.sleeping = 0 // WAKE ME UP
			M.stuttering += 30
			M.ear_deaf += 10
			M.Knockdown(7) // CAN'T WAKE UP
			M.Jitter(30)
			add_gamelogs(user, "knocked out [key_name(M)] with an emagged [name]", admin = FALSE, tp_link = FALSE)
		cooldown = world.time + 1 MINUTES

//Noir upgrade modules
#define NEEDED_CHARGE_TO_RESTOCK_AMMO 5

/obj/item/ammo_storage/speedloader/c38/cyborg
	desc = "The echo of the first shot, like the first sip of whiskey, burning..."
	var/charge = 0

/obj/item/ammo_storage/speedloader/c38/cyborg/restock()
	charge++
	if(charge >= NEEDED_CHARGE_TO_RESTOCK_AMMO && stored_ammo.len < max_ammo) //takes about 10 seconds.
		stored_ammo += new ammo_type(src)
		update_icon()
		charge = initial(charge)

#undef NEEDED_CHARGE_TO_RESTOCK_AMMO

//Warden upgrade modules
#define NEEDED_CHARGE_TO_RESTOCK_IMP 30

/obj/item/weapon/implanter/loyalty/cyborg
	var/charge = 0

/obj/item/weapon/implanter/loyalty/cyborg/restock()
	charge++
	if(charge >= NEEDED_CHARGE_TO_RESTOCK_IMP && !imp) //takes about 60 seconds.
		imp = new /obj/item/weapon/implant/loyalty(src)
		update_icon()
		charge = initial(charge)

#undef NEEDED_CHARGE_TO_RESTOCK_IMP

//The cyborg-friendly version and shameless copypaste of binoculars.
/obj/item/cyborglens
	name = "long-range zoom camera lens"
	icon_state = "pocket_mirror"
	var/zoom = FALSE
	var/event_key = null

/obj/item/cyborglens/attack_self(mob/user)
	zoom = !zoom
	update_zoom(user)

/obj/item/cyborglens/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(zoom)
		zoom = FALSE
		update_zoom(holder)

/obj/item/cyborglens/proc/update_zoom(var/mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R =user
		if(R.client)
			var/client/C = R.client
			if(zoom && R.is_component_functioning("camera"))
				event_key = R.on_moved.Add(src, "mob_moved")
				R.visible_message("[R]'s camera lens focuses loudly.","Your camera lens focuses loudly.")
				R.regenerate_icons()
				C.changeView(C.view + 4)
			else
				R.on_moved.Remove(event_key)
				R.regenerate_icons()
				C.changeView(C.view - 4)