
/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	w_class = 4.0
	flags = FPRINT
	slot_flags = SLOT_BACK	//ERROOOOO
	max_w_class = 3
	max_combined_w_class = 21

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(get_turf(src), "rustle", 50, 1, -5)
	..()

/*
 * Backpack Types
 */




/obj/item/weapon/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Bluespace. Highly unstable in proximity of other Bluespace-using devices."
	origin_tech = "bluespace=4"
	item_state = "holdingpack"
	icon_state = "holdingpack"
	max_w_class = 4
	max_combined_w_class = 28

/obj/item/weapon/storage/backpack/holding/suicide_act(mob/user)
		viewers(user) << "<span class = 'danger'><b>[user] puts the [src.name] on \his head and stretches the bag around \himself. With a sudden snapping sound, the bag shrinks to it's original size, leaving no trace of [user] </b></span>"
		loc = get_turf(user)
		qdel(user)

/obj/item/weapon/storage/backpack/holding/New()
	..()
	return

/obj/item/weapon/storage/backpack/holding/attackby(obj/item/W as obj, mob/user as mob)
	if(W == src)
		return // HOLY FUCKING SHIT WHY STORAGE CODE, WHY - pomf
	if(crit_fail)
		user << "<span class = 'warning'>The Bluespace generator isn't working.</span>"
		return
	if(!W.crit_fail && checkforbluespace(W))
		if(bluespaceerror(W, user)!=1)
			return
	/*if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
		user << "<span class = 'warning'>The Bluespace interfaces of the two devices conflict and malfunction.</span>"
		del(W)
		return*/
	/*//BoH+BoH=Singularity, WAS commented out
	if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
		investigation_log(I_SINGULO,"has become a singularity. Caused by [user.key]")
		message_admins("[src] has become a singularity. Caused by [user.key]")
		user << "<span class = 'danger'>The Bluespace interfaces of the two devices catastrophically malfunction!</span>"
		del(W)
		var/obj/machinery/singularity/singulo = new /obj/machinery/singularity (get_turf(src))
		singulo.energy = 300 //should make it a bit bigger~
		message_admins("[key_name_admin(user)] detonated a bag of holding")
		log_game("[key_name(user)] detonated a bag of holding")
		del(src)
		return*/
	..()

/obj/item/weapon/storage/backpack/holding/proc/checkforbluespace(obj/item/W) //check the item and its contents for bluespace shit
	if(W.UsesBluespace())
		return 1
	for(var/obj/item/W1 in W.contents)
		if(.(W1))
			return 1

//If bluespaceerror returns 1, the item will still be put inside. Otherwise it won't.
/obj/item/weapon/storage/backpack/holding/proc/bluespaceerror(obj/item/W as obj, mob/user as mob) //Don't play with bluespace, kids
	if(!istype(W)) return
	if(crit_fail) return

	if(istype(W,/obj/item/device/gps)) //GPS only uses bluespace to transmit/gather data or some shit like that
		var/obj/item/device/gps/G = W //Not enough for a real malfunction, just corrupt the GPS and put it inside
		G.emped = 1
		G.overlays -= "working"
		G.overlays += "emp"
		user << "<span class = 'warning'>[W]'s screen flashes brightly, overloaded with data.</span>"
		return 1

	src.visible_message("<span class = 'danger'>[W] causes [src]'s Bluespace interface to malfunction!</span>")
	switch(rand(0,11))
		if(0 to 2) //Just delete the item.
			src.visible_message("<span class='warning'>[W] disappears in an instant.</span>")
			del(W)
		if(3 to 5) //Delete a random amount of items inside the bag. If anything was deleted, show a special message
			var/deleted_anything=0
			for(var/obj/O in src.contents)
				if(prob(030))
					deleted_anything=1
					del(O)
			if(deleted_anything==1)
				src.visible_message("<span class='warning'>The bluespace window flickers for a moment.</span>")
				return
			user << "Nothing seems to happen."
		if(6 to 8) //A small explosion
			src.visible_message("<span class='danger'>[src] releases a sudden burst of energy!</span>")
			explosion(src.loc,-1,1,3)
		if(9) //Honk
			for(var/mob/living/carbon/M in hearers(src, null))
				M << sound('sound/items/AirHorn.ogg')
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					if(H.is_on_ears(/obj/item/clothing/ears/earmuffs))
						continue
				M << "<font color='red' size='7'>HONK</font>"
				M.sleeping = 0
				M.stuttering += 20
				M.ear_deaf += 30
				M.Weaken(3)
				if(prob(30))
					M.Stun(10)
					M.Paralyse(4)
				else
					M.Jitter(500)
		if(10 to 11) //BoH turns itself off
			src.visible_message("<span class='warning'>[src] shuts itself down to prevent potentially catastrophic damage.</span>")
			crit_fail = 1
			icon_state = "brokenpack"
	return 0

/obj/item/weapon/storage/backpack/holding/proc/failcheck(mob/user as mob)
	if (prob(src.reliability)) return 1 //No failure
	if (prob(src.reliability))
		user << "<span class = 'warning'>The Bluespace portal resists your attempt to add another item.</span>" //light failure
	else
		user << "<span class = 'danger'>The Bluespace generator malfunctions!</span>"
		for (var/obj/O in src.contents) //it broke, delete what was in it
			del(O)
		crit_fail = 1
		icon_state = "brokenpack"

/obj/item/weapon/storage/backpack/holding/singularity_act(current_size)
//	var/dist = max((current_size - 2), 1)
//	explosion(src.loc,(dist),(dist*2),(dist*4))
	return

/obj/item/weapon/storage/backpack/holding/UsesBluespace()
	if(crit_fail)
		return 0
	return 1

/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4.0
	storage_slots = 20
	max_w_class = 3
	max_combined_w_class = 400 // can store a ton of shit!

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"
	item_state = "cultpacknew"

/obj/item/weapon/storage/backpack/cultify()
	new /obj/item/weapon/storage/backpack/cultpack(loc)
	..()

/obj/item/weapon/storage/backpack/cultpack/cultify()
	return

/obj/item/weapon/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"

/*
 * Satchel Types
 */

/obj/item/weapon/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"

/obj/item/weapon/storage/backpack/satchel/withwallet
	New()
		..()
		new /obj/item/weapon/storage/wallet/random( src )

/obj/item/weapon/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"

/obj/item/weapon/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	item_state = "engiepack"

/obj/item/weapon/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/weapon/storage/backpack/satchel_chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/weapon/storage/backpack/satchel_gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/weapon/storage/backpack/satchel_tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"

/obj/item/weapon/storage/backpack/satchel_sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/satchel_hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"

/obj/item/weapon/storage/backpack/satchel_cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	item_state = "captainpack"