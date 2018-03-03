#define MAX_COPIES 10

/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	var/opened = 0
	var/obj/item/weapon/paper/copy = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/greytoggle = "Greyscale"
	var/mob/living/ass = null
	var/copying = 0

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/

/obj/machinery/photocopier/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/photocopier,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/photocopier/attack_ai(mob/user)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/proc/make_copy(mob/living/user)
	if(copying)
		to_chat(user, "<span class='warning'>\The [src] is busy with another print job.</span>")
		return

	if(copy)
		copies = Clamp(copies, 0, 10)
		spawn()
			copying = 1
			for(var/i = 0, i < copies, i++)
				if(!copying)
					break
				if(toner > 0)
					var/obj/item/weapon/paper/paper_type = copy.type
					var/obj/item/weapon/paper/c = new paper_type(loc)
					if(toner > 10)	//lots of toner, make it dark
						c.info = "<font color = #101010>"
					else			//no toner? shitty copies for you!
						c.info = "<font color = #808080>"
					var/copied = html_decode(copy.info)
					copied = replacetext(copied, "color:", "nocolor:")	//state of the art techniques in action
					c.info += copied
					c.info += "</font>"
					c.name = copy.name
					c.fields = copy.fields
					c.updateinfolinks()
					toner--
					sleep(15)
				else
					break
			copying = 0
		updateUsrDialog()
	else if(photocopy)
		copies = Clamp(copies, 0, 10)
		spawn()
			copying = 1
			for(var/i = 0, i < copies, i++)
				if(!copying)
					break
				if(toner >= 5)  //Was set to = 0, but if there was say 3 toner left and this ran, you would get -2 which would be weird for ink
					var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
					var/icon/I = icon(photocopy.icon, photocopy.icon_state)
					var/icon/img = icon(photocopy.img)
					if(greytoggle == "Greyscale")
						if(toner > 10) //plenty of toner, go straight greyscale
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0)) //I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
						else //not much toner left, lighten the photo
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
						toner -= 5	//photos use a lot of ink!
					else if(greytoggle == "Color")
						if(toner >= 10)
							toner -= 10 //Color photos use even more ink!
						else
							continue
					p.icon = I
					p.img = img
					p.name = photocopy.name
					p.desc = photocopy.desc
					p.scribble = photocopy.scribble
					p.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
					p.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
					p.blueprints = photocopy.blueprints //a copy of a picture is still good enough for the syndicate
					p.info = photocopy.info

					sleep(15)
				else
					break
			copying = 0
	else if(ass) //ASS COPY. By Miauw
		copies = Clamp(copies, 0, 10)
		spawn()
			copying = 1
			for(var/i = 0, i < copies, i++)
				if(!copying)
					break
				var/icon/temp_img
				if(ishuman(ass) && (ass.get_item_by_slot(slot_w_uniform) || ass.get_item_by_slot(slot_wear_suit)))
					to_chat(user, "<span class='notice'>You feel kind of silly copying [ass == user ? "your" : ass][ass == user ? "" : "\'s"] ass with [ass == user ? "your" : "their"] clothes on.</span>")
				else if(toner >= 5 && check_ass()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
					if(isalien(ass) || istype(ass,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
						temp_img = icon("icons/ass/assalien.png")
					else if(ishuman(ass) || istype(ass, /mob/living/simple_animal/hostile/gremlin)) //Suit checks are in check_ass
						if(ass.gender == MALE)
							temp_img = icon("icons/ass/assmale.png")
						else if(ass.gender == FEMALE)
							temp_img = icon("icons/ass/assfemale.png")
						else 									//In case anyone ever makes the generic ass. For now I'll be using male asses.
							temp_img = icon("icons/ass/assmale.png")
					else
						break
					var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
					p.info = "You see [ass]'s ass on the photo."
					p.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
					p.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
					p.img = temp_img
					var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
					var/icon/ic = icon('icons/obj/items.dmi',"photo")
					small_img.Scale(8, 8)
					ic.Blend(small_img,ICON_OVERLAY, 10, 13)
					p.icon = ic
					toner -= 5
					sleep(15)
				else
					break
			copying = 0
	updateUsrDialog()

/obj/machinery/photocopier/attack_hand(mob/user)
	user.set_machine(src)

	var/dat = "Photocopier<BR><BR>"
	if(copy || photocopy || (ass && (ass.loc == src.loc)))
		dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
			dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
			if(photocopy)
				dat += "Printing in <a href='byond://?src=\ref[src];colortoggle=1'>[greytoggle]</a><BR><BR>"
	else if(toner)
		dat += "Please insert paper to copy.<BR><BR>"
	if(istype(user,/mob/living/silicon/ai))
		dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	user << browse(dat, "window=copier")
	onclose(user, "copier")

/obj/machinery/photocopier/Topic(href, href_list)
	if(..())
		return
	if(href_list["copy"])
		make_copy(usr)
	else if(href_list["remove"])
		copying = 0
		if(copy)
			if(!istype(usr,/mob/living/silicon/ai)) //surprised this check didn't exist before, putting stuff in AI's hand is bad
				copy.forceMove(usr.loc)
				usr.put_in_hands(copy)
			else
				copy.forceMove(src.loc)
			to_chat(usr, "<span class='notice'>You take [copy] out of [src].</span>")
			copy = null
			updateUsrDialog()
		else if(photocopy)
			if(!istype(usr,/mob/living/silicon/ai)) //same with this one, wtf
				photocopy.forceMove(usr.loc)
				usr.put_in_hands(photocopy)
			else
				photocopy.forceMove(src.loc)
			to_chat(usr, "<span class='notice'>You take [photocopy] out of [src].</span>")
			photocopy = null
			updateUsrDialog()
		else if(check_ass())
			to_chat(ass, "<span class='notice'>You feel a slight pressure on your ass.</span>")
	else if(href_list["min"])
		if(copying)
			if(!alert("Cancel current print job?","","Yes","No") == "Yes")
				to_chat(usr, "<span class='warning'>Must wait for current print job to finish.</span>")
				return
			copying = 0
		if(copies > 1)
			copies--
			updateUsrDialog()
	else if(href_list["add"])
		if(copying)
			if(!alert("Cancel current print job?","","Yes","No") == "Yes")
				to_chat(usr, "<span class='warning'>Must wait for current print job to finish.</span>")
				return
			copying = 0
		if(copies < maxcopies)
			copies++
			updateUsrDialog()
	else if(href_list["aipic"])
		if(copying)
			if(!alert("Cancel current print job?","","Yes","No") == "Yes")
				to_chat(usr, "<span class='warning'>Must wait for current print job to finish.</span>")
				return
			copying = 0
		if(!istype(usr,/mob/living/silicon/ai))
			return
		if(toner >= 5)
			var/list/nametemp = list()
			var/find
			var/datum/picture/selection
			var/mob/living/silicon/ai/tempAI = usr
			if(tempAI.aicamera.aipictures.len == 0)
				to_chat(usr, "<font color=red><B>No images saved<B></font>")
				return
			for(var/datum/picture/t in tempAI.aicamera.aipictures)
				nametemp += t.fields["name"]
			find = input("Select image") in nametemp
			var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
			for(var/datum/picture/q in tempAI.aicamera.aipictures)
				if(q.fields["name"] == find)
					selection = q
					break
			var/icon/I = selection.fields["icon"]
			var/icon/img = selection.fields["img"]
			p.icon = I
			p.img = img
			p.desc = selection.fields["desc"]
			p.blueprints = selection.fields["blueprints"]
			p.pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
			p.pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
			toner -= 5	 //AI prints color pictures only, thus they can do it more efficiently
			sleep(15)
		updateUsrDialog()
	else if(href_list["colortoggle"])
		if(copying)
			if(!alert("Cancel current print job?","","Yes","No") == "Yes")
				to_chat(usr, "<span class='warning'>Must wait for current print job to finish.</span>")
				return
			copying = 0
		if(greytoggle == "Greyscale")
			greytoggle = "Color"
		else
			greytoggle = "Greyscale"
		updateUsrDialog()

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(copying)
		if(!alert("Cancel current print job?","","Yes","No") == "Yes")
			to_chat(usr, "<span class='warning'>Must wait for current print job to finish.</span>")
			return
		copying = 0
	if(istype(O, /obj/item/weapon/paper))
		if(copier_empty())
			if(user.drop_item(O, src))
				copy = O
				to_chat(user, "<span class='notice'>You insert [O] into [src].</span>")
				flick("bigscanner1", src)
				updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in [src].</span>")
	else if(istype(O, /obj/item/weapon/photo))
		if(copier_empty())
			if(user.drop_item(O, src))
				photocopy = O
				to_chat(user, "<span class='notice'>You insert [O] into [src].</span>")
				flick("bigscanner1", src)
				updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in [src].</span>")
	else if(istype(O, /obj/item/device/toner))
		if(toner <= 0)
			if(user.drop_item(O))
				qdel(O)
				toner = 40
				to_chat(user, "<span class='notice'>You insert [O] into [src].</span>")
				updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(iswrench(O))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] [src].</span>")
	else if(istype(O, /obj/item/weapon/grab)) //For ass-copying.
		var/obj/item/weapon/grab/G = O
		if(ismob(G.affecting) && G.affecting != ass)
			var/mob/GM = G.affecting
			if(GM.locked_to)
				return
			visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
			GM.forceMove(get_turf(src))
			ass = GM
			if(photocopy)
				photocopy.forceMove(src.loc)
				photocopy = null
			else if(copy)
				copy.forceMove(src.loc)
				copy = null
			updateUsrDialog()
	else if(isscrewdriver(O))
		if(anchored)
			to_chat(user, "[src] needs to be unanchored.")
			return
		if(!opened)
			src.opened = 1
			//src.icon_state = "photocopier_t"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			src.opened = 0
			//src.icon_state = "photocopier"
			to_chat(user, "You close the maintenance hatch of [src].")
		return 1
	if(opened)
		if(iscrowbar(O))
			to_chat(user, "You begin to remove the circuits from the [src].")
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			if(do_after(user, src, 50))
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 1
				M.set_build_state(2)
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.forceMove(src.loc)
				qdel(src)
				return 1
	return

/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else
				if(toner > 0)
					var/obj/effect/decal/cleanable/blood/oil/O = getFromPool(/obj/effect/decal/cleanable/blood/oil, get_turf(src))
					O.New(O.loc)
					toner = 0
		else
			if(prob(50))
				if(toner > 0)
					var/obj/effect/decal/cleanable/blood/oil/O = getFromPool(/obj/effect/decal/cleanable/blood/oil, get_turf(src))
					O.New(O.loc)
					toner = 0
	return

/obj/machinery/photocopier/blob_act()
	if(prob(50))
		qdel(src)
	else
		if(toner > 0)
			var/obj/effect/decal/cleanable/blood/oil/O = getFromPool(/obj/effect/decal/cleanable/blood/oil, get_turf(src))
			O.New(O.loc)
			toner = 0
	return

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if (!istype(target) || target.locked_to || !Adjacent(user) || !user.Adjacent(target) || user.stat || istype(user, /mob/living/silicon/ai) || target == ass || copier_blocked(user))
		return
	src.add_fingerprint(user)
	if(target == user && !(user.incapacitated()))
		visible_message("<span class='warning'>[usr] jumps onto the photocopier!</span>")
	else if(target != user && !user.incapacitated())
		if(target.anchored)
			return
		if(!ishigherbeing(user) && !ismonkey(user))
			return
		visible_message("<span class='warning'>[usr] drags [target.name] onto the photocopier!</span>")
	target.forceMove(get_turf(src))
	ass = target
	if(photocopy)
		photocopy.forceMove(src.loc)
		visible_message("<span class='notice'>[photocopy] is shoved out of the way by [ass]!</span>")
		photocopy = null
	else if(copy)
		copy.forceMove(src.loc)
		visible_message("<span class='notice'>[copy] is shoved out of the way by [ass]!</span>")
		copy = null
	updateUsrDialog()

/obj/machinery/photocopier/npc_tamper_act(mob/living/L)
	//Make a photocopy of the gremlin's ass
	MouseDrop_T(L, L)
	copies = rand(1, MAX_COPIES)
	make_copy(L)

/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return 0
	if(ass.loc != src.loc)
		ass = null
		updateUsrDialog()
		return 0
	else if(istype(ass,/mob/living/carbon/human))
		if(!ass.get_item_by_slot(slot_w_uniform) && !ass.get_item_by_slot(slot_wear_suit))
			return 1
		else
			return 0
	else
		return 1

/obj/machinery/photocopier/proc/copier_empty()
	if(copy || photocopy || check_ass())
		return 0
	else
		return 1

/*
 * Toner cartridge
 */
/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	var/charges = 5
	var/max_charges = 5

/obj/machinery/photocopier/proc/copier_blocked(var/mob/user)
	if(gcDestroyed)
		return
	if(loc.density)
		return 1
	for(var/atom/movable/AM in loc)
		if(AM == src)
			continue
		if(AM.density)
			if(AM.flow_flags&ON_BORDER)
				if(!AM.Cross(user, src.loc))
					return 1
			else
				return 1
	return 0

/obj/machinery/photocopier/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1

	return (!mover.density || !density || mover.pass_flags)

#undef MAX_COPIES
