/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 10
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = new/list()	//List of papers put in the bin for reference.

	autoignition_temperature = 519.15 // Kelvin


/obj/item/weapon/paper_bin/ignite()
	if(amount || papers.len)
		..()

/obj/item/weapon/paper_bin/ashify()
	if(!on_fire)
		return
	if(amount || papers.len)
		var/ashtype = ashtype()
		new ashtype(src.loc)
		amount = 0
		for(var/obj/item/weapon/paper/p in papers)
			qdel(p)
		papers = list() //In case somehow there's still something in it
	extinguish()
	update_icon()

/obj/item/weapon/paper_bin/getFireFuel()
	return amount + papers.len

/obj/item/weapon/paper_bin/Exited(atom/movable/Obj, atom/newloc)
	papers -= Obj
	..()

/obj/item/weapon/paper_bin/MouseDropFrom(atom/over_object)
	MouseDropPickUp(over_object)
	return ..()


/obj/item/weapon/paper_bin/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/paper_bin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--

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
		P.forceMove(user.loc)
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

	add_fingerprint(user)
	return


/obj/item/weapon/paper_bin/attackby(obj/item/weapon/paper/i as obj, mob/user as mob)
	if(!istype(i))
		return

	if(user.drop_item(i, src))
		to_chat(user, "<span class='notice'>You put [i] in [src].</span>")
		papers.Add(i)
		amount++
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
				to_chat(user, "<span class='info'>You notice some writings on the top paper. <a HREF='?src=\ref[user];lookitem=\ref[P]'>Take a closer look.</a></span>")
			*/
	else
		to_chat(user, "<span class='info'>There are no papers in the bin.</span>")


/obj/item/weapon/paper_bin/update_icon()
	if(amount > 0)
		if(papers.len > 0)
			var/obj/item/weapon/paper/P = papers[papers.len]
			if(P.info)
				icon_state = "paper_bin2"
			else
				icon_state = "paper_bin1"
		else
			icon_state = "paper_bin1"
	else
		icon_state = "paper_bin0"

/obj/item/weapon/paper_bin/empty
	icon_state = "paper_bin0"
	amount = 0
