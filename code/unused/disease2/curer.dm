/obj/machinery/computer/curer
	name = "Cure Research Machine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
//	brightnessred = 0
//	brightnessgreen = 2 //Used for multicoloured lighting on BS12
//	brightnessblue = 2
	var/curing
	var/virusing
	circuit = "/obj/item/weapon/circuitboard/mining"

	var/obj/item/weapon/virusdish/dish = null

/obj/machinery/computer/curer/attackby(var/obj/I as obj, var/mob/user as mob)
	/*if(istype(I, /obj/item/weapon/screwdriver))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, src, 20))
			if (stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				new /obj/item/weapon/shard( loc )
				var/obj/item/weapon/circuitboard/curer/M = new /obj/item/weapon/circuitboard/curer( A )
				for (var/obj/C in src)
					C.loc = loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				var/obj/item/weapon/circuitboard/curer/M = new /obj/item/weapon/circuitboard/curer( A )
				for (var/obj/C in src)
					C.loc = loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)*/
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)

			dish = I
			c.drop_item()
			I.loc = src

	//else
	attack_hand(user)
	return

/obj/machinery/computer/curer/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/curer/attack_paw(var/mob/user as mob)

	return attack_hand(user)
	return

/obj/machinery/computer/curer/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	if(curing)
		dat = "Antibody production in progress"
	else if(virusing)
		dat = "Virus production in progress"
	else if(dish)
		dat = "Virus dish inserted"
		if(dish.virus2)
			if(dish.growth >= 100)
				dat += "<BR><A href='?src=\ref[src];antibody=1'>Begin antibody production</a>"
				dat += "<BR><A href='?src=\ref[src];virus=1'>Begin virus production</a>"
			else
				dat += "<BR>Insufficent cells to attempt to create cure"
		else
			dat += "<BR>Please check dish contents"

		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject disk</a>"
	else
		dat = "Please insert dish"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/curer/process()
	..()

	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	updateDialog()

	if(curing)
		curing -= 1
		if(curing == 0)
			icon_state = "dna"
			if(dish.virus2)
				createcure(dish.virus2)
	if(virusing)
		virusing -= 1
		if(virusing == 0)
			icon_state = "dna"
			if(dish.virus2)
				createvirus(dish.virus2)

	return

/obj/machinery/computer/curer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["antibody"])
			curing = 30
			dish.growth -= 50
			icon_state = "dna"
		if (href_list["virus"])
			virusing = 30
			dish.growth -= 100
			icon_state = "dna"
		else if(href_list["eject"])
			dish.loc = loc
			dish = null

		add_fingerprint(usr)
	updateUsrDialog()
	return


/obj/machinery/computer/curer/proc/createcure(var/datum/disease2/disease/virus2)
	var/obj/item/weapon/cureimplanter/implanter = new /obj/item/weapon/cureimplanter(loc)
	implanter.resistance = new /datum/disease2/resistance(dish.virus2)
	if(probG("Virus curing",3))
		implanter.works = 0
	else
		implanter.works = rand(1,2)
	state("The [name] Buzzes")

/obj/machinery/computer/curer/proc/createvirus(var/datum/disease2/disease/virus2)
	var/obj/item/weapon/cureimplanter/implanter = new /obj/item/weapon/cureimplanter(loc)
	implanter.name = "Viral implanter (MAJOR BIOHAZARD)"
	implanter.virus2 = dish.virus2.getcopy()
	implanter.works = 3
	state("The [name] Buzzes")


/obj/machinery/computer/curer/proc/state(var/msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("[bicon(src)] <span class='notice'>[msg]</span>", 2)
