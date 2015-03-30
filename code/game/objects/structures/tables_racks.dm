/* Tables and Racks
 * Contains:
 *		Tables
 *		Wooden tables
 *		Reinforced tables
 *		Racks
 */


/*
 * Tables
 */
/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.")
	var/parts = /obj/item/weapon/table_parts
	var/icon/clicked
	var/flipped = 0
	var/health = 100

/obj/structure/table/proc/update_adjacent()
	for(var/direction in alldirs)
		if(locate(/obj/structure/table, get_step(src, direction)))
			var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
			T.update_icon()

/obj/structure/table/cultify()
	new /obj/structure/table/woodentable(loc)
	..()

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			del(T)
	update_icon()
	update_adjacent()

/obj/structure/table/Destroy()
	update_adjacent()
	..()

/obj/structure/table/proc/destroy()
	new parts(loc)
	density = 0
	qdel(src)

/obj/structure/rack/proc/destroy()
	new parts(loc)
	density = 0
	qdel(src)

/obj/structure/table/proc/can_disassemble()
	return 1

/obj/structure/table/update_icon()
	spawn(2) //So it properly updates when deleting

		if(flipped)
			var/type = 0
			var/tabledirs = 0
			for(var/direction in list(turn(dir,90), turn(dir,-90)) )
				var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
				if (T && T.flipped && T.dir == src.dir)
					type++
					tabledirs |= direction
			var/base = "table"
			if (istype(src, /obj/structure/table/woodentable))
				base = "wood"
			if (istype(src, /obj/structure/table/reinforced))
				base = "rtable"

			icon_state = "[base]flip[type]"
			if (type==1)
				if (tabledirs & turn(dir,90))
					icon_state = icon_state+"-"
				if (tabledirs & turn(dir,-90))
					icon_state = icon_state+"+"
			return 1

		var/dir_sum = 0
		var/in_cardinal = 0
		for(var/direction in alldirs)
			var/skip_sum = 0
			for(var/obj/structure/window/W in src.loc)
				if(W.dir == direction) //So smooth tables don't go smooth through windows
					skip_sum = 1
					continue
			var/inv_direction //inverse direction
			switch(direction)
				if(1)
					inv_direction = 2
				if(2)
					inv_direction = 1
				if(4)
					inv_direction = 8
				if(8)
					inv_direction = 4
				if(5)
					inv_direction = 10
				if(6)
					inv_direction = 9
				if(9)
					inv_direction = 6
				if(10)
					inv_direction = 5
			for(var/obj/structure/window/W in get_step(src,direction))
				if(W.dir == inv_direction) //So smooth tables don't go smooth through windows when the window is on the other table's tile
					skip_sum = 1
					continue
			if(!skip_sum) //means there is a window between the two tiles in this direction
				var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
				if(T && !T.flipped)
					if(direction in cardinal)
						dir_sum += direction
						in_cardinal = 1 //we have a table in a cardinal direction
					else
						if(direction == 5)	//This permits the use of all table directions. (Set up so clockwise around the central table is a higher value, from north)
							dir_sum += 16 //NE (1 + 4)
						if(direction == 6)
							dir_sum += 32 //SE (2 + 4)
						if(direction == 10)
							dir_sum += 64 //SW (2 + 8)
						if(direction == 9)
							dir_sum += 128 //NW (1 + 8)

		if(!dir_sum || !in_cardinal) //if there are no cardinal tables, no reason to draw the sprite
			overlays.len = 0
			icon_state = "[initial(icon_state)]"

		else
			icon_state = "[initial(icon_state)]_base"
			overlays.len = 0

			if(dir_sum & 1) //north - this builds top and middle connections
				overlays += icon(src.icon, "[initial(icon_state)]_plane", 1) //we extend northwards
				if(dir_sum & 4) //if we have east
					overlays += icon(src.icon, "[initial(icon_state)]_plane", 4) //add the connector for east
					if(dir_sum & 16) //if we have east AND northeast - see above as to why this is 16
						overlays += icon(src.icon, "[initial(icon_state)]_plane", 5) //we connect to the northeast as well
					else
						overlays += icon(src.icon, "[initial(icon_state)]_icorner", 5) //inverted corner - we only go north and east
				else
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 5) //insert the stopblock for northeast
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 4) //and for east

				if(dir_sum & 8) //this section is the same, but for west(8) and northwest(9)
					overlays += icon(src.icon, "[initial(icon_state)]_plane", 8)
					if(dir_sum & 128)
						overlays += icon(src.icon, "[initial(icon_state)]_plane", 9)
					else
						overlays += icon(src.icon, "[initial(icon_state)]_icorner", 9)
				else
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 9)
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 8)

			else //we don't connect diagonally (NE, NW) without north, so that doesn't need handling
				overlays += icon(src.icon, "[initial(icon_state)]_horiz", 1) //we stopcap the north end
				if(dir_sum & 4) //if we extend east
					overlays += icon(src.icon, "[initial(icon_state)]_horiz", 5) // we stopcap northeast
					overlays += icon(src.icon, "[initial(icon_state)]_plane", 4) //and add the connector for east
				else
					overlays += icon(src.icon, "[initial(icon_state)]_corner", 5) //corner the dorner
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 4) //cap the east end

				if(dir_sum & 8) //same as above, but for west (8) and northwest (9)
					overlays += icon(src.icon, "[initial(icon_state)]_horiz", 9)
					overlays += icon(src.icon, "[initial(icon_state)]_plane", 8)
				else
					overlays += icon(src.icon, "[initial(icon_state)]_corner", 9)
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 8)

			if(dir_sum & 2) //south - this forms the lower third of the connectors
				overlays += icon(src.icon, "[initial(icon_state)]_plane", 2)
				if(dir_sum & 4) //east - remember, the connector eastwards has been set already
					if(dir_sum & 32) //if we go southeast as well
						overlays += icon(src.icon, "[initial(icon_state)]_plane", 6) //add that connector
					else
						overlays += icon(src.icon, "[initial(icon_state)]_icorner", 6) //inverted corner
				else
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 6) //connects southwards

				if(dir_sum & 8) //west - see above
					if(dir_sum & 64)
						overlays += icon(src.icon, "[initial(icon_state)]_plane", 10)
					else
						overlays += icon(src.icon, "[initial(icon_state)]_icorner", 10)
				else
					overlays += icon(src.icon, "[initial(icon_state)]_vert", 10)

			else //we only connect diagonally if we go southwards, so we only worry about if we extend east and/or west
				overlays += icon(src.icon, "[initial(icon_state)]_horiz", 2) //cap the south

				if(dir_sum & 4) //east
					overlays += icon(src.icon, "[initial(icon_state)]_horiz", 6) //this is the extending eastwards icon
				else
					overlays += icon(src.icon, "[initial(icon_state)]_corner", 6) //cap with a corner - remember, the eastwards cap was already put down

				if(dir_sum & 8) //same for west
					overlays += icon(src.icon, "[initial(icon_state)]_horiz", 10)
				else
					overlays += icon(src.icon, "[initial(icon_state)]_corner", 10)


		if (dir_sum in alldirs)
			dir = dir_sum
		else
			dir = 2

	clicked = new/icon(src.icon, initial(src.icon_state), src.dir) //giving you runtime icon access is too byond Byond

/obj/structure/table/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				destroy()
		else
	return


/obj/structure/table/blob_act()
	if(prob(75))
		destroy()

/obj/structure/table/attack_paw(mob/user)
	if(M_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes the [src] apart!</span>")
		user.delayNextAttack(8)
		destroy()


/obj/structure/table/attack_alien(mob/user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()

/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash>0)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()



/obj/structure/table/attack_hand(mob/user)
	if(M_HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = flipped ? get_turf(src) : get_step(loc, get_dir(from, loc))
	if (get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
		return 1
	if (get_turf(P.original) == cover)
		var/chance = 20
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.lying)
				chance += 20				//Lying down lets you catch less bullets
		if(flipped)
			if(get_dir(loc, from) == dir)	//Flipped tables catch mroe bullets
				chance += 20
			else
				return 1					//But only from one side
		if(prob(chance))
			health -= P.damage/2
			if (health > 0)
				visible_message("<span class='warning'>[P] hits \the [src]!</span>")
				return 0
			else
				visible_message("<span class='warning'>[src] breaks down!</span>")
				destroy()
				return 1
	return 1

/obj/structure/table/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 1

/obj/structure/table/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return


/obj/structure/table/attackby(obj/item/W as obj, mob/user as mob, params)
	if (!W) return

	var/list/params_list = params2list(params)

	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			if (G.state < 2)
				if(user.a_intent == I_HURT)
					if (prob(15))	M.Weaken(5)
					M.apply_damage(8,def_zone = "head")
					visible_message("\red [G.assailant] slams [G.affecting]'s face against \the [src]!")
					playsound(get_turf(src), 'sound/weapons/tablehit1.ogg', 50, 1)
				else
					user << "\red You need a better grip to do that!"
					return
			else
				G.affecting.loc = src.loc
				G.affecting.Weaken(5)
				visible_message("\red [G.assailant] puts [G.affecting] on \the [src].")
			del(W)
			return

	if (istype(W, /obj/item/weapon/wrench) && can_disassemble())
		//if(!params_list.len || text2num(params_list["icon-y"]) < 8) //8 above the bottom of the icon
		user << "<span class='notice'>Now disassembling table</span>"
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user,50))
			destroy()
		return

	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(get_turf(src), 'sound/weapons/blade1.ogg', 50, 1)
		playsound(get_turf(src), "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message("\blue The [src] was sliced apart by [user]!", 1, "\red You hear [src] coming apart.", 2)
		destroy()

	if(user.drop_item(src.loc))
		if(W.loc == src.loc && params_list.len)
			var/clamp_x = clicked.Width() / 2
			var/clamp_y = clicked.Height() / 2
			W.pixel_x = Clamp(text2num(params_list["icon-x"]) - clamp_x, -clamp_x, clamp_x)
			W.pixel_y = Clamp(text2num(params_list["icon-y"]) - clamp_y, -clamp_y, clamp_y)
	return

/obj/structure/table/proc/straight_table_check(var/direction)
	var/obj/structure/table/T
	for(var/angle in list(-90,90))
		T = locate() in get_step(src.loc,turn(direction,angle))
		if(T && !T.flipped)
			return 0
	T = locate() in get_step(src.loc,direction)
	if (!T || T.flipped)
		return 1
	if (istype(T,/obj/structure/table/reinforced/))
		var/obj/structure/table/reinforced/R = T
		if (R.status == 2)
			return 0
	return T.straight_table_check(direction)

/obj/structure/table/verb/can_touch(var/mob/user)
	if (!user)
		return 0
	if (user.stat)	//zombie goasts go away
		return 0
	if (issilicon(user))
		user << "<span class='notice'>You need hands for this.</span>"
		return 0
	return 1

/obj/structure/table/verb/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table"
	set category = "Object"
	set src in oview(1)
	if(ismouse(usr))
		return
	if (!can_touch(usr))
		return
	if(!flip(get_cardinal_dir(usr,src)))
		usr << "<span class='notice'>It won't budge.</span>"
	else
		usr.visible_message("<span class='warning'>[usr] flips \the [src]!</span>")
		return

/obj/structure/table/proc/unflipping_check(var/direction)
	for(var/mob/M in oview(src,0))
		return 0

	var/list/L = list()
	if(direction)
		L.Add(direction)
	else
		L.Add(turn(src.dir,-90))
		L.Add(turn(src.dir,90))
	for(var/new_dir in L)
		var/obj/structure/table/T = locate() in get_step(src.loc,new_dir)
		if(T)
			if(T.flipped && T.dir == src.dir && !T.unflipping_check(new_dir))
				return 0
	return 1

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back"
	set category = "Object"
	set src in oview(1)

	if (!can_touch(usr))
		return

	if (!unflipping_check())
		usr << "<span class='notice'>It won't budge.</span>"
		return
	unflip()

/obj/structure/table/proc/flip(var/direction)
	if( !straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)) )
		return 0

	verbs -=/obj/structure/table/verb/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src,dir),get_step(src,turn(dir, 45)),get_step(src,turn(dir, -45)))
	for (var/atom/movable/A in get_turf(src))
		if (!A.anchored)
			spawn(0)
				A.throw_at(pick(targets),1,1)

	dir = direction
	if(dir != NORTH)
		layer = 5
	flipped = 1
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src,D)
		if(T && !T.flipped)
			T.flip(direction)
	update_icon()
	update_adjacent()

	return 1

/obj/structure/table/proc/unflip()
	verbs -=/obj/structure/table/proc/do_put
	verbs +=/obj/structure/table/verb/do_flip

	layer = initial(layer)
	flipped = 0
	flags &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(src.loc,D)
		if(T && T.flipped && T.dir == src.dir)
			T.unflip()
	update_icon()
	update_adjacent()

	return 1

/*
 * Wooden tables
 */
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon_state = "woodtable"
	parts = /obj/item/weapon/table_parts/wood
	health = 50
	autoignition_temperature = AUTOIGNITION_WOOD // TODO:  Special ash subtype that looks like charred table legs.
	fire_fuel = 5

/obj/structure/table/woodentable/cultify()
	return

/obj/structure/table/woodentable/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon_state = "pokertable"
	parts = /obj/item/weapon/table_parts/wood/poker

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon_state = "reinf"
	parts = /obj/item/weapon/table_parts/reinforced
	var/status = 2

/obj/structure/table/reinforced/can_disassemble()
	return status != 2

/obj/structure/table/reinforced/flip(var/direction)
	if (status == 2)
		return 0
	else
		return ..()

/obj/structure/table/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!(WT.welding)/* || (params_list.len && text2num(params_list["icon-y"]) > 8)*/) //8 above the bottom of the icon
			return ..()
		if(WT.remove_fuel(0, user))
			if(src.status == 2)
				user << "\blue Now weakening the reinforced table"
				playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
				if (do_after(user, 50))
					if(!src || !WT.isOn()) return
					user << "\blue Table weakened"
					src.status = 1
			else
				user << "\blue Now strengthening the reinforced table"
				playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
				if (do_after(user, 50))
					if(!src || !WT.isOn()) return
					user << "\blue Table strengthened"
					src.status = 2
			return
		return
	return ..()

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	flags = FPRINT
	anchored = 1.0
	throwpass = 1	//You can throw objects over this, despite it's density.
	var/parts = /obj/item/weapon/rack_parts

/obj/structure/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			qdel(src)
			if(prob(50))
				new /obj/item/weapon/rack_parts(src.loc)
		if(3.0)
			if(prob(25))
				qdel(src)
				new /obj/item/weapon/rack_parts(src.loc)

/obj/structure/rack/blob_act()
	if(prob(75))
		del(src)
		return
	else if(prob(50))
		new /obj/item/weapon/rack_parts(src.loc)
		del(src)
		return

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/rack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/rack_parts( src.loc )
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		del(src)
		return
	if(isrobot(user))
		return
	user.drop_item(src.loc)
	return 1

/obj/structure/rack/meteorhit(obj/O as obj)
	del(src)


/obj/structure/table/attack_hand(mob/user)
	if(M_HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()

/obj/structure/rack/attack_paw(mob/user)
	if(M_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_alien(mob/user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()

/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash>0)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_tk() // no telehulk sorry
	return

