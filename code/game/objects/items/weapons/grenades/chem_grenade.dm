/obj/item/weapon/grenade/chem_grenade
	name = "grenade casing"
	icon_state = "chemg"
	item_state = "flashbang"
	desc = "A hand made chemical grenade."
	w_class = W_CLASS_SMALL
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/device/assembly_holder/detonator = null
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle, /obj/item/weapon/reagent_containers/food/drinks)
	var/affected_area = 3
	var/inserted_cores = 0
	var/obj/item/slime_extract/firstExtract = null	//for large and Ex grenades
	var/obj/item/slime_extract/secondExtract = null	//for Ex grenades
	var/obj/item/weapon/reagent_containers/glass/beaker/noreactgrenade/reservoir = null
	var/extract_uses = 0
	var/mob/primed_by = "N/A" //"name (ckey)". For logging purposes
	mech_flags = null
	det_time =0 //recycling this variable to be used by the grenade launcher's timer override function since chemnades use their assembly's timer instead.

/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user as mob)
	if(!stage || stage==1)
		if(detonator)
//				detonator.loc=src.loc
			detonator.detached()
			usr.put_in_hands(detonator)
			detonator=null
			stage=0
			icon_state = initial(icon_state)
		else if(beakers.len)
			for(var/obj/B in beakers)
				if(istype(B))
					beakers -= B
					user.put_in_hands(B)
					firstExtract = null
					secondExtract = null
					inserted_cores = 0
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
	if(stage > 1 && !active && clown_check(user))
		to_chat(user, "<span class='attack'>You prime \the [name]!</span>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) primed \a [src].</font>")
		log_admin("ATTACK: [user] ([user.ckey]) primed \a [src] at ([user.x],[user.y],[user.z]).")
		message_admins("ATTACK: [user] ([user.ckey]) primed \a [src] at [formatJumpTo(user.loc)].")
		primed_by = "[user] ([user.ckey])"

		activate()
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_on()

/obj/item/weapon/grenade/chem_grenade/proc/eject_contents()
	var/turf/T = get_turf(src)

	for(var/obj/item/I in beakers)
		I.forceMove(T)
	beakers = list()

	if(firstExtract)
		firstExtract.forceMove(T)
		firstExtract = null
	if(secondExtract)
		secondExtract.forceMove(T)
		secondExtract = null
	if(reservoir)
		reservoir.forceMove(T)
		reservoir = null

/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, "<span class='warning'> Assembly must contain one igniter.</span>")
			return
		if(!det.secured)
			to_chat(user, "<span class='warning'> Assembly must be secured with screwdriver.</span>")
			return
		path = 1
		to_chat(user, "<span class='notice'>You add [W] to the metal casing.</span>")
		W.playtoolsound(src, 25, TRUE, -3)
		user.remove_from_mob(det)
		det.forceMove(src)
		detonator = det
		icon_state = initial(icon_state) +"_ass"
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
		stage = 1
	else if(istype(W,/obj/item/stack/cable_coil) && !beakers.len)
		var/obj/item/stack/cable_coil/coil = W
		if(coil.amount < 2)
			return
		coil.use(2)
		var/obj/item/weapon/electrolyzer/E = new /obj/item/weapon/electrolyzer
		to_chat(user, "<span class='notice'>You tightly coil the wire around the metal casing.</span>")
		W.playtoolsound(src, 30, TRUE, -2)
		user.before_take_item(src)
		user.put_in_hands(E)
		qdel(src)
	else if(W.is_screwdriver(user) && path != 2)
		if(stage == 1)
			path = 1
			if(beakers.len)
				to_chat(user, "<span class='notice'>You lock the assembly.</span>")
				var/temp_reagents = new/list()
				var/reagents_text = ""
				for(var/obj/item/weapon/reagent_containers/G in beakers)
					if(istype(G, /obj/item/weapon/reagent_containers/glass/beaker) || istype(G, /obj/item/weapon/reagent_containers/glass/bottle) || istype(G, /obj/item/weapon/reagent_containers/food/drinks))
						temp_reagents += G.reagents.amount_cache
						if(reagents_text)
							reagents_text += " and ([english_list(temp_reagents)])"
							temp_reagents = null
						else
							reagents_text += "([english_list(temp_reagents)])"
							temp_reagents = null
				add_gamelogs(user, "constructed a grenade containing [reagents_text]", tp_link=TRUE)
				name = "grenade"
			else
//					to_chat(user, "<span class='warning'>You need to add at least one beaker before locking the assembly.</span>")
				to_chat(user, "<span class='warning'>You lock the empty assembly.</span>")
				name = "fake grenade"
			W.playtoolsound(src, 25, -3)
			icon_state = initial(icon_state) +"_locked"
			stage = 2
		else if(stage == 2)
			if(active && prob(95))
				to_chat(user, "<span class='warning'>You trigger the assembly!</span>")
				prime()
				return
			else
				to_chat(user, "<span class='notice'>You unlock the assembly.</span>")
				W.playtoolsound(src, 25, -3)
				name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0
	else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(beakers.len == 2)
			to_chat(user, "<span class='warning'> The grenade can not hold more containers.</span>")
			return
		else
			if (istype(W,/obj/item/slime_extract))
				if (inserted_cores > 0)
					to_chat(user, "<span class='warning'> This type of grenade cannot hold more than one slime core.</span>")
				else
					if(user.drop_item(W, src))
						to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
						inserted_cores++
						firstExtract = W
						beakers += W
						stage = 1
						name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else if(W.reagents.total_volume)
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
					beakers += W
					stage = 1
					name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else
				to_chat(user, "<span class='warning'> \the [W] is empty.</span>")
	else if (istype(W,/obj/item/slime_extract))
		to_chat(user, "<span class='warning'> This grenade case is too small for a slime core to fit in it.</span>")
	else if(iscrowbar(W))
		to_chat(user, "You begin pressing \the [W] into \the [src].")
		if(do_after(user, src, 30))
			to_chat(user, "You poke a hole in \the [src].")
			eject_contents()
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/fuel_reservoir/I = new (get_turf(user))
				user.put_in_hands(I)
				qdel(src)
			else
				new /obj/item/weapon/fuel_reservoir(get_turf(src.loc))
				qdel(src)

/obj/item/weapon/grenade/chem_grenade/examine(mob/user)
	..()
	if(detonator)
		to_chat(user, "<span class='info'>With an attached [detonator.name]</span>")

/obj/item/weapon/grenade/chem_grenade/Crossed(AM as mob|obj)
	if(detonator)
		detonator.Crossed(AM)
	..()

/obj/item/weapon/grenade/chem_grenade/on_found(wearer, AM as mob|obj)
	if(detonator)
		detonator.on_found(wearer, AM)
	..()

/obj/item/weapon/grenade/chem_grenade/activate(mob/user as mob)
	if(active)
		return

	if(det_time != 0) //this can only ever be non-zero if fired from a grenade launcher with timer override toggled on... I think
		spawn(det_time)
			if(gcDestroyed)
				return
			prime(user)
			active = 1

	if(detonator)
		if(!isigniter(detonator.a_left))
			detonator.a_left.activate()
			active = 1
		if(!isigniter(detonator.a_right))
			detonator.a_right.activate()
			active = 1
	if(active)
		icon_state = initial(icon_state) + "_active"

		if(user)
			log_attack("<font color='red'>[user.name] ([user.ckey]) primed \a [src]</font>")
			log_admin("ATTACK: [user] ([user.ckey]) primed \a [src] at ([user.x],[user.y],[user.z]).")
			message_admins("ATTACK: [user] ([user.ckey]) primed \a [src] at [formatJumpTo(user.loc)].")
			primed_by = "[user] ([user.ckey])"

	return

/obj/item/weapon/grenade/chem_grenade/proc/primed(var/primed = 1)
	if(active)
		icon_state = initial(icon_state) + (primed?"_primed":"_active")

/obj/item/weapon/grenade/chem_grenade/prime()
	if(!stage || stage<2)
		return

	//if(prob(reliability))
	var/has_reagents = 0
	for(var/obj/item/weapon/reagent_containers/G in beakers)
		if(G.reagents.total_volume)
			has_reagents = 1

	active = 0
	if(!has_reagents)
		icon_state = initial(icon_state) +"_locked"
		playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	playsound(src, 'sound/effects/bamfgas.ogg', 50, 1)

	visible_message("<span class='warning'>[bicon(src)] \The [src] bursts open.</span>")

	reservoir = new /obj/item/weapon/reagent_containers/glass/beaker/noreactgrenade() //acts like a stasis beaker, so the chemical reactions don't occur before all the slime reactions have occured

	for(var/obj/item/weapon/reagent_containers/G in beakers)
		G.reagents.trans_to(reservoir, G.reagents.total_volume)
	for(var/obj/item/slime_extract/S in beakers)		//checking for reagents inside the slime extracts
		S.reagents.trans_to(reservoir, S.reagents.total_volume)
	if (firstExtract != null)
		extract_uses = firstExtract.Uses
		for(var/i=1,i<=extract_uses,i++)//<-------//exception for slime extracts injected with steroids. The grenade will repeat its checks untill all its remaining uses are gone
			if (reservoir.reagents.has_reagent(PLASMA, 5))
				reservoir.reagents.trans_id_to(firstExtract, PLASMA, 5)		//If the grenade contains a slime extract, the grenade will check in this order
			else if (reservoir.reagents.has_reagent(BLOOD, 5))	//for any Plasma -> Blood ->or Water among the reagents of the other containers
				reservoir.reagents.trans_id_to(firstExtract, BLOOD, 5)		//and inject 5u of it into the slime extract.
			else if (reservoir.reagents.has_reagent(WATER, 5))
				reservoir.reagents.trans_id_to(firstExtract, WATER, 5)
			else if (reservoir.reagents.has_reagent(SUGAR, 5))
				reservoir.reagents.trans_id_to(firstExtract, SUGAR, 5)
		if(firstExtract.reagents.total_volume)						  //<-------//exception for slime reactions that produce new reagents. The grenade checks if any
			firstExtract.reagents.trans_to(reservoir, firstExtract.reagents.total_volume)	//reagents are left in the slime extracts after the slime reactions occured
		if (secondExtract != null)
			extract_uses = secondExtract.Uses
			for(var/j=1,j<=extract_uses,j++)	//why don't anyone ever uses "while" directives anyway?
				if (reservoir.reagents.has_reagent(PLASMA, 5))
					reservoir.reagents.trans_id_to(secondExtract, PLASMA, 5)	//since the order in which slime extracts are inserted matters (in the case of an Ex grenade)
				else if (reservoir.reagents.has_reagent(BLOOD, 5))//this allow users to plannify which reagent will get into which extract.
					reservoir.reagents.trans_id_to(secondExtract, BLOOD, 5)
				else if (reservoir.reagents.has_reagent(WATER, 5))
					reservoir.reagents.trans_id_to(secondExtract, WATER, 5)
				else if (reservoir.reagents.has_reagent(SUGAR, 5))
					reservoir.reagents.trans_id_to(secondExtract, SUGAR, 5)
			if(secondExtract.reagents.total_volume)
				secondExtract.reagents.trans_to(reservoir, secondExtract.reagents.total_volume)

		reservoir.reagents.update_total()

	investigation_log(I_CHEMS, "has detonated, containing [reservoir.reagents.get_reagent_ids(1)] - Primed by: [primed_by]")

	reservoir.reagents.trans_to(src, reservoir.reagents.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, get_turf(src)))
			if( A == src )
				continue
			src.reagents.reaction(A, 1, 10)

	invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.
	/*else
		icon_state = initial(icon_state) + "_locked"
		crit_fail = 1
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.forceMove(get_turf(src.loc))*/

/obj/item/weapon/grenade/chem_grenade/New()
	. = ..()
	create_reagents(1000)

/obj/item/weapon/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/slime_extract, /obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=3"
	affected_area = 4

obj/item/weapon/grenade/chem_grenade/exgrenade
	name = "EX Chem Grenade"
	desc = "A specially designed large grenade that can hold three containers."
	icon_state = "ex_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/slime_extract, /obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2"
	affected_area = 4

obj/item/weapon/grenade/chem_grenade/exgrenade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, "<span class='warning'> Assembly must contain one igniter.</span>")
			return
		if(!det.secured)
			to_chat(user, "<span class='warning'> Assembly must be secured with screwdriver.</span>")
			return
		path = 1
		to_chat(user, "<span class='notice'>You insert [W] into the grenade.</span>")
		W.playtoolsound(src, 25, TRUE, -3)
		user.remove_from_mob(det)
		det.forceMove(src)
		detonator = det
		icon_state = initial(icon_state) +"_ass"
		name = "unsecured EX grenade with [beakers.len] containers[detonator?" and detonator":""]"
		stage = 1
	else if(W.is_screwdriver(user) && path != 2)
		if(stage == 1)
			path = 1
			if(beakers.len)
				to_chat(user, "<span class='notice'>You lock the assembly.</span>")
				name = "EX Grenade"
			else
				to_chat(user, "<span class='notice'>You lock the empty assembly.</span>")
				name = "fake grenade"
			W.playtoolsound(src, 25, -3)
			icon_state = initial(icon_state) +"_locked"
			stage = 2
		else if(stage == 2)
			if(active && prob(95))
				to_chat(user, "<span class='attack'>You trigger the assembly!</span>")
				prime()
				return
			else
				to_chat(user, "<span class='notice'>You unlock the assembly.</span>")
				W.playtoolsound(src, 25, -3)
				name = "unsecured EX grenade with [beakers.len] containers[detonator?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0
	else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(beakers.len == 3)
			to_chat(user, "<span class='warning'> The grenade can not hold more containers.</span>")
			return
		else
			if (istype(W,/obj/item/slime_extract))
				if (inserted_cores > 1)
					to_chat(user, "<span class='warning'>You cannot fit more than two slime cores in this grenade.</span>")
				else
					if(user.drop_item(W, src))
						to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
						beakers += W
						if(!firstExtract)
							firstExtract = W
						else
							secondExtract = W
						inserted_cores++
						stage = 1
						name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else if(W.reagents.total_volume)
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
					beakers += W
					stage = 1
					name = "unsecured EX grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else
				to_chat(user, "<span class='warning'> \the [W] is empty.</span>")

/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/metalfoam/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(ALUMINUM, 30)
	B2.reagents.add_reagent(FOAMING_AGENT, 10)
	B2.reagents.add_reagent(PACID, 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/ironfoam
	name = "Iron-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/ironfoam/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(IRON, 30)
	B2.reagents.add_reagent(FOAMING_AGENT, 10)
	B2.reagents.add_reagent(PACID, 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/incendiary/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(ALUMINUM, 15)
	//B1.reagents.add_reagent(FUEL,20)
	B2.reagents.add_reagent(PLASMA, 15)
	B2.reagents.add_reagent(SACID, 15)
	//B1.reagents.add_reagent(FUEL,20)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/antiweed/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(PLANTBGONE, 25)
	B1.reagents.add_reagent(POTASSIUM, 25)
	B2.reagents.add_reagent(PHOSPHORUS, 25)
	B2.reagents.add_reagent(SUGAR, 25)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = "grenade"

/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "Cleaner Grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/cleaner/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(FLUOROSURFACTANT, 40)
	B2.reagents.add_reagent(WATER, 40)
	B2.reagents.add_reagent(CLEANER, 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/wind
	name = "wind grenade"
	desc = "Designed to perfectly bring an empty five-by-five room back into a filled, breathable state. Larger rooms will require additional gas sources."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/wind/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(VAPORSALT, 50)
	B2.reagents.add_reagent(OXYGEN, 10)
	B2.reagents.add_reagent(NITROGEN, 40)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/reagent_containers/glass/beaker/noreactgrenade
	name = "grenade reservoir"
	desc = "..."
	icon_state = null
	volume = 1000
	flags = FPRINT  | OPENCONTAINER | NOREACT
