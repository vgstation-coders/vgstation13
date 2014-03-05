/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_combined_w_class = 16

/obj/item/weapon/storage/briefcase/New()
	new /obj/item/weapon/paper/demotion_key(src)
	new /obj/item/weapon/paper/commendation_key(src)
	..()

/obj/item/weapon/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	//..()

	if ((M_CLUMSY in user.mutations) && prob(50))
		user << "<span class=\"rose\">The [src] slips out of your hand and hits your head.</span>"
		user.take_organ_damage(10)
		user.Paralyse(2)
		return


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "<span class=\"rose\">The helmet protects you from being hit hard in the head!</span>"
			return
		var/time = rand(2, 6)
		if (prob(75))
			M.Paralyse(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class=\"danger\">[] has been knocked unconscious!</span>", M), 1, "<span class=\"rose\">You hear someone fall.</span>", 2)
	else
		M << text("<span class=\"rose\">[] tried to knock you unconcious!</span>",user)
		M.eye_blurry += 3

	return
