// Making fuse bombs
/obj/item/cannonball/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/tool/surgicaldrill/diamond))
		var/obj/item/cannonball/fuse_bomb/F = new /obj/item/cannonball/fuse_bomb
		F.assembled = 0
		user.put_in_hands(F)
		to_chat(user, "<span  class='notice'>You drill a hole in the [src] with the [I].</span>")
		qdel(src)
		
/obj/item/cannonball/fuse_bomb
	name = "fuse bomb"
	desc = "fshhhhhhhh BOOM!"
	icon = 'icons/obj/device.dmi'
	icon_state = "fuse_bomb_5"
	item_state = "fuse_bomb"
	flags = FPRINT
	var/assembled = 2
	var/fuse_lit = 0
	var/seconds_left = 5

/obj/item/cannonball/fuse_bomb/New()
	..()
	if(assembled == 0)
		name = "empty fuse bomb assembly"
		desc = "Just add fire. And fuel."
		update_icon()

/obj/item/cannonball/fuse_bomb/admin//spawned by the adminbus, doesn't send an admin message, but the logs are still kept.

/obj/item/cannonball/fuse_bomb/attack_self(mob/user as mob)
	if(!fuse_lit)
		lit(user)
	else
		fuse_lit = 0
		update_icon()
		to_chat(user, "<span class='warning'>You extinguish the fuse with [seconds_left] seconds left!</span>")
	return

/obj/item/cannonball/fuse_bomb/afterattack(atom/target, mob/user , flag) //Filling up the bomb
	if(assembled == 0)
		if(istype(target, /obj/structure/reagent_dispensers/fueltank) && target.Adjacent(user))
			if(target.reagents.total_volume < 200)
				to_chat(user, "<span  class='notice'>There's not enough fuel left to work with.</span>")
				return
			var/obj/structure/reagent_dispensers/fueltank/F = target
			F.reagents.remove_reagent(FUEL, 200, 1)//Deleting 200 fuel from the welding fuel tank,
			assembled = 1
			to_chat(user, "<span  class='notice'>You've filled the [src] with welding fuel.</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
			name = "fuse bomb assembly"
			desc = "Just add fire."
			return

/obj/item/cannonball/fuse_bomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(assembled == 1)
		if(istype(I, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = I
			C.use(1)
			assembled = 2
			to_chat(user, "<span  class='notice'>You wire the [src].</span>")
			name = "fuse bomb"
			desc = "fshhhhhhhh BOOM!"
			update_icon()
	else if(assembled == 2)
		if(!fuse_lit)
			if(iswelder(W))
				var/obj/item/tool/weldingtool/WT = W
				if(WT.isOn())
					lit(user,W)
			else if(istype(W, /obj/item/weapon/lighter))
				var/obj/item/weapon/lighter/L = W
				if(L.lit)
					lit(user,W)
			else if(istype(W, /obj/item/weapon/match))
				var/obj/item/weapon/match/M = W
				if(M.lit)
					lit(user,W)
			else if(istype(W, /obj/item/candle))
				var/obj/item/candle/C = W
				if(C.lit)
					lit(user,W)
			else if(iswirecutter(W))
				assembled = 1
				to_chat(user, "<span  class='notice'>You remove the fuse from the [src].</span>")
				name = "fuse bomb assembly"
				desc = "Just add fire."
				update_icon()
		else
			if(iswirecutter(W))
				fuse_lit = 0
				update_icon()
				to_chat(user, "<span class='warning'>You extinguish the fuse with [seconds_left] seconds left!</span>")


/obj/item/cannonball/fuse_bomb/proc/lit(mob/user as mob, var/obj/O=null)
	fuse_lit = 1
	to_chat(user, "<span class='warning'>You lit the fuse[O ? " with [O]":""]! [seconds_left] seconds till detonation!</span>")
	admin_warn(user)
	add_fingerprint(user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	update_icon()
	fuse_burn()

/obj/item/cannonball/fuse_bomb/proc/fuse_burn()
	set waitfor = 0

	if(src && src.fuse_lit)
		if(src.seconds_left)
			sleep(10)
			src.seconds_left--
			src.update_icon()
			.()
		else
			src.detonation()
	return

/obj/item/cannonball/fuse_bomb/extinguish()
	..()
	fuse_lit = 0
	update_icon()

/obj/item/cannonball/fuse_bomb/proc/detonation()
	explosion(get_turf(src), -1, 1, 3)
	qdel(src)

/obj/item/cannonball/fuse_bomb/update_icon()
	if (assembled == 2)
		icon_state = "fuse_bomb_[seconds_left][fuse_lit ? "-lit":""]"
	else
		icon_state = "fuse_bomb_[seconds_left][fuse_lit ? "-lit":""]"

/obj/item/cannonball/fuse_bomb/proc/admin_warn(mob/user as mob)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)

	var/demoman_name = ""
	if(!user)
		demoman_name = "Unknown"
	else
		demoman_name = "[user.name]([user.ckey])"

	var/log_str = "Bomb fuse lit in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> by [demoman_name]"

	if(user)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)"

	bombers += log_str
	message_admins(log_str, 0, 1)
	log_game(log_str)

/obj/item/cannonball/fuse_bomb/admin/admin_warn(mob/user as mob)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)

	var/demoman_name = ""
	if(!user)
		demoman_name = "Unknown"
	else
		demoman_name = "[user.name]([user.ckey])"

	var/log_str = "Bomb fuse lit in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> by [demoman_name]"

	if(user)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)"

	bombers += log_str
	log_game(log_str)

/obj/item/cannonball/fuse_bomb/ex_act(severity)//MWAHAHAHA
	detonation()

/obj/item/cannonball/fuse_bomb/cultify()
	return

/obj/item/cannonball/fuse_bomb/throw_impact(atom/hit_atom, var/speed, mob/user)
	..()
	detonation()