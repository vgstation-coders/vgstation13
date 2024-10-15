/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin_"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_CARDBOARD
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 10
	layer = BELOW_OBJ_LAYER
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = new/list()	//List of papers put in the bin for reference.
	var/crayon = null
	var/image/paper = null
	flammable = TRUE

/obj/item/weapon/paper_bin/New()
	..()
	update_icon()
	thermal_mass = thermal_mass + amount * 0.1 //0.1 = paper thermal_mass

/obj/item/weapon/paper_bin/black
	crayon = "black"
	icon_state = "paper_bin_black" //previews for mapper sanity

/obj/item/weapon/paper_bin/blue
	crayon = "blue"
	icon_state = "paper_bin_blue"

/obj/item/weapon/paper_bin/red
	crayon = "red"
	icon_state = "paper_bin_red"

/obj/item/weapon/paper_bin/white
	crayon = "sterile"
	icon_state = "paper_bin_sterile"

/obj/item/weapon/paper_bin/yellow
	crayon = "yellow"
	icon_state = "paper_bin_yellow"

/obj/item/weapon/paper_bin/purple
	crayon = "purple"
	icon_state = "paper_bin_purple"

/obj/item/weapon/paper_bin/orange
	crayon = "orange"
	icon_state = "paper_bin_orange"

/obj/item/weapon/paper_bin/green
	crayon = "green"
	icon_state = "paper_bin_green"

/obj/item/weapon/paper_bin/rainbow
	crayon = "rainbow"
	icon_state = "paper_bin_rainbow"

/obj/item/weapon/paper_bin/mime
	crayon = "mime"
	icon_state = "paper_bin_mime"

/obj/item/weapon/paper_bin/decontaminate()
	..()
	crayon = "sterile"
	update_icon()

/obj/item/weapon/paper_bin/useThermalMass(var/used_mass)
	..()
	if(amount)
		var/burnt_papers = round((amount * 0.1)-(thermal_mass - initial_thermal_mass)) //0.1 = paper thermal_mass
		for(var/i in 1 to burnt_papers)
			var/obj/item/weapon/paper/P
			if(papers.len > 0)
				P = papers[papers.len]
				papers.Remove(P)
				qdel(P)
			amount--
	else
		update_icon()

/obj/item/weapon/paper_bin/Exited(atom/movable/Obj, atom/newloc)
	if(papers.Remove(Obj))
		amount--
		thermal_mass--
	..()

/obj/item/weapon/paper_bin/MouseDropFrom(atom/over_object)
	MouseDropPickUp(over_object)
	return ..()


/obj/item/weapon/paper_bin/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/paper_bin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--
		thermal_mass--

		var/obj/item/weapon/paper/P
		if(papers.len > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
		else
			P = new /obj/item/weapon/paper
			if(Holiday == APRIL_FOOLS_DAY)
				if(prob(30))
					P.info = "<font face=\"MS Comic Sans\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()
		update_icon()
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

	add_fingerprint(user)
	return

/obj/item/weapon/paper_bin/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/paper) && user.drop_item(I, src))
		to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		papers.Add(I)
		amount++
		thermal_mass++
		update_icon()
	else if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		crayon = C.colourName
		update_icon()
	else if (istype(I, /obj/item/weapon/soap))
		crayon = null
		update_icon()

/obj/item/weapon/paper_bin/examine(mob/user)
	..()
	if(amount)
		to_chat(user, "<span class='info'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>")
		/*
		if(papers.len > 0)
			var/obj/item/weapon/paper/P = papers[papers.len]
			if(istype(P,/obj/item/weapon/paper/talisman))
				if(iscultist(user) || isobserver(user))
					var/obj/item/weapon/paper/talisman/T = P
					switch(T.imbue)
						if("newtome")
							to_chat(user, "<span class='info'>You spot a Spawn Arcane Tome talisman on top.</span>")
						if("armor")
							to_chat(user, "<span class='info'>You spot a Cult Armor talisman on top.</span>")
						if("emp")
							to_chat(user, "<span class='info'>You spot an EMP talisman on top.</span>")
						if("conceal")
							to_chat(user, "<span class='info'>You spot an Hide Runes talisman on top.</span>")
						if("revealrunes")
							to_chat(user, "<span class='info'>You spot a Reveal Runes talisman on top.</span>")
						if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
							to_chat(user, "<span class='info'>You spot a Teleport talisman on top, linked to <i>[T.imbue]</i></span>")
						if("communicate")
							to_chat(user, "<span class='info'>You spot a Communicate talisman on top.</span>")
						if("deafen")
							to_chat(user, "<span class='info'>You spot a Deafen talisman on top.</span>")
						if("blind")
							to_chat(user, "<span class='info'>You spot a Blind talisman on top.</span>")
						if("runestun")
							to_chat(user, "<span class='info'>You spot a Stun talisman on top.</span>")
						if("supply")
							to_chat(user, "<span class='info'>You spot a Supply talisman on top.</span>")
						else
							to_chat(user, "<span class='info'>You spot a weird talisman on top.</span>")
				else
					to_chat(user, "<span class='info'>The paper on top has some bloody markings on it.</span>")
			else if(P.info)
				to_chat(user, "<span class='info'>You notice some writings on the top paper. <a HREF='?src=\ref[P];lookitem=\ref[user]'>Take a closer look.</a></span>")
			*/
	else
		to_chat(user, "<span class='info'>There are no papers in the bin.</span>")


/obj/item/weapon/paper_bin/update_icon()
	overlays.len = 0
	if(amount > 0)
		if(papers.len > 0)
			var/obj/item/weapon/paper/P = papers[papers.len]
			if(P.info)
				paper = image('icons/obj/bureaucracy.dmi', src, "paper_bin_words")
				overlays += paper
			else
				paper = image('icons/obj/bureaucracy.dmi', src, "paper_bin_blank")
				overlays += paper
		else
			paper = image('icons/obj/bureaucracy.dmi', src, "paper_bin_blank")
			overlays += paper
	else
		paper = null
		overlays += paper

	icon_state = "paper_bin_[crayon]"

/obj/item/weapon/paper_bin/empty
	amount = 0
