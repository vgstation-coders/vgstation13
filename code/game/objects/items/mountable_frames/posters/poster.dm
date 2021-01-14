/obj/item/mounted/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface."
	icon = 'icons/obj/posters.dmi'
	icon_state = "rolled_poster"
	var/build_time = 2 SECONDS
	var/datum/poster/design
	w_type=RECYK_MISC


/obj/item/mounted/poster/New(turf/loc, var/datum/poster/predesign=null)
	design = predesign
	if(!design)
		pick_design()
	..()

/obj/item/mounted/poster/examine(mob/user)
	..()
	if(design)
		to_chat(user,"<span class='info'>This one is titled '[design.name]'.</span>")

/obj/item/mounted/poster/proc/pick_design()
	var/random = subtypesof(/datum/poster) - typesof(/datum/poster/special)
	var/type = pick(random)
	design = new type

/obj/item/mounted/poster/do_build(turf/on_wall, mob/user)
	var/obj/structure/sign/poster/D = new(on_wall,design)
	poster_animation(D,user)
	if(do_after(user, on_wall, build_time))//Let's check if everything is still there
		to_chat(user, "<span class='notice'>You place \the [src]!</span>")
		qdel(src)
		return
	qdel(D)

/obj/item/mounted/poster/proc/poster_animation(obj/D,mob/user)
	to_chat(user, "<span class='notice'>You start placing the poster on the wall...</span>")
	flick("poster_being_set",D)
	playsound(get_turf(D), 'sound/items/poster_being_created.ogg', 100, 1)

/obj/item/mounted/poster/goldstar/pick_design()
	design = new /datum/poster/special/goldstar

/obj/item/mounted/poster/cargo/pick_design()
	var/type = pick(/datum/poster/special/cargoflag,/datum/poster/special/cargofull)
	design = new type

//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. "
	icon = 'icons/obj/posters.dmi'
	icon_state = "default"
	anchored = 1
	var/datum/poster/design
	var/ruined = 0


/obj/structure/sign/poster/New(loc, var/datum/poster/predesign)
	..()
	if(!design)
		if(predesign)
			design = predesign
		else
			design()
	name = design.name
	desc = design.desc
	icon_state = design.icon_state

/obj/structure/sign/poster/proc/design()
	var/list/poster_designs = subtypesof(/datum/poster) - typesof(/datum/poster/special)
	var/type = pick(poster_designs)
	design = new type

/obj/structure/sign/poster/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswirecutter(W))
		W.playtoolsound(loc, 100)
		if(ruined)
			to_chat(user, "<span class='notice'>You remove the remnants of the poster.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You carefully remove the poster from the wall.</span>")
			roll_and_drop(user.loc)

/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		to_chat(user,"<span class='warning'>It's in tatters. You'll need wirecutters to get all the scraps off.</span>" )
		return
	switch(user.a_intent)
		if(I_HURT)
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(src, 'sound/items/poster_ripped.ogg', 100, 1)
			rip()
			add_fingerprint(user)
		if(I_HELP)
			visible_message("<span class='notice'>[user] admires \the [src].</span>" )
		else
			visible_message("<span class='notice'>[user] begins taking down \the [src].</span>")
			if(do_after(user, src, 4 SECONDS))
				roll_and_drop(user.loc)


/obj/structure/sign/poster/proc/rip(mob/user)
	ruined = 1
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

/obj/structure/sign/poster/proc/roll_and_drop(turf/newloc)
	if(newloc)
		new /obj/item/mounted/poster(newloc, design)
	else
		new /obj/item/mounted/poster(get_turf(src), design)
	qdel(src)

/obj/structure/sign/poster/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(prob(70))
		if(H.foot_impact(src, rand(5,7)))
			to_chat(H, "<span class='userdanger'>Ouch! That hurts!</span>")

/obj/structure/sign/poster/goldstar/design()
	design = new /datum/poster/special/goldstar

/obj/structure/sign/poster/cargo/design()
	var/type = pick(/datum/poster/special/cargoflag,/datum/poster/special/cargofull)
	design = new type

/datum/poster
	var/name=""
	var/desc=""
	var/icon_state=""
	var/path = /obj/structure/sign/poster
//see decals/posters/bs12.dm, tpgposters.dm and vgposters.dm