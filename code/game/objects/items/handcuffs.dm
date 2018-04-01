/obj/item/restraints
	breakouttime = 600

/obj/item/restraints/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/restraints/Destroy()
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		if(M.handcuffed == src)
			M.handcuffed = null
			M.update_handcuffed()
			if(M.buckled && M.buckled.buckle_requires_restraints)
				M.buckled.unbuckle_mob(M)
		if(M.legcuffed == src)
			M.legcuffed = null
			M.update_inv_legcuffed()
	return ..()

//Handcuffs

/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=500)
	breakouttime = 600 //Deciseconds = 60s = 1 minute
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	var/trashtype = null //for disposable cuffs

/obj/item/restraints/handcuffs/attack(mob/living/carbon/C, mob/living/user)
	if(!istype(C))
		return

	if(iscarbon(user) && (user.has_trait(TRAIT_CLUMSY) && prob(50)))
		to_chat(user, "<span class='warning'>Uh... how do those things work?!</span>")
		apply_cuffs(user,user)
		return

	// chance of monkey retaliation
	if(ismonkey(C) && prob(MONKEY_CUFF_RETALIATION_PROB))
		var/mob/living/carbon/monkey/M
		M = C
		M.retaliate(user)

	if(!C.handcuffed)
		if(C.get_num_arms() >= 2 || C.get_arm_ignore())
			C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
								"<span class='userdanger'>[user] is trying to put [src.name] on [C]!</span>")

			playsound(loc, cuffsound, 30, 1, -2)
			if(do_mob(user, C, 30) && (C.get_num_arms() >= 2 || C.get_arm_ignore()))
				if(iscyborg(user))
					apply_cuffs(C, user, TRUE)
				else
					apply_cuffs(C, user)
				to_chat(user, "<span class='notice'>You handcuff [C].</span>")
				SSblackbox.record_feedback("tally", "handcuffs", 1, type)

				add_logs(user, C, "handcuffed")
			else
				to_chat(user, "<span class='warning'>You fail to handcuff [C]!</span>")
		else
			to_chat(user, "<span class='warning'>[C] doesn't have two hands...</span>")

/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, var/dispense = 0)
	if(target.handcuffed)
		return

	if(!user.temporarilyRemoveItemFromInventory(src) && !dispense)
		return

	var/obj/item/restraints/handcuffs/cuffs = src
	if(trashtype)
		cuffs = new trashtype()
	else if(dispense)
		cuffs = new type()

	cuffs.forceMove(target)
	target.handcuffed = cuffs

	target.update_handcuffed()
	if(trashtype && !dispense)
		qdel(src)
	return

/obj/item/restraints/handcuffs/sinew
	name = "sinew restraints"
	desc = "A pair of restraints fashioned from long strands of flesh."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff"
	item_state = "coil"
	item_color = "red"
	color = "#ff0000"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(MAT_METAL=150, MAT_GLASS=75)
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable/Initialize(mapload, param_color)
	. = ..()

	var/list/cable_colors = GLOB.cable_colors
	item_color = param_color || item_color || pick(cable_colors)
	if(cable_colors[item_color])
		item_color = cable_colors[item_color]
	update_icon()

/obj/item/restraints/handcuffs/cable/update_icon()
	color = null
	add_atom_colour(item_color, FIXED_COLOUR_PRIORITY)

/obj/item/restraints/handcuffs/cable/red
	item_color = "red"
	color = "#ff0000"

/obj/item/restraints/handcuffs/cable/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/restraints/handcuffs/cable/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/restraints/handcuffs/cable/green
	item_color = "green"
	color = "#00aa00"

/obj/item/restraints/handcuffs/cable/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/restraints/handcuffs/cable/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/restraints/handcuffs/cable/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/restraints/handcuffs/cable/white
	item_color = "white"

/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/fake
	name = "fake handcuffs"
	desc = "Fake handcuffs meant for gag purposes."
	breakouttime = 10 //Deciseconds = 1s

/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/wirerod/W = new /obj/item/wirerod
			remove_item_from_storage(user)
			user.put_in_hands(W)
			to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need one rod to make a wired rod!</span>")
			return
	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 6)
			to_chat(user, "<span class='warning'>You need at least six metal sheets to make good enough weights!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to apply [I] to [src]...</span>")
		if(do_after(user, 35, target = src))
			if(M.get_amount() < 6 || !M)
				return
			var/obj/item/restraints/legcuffs/bola/S = new /obj/item/restraints/legcuffs/bola
			M.use(6)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>You make some weights out of [I] and tie them to [src].</span>")
			remove_item_from_storage(user)
			qdel(src)
	else
		return ..()

/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	icon_state = "cuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	materials = list()
	breakouttime = 450 //Deciseconds = 45s
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used
	item_color = "white"

/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cuff_used"
	item_state = "cuff"

/obj/item/restraints/handcuffs/cable/zipties/used/attack()
	return

//Legcuffs

/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 7
	breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0
	var/trap_damage = 20

/obj/item/restraints/legcuffs/beartrap/Initialize()
	. = ..()
	icon_state = "[initial(icon_state)][armed]"

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking [user.p_their()] head in the [src.name]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "[initial(icon_state)][armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")

/obj/item/restraints/legcuffs/beartrap/Crossed(AM as mob|obj)
	if(armed && isturf(src.loc))
		if(isliving(AM))
			var/mob/living/L = AM
			var/snap = 0
			var/def_zone = BODY_ZONE_CHEST
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				snap = 1
				if(!C.lying)
					def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
					if(!C.legcuffed && C.get_num_legs() >= 2) //beartrap can't cuff your leg if there's already a beartrap or legcuffs, or you don't have two legs.
						C.legcuffed = src
						forceMove(C)
						C.update_inv_legcuffed()
						SSblackbox.record_feedback("tally", "handcuffs", 1, type)
			else if(isanimal(L))
				var/mob/living/simple_animal/SA = L
				if(SA.mob_size > MOB_SIZE_TINY)
					snap = 1
			if(L.movement_type & FLYING)
				snap = 0
			if(snap)
				armed = 0
				icon_state = "[initial(icon_state)][armed]"
				playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
				L.visible_message("<span class='danger'>[L] triggers \the [src].</span>", \
						"<span class='userdanger'>You trigger \the [src]!</span>")
				L.apply_damage(trap_damage,BRUTE, def_zone)
	..()

/obj/item/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0
	flags_1 = DROPDEL_1

/obj/item/restraints/legcuffs/beartrap/energy/New()
	..()
	addtimer(CALLBACK(src, .proc/dissipate), 100)

/obj/item/restraints/legcuffs/beartrap/energy/proc/dissipate()
	if(!ismob(loc))
		do_sparks(1, TRUE, src)
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk
	. = ..()

/obj/item/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 20 // Cyborgs shouldn't have a strong restraint

/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	breakouttime = 35//easy to apply, easy to break out of
	gender = NEUTER
	var/knockdown = 0

/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	if(!..())
		return
	playsound(src.loc,'sound/weapons/bolathrow.ogg', 75, 1)

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom)
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort
	var/mob/living/carbon/C = hit_atom
	if(!C.legcuffed && C.get_num_legs() >= 2)
		visible_message("<span class='danger'>\The [src] ensnares [C]!</span>")
		C.legcuffed = src
		forceMove(C)
		C.update_inv_legcuffed()
		SSblackbox.record_feedback("tally", "handcuffs", 1, type)
		to_chat(C, "<span class='userdanger'>\The [src] ensnares you!</span>")
		C.Knockdown(knockdown)

/obj/item/restraints/legcuffs/bola/tactical//traitor variant
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = 70
	knockdown = 20

/obj/item/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	hitsound = 'sound/weapons/taserhit.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 60

/obj/item/restraints/legcuffs/bola/energy/throw_impact(atom/hit_atom)
	if(iscarbon(hit_atom))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy/cyborg(get_turf(hit_atom))
		B.Crossed(hit_atom)
		qdel(src)
	..()