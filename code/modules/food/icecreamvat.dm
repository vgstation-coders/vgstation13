
//**************************************************************
//
// Ice Cream Machine
// ---------------------
// Original code by Sawu of Sawustation.
//
//**************************************************************

// Base ////////////////////////////////////////////////////////

/obj/machinery/cooking/icemachine
	name = "Cream-Master Deluxe"
	icon_state = "icecream_vat"
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/datum/reagents/to_add
	var/soda
	var/alcohol

/obj/machinery/cooking/icemachine/New()
	create_reagents(500)
	flags |= NOREACT
	to_add = new/datum/reagents(30)
	to_add.my_atom = src
	soda = pick(COLA,DR_GIBB,SPACE_UP,SPACEMOUNTAINWIND)
	alcohol = pick(KAHLUA,VODKA,RUM,GIN)
	generate_icecream_reagents(51)
	..()

/obj/machinery/cooking/icemachine/Destroy()
	qdel(beaker)
	beaker = null
	qdel(to_add)
	to_add = null
	..()

// Utilities ///////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/proc/generate_icecream_reagents(var/reagent_total)
	reagents.add_reagent(soda, min(reagent_total-reagents.get_reagent_amount(soda), reagent_total))
	reagents.add_reagent(alcohol, min(reagent_total-reagents.get_reagent_amount(alcohol), reagent_total))
	reagents.add_reagent(CREAM, min(reagent_total-reagents.get_reagent_amount(CREAM), reagent_total))
	reagents.add_reagent(ICE, min(reagent_total-reagents.get_reagent_amount(ICE), reagent_total), T0C)
	reagents.add_reagent(NUTRIMENT, min(reagent_total-reagents.get_reagent_amount(NUTRIMENT), reagent_total))
	reagents.add_reagent(SPRINKLES, min(reagent_total-reagents.get_reagent_amount(SPRINKLES), reagent_total))

/obj/machinery/cooking/icemachine/proc/generateName(reagentName)
	. = pick("Mr. ","Mrs. ","Super ","Happy ","Whippy ")
	. += pick("Whippy","Slappy","Creamy","Dippy","Swirly","Swirl")
	if (reagentName)
		. += " [reagentName]"

// Processing //////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/takeIngredient(var/obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>The [name] already has a beaker.</span>")
			return

		if(I.w_class > W_CLASS_SMALL)
			to_chat(user, "<span class='warning'>\The [I] is too big to fit.</span>")
			return

		if(user.drop_item(I, src))
			beaker = I
			. = 1
			to_chat(user, "<span class='notice'>You add the [I.name] to the [name].</span>")
			updateUsrDialog()

	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/icecream))
		if(!I.reagents.has_reagent(SPRINKLES) && reagents.has_reagent(SPRINKLES))
			reagents.trans_id_to(I, SPRINKLES, 1)
			to_chat(user, "<span class = 'notice'>You add sprinkles to \the [I].</span>")
			I.overlays += image('icons/obj/kitchen.dmi',src,SPRINKLES)
			I.name += " with sprinkles"
			I.desc += " It has sprinkles on top."
			. = 1
		else
			to_chat(user, "<span class='warning'>The [I.name] already has sprinkles.</span>")
			return

// Interactions ////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/cooking/icemachine/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/cooking/icemachine/attack_hand(mob/user)
	if(istype(user,/mob/dead/observer))
		to_chat(user, "Your ghostly hand goes straight through.")
	user.set_machine(src)
	var/dat = ""
	if(beaker)
		dat += "<A href='?src=\ref[src];eject=1'>Eject container and end transfer.</A><BR>"
		if(!beaker.reagents.total_volume)
			dat += "Container is empty.<BR><HR>"
		else
			dat += showReagents(1)
		dat += showReagents(2)
		dat += showReagents(3)
		dat += showToppings()
	else
		dat += "No container is loaded into the machine, external transfer offline.<BR>"
		dat += showReagents(2)
		dat += showReagents(3)
		dat += showToppings()
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	var/datum/browser/popup = new(user,"cream_master","Cream-Master Deluxe",700,400,src)
	popup.set_content(dat)
	popup.open()

// HTML Menu ///////////////////////////////////////////////////

/obj/machinery/cooking/icemachine/Topic(href,href_list)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["close"])
		usr << browse(null,"window=cream_master")
		usr.unset_machine()

	else if(href_list["add"] && href_list["amount"] && beaker)
		var/id = href_list["add"]
		var/amount = text2num(href_list["amount"])
		if(amount > 0)
			if(reagents.has_reagent(id))
				beaker.reagents.trans_id_to(src,id,amount)
			else
				beaker.reagents.trans_id_to(to_add,id,amount)

	else if(href_list["remove"] && href_list["amount"])
		var/id = href_list["remove"]
		var/amount = text2num(href_list["amount"])
		if(reagents.has_reagent(id))
			if(beaker)
				to_add.trans_id_to(beaker,id,amount)
			else
				to_add.trans_id_to(reagents,id,amount)

	else if(href_list["main"])
		attack_hand(usr)

	else if(href_list["eject"] && beaker)
		to_add.trans_to(beaker,to_add.total_volume)
		beaker.forceMove(loc)
		beaker = null

	else if(href_list["synthcond"] && href_list["type"])
		switch(text2num(href_list["type"]))
			if(2)
				for(var/id in list(COLA,DR_GIBB,SPACE_UP,SPACEMOUNTAINWIND))
					if(reagents.has_reagent(id))
						. = id
						break
			if(3)
				for(var/id in list(KAHLUA,VODKA,RUM,GIN))
					if(reagents.has_reagent(id))
						. = id
						break
			if(4)
				. = CREAM
			if(5)
				. = ICE
		if(reagents.has_reagent(.,6))
			reagents.trans_id_to(to_add, .,5)
		else
			to_chat(usr, "<span class = 'warning'>\The [src] does not have enough of [.]!</span>")

	else if(href_list["createcup"] || href_list["createcone"])
		if(!reagents.has_reagent(NUTRIMENT, 5))
			to_chat(usr, "<span class = 'warning'>There is not enough nutrient to create an ice cream cone!</span>")
			return
		reagents.remove_reagent(NUTRIMENT, 5)
		var/obj/item/weapon/reagent_containers/food/C
		if(href_list["createcup"])
			C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup(loc)
		else
			C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone(loc)
		C.name = "[generateName(to_add.get_master_reagent_name())] [C.name]"
		C.pixel_x = rand(-8,8) * PIXEL_MULTIPLIER
		C.pixel_y = -16 * PIXEL_MULTIPLIER
		to_add.trans_to(C,30)
		to_add.clear_reagents()
		C.update_icon()

	updateUsrDialog()
	return

/obj/machinery/cooking/icemachine/proc/showToppings()
	var/dat = ""
	if(to_add.total_volume <= 30)
		dat += "<HR>"
		dat += "<strong>Add fillings:</strong><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=2'>Soda</A><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=3'>Alcohol</A><BR>"
		dat += "<strong>Finish With:</strong><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=4'>Cream</A><BR>"
		dat += "<A href='?src=\ref[src];synthcond=1;type=5'>Ice</A><BR>"
		dat += "<strong>Dispense in:</strong><BR>"
	dat += "<A href='?src=\ref[src];createcup=1'>Chocolate Cone</A><BR>"
	dat += "<A href='?src=\ref[src];createcone=1'>Cone</A><BR>"
	dat += "</center>"
	return dat

/obj/machinery/cooking/icemachine/proc/showReagents(container)
	//1 = beaker / 2 = reagents added to the ice cream
	var/dat = ""
	if(container == 1)
		dat += "The container has:<BR>"
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			dat += "[R.volume] unit(s) of [R.name] | "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=5'>(5)</A> "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=10'>(10)</A> "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=15'>(15)</A> "
			dat += "<A href='?src=\ref[src];add=[R.id];amount=[R.volume]'>(All)</A>"
			dat += "<BR>"
	else if(container == 2)
		dat += "<BR>\The [src] will add to the ice cream:<BR>"
		if(to_add.total_volume)
			for(var/datum/reagent/R in to_add.reagent_list)
				dat += "[R.volume] unit(s) of [R.name] | "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=15'>(15)</A> "
				dat += "<A href='?src=\ref[src];remove=[R.id];amount=[R.volume]'>(All)</A>"
				dat += "<BR>"
		else
			dat += "No reagents. <BR>"
	else if(container == 3)
		dat += "<BR>\The [src] contains:<BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/R in reagents.reagent_list)
				dat += "[R.volume-1] unit(s) of [R.name] | "
				dat += "<BR>"
		else
			dat += "Nothing. Please report to Whippy Inc. for a refill package.<BR>"
	else
		dat += "<BR>INVALID REAGENT CONTAINER. Make a bug report.<BR>"
	return dat
