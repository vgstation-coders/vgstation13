/*
CONTAINS:
SAFES
FLOOR SAFES
*/

//SAFES
/obj/structure/safe
	name = "safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = 1
	density = 1
	var/open = 0		//is the safe open?
	var/tumbler_1_pos	//the tumbler position- from 0 to 72
	var/tumbler_1_open	//the tumbler position to open at- 0 to 72
	var/tumbler_2_pos
	var/tumbler_2_open
	var/dial = 0		//where is the dial pointing?
	var/space = 0		//the combined w_class of everything in the safe
	var/maxspace = 48	//the maximum combined w_class of stuff in the safe


/obj/structure/safe/New()
	tumbler_1_pos = rand(0, 71)
	tumbler_1_open = rand(2, 71)

	tumbler_2_pos = rand(0, 71)
	tumbler_2_open = rand(2, 71)

/obj/structure/safe/initialize()
	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.forceMove(src)

/obj/structure/safe/proc/check_unlocked(mob/user as mob, canhear)
	if(user && canhear)
		if(tumbler_1_pos == tumbler_1_open)
			to_chat(user, "<span class='notice'>You hear a [pick("tonk", "krunk", "plunk")] from [src].</span>")
		if(tumbler_2_pos == tumbler_2_open)
			to_chat(user, "<span class='notice'>You hear a [pick("tink", "krink", "plink")] from [src].</span>")
	if(tumbler_1_pos == tumbler_1_open && tumbler_2_pos == tumbler_2_open)
		if(user)
			visible_message("<b>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</b>")
		return 1
	return 0


/obj/structure/safe/proc/decrement(num)
	num -= 1
	if(num < 0)
		num = 71
	return num


/obj/structure/safe/proc/increment(num)
	num += 1
	if(num > 71)
		num = 0
	return num


/obj/structure/safe/update_icon()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)


/obj/structure/safe/attack_hand(mob/user,params,proximity)
	user.set_machine(src)

	var/dat = {"<center>
<a href='?src=\ref[src];open=1'>[open ? "Close" : "Open"] [src]</a> | <a href='?src=\ref[src];decrement=1'>-</a> [dial * 5] <a href='?src=\ref[src];increment=1'>+</a>"}
	if(open)
		dat += "<table>"
		for(var/i = contents.len, i>=1, i--)
			var/obj/item/P = contents[i]
			dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[P]'>[P.name]</a></td></tr>"
		dat += "</table></center>"
	user << browse("<html><head><title>[name]</title></head><body>[dat]</body></html>", "window=safe;size=350x300")
	onclose(user, "safe")


/obj/structure/safe/Topic(href, href_list)
	if(!ishigherbeing(usr))
		return
	var/mob/living/carbon/human/user = usr
	var/canhear = 0
	if(Adjacent(user) && user.find_held_item_by_type(/obj/item/clothing/accessory/stethoscope))
		canhear = 1

	if(href_list["open"])
		if(check_unlocked())
			to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
			open = !open
			update_icon()
			updateUsrDialog()
			return
		else
			to_chat(user, "<span class='notice'>You can't [open ? "close" : "open"] [src], the lock is engaged!</span>")
			return

	if(href_list["decrement"])
		dial = decrement(dial)
		if(dial == tumbler_1_pos + 1 || dial == tumbler_1_pos - 71)
			tumbler_1_pos = decrement(tumbler_1_pos)
			if(canhear)
				to_chat(user, "<span class='notice'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>")
			if(tumbler_1_pos == tumbler_2_pos + 37 || tumbler_1_pos == tumbler_2_pos - 35)
				tumbler_2_pos = decrement(tumbler_2_pos)
				if(canhear)
					to_chat(user, "<span class='notice'>You hear a [pick("click", "chink", "clink")] from [src].</span>")
			check_unlocked(user, canhear)
		updateUsrDialog()
		return

	if(href_list["increment"])
		dial = increment(dial)
		if(dial == tumbler_1_pos - 1 || dial == tumbler_1_pos + 71)
			tumbler_1_pos = increment(tumbler_1_pos)
			if(canhear)
				to_chat(user, "<span class='notice'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>")
			if(tumbler_1_pos == tumbler_2_pos - 37 || tumbler_1_pos == tumbler_2_pos + 35)
				tumbler_2_pos = increment(tumbler_2_pos)
				if(canhear)
					to_chat(user, "<span class='notice'>You hear a [pick("click", "chink", "clink")] from [src].</span>")
			check_unlocked(user, canhear)
		updateUsrDialog()
		return

	if(href_list["retrieve"])
		user << browse("", "window=safe") // Close the menu

		var/obj/item/P = locate(href_list["retrieve"]) in src
		if(open)
			if(P && in_range(src, user))
				user.put_in_hands(P)
				updateUsrDialog()


/obj/structure/safe/attackby(obj/item/I as obj, mob/user as mob)
	if(open)
		if(I.w_class + space <= maxspace)
			if(user.drop_item(I, src))
				space += I.w_class
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
				updateUsrDialog()
			return
		else
			to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
			return
	else
		if(istype(I, /obj/item/clothing/accessory/stethoscope))
			to_chat(user, "Hold [I] in one of your hands while you manipulate the dial.")
			return


obj/structure/safe/blob_act()
	return


obj/structure/safe/ex_act(severity)
	return

//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = 0
	level = 1	//underfloor
	layer = BELOW_OBJ_LAYER


/obj/structure/safe/floor/initialize()
	..()
	var/turf/T = loc
	hide(T.intact)


/obj/structure/safe/floor/hide(var/intact)
	invisibility = intact ? 101 : 0

/obj/structure/safe/floor/wizard	//Given that these are so difficult to open, and only spawn in wizard dens, they should have some good loot.
	var/list/loot_list = list(
		/obj/item/weapon/spellbook/oneuse/fireball,
		/obj/item/weapon/spellbook/oneuse/smoke,
		/obj/item/weapon/spellbook/oneuse/blind,
		/obj/item/weapon/spellbook/oneuse/disorient,
		/obj/item/weapon/spellbook/oneuse/mindswap,
		/obj/item/weapon/spellbook/oneuse/forcewall,
		/obj/item/weapon/spellbook/oneuse/teleport/blink,
		/obj/item/weapon/spellbook/oneuse/knock,
		/obj/item/weapon/spellbook/oneuse/horsemask,
		/obj/item/weapon/spellbook/oneuse/clown,
		/obj/item/weapon/spellbook/oneuse/mime,
		/obj/item/weapon/spellbook/oneuse/shoesnatch,
		/obj/item/weapon/spellbook/oneuse/bound_object,
		/obj/item/weapon/gun/energy/staff/change,
		/obj/item/weapon/gun/energy/staff/animate,
		/obj/item/weapon/gun/energy/staff/focus,
		/obj/item/weapon/storage/box/smartbox/clothing_box/gemsuit,
		)

/obj/structure/safe/floor/wizard/New()
	..()
	var/I = pick(loot_list)
	new I(src)
