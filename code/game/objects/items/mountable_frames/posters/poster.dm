
/obj/item/mounted/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface."
	icon = 'icons/obj/posters.dmi'
	icon_state = "rolled_poster"
	var/serial_number = 0
	var/build_time = 17
	var/path = /obj/structure/sign/poster
	var/serial = TRUE
	w_type=RECYK_MISC


/obj/item/mounted/poster/New(turf/loc, var/given_serial = 0)
	if(serial)
		if(given_serial == 0)
			serial_number = rand(1, poster_designs.len)
		else
			serial_number = given_serial
		name += " - No. [serial_number]"
		if(serial_number == -1)
			name = "Commendation Poster"
	..(loc)

/obj/item/mounted/poster/do_build(turf/on_wall, mob/user)
	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = new path(on_wall,src.serial_number)

	var/temp_loc = user.loc
	poster_animation(D,user)
	qdel(src)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway



	if(!D)
		return

	if(do_after(user, on_wall, build_time))//Let's check if everything is still there
		to_chat(user, "<span class='notice'>You place \the [src]!</span>")
		return D
	else
		D.roll_and_drop(temp_loc)


/obj/item/mounted/poster/proc/poster_animation(obj/D,mob/user)
	to_chat(user, "<span class='notice'>You start placing the poster on the wall...</span>")
	flick("poster_being_set",D)
	playsound(get_turf(D), 'sound/items/poster_being_created.ogg', 100, 1)

//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. "
	icon = 'icons/obj/posters.dmi'
	icon_state = "default"
	anchored = 1
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/ruined = 0


/obj/structure/sign/poster/New(loc,var/serial=0)

	serial_number = serial
	switch(serial_number)
		if(-2)
			return
		if(-1)
			name = "Award of Sufficiency"
			desc = "The mere sight of it makes you very proud."
			icon_state = "goldstar"
			return
		if(0)
			serial_number = rand(1, poster_designs.len) //mapping specific posters
	var/designtype = poster_designs[serial_number]
	var/datum/poster/design=new designtype
	name += " - [design.name]"
	desc += " [design.desc]"
	icon_state = design.icon_state // poster[serial_number]
	..()

/obj/structure/sign/poster/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswirecutter(W))
		W.playtoolsound(loc, 100)
		if(ruined)
			to_chat(user, "<span class='notice'>You remove the remnants of the poster.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You carefully remove the poster from the wall.</span>")
			roll_and_drop(user.loc)
		return

/obj/structure/sign/poster/attack_hand(mob/user as mob)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(alert("Do I want to rip the poster from the wall?","You think...","Yes","No"))
		if("Yes")
			if(user.loc != temp_loc)
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(src, 'sound/items/poster_ripped.ogg', 100, 1)
			rip()
			add_fingerprint(user)
		if("No")
			return

/obj/structure/sign/poster/proc/rip(mob/user)
	ruined = 1
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

/obj/structure/sign/poster/proc/roll_and_drop(turf/newloc)
	if(newloc)
		new /obj/item/mounted/poster(newloc, serial_number)
	else
		new /obj/item/mounted/poster(get_turf(src), serial_number)
	qdel(src)

/obj/structure/sign/poster/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(prob(70))
		to_chat(H, "<span class='userdanger'>Ouch! That hurts!</span>")

		H.apply_damage(rand(5,7), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))


/datum/poster
	// Name suffix. Poster - [name]
	var/name=""
	// Description suffix
	var/desc=""
	var/icon_state=""
