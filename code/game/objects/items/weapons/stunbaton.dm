/obj/item/weapon/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stun baton"
	item_state = "baton0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_COMBAT + "=2"
	attack_verb = list("beats")
	var/stunforce = 10
	var/status = 0
	var/obj/item/weapon/cell/bcell = null
	var/hitcost = 100 // 10 hits on crap cell
	var/stunsound = 'sound/weapons/Egloves.ogg'
	var/swingsound = "swing_hit"

/obj/item/weapon/melee/baton/get_cell()
	return bcell

/obj/item/weapon/melee/baton/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/melee/baton/New()
	..()
	update_icon()

/obj/item/weapon/melee/baton/Destroy()
	if (bcell)
		QDEL_NULL(bcell)

	return ..()

/obj/item/weapon/melee/baton/loaded/New() //this one starts with a cell pre-installed.
	..()
	bcell = new(src)
	bcell.charge=bcell.maxcharge // Charge this shit
	update_icon()

/obj/item/weapon/melee/baton/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.use(chrgdeductamt))
			if(bcell.charge < hitcost)
				status = 0
				update_icon()
				depower()
			return 1
		else
			status = 0
			update_icon()
			depower()
			return 0

/obj/item/weapon/melee/baton/proc/canbehonkified()
	return 1


/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
		item_state = "baton1"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
		item_state = "baton0"
	else
		icon_state = "[initial(name)]"
		item_state = "baton0"

	if (istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_back()
		M.update_inv_hands()

/obj/item/weapon/melee/baton/examine(mob/user)
	..()
	if(bcell)
		to_chat(user, "<span class='info'>The baton is [round(bcell.percent())]% charged.</span>")
	if(!bcell)
		to_chat(user, "<span class='warning'>The baton does not have a power source installed.</span>")

/obj/item/weapon/melee/baton/attackby(obj/item/weapon/W, mob/user)
	if(ispowercell(W))
		if(!bcell)
			if(user.drop_item(W, src))
				bcell = W
				to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")

	else if(W.is_screwdriver(user))
		if(bcell)
			bcell.updateicon()
			bcell.forceMove(get_turf(src.loc))
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			status = 0
			update_icon()
			depower()
			return
		..()
	else if(isbikehorn(W) && canbehonkified(src))
		var/obj/item/weapon/bikehorn/HONKER = W
		if(HONKER.can_honk_baton)
			user.visible_message("<span class='notice'>[user] starts jamming \the [src] into the mouth of \the [HONKER].</span>",\
			"<span class='info'>You do your best to jam \the [src] into the mouth of \the [HONKER].</span>")

			if(do_after(user, src, 5 SECONDS))
				if(!W || !src)
					return

				if(!user.drop_item(HONKER))
					to_chat(user, "<span class='warning'>You fail to push \the [HONKER] hard enough, and it falls off \the [src].</span>")
					return

				var/obj/item/weapon/bikehorn/baton/B = new /obj/item/weapon/bikehorn/baton

				user.put_in_hands(B)
				user.visible_message("<span class='notice'>[user] jams \the [src] into the mouth of \the [HONKER].</span>",\
				"<span class='notice'>You jam \the [src] into the mouth of \the [HONKER]. Honk!</span>")
				qdel(HONKER)
				qdel(src)

/obj/item/weapon/melee/baton/proc/apply_baton_effect(mob/victim)
	victim.Knockdown(stunforce)
	victim.Stun(stunforce)
	if(iscarbon(victim))
		var/mob/living/L = victim
		L.apply_effect(10, STUTTER)
	return

/obj/item/weapon/melee/baton/attack_self(mob/user)
	if(status && clumsy_check(user) && prob(50))
		user.simple_message("<span class='warning'>You grab the [src] on the wrong side.</span>",
			"<span class='danger'>The [name] blasts you with its power!</span>")
		apply_baton_effect(user)
		playsound(loc, "sparks", 75, 1, -1)
		deductcharge(hitcost)
		return
	if(bcell && bcell.charge >= hitcost)
		status = !status
		user.simple_message("<span class='notice'>[src] is now [status ? "on" : "off"].</span>",
			"<span class='notice'>[src] is now [pick("drowsy","hungry","thirsty","bored","unhappy")].</span>")
		playsound(loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		if(!bcell)
			user.simple_message("<span class='warning'>[src] does not have a power source!</span>",
				"<span class='warning'>[src] has no pulse and its soul has departed...</span>")
		else if (bcell.maxcharge < hitcost)
			to_chat(user, "<span class='warning'>[src] clicks but nothing happens. Something must be wrong with the battery.</span>")
		else
			user.simple_message("<span class='warning'>[src] is out of charge.</span>",
				"<span class='warning'>[src] refuses to obey you.</span>")

	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/M, mob/user)
	if(status && clumsy_check(user) && prob(50))
		user.simple_message("<span class='danger'>You accidentally hit yourself with [src]!</span>",
			"<span class='danger'>The [name] goes mad!</span>")
		apply_baton_effect(user)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return
	if(!isliving(M))
		return

	var/mob/living/L = M

	if(user.a_intent == I_HURT) // Harm intent : possibility to miss (in exchange for doing actual damage)
		. = ..() // Does the actual damage and missing chance. Returns null on sucess ; 0 on failure (blame oldcoders)
		playsound(loc, swingsound, 50, 1, -1)

	else
		if(!status) // Help intent + no charge = nothing
			L.visible_message("<span class='attack'>\The [L] has been prodded with \the [src] by \the [user]. Luckily it was off.</span>",
				self_drugged_message="<span class='warning'>\The [name] decides to spare this one.</span>")
			return

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.check_shields(force,src))
			return FALSE //That way during a harmbaton it will not check for the shield twice

	if(status && . != FALSE) // This is charged : we stun
		user.lastattacked = L
		L.lastattacker = user

		apply_baton_effect(L)

		L.visible_message("<span class='danger'>\The [L] has been stunned with \the [src] by [user]!</span>",\
			"<span class='userdanger'>You have been stunned with \the [src] by \the [user]!</span>",\
			self_drugged_message="<span class='userdanger'>\The [user]'s [src] sucks the life right out of you!</span>")
		playsound(loc, stunsound, 50, 1, -1)

		deductcharge(hitcost)

		L.forcesay(hit_appends)

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [L.name] ([L.ckey]) with [name]</font>"
		L.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [name]</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) stunned [L.name] ([L.ckey]) with [name]</font>" )
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user
			M.assaulted_by(user)

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom)
	if(prob(50))
		return ..()
	if(!isliving(hit_atom) || !status)
		return
	var/client/foundclient = directory[ckey(fingerprintslast)]
	var/mob/foundmob = foundclient.mob
	var/mob/living/L = hit_atom
	if(foundmob && ismob(foundmob))
		foundmob.lastattacked = L
		L.lastattacker = foundmob

	apply_baton_effect(L)

	L.visible_message("<span class='danger'>[L] has been stunned with [src] by [foundmob ? foundmob : "Unknown"]!</span>")
	playsound(loc, stunsound, 50, 1, -1)

	deductcharge(hitcost)

	L.forcesay(hit_appends)

	foundmob.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [L.name] ([L.ckey]) with [name]</font>"
	L.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by thrown [src] by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""])</font>"
	log_attack("<font color='red'>Flying [src.name], thrown by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""]) stunned [L.name] ([L.ckey])</font>" )
	if(!iscarbon(foundmob))
		L.LAssailant = null
	else
		L.LAssailant = foundmob
		L.assaulted_by(foundmob)

/obj/item/weapon/melee/baton/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
		if(bcell.reliability != 100 && prob(50/severity))
			bcell.reliability -= 10 / severity
	..()

/obj/item/weapon/melee/baton/restock()
	if(bcell)
		bcell.charge = bcell.maxcharge

/obj/item/weapon/melee/baton/proc/depower()
	force = initial(force)
	throwforce = initial(throwforce)

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/weapon/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	item_state = "prod"
	force = 3
	throwforce = 5
	stunforce = 5
	hitcost = 2500
	slot_flags = null

/obj/item/weapon/melee/baton/cattleprod/canbehonkified()
	return 0

// Yes, loaded, this is so attack_self() works.
// In the unlikely event somebody manages to get a hold of this item, don't allow them to fuck with the nonexistant cell.
/obj/item/weapon/melee/baton/loaded/borg/attackby(var/obj/item/W, var/mob/user)
	return

/obj/item/weapon/melee/baton/loaded/borg/deductcharge(var/chrgdeductamt)
	if (isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if (R.cell)
			R.cell.use(hitcost)

/obj/item/weapon/melee/baton/harm
	desc = "A baton for permanently incapacitating people with."
	icon_state = "harmbaton"
	item_state = "baton0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	origin_tech = Tc_COMBAT + "=2;" + Tc_SYNDICATE + "=3"
	attack_verb = list("robusts", "harms")
	var/dial = 1

/obj/item/weapon/melee/baton/harm/examine(mob/user)
	..()
	if(user.is_holding_item(src))
		to_chat(user, "<span class='notice'>It has a small dial at the base.</span>") //if you add a feature and won't add a way to advertise it, no one is going to use it

/obj/item/weapon/melee/baton/harm/apply_baton_effect(mob/victim)
	var/mob/living/L = victim
	L.apply_effect(10, STUTTER) //sanity
	L.apply_effect(stunforce, AGONY) //apply pain by throwing, it doesn't damage them though
	L.audible_scream()
	return

/obj/item/weapon/melee/baton/harm/attack_self(mob/user) //putting this here because having damage increases closer to harm baton is more clear
	if(status && clumsy_check(user) && prob(50))
		..()
		return
	if(bcell && bcell.charge >= hitcost)
		..()
		if(status)
			force += 10 + 2*(dial-1) //send someone into the shadow realm with 10
			throwforce += 10 + 2*(dial-1) //it doesn't deal damage on throw, this is just a constistency thing, I guess
			hitcost = 100 * (dial * dial) // 100 cost on 1, 10000 cost on 10, change power cell
			stunforce = 10 * dial //welcome to the world of pain
		else
			depower()
		update_icon()
	else
		..()
		depower()

	add_fingerprint(user)

/obj/item/weapon/melee/baton/harm/proc/turning_dial(mob/user)
	if(status)
		status = !status //if it's enabled, it get disabled when turing dial
		update_icon()
		depower()
	var new_dial = input(user, "What would you like the dial to be set to from 1 to 10?","Dial",dial) as num
	if(new_dial < 1)
		to_chat(user, "<span class = 'warning'>There is no option to set it on 0, you either harm them or don't, pussy.</span>")
		return
	if(new_dial > 10)
		to_chat(user, "<span class = 'notice'>Your lust for inflicting pain is admirable, but 10 is maximum.</span>")
		new_dial = 10
	dial = new_dial
	hitcost = 100 * (dial * dial)
	to_chat(user, "<span class = 'notice'>The dial is set to [dial].</span>")
	add_fingerprint(user)
	return

/obj/item/weapon/melee/baton/harm/verb/turn_dial()
	set name = "Turn dial"
	set category = "Object"
	set src in usr
	if(!usr.is_holding_item(src))
		to_chat(usr, "<span class='notice'>You'll need [src] in your hands to do that.</span>")
		return
	if(usr.incapacitated())
		to_chat(usr, "<span class='rose'>You can't do this!</span>")
		return
	turning_dial(usr)

/obj/item/weapon/melee/baton/harm/loaded/New() //starting cell, only really enough for dial 1
	..()
	bcell = new(src)
	bcell.charge=bcell.maxcharge
	update_icon()

