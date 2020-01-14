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
	desc = "A square piece of metal standing on four metal legs. It cannot move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = TABLE_LAYER
	throwpass = 1	//You can throw objects over this, despite its density.
	var/parts = /obj/item/weapon/table_parts
	var/flipped = 0
	var/health = 100

/obj/structure/table/proc/update_adjacent()
	for(var/direction in alldirs)
		if(locate(/obj/structure/table, get_step(src, direction)))
			var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
			T.update_icon()

/obj/structure/table/cultify()
	new /obj/structure/table/woodentable(loc) //See New() for qdel

/obj/structure/table/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/structure/table/reinforced/clockwork, CLOCKWORK_GENERIC_GLOW)

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			qdel(T)
	if(flipped)
		flip(dir)
	update_icon()
	update_adjacent()

/obj/structure/table/Destroy()
	update_adjacent()
	..()

/obj/structure/table/glass/proc/checkhealth()
	if(health <= 0)
		playsound(src, "shatter", 50, 1)
		new /obj/item/weapon/shard(src.loc)
		new /obj/item/weapon/table_parts(src.loc)
		qdel(src)

/obj/structure/table/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		src.ex_act(1)
	..()
	return 0

/obj/structure/table/proc/destroy()
	if(parts)
		new parts(loc)
	setDensity(FALSE)
	qdel(src)

/obj/structure/table/proc/can_disassemble()
	return 1

/obj/structure/table/update_icon() //MWAHAHAHAHAAAAAH!!! WELCOME TO MAGIC NUMBER HELL!!!
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
			if (istype(src, /obj/structure/table/glass))
				base = "glasstable"

			icon_state = "[base]flip[type]"
			if (type==1)
				if (tabledirs & turn(dir,90))
					icon_state = icon_state+"-"
				if (tabledirs & turn(dir,-90))
					icon_state = icon_state+"+"
			return 1

		var/dir_sum = 0
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
					if(direction <5)
						dir_sum += direction
					else
						if(direction == 5)	//This permits the use of all table directions. (Set up so clockwise around the central table is a higher value, from north)
							dir_sum += 16
						if(direction == 6)
							dir_sum += 32
						if(direction == 8)	//Aherp and Aderp.  Jezes I am stupid.  -- SkyMarshal
							dir_sum += 8
						if(direction == 10)
							dir_sum += 64
						if(direction == 9)
							dir_sum += 128

		var/table_type = 0 //stand_alone table
		if(dir_sum%16 in cardinal)
			table_type = 1 //endtable
			dir_sum %= 16
		if(dir_sum%16 in list(3,12))
			table_type = 2 //1 tile thick, streight table
			if(dir_sum%16 == 3) //3 doesn't exist as a dir
				dir_sum = 2
			if(dir_sum%16 == 12) //12 doesn't exist as a dir.
				dir_sum = 4
		if(dir_sum%16 in list(5,6,9,10))
			if(locate(/obj/structure/table,get_step(src.loc,dir_sum%16)))
				table_type = 3 //full table (not the 1 tile thick one, but one of the 'tabledir' tables)
			else
				table_type = 2 //1 tile thick, corner table (treated the same as streight tables in code later on)
			dir_sum %= 16
		if(dir_sum%16 in list(13,14,7,11)) //Three-way intersection
			table_type = 5 //full table as three-way intersections are not sprited, would require 64 sprites to handle all combinations.  TOO BAD -- SkyMarshal
			switch(dir_sum%16)	//Begin computation of the special type tables.  --SkyMarshal
				if(7)
					if(dir_sum == 23)
						table_type = 6
						dir_sum = 8
					else if(dir_sum == 39)
						dir_sum = 4
						table_type = 6
					else if(dir_sum == 55 || dir_sum == 119 || dir_sum == 247 || dir_sum == 183)
						dir_sum = 4
						table_type = 3
					else
						dir_sum = 4
				if(11)
					if(dir_sum == 75)
						dir_sum = 5
						table_type = 6
					else if(dir_sum == 139)
						dir_sum = 9
						table_type = 6
					else if(dir_sum == 203 || dir_sum == 219 || dir_sum == 251 || dir_sum == 235)
						dir_sum = 8
						table_type = 3
					else
						dir_sum = 8
				if(13)
					if(dir_sum == 29)
						dir_sum = 10
						table_type = 6
					else if(dir_sum == 141)
						dir_sum = 6
						table_type = 6
					else if(dir_sum == 189 || dir_sum == 221 || dir_sum == 253 || dir_sum == 157)
						dir_sum = 1
						table_type = 3
					else
						dir_sum = 1
				if(14)
					if(dir_sum == 46)
						dir_sum = 1
						table_type = 6
					else if(dir_sum == 78)
						dir_sum = 2
						table_type = 6
					else if(dir_sum == 110 || dir_sum == 254 || dir_sum == 238 || dir_sum == 126)
						dir_sum = 2
						table_type = 3
					else
						dir_sum = 2 //These translate the dir_sum to the correct dirs from the 'tabledir' icon_state.
		if(dir_sum%16 == 15)
			table_type = 4 //4-way intersection, the 'middle' table sprites will be used.
		switch(table_type)
			if(0)
				icon_state = "[initial(icon_state)]"
			if(1)
				icon_state = "[initial(icon_state)]_1tileendtable"
			if(2)
				icon_state = "[initial(icon_state)]_1tilethick"
			if(3)
				icon_state = "[initial(icon_state)]_dir"
			if(4)
				icon_state = "[initial(icon_state)]_middle"
			if(5)
				icon_state = "[initial(icon_state)]_dir2"
			if(6)
				icon_state = "[initial(icon_state)]_dir3"
		if (dir_sum in alldirs)
			dir = dir_sum
		else
			dir = 2

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

/obj/structure/table/kick_act()
	..()

	if(!usr)
		return
	do_flip()

/obj/structure/table/glass/kick_act()
	health -= 5
	checkhealth()
	..()

/obj/structure/table/blob_act()
	if(prob(75))
		destroy()

/obj/structure/table/attack_paw(mob/living/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes the [src] apart!</span>")
		user.delayNextAttack(8)
		destroy()


/obj/structure/table/attack_alien(mob/living/user)
	user.do_attack_animation(src, user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()

/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash_flags & SMASH_LIGHT_STRUCTURES)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()



/obj/structure/table/attack_hand(mob/living/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(flipped)
		if(get_dir(loc, target) == dir || get_dir(loc, mover) == dir)
			return !density
		else
			return 1
	return 0

/obj/structure/table/bumped_by_firebird(obj/structure/bed/chair/vehicle/firebird/F)
	destroy()

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/shooting_at_the_table_directly = P.original == src
	var/chance = 60
	if(!shooting_at_the_table_directly)
		if(!flipped || get_dir(loc, from) != dir) // It needs to be flipped and the direction needs to be right
			return 1
		if(get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
			return 1
		if(ismob(P.original))
			var/mob/M = P.original
			if(M.lying)
				chance += 20 //Lying down lets you catch less bullets
	if(shooting_at_the_table_directly || prob(chance))
		health -= P.damage/2
		if (health > 0)
			visible_message("<span class='warning'>[P] hits \the [src]!</span>")
			return 0
		else
			visible_message("<span class='warning'>[src] breaks down!</span>")
			destroy()
			return 1
	return 1

/obj/structure/table/Uncross(atom/movable/mover as mob|obj, target as turf)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(flow_flags & ON_BORDER)
		if(target) //Are we doing a manual check to see
			if(get_dir(loc, target) == dir)
				return !density
		else if(mover.dir == dir) //Or are we using move code
			if(density)
				mover.to_bump(src)
			return !density
	return 1

/obj/structure/table/MouseDropTo(atom/movable/O,mob/user,src_location,over_location,src_control,over_control,params)
	if(O == user)
		if(!ishigherbeing(user) || !Adjacent(user) || user.incapacitated() || user.lying) // Doesn't work if you're not dragging yourself, not a human, not in range or incapacitated
			return
		var/mob/living/carbon/M = user
		M.apply_damage(2, BRUTE, LIMB_HEAD, used_weapon = "[src]")
		M.adjustBrainLoss(5)
		M.Knockdown(1)
		M.Stun(1)
		if (prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)
		M.visible_message("<span class='danger'>[user] bangs \his head on \the [src].</span>", "<span class='danger'>You bang your head on \the [src].</span>", "You hear a bang.")
		return
	return ..()

/obj/structure/table/attackby(obj/item/W as obj, mob/user as mob, params)
	if (!W)
		return

	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			if (G.state < GRAB_AGGRESSIVE)
				if(user.a_intent == I_HURT)
					G.affecting.forceMove(loc)
					if (prob(15))
						M.Knockdown(5)
						M.Stun(5)
					M.apply_damage(8,def_zone = LIMB_HEAD)
					visible_message("<span class='warning'>[G.assailant] slams [G.affecting]'s face against \the [src]!</span>")
					playsound(src, 'sound/weapons/tablehit1.ogg', 50, 1)
				else
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
					return
			else
				G.affecting.forceMove(loc)
				G.affecting.Knockdown(5)
				G.affecting.Stun(5)
				visible_message("<span class='warning'>[G.assailant] puts [G.affecting] on \the [src].</span>")
			returnToPool(W)
			return

	if (W.is_wrench(user) && can_disassemble())
		to_chat(user, "<span class='notice'>Now disassembling table...</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, src,50))
			destroy()
		return

	if(user.drop_item(W, src.loc))
		if(W.loc == src.loc && params)
			W.setPixelOffsetsFromParams(params, user)
			return 1

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
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
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
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
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
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
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
		plane = ABOVE_HUMAN_PLANE
	flipped = 1
	flow_flags |= ON_BORDER
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

	reset_plane_and_layer()
	flipped = 0
	flow_flags &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(src.loc,D)
		if(T && T.flipped && T.dir == src.dir)
			T.unflip()
	update_icon()
	update_adjacent()

	return 1

/obj/structure/table/flipped
	flipped = 1

/obj/structure/table/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"flipped",
		"health")

	reset_vars_after_duration(resettable_vars, duration)

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
	icon_state = "reinftable"
	parts = /obj/item/weapon/table_parts/reinforced
	var/status = 2 //DARE YOU ENTER MY MAGICAL NUMBER REALM?
	var/can_optable = TRUE

/obj/structure/table/reinforced/can_disassemble()
	return status != 2

/obj/structure/table/reinforced/flip(var/direction)
	if (status == 2)
		return 0
	else
		return ..()

/obj/structure/table/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/weapon/stock_parts/scanning_module) && can_optable)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 40))
			if(user.drop_item(W))
				var/obj/machinery/optable/OPT = new /obj/machinery/optable(src.loc)
				var/obj/item/weapon/stock_parts/scanning_module/SM = W
				OPT.rating = SM.rating

				qdel(W)
				qdel(src)

				return
			else
				user << "<span class='warning'>\The [W] is stuck to your hands!</span>"
				return

	else if (iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn())
			to_chat(user, "<span class='notice'>Now [status == 2?"weakening":"strenghening"] the reinforced table.</span>")
			if(WT.do_weld(user, src, 50, 0))
				if(src.status == 2)
					if(gcDestroyed)
						return
					to_chat(user, "<span class='notice'>Table weakened.</span>")
					src.status = 1
				else
					if(gcDestroyed)
						return
					to_chat(user, "<span class='notice'>Table strengthened.</span>")
					src.status = 2
			return
	return ..()

/*
 * Glass
 */

/obj/structure/table/glass
	name = "glass table"
	desc = "A standard table with a fine glass finish."
	icon_state = "glass_table"
	parts = /obj/item/weapon/table_parts/glass
	health = 30

/obj/structure/table/glass/attackby(obj/item/W as obj, mob/living/user as mob, params)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			if (G.state < GRAB_AGGRESSIVE)
				if(user.a_intent == I_HURT)
					user.do_attack_animation(src, W)
					if (prob(15))
						M.Knockdown(5)
						M.Stun(5)
					M.apply_damage(15,def_zone = LIMB_HEAD)
					visible_message("<span class='warning'>[G.assailant] slams [G.affecting]'s face against \the [src]!</span>")
					playsound(src, 'sound/weapons/tablehit1.ogg', 50, 1)
					playsound(src, "shatter", 50, 1) //WRESTLEMANIA tax
					new /obj/item/weapon/shard(src.loc)
					new /obj/item/weapon/table_parts(src.loc)
					qdel(src)
				else
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
					return
			else
				G.affecting.forceMove(loc)
				G.affecting.Knockdown(5)
				G.affecting.Stun(5)
				visible_message("<span class='warning'>[G.assailant] puts [G.affecting] on \the [src].</span>")
			returnToPool(W)

	else if (user.a_intent == I_HURT)
		user.do_attack_animation(src, W)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		playsound(src, 'sound/effects/Glasshit.ogg', 50, 1)
		checkhealth()

	else
		..()

/obj/structure/table/glass/plasma
	name = "plasma glass table"
	desc = "A standard table with a reinforced plasma glass finish."
	icon_state = "plasma_table"
	parts = /obj/item/weapon/table_parts/glass/plasma
	health = 150

/*
 * Brass
 */

/obj/structure/table/reinforced/clockwork
	name = "brass table"
	desc = "A solid, slightly beveled brass table."
	icon_state = "clock_table"
	parts = /obj/item/weapon/table_parts/clockwork
	can_optable = FALSE

/obj/structure/table/reinforced/clockwork/cultify()
	return

/obj/structure/table/reinforced/clockwork/clockworkify()
	return

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
	throwpass = 1	//You can throw objects over this, despite its density.
	layer = TABLE_LAYER //So items are always layered over it
	var/parts = /obj/item/weapon/rack_parts
	var/offset_step = 0
	var/health = 20

/obj/structure/rack/proc/destroy(var/dropParts = TRUE)
	if(parts && dropParts)
		new parts(loc)
	setDensity(FALSE)
	qdel(src)

/obj/structure/rack/proc/can_disassemble()
	return TRUE

/obj/structure/rack/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		src.ex_act(1)
	..()
	return 0

/obj/structure/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			destroy(FALSE)
		if(2.0)
			if(prob(50))
				destroy(TRUE)
			else
				destroy(FALSE)
		if(3.0)
			if(prob(25))
				destroy(TRUE)
			else
				destroy(FALSE)

/obj/structure/rack/proc/checkhealth()
	if(health <= 0)
		destroy()

/obj/structure/rack/proc/spawnParts()
	new /obj/item/weapon/rack_parts(loc)

/obj/structure/rack/kick_act()
	health -= 5
	checkhealth()
	..()

/obj/structure/rack/blob_act()
	if(prob(50))
		destroy(TRUE)
	else
		destroy(FALSE)

/obj/structure/rack/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	return !density

/obj/structure/rack/bumped_by_firebird(obj/structure/bed/chair/vehicle/firebird/F)
	destroy()

/obj/structure/rack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_wrench(user) && can_disassemble())
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		destroy(TRUE)
		return

	if(user.drop_item(W, src.loc))
		if(W.loc == src.loc)
			switch(offset_step)
				if(1)
					W.pixel_x = -3 * PIXEL_MULTIPLIER
					W.pixel_y = 3 * PIXEL_MULTIPLIER
				if(2)
					W.pixel_x = 0
					W.pixel_y = 0
				if(3)
					W.pixel_x = 3 * PIXEL_MULTIPLIER
					W.pixel_y = -3 * PIXEL_MULTIPLIER
					offset_step = 0
			offset_step++
			return 1

/obj/structure/rack/attack_hand(mob/living/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()

/obj/structure/rack/attack_paw(mob/living/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_alien(mob/living/user)
	user.do_attack_animation(src, user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()

/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash_flags & SMASH_LIGHT_STRUCTURES)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_tk() // no telehulk sorry
	return
