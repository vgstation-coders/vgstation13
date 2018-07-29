/obj/item/weapon/gun/projectile/shotgun/pump
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "shotgun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 4
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list(GAUGE12 = 1, GAUGEFLARE = 1) //flare shells are still shells
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	var/obj/item/ammo_casing/current_shell = null


	gun_flags = 0

/obj/item/weapon/gun/projectile/shotgun/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/shotgun/pump/attack_self(mob/living/user as mob)
	if(recentpump)
		return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return

/obj/item/weapon/gun/projectile/shotgun/pump/process_chambered()
	if(in_chamber)
		return 1
	else if(current_shell && current_shell.BB)
		in_chamber = current_shell.BB //Load projectile into chamber.
		current_shell.BB.forceMove(src) //Set projectile loc to gun.
		current_shell.BB = null
		current_shell.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/shotgun/pump/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pumped = 0
	if(current_shell)//We have a shell in the chamber
		current_shell.forceMove(get_turf(src))//Eject casing
		current_shell = null
		if(in_chamber)
			in_chamber = null
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	current_shell = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/pump/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 8
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun"

//this is largely hacky and bad :(	-Pete
/obj/item/weapon/gun/projectile/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 2
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list(GAUGE12 = 1, GAUGEFLARE = 1)
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=1"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	var/doubleshot = 0
	var/doubleshooting = 0
	var/recoileffectchance = 50

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/process_chambered()
	if(in_chamber)
		return 1
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	loaded += AC //Put it in at the end - because it hasn't been ejected yet
	if(AC.BB)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.forceMove(src) //Set projectile loc to gun.
		AC.BB = null
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/attack_self(mob/living/user as mob)
	if(!(locate(/obj/item/ammo_casing/shotgun) in src) && !getAmmo())
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return
	if(jammed)
		to_chat(user, "<span class='warning'>You break open \the [src], but the shells inside seem to be stuck...</span>")
		sleep(10)
		to_chat(user, "<span class='notice'>You should get a rod to loosen them, fumbling won't get you anywhere.</span>")
		return
	var/i = 0
	for(var/obj/item/ammo_casing/shotgun/loaded_shell in src) //This feels like a hack. don't code at 3:30am kids!!
		loaded_shell.forceMove(get_turf(src))
		loaded_shell.pixel_x = min(-3 + (i*4),15) * PIXEL_MULTIPLIER
		loaded_shell.pixel_y = min( 3 - (i*4),15) * PIXEL_MULTIPLIER
		if(loaded_shell in loaded)
			loaded -= loaded_shell
		i++

	to_chat(user, "<span class='notice'>You break open \the [src], and [i] shell\s fl[i == 1 ? "ies" : "y"] out of the barrel\s.</span>")
	update_icon()

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	A.update_icon()
	update_icon()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(getAmmo())
			afterattack(user, user)	//will this work?
			afterattack(user, user)	//it will. we call it twice, for twice the FUN
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
			return
		if(do_after(user, src, 30))	//SHIT IS STEALTHY EYYYYY
			icon_state = "sawnshotgun"
			w_class = W_CLASS_MEDIUM
			item_state = "sawnshotgun"
			slot_flags &= ~SLOT_BACK	//you can't sling it on your back
			slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
			name = "sawn-off shotgun"
			desc = "Omar's coming!"
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")
			if(istype(user, /mob/living/carbon/human) && src.loc == user)
				var/mob/living/carbon/human/H = user
				H.update_inv_hands()
	if(istype(A, /obj/item/stack/rods))
		to_chat(user, "<span class='notice'>You start jamming a rod into \the [src]'s barrels to try and loosen the shells...</span>")
		if(do_after(user, src, 60))
			jammed = 0
			to_chat(user, "<span class='notice'>You manage to loosen the shells.</span>")

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/verb/toggle_doubleshot()
	set name = "Toggle Shooting Both Barrels"
	set category = "Object"
	if((world.time >= last_fired + fire_delay) && !doubleshooting)
		doubleshot = !doubleshot
		if(!doubleshot)
			fire_delay = initial(fire_delay)
		to_chat(usr, "You switch \the [src]'s fire selector to [doubleshot ? "fire both barrels at once" : "fire one barrel at a time"].")

#define JAMMED 1
#define DROPGUN 2
#define KNOCKDOWN 3
#define RECOILBRUISE 4

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(doubleshot && (getLiveAmmo() == 2)) //ANGERY
		var/atom/reverse = locate(2*user.x - target.x, 2*user.y - target.y, target.z)

		if(ready_to_fire())
			fire_delay = 0
		else
			return
		if(defective && prob(5))
			to_chat(user, "<span class='danger'>\The [src] can't handle the pressure of firing two shells at once!</span>")
			explosion(get_turf(loc), -1, 0, 2)
			user.drop_item(src, force_drop = 1)
			qdel(src)
		else
			doubleshooting = 1
			recoil = 2 * initial(recoil)
			..()
			..()
			message_admins("[usr] just fired both barrels out of \his [src].")
			fire_delay = 20
			recoil = initial(recoil)
			doubleshooting = 0
			if(prob(recoileffectchance)) // Total chance to fuck up
				var/mob/living/carbon/human/H = user
				switch(pick(JAMMED,DROPGUN,KNOCKDOWN,RECOILBRUISE))
					if(JAMMED)
						jammed = 1 // Needs some work to be unloaded and reloaded again
					if(DROPGUN)
						if(user.drop_item(src)) // Launches it from your hands behind you, letting someone else steal it
							src.throw_at(reverse, 2, 10)
							to_chat(user, "<span class='danger'>The recoil is too strong and \the [src] flies out of your hand!</span>")
						else
							to_chat(user, "<span class='notice'>You barely manage to withstand the recoil.</span>")
					if(KNOCKDOWN)
						H.Stun(3) //Drops you on your ass, this is a death sentence if you're in combat
						H.Knockdown(3)
						to_chat(user, "<span class='danger'>The recoil throws you off balance!</span>")
					if(RECOILBRUISE)
						var/datum/organ/external/org = H.find_organ_by_grasp_index(user.is_holding_item(src)).parent // It should break your arm, not your hand, the gun still has a stock you're bracing against.
						org.take_damage(rand(15,40), null , null, null)// I have no idea what the fuck I am doing, adjustBruteLossByPart() doesn't work for some reason.
						to_chat(user, "<span class='danger'>The recoil kicks your arm like a mule!</span>")
	else
		..()

#undef JAMMED
#undef DROPGUN
#undef KNOCKDOWN
#undef RECOILBRUISE


/obj/item/weapon/gun/projectile/shotgun/doublebarrel/proc/getLiveAmmo() // Mad.
	var/bullets = 0
	for(var/obj/item/ammo_casing/AC in loaded)
		if(istype(AC) && AC.BB)
			bullets += 1
	return bullets

/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawnoff
	name = "sawn-off shotgun"
	desc = "Omar's coming!"
	icon_state = "sawnshotgun"
	item_state = "sawnshotgun"
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_BELT
	ammo_type = "/obj/item/ammo_casing/shotgun/buckshot"
