/////Medi-Gun, coded by Deity Link, inspired by Valve's Team Fortress 2/////

#define MAX_UBERCHARGE	100
#define MEDIHEAL		0.5
#define MEDIUBER		1
#define MEDIHARM		-1

/obj/item/medigunpack
	name = "\improper Medi-Gun"
	desc = "You wear this on your back and heal people with it."
	icon = 'icons/obj/gun_experimental.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/backpacks_n_bags.dmi', "right_hand" = 'icons/mob/in-hand/right/backpacks_n_bags.dmi')
	icon_state = "medigunfull"
	item_state = "medigun"
	w_class = W_CLASS_LARGE
	flags = FPRINT
	slot_flags = SLOT_BACK
	var/obj/item/medigun/medigun = null
	var/emagged = 0//emagged gun slowly deals damage of all types at once.

/obj/item/medigunpack/examine(mob/user)
	..()
	if(medigun)
		to_chat(user,"<span class='info'>Charge = [medigun.ubercharge]%</span>")

/obj/item/medigunpack/New()
	..()
	medigun = new(src,src)

/obj/item/medigunpack/Destroy()
	if(medigun)
		medigun.medigunpack = null
		qdel(medigun)
	medigun = null
	..()

/obj/item/medigunpack/MouseDrop(atom/over_object)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(!H.incapacitated())
			if (!istype(over_object, /obj/screen/inventory))
				return ..()
			playsound(get_turf(src), "rustle", 50, 1, -5)

			if(medigun)
				if(istype(medigun.loc,/mob))
					var/mob/M = medigun.loc
					M.u_equip(medigun)
				medigun.forceMove(src)
				update_icon()

			if (src == H.get_item_by_slot(slot_back))
				var/obj/screen/inventory/OI = over_object

				if(OI.hand_index)
					H.u_equip(src, 1)
					H.put_in_hand(OI.hand_index, src)
					H.update_inv_wear_suit()
					add_fingerprint(H)

/obj/item/medigunpack/attack_hand(mob/user)
	if (medigun && (src.loc == user))
		add_fingerprint(user)
		user.put_in_hands(medigun)
		update_icon()
	else
		..()

/obj/item/medigunpack/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W == medigun)
		user.drop_item(W,src)
		W.forceMove(W)
		update_icon()
		return 1
	return ..()

/obj/item/medigunpack/emag_act(mob/user as mob)
	medigun.emag_act(user)

/obj/item/medigunpack/dropped(mob/user)
	if(medigun)
		if(istype(medigun.loc,/mob))
			var/mob/M = medigun.loc
			M.u_equip(medigun)
		medigun.forceMove(src)
		update_icon()

/obj/item/medigunpack/stripped(mob/wearer,mob/stripper)
	dropped(wearer)

/obj/item/medigunpack/update_icon()
	if(medigun && (medigun.loc == src))
		icon_state = "medigunfull"
	else
		icon_state = "medigunpack"
	if(emagged)
		icon_state += "red"
		item_state = "medigunred"

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_back()
		H.update_inv_hands()

/obj/item/uberdevice
	name = "\improper Uber Device"
	desc = "This small device has a gauge with Uber written on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "uber_device"
	w_class = W_CLASS_SMALL
	force = 2
	throwforce = 5

/obj/item/medigun
	name = "\improper Medi-Gun"
	desc = "Now aim at people."//I'm tired right now, someone pls find a snarky, possibly TF2-referencing, description to replace that
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "medigun"
	item_state = "medigun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 1
	flags = FPRINT
	w_class = W_CLASS_HUGE
	var/fire_sound = 'sound/weapons/medigun_heal.ogg'
	var/empty_sound = 'sound/weapons/medigun_no_target.ogg'
	var/obj/item/medigunpack/medigunpack = null
	var/mob/living/healtarget = null
	var/mob/living/wielder = null
	var/ubercharge = 0
	var/emagged = 0

/obj/item/medigun/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>Charge = [ubercharge]%</span>")

/obj/item/medigun/New(var/turf/loc,var/pack=null)
	..()
	if(!pack)
		qdel(src)
	medigunpack = pack

/obj/item/medigun/Destroy()
	if(medigunpack)
		medigunpack.medigun = null
		qdel(medigunpack)
	medigunpack = null
	..()

/obj/item/medigun/process()
	if(!healtarget || (wielder != loc) || (get_dist(src,healtarget) > 3))
		processing_objects.Remove(src)
		return

	//check for obstacles
	var/turf/T = get_turf(wielder)
	var/turf/U = get_turf(healtarget)
	var/beamtype = /obj/item/projectile/beam/bison/heal
	if(emagged)
		beamtype = /obj/item/projectile/beam/bison/heal/hurt
	var/obj/item/projectile/beam/bison/heal/hC = getFromPool(beamtype,T)
	hC.current = healtarget
	hC.original = healtarget
	hC.target = U
	hC.current = T
	hC.firer = wielder
	hC.starting = T
	hC.yo = U.y - T.y
	hC.xo = U.x - T.x

	var/healCanReach = hC.process()

	if(healCanReach)
		heal(healtarget)
	else
		healtarget = null

	returnToPool(hC)

	return

/obj/item/medigun/throw_at(atom/end)
	if(medigunpack)
		loc = medigunpack
		medigunpack.update_icon()
	else
		qdel(src)

/obj/item/medigun/afterattack(var/atom/A, var/mob/living/user)
	add_fingerprint(user)
	if(get_dist(user,A) > 3)
		playsound(user, empty_sound, 50, 1)
		return
	if(ismob(A) && (A != user))
		//GHOSTBUSTERRRSSSSSS
		if(istype(A,/mob/dead/observer) && !A.invisibility)
			A.invisibility = INVISIBILITY_OBSERVER
			user.visible_message("<span class='danger'> [user] busts the ghost of [A].</span>")
			ghostbuster(A)
			return
		if(istype(A,/mob/living/simple_animal/shade))
			var/mob/living/simple_animal/shade/S = A
			for(var/i=0;i<3;i++)
				new /obj/item/weapon/ectoplasm (S.loc)
			user.visible_message("<span class='danger'> [user] busts \the [S].</span>")
			ghostbuster(S)
			S.ghostize()
			qdel(S)
			return

		healtarget = A
		wielder = user
		processing_objects.Add(src)
		playsound(user, fire_sound, 50, 1)

		var/tracker_effect = "heal"
		if(emagged)
			tracker_effect += "red"
		spawn()
			make_tracker_effects(get_turf(src), healtarget, 1, tracker_effect, 3, /obj/effect/tracker/heal)
			sleep(2)
			make_tracker_effects(get_turf(src), healtarget, 1, tracker_effect, 3, /obj/effect/tracker/heal)
			sleep(2)
			make_tracker_effects(get_turf(src), healtarget, 1, tracker_effect, 3, /obj/effect/tracker/heal)
	else
		playsound(user, empty_sound, 50, 1)

/obj/item/medigun/attack_self(mob/user)
	if((ubercharge >= MAX_UBERCHARGE) && healtarget && !(healtarget.flags & INVULNERABLE))
		ubercharge = 0
		playsound(user, 'sound/weapons/medigun_ubercharge.ogg', 75, 1)

		var/mob/living/ubertarget = healtarget
		var/target_has_uberheart = 0
		var/datum/organ/internal/heart/heartcheck = null

		if(istype(ubertarget,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = ubertarget
			heartcheck = H.internal_organs_by_name["heart"]
			if(heartcheck.modifiers & OMODIFER_UBER)
				target_has_uberheart = 1

		ubertarget.flags |= INVULNERABLE
		animate(ubertarget, color = "#FF0000", time = 2, loop = -1)
		animate(color = "#00FF00", time = 2)
		animate(color = "#0000FF", time = 2)

		if(emagged)
			var/chance_of_death = 80//"Most hearts couldn't whistand this voltage...

			if(target_has_uberheart)
				chance_of_death = 20

			if(prob(chance_of_death))//...But I'm fairly certain your heart-"...
				to_chat(ubertarget,"<span class='danger'>THIS--THIS IS TOO MUCH POWER")
				spawn(160)
					if(ubertarget)
						ubertarget.flags &= ~INVULNERABLE
						ubertarget.gib()
			else
				to_chat(ubertarget,"<span class='danger'>YOU ARE BULLETPROOF")
				spawn(80)
					if(ubertarget)
						animate(ubertarget)
						ubertarget.color = null
						ubertarget.flags &= ~INVULNERABLE
						if(heartcheck)
							heartcheck.take_damage(rand(5,60))
		else
			var/duration = 40

			if(target_has_uberheart)
				duration = 60

			spawn(duration)
				if(ubertarget)
					animate(ubertarget)
					ubertarget.color = null
					ubertarget.flags &= ~INVULNERABLE
					if(heartcheck)
						heartcheck.take_damage(rand(5,30))


/obj/item/medigun/emag_act(mob/user as mob)
	if(!emagged)
		to_chat(user, "<span class='warning'>You swipe the cryptographic sequencer through the circuits.</span>")
		emagged = 1
		medigunpack.emagged = 1
		medigunpack.update_icon()
		icon_state = "medigunred"
		item_state = "medigunred"
		user.update_inv_back()
		user.update_inv_hands()

/obj/item/medigun/proc/heal(var/mob/living/M)
	var/healing = MEDIHEAL
	if(emagged)
		healing = MEDIHARM

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/heartcheck = H.internal_organs_by_name["heart"]
		if(heartcheck.modifiers & OMODIFER_UBER)
			healing = MEDIUBER

	M.adjustOxyLoss(-2*healing)
	M.heal_organ_damage(healing*2, 0)
	M.heal_organ_damage(0, healing*2)
	M.adjustToxLoss(-2*healing)
	M.adjustCloneLoss(-2*healing)
	M.adjustBrainLoss(-2*healing)
	M.adjustBruteLoss(-2*healing)
	M.adjustFireLoss(-2*healing)

	if(healing > 0)
		if(M.reagents)
			var/list/reagents_to_check = list(
				"toxin",
				"stoxin",
				"plasma",
				"sacid",
				"pacid",
				"cyanide",
				"amatoxin",
				"chloralhydrate",
				"carpotoxin",
				"mindbreaker",
				)
			for(var/reagent in reagents_to_check)
				if(M.reagents.has_reagent(reagent))
					M.reagents.remove_reagent(reagent, healing)

		if(istype(M,/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = M
			if(SA.health > 0)
				SA.health = min(SA.maxHealth,SA.health+2)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			for(var/datum/organ/external/temp in H.organs)
				if(temp.status & ORGAN_BLEEDING)
					temp.clamp()

		if(M.losebreath >= 10)
			M.losebreath = max(10, M.losebreath - 5)

		if(M.bodytemperature > BODYTEMP_IDEAL)
			M.bodytemperature = max(BODYTEMP_IDEAL, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
		else
			M.bodytemperature = min(BODYTEMP_IDEAL, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

	M.UpdateDamageIcon()
	var/tracker_effect = "heal"
	if(emagged)
		tracker_effect += "red"
	spawn()
		make_tracker_effects(get_turf(src), M, 1, tracker_effect, 3, /obj/effect/tracker/heal)
		sleep(2)
		make_tracker_effects(get_turf(src), M, 1, tracker_effect, 3, /obj/effect/tracker/heal)
		sleep(2)
		make_tracker_effects(get_turf(src), M, 1, tracker_effect, 3, /obj/effect/tracker/heal)
		sleep(2)
		make_tracker_effects(get_turf(src), M, 1, tracker_effect, 3, /obj/effect/tracker/heal)
		sleep(2)
		make_tracker_effects(get_turf(src), M, 1, tracker_effect, 3, /obj/effect/tracker/heal)
	if(healing == MEDIUBER)
		if((ubercharge == (MAX_UBERCHARGE-1)) && istype(loc,/mob))
			to_chat(loc,"<span class='info'>CHARGE READY</span>")
			playsound(loc, 'sound/weapons/medigun_charged.ogg', 50, 1)
		ubercharge = min(ubercharge+1,MAX_UBERCHARGE)

/obj/item/medigun/dropped(mob/user)
	if(medigunpack)
		forceMove(medigunpack)
		medigunpack.update_icon()
	else
		qdel(src)

/obj/item/medigun/proc/ghostbuster(var/atom/A)
	var/turf/T = get_turf(A)
	playsound(T, get_sfx("soulstone"), 50,1)
	//todo: add a custom /obj/effect/tracker

#undef MAX_UBERCHARGE
#undef MEDIHEAL
#undef MEDIUBER
#undef MEDIHARM
