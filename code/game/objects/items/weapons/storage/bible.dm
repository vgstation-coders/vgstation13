/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
//vg13 EDIT
// All cult functionality moved to Null Rod
/obj/item/weapon/storage/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 40
		for(var/datum/organ/external/affecting in H.organs)
			if(affecting.heal_damage(heal_amt, heal_amt))
				H.UpdateDamageIcon()
	return

/obj/item/weapon/storage/bible/attack(mob/living/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class=\"rose\">You don't have the dexterity to do this!</span>"
		return
	if(!chaplain)
		user << "<span class=\"rose\">The book sizzles in your hands.</span>"
		user.take_organ_damage(0,10)
		return

	if ((M_CLUMSY in user.mutations) && prob(50))
		user << "<span class=\"rose\">The [src] slips out of your hand and hits your head.</span>"
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if(M.mind && (M.mind.assigned_role == "Chaplain"))
			user << "<span class=\"rose\">You can't heal yourself!</span>"
			return
		if((M.mind in ticker.mode.cult && !(M.mind in ticker.mode.modePlayer)) && (prob(20))) // can't deconvert originals - Pomf
			M << "<span class=\"rose\">The power of [src.deity_name] clears your mind of heresy!</span>"
			user << "<span class=\"rose\">You see how [M]'s eyes become clear, the cult no longer holds control over him!</span>"
			ticker.mode.remove_cultist(M.mind)
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class=\"danger\">[] heals [] with the power of [src.deity_name]!</span>", user, M), 1)
			M << "<span class=\"rose\">May the power of [src.deity_name] compel you to be healed!</span>"
			playsound(get_turf(src), "punch", 25, 1, -1)
		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				M << "<span class=\"rose\">You feel dumber.</span>"
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class=\"danger\">[] beats [] over the head with []!</span>", user, M, src), 1)
			playsound(get_turf(src), "punch", 25, 1, -1)
	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class=\"danger\">[] smacks []'s lifeless corpse with [].</span>", user, M, src), 1)
		playsound(get_turf(src), "punch", 25, 1, -1)
	return

/obj/item/weapon/storage/bible/afterattack(atom/A, mob/user as mob)
/*	if (istype(A, /turf/simulated/floor))
		user << "<span class=\"notice\">You hit the floor with the bible.</span>"
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)*/
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			user << "<span class=\"notice\">You bless [A].</span>"
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(get_turf(src), "rustle", 50, 1, -5)
	..()
