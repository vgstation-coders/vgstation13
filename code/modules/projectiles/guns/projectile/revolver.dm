/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	max_shells = 6
	caliber = list(POINT38 = 1, POINT357 = 1)
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/c38"
	var/perfect = 0

	special_check(var/mob/living/carbon/human/M) //to see if the gun fires 357 rounds safely. A non-modified revolver randomly blows up
		if(getAmmo()) //this is a good check, I like this check
			var/obj/item/ammo_casing/AC = loaded[1]
			if(caliber[POINT38] == 0) //if it's been modified, this is true
				return 1
			if(istype(AC, /obj/item/ammo_casing/a357) && !perfect && prob(70 - (getAmmo() * 10)))	//minimum probability of 10, maximum of 60
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src, force_drop = 1)
				qdel(src)
				return 0
		return 1

	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)
			return 0
		if(!M.mind.assigned_role == "Detective")
			to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
			return 0

		var/input = stripped_input(usr,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

		if(src && input && !M.stat && in_range(src,M))
			name = input
			to_chat(M, "You name the gun [input]. Say hello to your new friend.")
			return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		..()
		if(A.is_screwdriver(user) || istype(A, /obj/item/weapon/conversion_kit))
			var/obj/item/weapon/conversion_kit/CK
			if(istype(A, /obj/item/weapon/conversion_kit))
				CK = A
				if(!CK.open)
					to_chat(user, "<span class='notice'>This [CK.name] is useless unless you open it first. </span>")
					return
			if(caliber[POINT38])
				to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//you know the drill
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber[POINT38] = 0
					desc = "The barrel and chamber assembly seems to have been modified."
					to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
					if(CK && istype(CK))
						perfect = 1
			else
				to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//and again
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber[POINT38] = 1
					desc = initial(desc)
					to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")
					perfect = 0




/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	
	
/obj/item/weapon/gun/projectile/nagant //revolver that simple mob russians use
	name = "nagant revolver"
	desc = "Just like in those neo-russian spy movies! Uses 7.62x38R ammo."
	icon_state = "nagant"
	max_shells = 7
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	caliber = list(NAGANTREVOLVER = 1)
	ammo_type = "/obj/item/ammo_casing/c762x38r"
	gun_flags = SILENCECOMP
	fire_sound = 'sound/weapons/nagant.ogg'
	
/obj/item/weapon/gun/projectile/nagant/update_icon()
	..()
	icon_state = "[initial(icon_state)][silenced ? "-silencer" : ""]"
	return


// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.
// Makes liberal use of cut() to move around the rounds after firing.

/obj/item/weapon/gun/projectile/russian
	name = "russian revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has six slots for ammo."
	max_shells = 6
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	fire_delay = 1

/obj/item/weapon/gun/projectile/russian/New()
	loaded = new/list(6) //imperative that this keeps 6 entries at all times
	loaded[1] = new ammo_type(src)
	Spin() //randomize where the first round is located
	update_icon()

/obj/item/weapon/gun/projectile/russian/proc/Spin()
	loaded = shuffle(loaded)

/obj/item/weapon/gun/projectile/russian/attackby(var/obj/item/A as obj, mob/user as mob)

	if(!A)
		return

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_casing)) //loading rounds one by one
		var/obj/item/ammo_casing/AC = A
		if(src.getAmmo() >= max_shells)
			to_chat(user, "<span class='warning'>It's already full of ammo.</span>")
			return
		if(caliber[AC.caliber])
			user.drop_item(AC)
			AC.forceMove(src)
			loaded += AC
			loaded -= null //ensure that the list constantly has 6 entries
			num_loaded++

	if(istype(A, /obj/item/ammo_storage)) //loading rounds from a box, still one by one
		var/obj/item/ammo_storage/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(src.getAmmo() >= max_shells)
				to_chat(user, "<span class='warning'>It's already full of ammo.</span>")
				return
			if(caliber[AC.caliber] && getAmmo() < max_shells)
				AC.forceMove(src)
				AM.stored_ammo -= AC
				loaded += AC
				loaded -= null //same here
				num_loaded++
			break //one at a time
		A.update_icon()

	if(num_loaded)
		user.visible_message("<span class='warning'>[user] loads a single bullet into the revolver and spins the chamber.</span>", "<span class='warning'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")


	if(getAmmo() > 0)
		Spin()
	playsound(user, 'sound/weapons/revolver_spin.ogg', 50, 1)
	update_icon()
	return

/obj/item/weapon/gun/projectile/russian/attack_self(mob/user as mob)

	user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	playsound(user, 'sound/weapons/revolver_spin.ogg', 50, 1)
	if(getAmmo() > 0)
		Spin()

/obj/item/weapon/gun/projectile/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

	var/obj/item/ammo_casing/AC = loaded[1]
	if(isliving(target) && isliving(user) && target == user)
		if(mouthshoot)
			to_chat(user, "<span class='warning'>You're already doing that.</span>")
			return
		var/datum/organ/external/affecting = user.zone_sel.selecting
		if(affecting == LIMB_HEAD || affecting == "mouth")
			user.visible_message("<span class='danger'>[user.name] puts \the [src] [affecting == LIMB_HEAD ? "against their head" : "in their mouth"], ready to pull the trigger...</span>")
			mouthshoot = 1
			if(!do_after(user,src, 40))
				user.visible_message("<span class='warning'>[user.name] chickened out.</span>")
				mouthshoot = 0
				return
			mouthshoot = 0
			if(!AC || !AC.BB)
				user.visible_message("<span class='warning'>*click*</span>")
				playsound(user, 'sound/weapons/empty.ogg', 100, 1)
				loaded.Cut(1,2)
				loaded += AC
				return
			if(AC.BB)
				in_chamber = AC.BB //Load projectile into chamber.
				AC.BB.forceMove(src) //Set projectile loc to gun.
				AC.BB = null //Empty casings
				AC.update_icon()
			if(!in_chamber)
				return
			var/obj/item/projectile/P = new AC.projectile_type
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>[user.name] fires \the [src]!</span>", "<span class='danger'>You fire \the [src]!</span>", "You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
			if(!P.nodamage)
				affecting = LIMB_HEAD
				user.apply_damage(300, BRUTE, affecting, used_weapon = "Shot self with [src].") // You are dead, dead, dead.
			in_chamber = null
			loaded.Cut(1,2)
			loaded += AC //to make it more realistic, empty casings remain in until you empty the gun
		else
			to_chat(user, "<span class='warning'>Aim for your head or put it in your mouth.</span>")
			return

	..()

/obj/item/weapon/gun/projectile/russian/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	var/obj/item/ammo_casing/AC = loaded[1]
	if(!AC || !AC.BB)
		user.visible_message("<span class='warning'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		loaded.Cut(1,2)
		loaded += AC
		return

	..()
	loaded += AC
	AC.forceMove(src) //get back in there you

/obj/item/weapon/gun/projectile/russian/force_removeMag()
	if(usr.incapacitated())
		return
	if(getAmmo() > 0)
		for(var/obj/item/ammo_casing/AC in loaded)
			AC.forceMove(get_turf(src))
			loaded -= AC
			loaded += null
	visible_message("<span class='warning'>[src] empties onto the ground!</span>")


/obj/item/weapon/gun/projectile/russian/empty/New()
	update_icon()

/obj/item/weapon/gun/projectile/colt
	name = "\improper Colt Single Action Army"
	desc = "The greatest handgun ever made."
	icon_state = "colt"
	max_shells = 6
	var/cocked = FALSE
	var/last_spin = 0
	var/spin_delay = 1 SECONDS	//let's not get crazy

/obj/item/weapon/gun/projectile/colt/update_icon()
	if(cocked)
		icon_state = "colt_cocked"
	else
		icon_state = "colt"

/obj/item/weapon/gun/projectile/colt/attack_self(mob/user, params, var/callparent = FALSE)
	if(callparent)
		return ..(user)
	if(cocked)
		if(!last_spin || (world.time - last_spin) >= spin_delay)
			user.visible_message("\The [user] spins \the [src] around \his finger.","You spin \the [src] around your finger.")
			last_spin = world.time
			animate(src, transform = turn(matrix(), 120), time = 1, loop = 3)
			animate(transform = turn(matrix(), 240), time = 1)
			animate(transform = null, time = 1)
	else
		cocked = TRUE
		update_icon()
		to_chat(user, "You cock \the [src].")
		playsound(user, 'sound/weapons/revolver_cock.ogg', 50, 1)

/obj/item/weapon/gun/projectile/colt/AltClick(var/mob/user)
	attack_self(user, callparent = TRUE)

/obj/item/weapon/gun/projectile/colt/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, struggle = 0)
	if(cocked)
		..()
		cocked = FALSE
		update_icon()

/obj/item/weapon/gun/projectile/banana
	name = "banana"
	desc = "It's an excellent prop for a comedy."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	max_shells = 1
	gun_flags = 0
	conventional_firearm = 0
	clumsy_check = 0

/obj/item/weapon/gun/projectile/banana/proc/make_peel(mob/user)
	user.drop_item(src, force_drop = 1)
	var/obj/item/weapon/bananapeel/B = new(get_turf(src))
	user.put_in_hands(B)
	qdel(src)

/obj/item/weapon/gun/projectile/banana/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0)
	. = ..()
	make_peel(user)

/obj/item/weapon/gun/projectile/banana/attack_self(mob/living/user)
	if(process_chambered())
		playsound(user, fire_sound, fire_volume, 1)
		in_chamber.on_hit(user)
		user.apply_damage(in_chamber.damage*1.5, in_chamber.damage_type, LIMB_HEAD, used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
		qdel(in_chamber)
		in_chamber = null
		make_peel(user)
		user.visible_message("<span class='danger'>\The [src] explodes as \the [user] bites into it!</span>","<span class='danger'>\The [src] explodes as you bite into it!</span>")