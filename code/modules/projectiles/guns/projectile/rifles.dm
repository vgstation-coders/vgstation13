/obj/item/weapon/gun/projectile/automatic/rifles
	name = "Perfect rifle"
	desc = "A lightweight, fast firing, purple gun, why admin spawn this?"
	icon = 'icons/obj/guns/projectile-rifle.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	icon_state = "rifle"
	item_state = null
	//mag
	load_method = MAGAZINE
	max_shells = 30
	ammo_type = "/obj/item/ammo_casing/a556"
	mag_type = "/obj/item/ammo_storage/magazine/a556"
	caliber = list("5.56" = 1)
	//datums
	origin_tech = "combat=3;materials=3;engineering=2"
	starting_materials = list(MAT_IRON = 3500)
	//other
	w_class = 4.0
	force = 15
	//firespeed and modes
	automatic = 1
	fire_delay = 1
	burstfire = 0
	burst_count = 3

	//modules
	barrel_slot_allowed = 1
	tactical_slot_allowed = 1
	underbarrel_slot_allowed = 1
	scope_slot_allowed = 1

	update_icon()
		..()
		icon_state = "[initial(icon_state)][stored_magazine ? ".full" : ""][scope_slot ? ".scope" : ""][barrel_slot ? ".silencer" : ""][underbarrel_slot ? ".launcher" : ""][tactical_slot ? ".tactical" : ""]"
		return

/obj/item/weapon/gun/projectile/automatic/rifles/k4m
	name = "\improper Carbine Mk4"
	desc = "Hmm.. That reminds me, but what? Uses 5.56 rounds."
	icon_state = "k4m"
	w_class = 4.0
	max_shells = 30
	caliber = list("5.56" = 1)
	ammo_type = "/obj/item/ammo_casing/a556"
	mag_type = "/obj/item/ammo_storage/magazine/a556"
	slot_flags = SLOT_BACK
	gun_flags = AUTOMAGDROP
	barrel_slot_allowed = 1
	tactical_slot_allowed = 1
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 1

/obj/item/weapon/gun/projectile/automatic/rifles/k4m/rnd
	desc = "Carbine Mk4, made from plastic and plasteel composite alloys. Uses 5.56 rounds."
	icon_state = "k4mr"
	origin_tech = "combat=3;materials=4;engineering=2"

/obj/item/weapon/gun/projectile/automatic/rifles/ak7m
	name = "\improper AK 7m"
	desc = "Ha, custom modification of k4m carbine Uses 7.62 rounds."
	icon_state = "k4m"
	w_class = 4.0
	max_shells = 30
	caliber = list("7.62" = 1)
	ammo_type = "/obj/item/ammo_casing/a762"
	mag_type = "/obj/item/ammo_storage/magazine/a762/x30"
	gun_flags = AUTOMAGDROP | EMPTYCASINGS
	barrel_slot_allowed = 0
	tactical_slot_allowed = 0
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

/obj/item/weapon/gun/projectile/automatic/rifles/assault
	name = "\improper Assault Rifle"
	desc = "A lightweight, fast firing gun, issued to shadow organization members."
	icon_state = "assaultrifle"
	item_state = null
	origin_tech = "combat=5;materials=2"
	w_class = 3.0
	max_shells = 20
	burst_count = 5
	caliber = list("12mm" = 1)
	ammo_type = "/obj/item/ammo_casing/a12mm"
	mag_type = "/obj/item/ammo_storage/magazine/a12mm"
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	gun_flags = AUTOMAGDROP | EMPTYCASINGS

	barrel_slot_allowed = 0
	tactical_slot_allowed = 0
	underbarrel_slot_allowed = 1
	scope_slot_allowed = 0

/obj/item/weapon/gun/projectile/automatic/advanced
	name = "\improper High tech assault rifle"
	desc = "A lightweight gun, made with plastic. Strange, but this rifle have mark with that text: Made from PKS. Uses 12.7 rounds"
	icon_state = "pkst1m"
	origin_tech = "combat=5;materials=5"
	item_state = "pkst1m"
	w_class = 4.0
	max_shells = 15
	starting_materials = list(MAT_IRON = 500)
	burst_count = 3
	force = 12
	caliber = list("12.7" = 1)
	ammo_type = "/obj/item/ammo_casing/a127s"
	mag_type = "/obj/item/ammo_storage/magazine/a127s"
	fire_sound = 'sound/weapons/G36.ogg'
	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/automatic/rifles/c20r
	name = "\improper C-20r SMG"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses 12mm rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp"
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	burst_count = 4
	caliber = list("12mm" = 1)
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	mag_type = "/obj/item/ammo_storage/magazine/a12mm"
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	load_method = MAGAZINE
	gun_flags = AUTOMAGDROP

	barrel_slot_allowed = 0
	tactical_slot_allowed = 0
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

	update_icon()
		..()
		if(stored_magazine)
			icon_state = "c20r-[round(getAmmo(),4)]"
		else
			icon_state = "c20r"
		return

/obj/item/weapon/gun/projectile/automatic/rifles/machine_gun
	name = "\improper L6 SAW"
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 4
	slot_flags = 0
	max_shells = 50
	burst_count = 10
	caliber = list("a762" = 1)
	origin_tech = "combat=5;materials=1;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	mag_type = "/obj/item/ammo_storage/magazine/a762"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	var/cover_open = 0

	attack_self(mob/user as mob)
		if(user.a_intent == "harm")
			cover_open = !cover_open
			to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
			update_icon()

	update_icon()
		icon_state = "l6[cover_open ? ".open" : ".closed"][stored_magazine ? round(getAmmo(), 20) : ".empty"]"

	afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
		if(cover_open)
			to_chat(user, "<span class='notice'>[src]'s cover is open! Close it before firing!</span>")
		else
			..()
			update_icon()

	attack_hand(mob/user as mob)
		if(loc != user)
			..()
			return
		if(!cover_open)
			..()
		else if(cover_open && stored_magazine && user.a_intent == "disarm")
			//drop the mag
			RemoveMag(user)
			to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")

	attackby(obj/item/ammo_storage/magazine/a762/A as obj, mob/user as mob)
		if(!cover_open)
			to_chat(user, "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>")
			return
		else if(cover_open)
			..()

	force_removeMag() //special because of its cover
		if(cover_open && stored_magazine)
			RemoveMag(usr)
			to_chat(usr, "<span class='notice'>You remove the magazine from [src].</span>")
		else if(stored_magazine)
			to_chat(usr, "<span class='rose'>The [src]'s cover has to be open to do that!</span>")
		else
			to_chat(usr, "<span class='rose'>There is no magazine to remove!</span>")