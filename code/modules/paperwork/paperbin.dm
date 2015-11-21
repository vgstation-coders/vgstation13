/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 10
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = new/list()	//List of papers put in the bin for reference.

	autoignition_temperature = 519.15 // Kelvin


/obj/item/weapon/paper_bin/ashify()
	new ashtype(src.loc)
	papers=0
	amount=0
	update_icon()

/obj/item/weapon/paper_bin/getFireFuel()
	return amount

/obj/item/weapon/paper_bin/MouseDrop(over_object)
	if(!usr.restrained() && !usr.stat && (usr.contents.Find(src) || Adjacent(usr)))
		if(!istype(usr, /mob/living/carbon/slime) && !istype(usr, /mob/living/simple_animal))
			if(istype(over_object,/obj/screen)) //We're being dragged into the user's UI...
				var/obj/screen/O = over_object
				switch(O.name)
					if("r_hand") //We're dragging and dropping over the user's hand slot!
						usr.u_equip(src,0)
						usr.put_in_r_hand(src)
					if("l_hand")
						usr.u_equip(src,0)
						usr.put_in_l_hand(src)
			else if(istype(over_object,/mob/living)) //We're being dragged on a living mob's sprite...
				if(usr == over_object) //It's the user!
					if( !usr.get_active_hand() )		//if active hand is empty
						usr.put_in_hands(src)
						usr.visible_message("<span class='notice'>[usr] picks up the [src].</span>", "<span class='notice'>You pick up \the [src].</span>")
	return


/obj/item/weapon/paper_bin/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/paper_bin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon()

		var/obj/item/weapon/paper/P
		if(papers.len > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
		else
			P = new /obj/item/weapon/paper
			if(Holiday == "April Fool's Day")
				if(prob(30))
					P.info = "<font face=\"MS Comic Sans\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()

		P.loc = user.loc
		user.put_in_hands(P)
		user << "<span class='notice'>You take [P] out of the [src].</span>"
	else
		user << "<span class='notice'>[src] is empty!</span>"

	add_fingerprint(user)
	return


/obj/item/weapon/paper_bin/attackby(obj/item/weapon/paper/i as obj, mob/user as mob)
	if(!istype(i))
		return

	user.drop_item(i, src)
	user << "<span class='notice'>You put [i] in [src].</span>"
	papers.Add(i)
	amount++
	update_icon()


/obj/item/weapon/paper_bin/examine(mob/user)
	..()
	if(amount)
		user << "<span class='info'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>"
	else
		user << "<span class='info'>There are no papers in the bin.</span>"


/obj/item/weapon/paper_bin/update_icon()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"

/obj/item/weapon/paper_bin/empty
	icon_state = "paper_bin0"
	amount = 0
