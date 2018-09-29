#define HUGMODE_HUGS 0
#define HUGMODE_BEAR 1
#define HUGMODE_SHOCK 2
#define HUGMODE_CRUSH 3

//Hugborg's hugging module
/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	icon = 'icons/obj/borg_items.dmi'
	desc = "For when a someone really needs a hug."
	var/mode = HUGMODE_HUGS
	var/crush_cooldown = 0
	var/shock_cooldown = 0

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged)
			if(mode < HUGMODE_CRUSH)
				mode++
			else
				mode = HUGMODE_HUGS
		else if(mode < HUGMODE_BEAR)
			mode++
		else
			mode = HUGMODE_HUGS
	switch(mode)
		if(HUGMODE_HUGS)
			to_chat(user,"Power reset. Hugs!")
		if(HUGMODE_BEAR)
			to_chat(user,"Power increased!")
		if(HUGMODE_SHOCK)
			to_chat(user,"BZZT. Electrifying arms...")
		if(HUGMODE_CRUSH)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user)
	if(M == user)
		return
	switch(mode)
		if(HUGMODE_HUGS)
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
		if(HUGMODE_BEAR)
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
		if(HUGMODE_SHOCK)
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
		if(HUGMODE_CRUSH)
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
