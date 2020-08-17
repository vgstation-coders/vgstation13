//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fireaxe cabinet"
	desc = "A small label reads 'For Emergency use only', accompanied with pictograms detailing safe usages for the included fireaxe. As if."
	var/obj/item/weapon/fireaxe/fireaxe = new/obj/item/weapon/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	density = 0
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	var/smashed = 0
	locked = 1
	plane = ABOVE_TURF_PLANE
	layer = FIREAXE_LOCKER_LAYER


/obj/structure/closet/fireaxecabinet/empty
	fireaxe = null
	locked = 0 //Doesn't matter if an empty cabinet is locked. Make sure to lock it after you put the axe in, though.
	localopened = 1

/obj/structure/closet/fireaxecabinet/New(loc, var/ndir)
	..()
	if(ndir)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE) //Stolen from one of several near-identical other things
		pixel_y = (ndir & 3)? (ndir == 1 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE) : 0 //Stolen from one of several near-identical other things
		dir = ndir
	update_icon()

/obj/structure/closet/fireaxecabinet/examine(mob/user)

	..()
	if(smashed)
		to_chat(user, "The protective glass shield has been damaged beyond repair.")
	else if(hitstaken)
		to_chat(user, "There are [hitstaken] impacts on the protective glass shield.")
	else
		to_chat(user, "The protective glass shield appears intact.")
	if(!fireaxe)
		to_chat(user, "The fireaxe is missing from the cabinet.")
	else
		to_chat(user, "The fireaxe is still in the cabinet [localopened ? "and up for grabs" : "behind the protective glass"].")

	to_chat(user, "A small [locked ? "red" : "green"] light indicates the cabinet is [locked ? "" : "un"]locked.")

/obj/structure/closet/fireaxecabinet/attackby(var/obj/item/O as obj, var/mob/living/user as mob)  //Marker -Agouri

	user.delayNextAttack(10) //Whatever we do here, no clicking around for the user for at least one second

	var/hasaxe = 0       //gonna come in handy later~
	if(fireaxe)
		hasaxe = 1

	if(isrobot(user) || src.locked)
		if(istype(O, /obj/item/device/multitool))
			visible_message("<span class='notice'>[user] starts fiddling with \the [src]'s locking module.</span>", \
			"<span class='notice'>You start disabling \the [src]'s locking module.</span>")
			playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
			if(do_after(user, src, 50))
				locked = 0
				visible_message("<span class='notice'>[user] disables \the [src]'s locking module.</span>", "<span class='notice'>You disable \the [src]'s locking module.</span>")
				update_icon()
		if(istype(O, /obj/item/weapon))
			var/obj/item/weapon/W = O
			if(smashed || localopened) //We're putting the axe back in
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
				return
			else //We are hitting the closet
				user.do_attack_animation(src, O)
				if(W.force < 15)
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
					visible_message("<span class='notice'>\The [src]'s protective glass glances off [user]'s hit with \the [O].")
				else
					hitstaken++
					if(hitstaken == 4) //Slam
						playsound(user, 'sound/effects/Glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
						visible_message("<span class='warning'>\The [src]'s protective glass shatters, exposing its contents.")
						smashed = 1
						locked = 0
						localopened = 1
					else //We have yet to break the closet, so glass hiting sound and damage message
						visible_message("<span class='warning'>[user] damages \the [src]'s protective glass with \the [O].")
						playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
				update_icon()
		return
	if(istype(O, /obj/item/weapon/fireaxe) && src.localopened)
		if(!fireaxe)
			var/obj/item/weapon/fireaxe/F = O
			if(F.wielded)
				to_chat(user, "<span class='warning'>Unwield [F] first!</span>")
				return
			user.drop_item(F, src, force_drop = 1)
			fireaxe = O
			visible_message("<span class='notice'>[user] places [F] back into [src].</span>", \
			"<span class='notice'>You place [F] back into [src].</span>")
			update_icon()
		else
			if(smashed)
				to_chat(user, "<span class='warning'>[src]'s protective glass is broken.</span>")
				return
			if(istype(O, /obj/item/device/multitool))
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
					return
				else
					visible_message("<span class='notice'>[user] starts to fiddle with [src]'s locking module.</span>", \
					"<span class='notice'>You start to re-enable [src]'s locking module.</span>")
					if(do_after(user, src, 50))
						locked = 1
						visible_message("<span class='notice'>[user] re-enables [src]'s locking module.</span>", \
						"<span class='notice'>You re-enable [src]'s locking module.</span>")
						playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
						update_icon()
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
						update_icon()
				else
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()
	else
		if(O.is_wrench(user) && src.localopened && !src.fireaxe)
			to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
			O.playtoolsound(src, 100)
			new /obj/item/stack/sheet/plasteel (src.loc,2)
			qdel(src)
		if(smashed)
			return
		else
			localopened = !localopened
			if(localopened)
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
				spawn(10)
					update_icon()
			else
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
				spawn(10)
					update_icon()

/obj/structure/closet/fireaxecabinet/attack_hand(mob/user as mob)

	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1

	if(locked)
		to_chat(user, "<span class='warning'>[src] is locked tight!</span>")
		return
	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			visible_message("<span class='notice'>[user] takes [fireaxe] from [src].</span>", \
			"<span class='notice'>You take [fireaxe] from [src].</span>")
			fireaxe = null
			add_fingerprint(user)
			update_icon()
		else
			if(smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
						update_icon()
				else
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
						update_icon()

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
			spawn(10)
				update_icon()
		else
			icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
			spawn(10)
				update_icon()

/obj/structure/closet/fireaxecabinet/verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
	set name = "Open/Close"
	set category = "Object"

	if(isrobot(usr) || locked || smashed)
		if(locked)
			to_chat(usr, "<span class='warning'>\The [src] is locked tight!</span>")
		else if(smashed)
			to_chat(usr, "<span class='notice'>\The [src]'s protective glass is broken!</span>")
		return

	localopened = !localopened
	update_icon()

/obj/structure/closet/fireaxecabinet/verb/remove_fire_axe()
	set name = "Remove Fire Axe"
	set category = "Object"

	if(isrobot(usr))
		return

	if(localopened)
		if(fireaxe)
			usr.put_in_hands(fireaxe)
			visible_message("<span class='notice'>[usr] takes [fireaxe] from \the [src].</span>", \
			"<span class='notice'>You take [fireaxe] from \the [src].</span>")
			fireaxe = null
		else
			to_chat(usr, "<span class='notice'>\The [src] is empty.</span>")
	else
		to_chat(usr, "<span class='notice'>\The [src] is closed.</span>")
	update_icon()

/obj/structure/closet/fireaxecabinet/attack_paw(mob/user as mob)
	attack_hand(user)
	return

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(isobserver(user))
		return //NO. FUCK OFF.
	if(smashed)
		to_chat(user, "<span class='warning'>\The [src]'s security protocols have locked down its electronic systems. Might have to do with the smashed glass.</span>")
		return
	else
		locked = !locked
		if(locked)
			visible_message("<span class='notice'>[user] locks \the [src]</span>", \
			"<span class='notice'>You lock [src]</span>")
		else
			visible_message("<span class='notice'>[user] unlocks \the [src]</span>", \
			"<span class='notice'>You unlock [src]</span>")
		return

/obj/structure/closet/fireaxecabinet/update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1
	icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]"

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return

/obj/structure/closet/fireaxecabinet/Destroy()
	if(fireaxe)
		visible_message("<span class='notice'>The fireaxe noisily ricochets off the ground as it slides out of \the [src].</span>")
		fireaxe.forceMove(get_turf(src)) //Save the axe from destruction
	..()
