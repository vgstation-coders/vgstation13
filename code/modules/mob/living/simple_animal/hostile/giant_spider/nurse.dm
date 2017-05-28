#define MAX_SQUEENS 5

//nursemaids - these create webs and eggs
// Slower
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	maxHealth = 75 // 40
	health = 75
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 10
	poison_type = STOXIN
	var/fed = 0
	var/atom/cocoon_target

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/check_evolve()
	if(spider_queens.len < MAX_SQUEENS)
		var/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/NQ = new(src.loc)
		NQ.inherit_mind(src)
		qdel(src)
		return 1
	return 0

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	if(timestopped)
		return 0 //under effects of time magick
	if(istype(loc,/obj/item/device/mobcapsule)) //Dont bother trying to do shit while inside of a capsule, stops self-web spinning
		return
	..()
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE)
			if(check_evolve())
				return

			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat && !istype(C,/mob/living/simple_animal/hostile/giant_spider))
						cocoon_target = C
						busy = MOVING_TO_TARGET
						Goto(C, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return

				//second, spin a sticky spiderweb on this tile
				var/obj/effect/spider/stickyweb/W = locate() in get_turf(src)
				if(!W)
					busy = SPINNING_WEB
					src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
					stop_automated_movement = 1
					spawn(40)
						if(busy == SPINNING_WEB)
							W = locate() in get_turf(src)
							if(!W)
								new /obj/effect/spider/stickyweb(src.loc)
							busy = 0
							stop_automated_movement = 0
				// If there IS web and we've been fed...
				else if(fed > 0)
					//third, lay an egg cluster there
					var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
					if(!E)
						busy = LAYING_EGGS
						src.visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
						stop_automated_movement = 1
						spawn(50)
							if(busy == LAYING_EGGS)
								E = locate() in get_turf(src)
								if(!E)
									new /obj/effect/spider/eggcluster(src.loc)
									fed--
								busy = 0
								stop_automated_movement = 0
				// If we've got eggs, don't do anything but attack and lay eggs.
				if(fed>0)
					return
				//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
				for(var/obj/O in can_see)

					if(istype(O,/obj/machinery/door))
						var/obj/machinery/door/D=O
						if(D.density)
							continue
						// Jammed? Skippit.
						if(locate(/obj/effect/spider/stickyweb) in get_turf(O))
							continue
					else
						if(O.anchored)
							continue

					if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
						// Quit breaking shit you can't break.
						//if(istype(O,/obj/structure/window) && O:godmode==1)
						//	continue
						// Skip things we can't wrap
						if(istype(O, /mob/living/simple_animal/hostile/giant_spider))
							continue

						//Don't cocoon the box we're stored in
						if(loc == O || locked_to == O)
							continue

						cocoon_target = O
						busy = MOVING_TO_TARGET
						stop_automated_movement = 1
						Goto(O, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(O)

			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					if(istype(cocoon_target, /mob/living/simple_animal/hostile/giant_spider))
						busy=0
						stop_automated_movement=0
					busy = SPINNING_COCOON
					src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
					stop_automated_movement = 1
					walk(src,0)
					spawn(50)
						if(busy == SPINNING_COCOON)
							if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
								if(istype(cocoon_target,/obj/machinery/door))
									var/obj/machinery/door/D=cocoon_target
									var/obj/effect/spider/stickyweb/W = locate() in get_turf(cocoon_target)
									if(!W)
										src.visible_message("<span class='warning'>\the [src] jams \the [cocoon_target] open with web!</span>")
										W=new /obj/effect/spider/stickyweb(cocoon_target.loc)
										// Jam the door open with webs
										D.jammed=W
									busy = 0
									stop_automated_movement = 0
								else
									var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
									var/large_cocoon = 0
									C.pixel_x = cocoon_target.pixel_x
									C.pixel_y = cocoon_target.pixel_y
									for(var/mob/living/M in C.loc)
										if(istype(M, /mob/living/simple_animal/hostile/giant_spider))
											continue
										large_cocoon = 1
										fed++
										src.visible_message("<span class='warning'>\the [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.</span>")
										M.forceMove(C)
										C.pixel_x = M.pixel_x
										C.pixel_y = M.pixel_y
										break
									for(var/obj/item/I in C.loc)
										I.forceMove(C)
									for(var/obj/structure/S in C.loc)
										if(!S.anchored)
											S.forceMove(C)
											large_cocoon = 1
									for(var/obj/machinery/M in C.loc)
										if(!M.anchored)
											M.forceMove(C)
											large_cocoon = 1
									if(large_cocoon)
										C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
										C.health = initial(C.health)*2
							busy = 0
							stop_automated_movement = 0

		else
			busy = 0
			stop_automated_movement = 0

var/list/spider_queens = list()

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider
	name = "spider queen"
	desc = "Massive, dark, and very furry. This is an absolutely massive spider. Its fangs are almost as big as you!"
	icon = 'icons/mob/giantmobs.dmi'			//Both the alien queen sprite and the queen spider sprite are 64x64, it seemed pointless to make a new file for two new states
	icon_state = "spider_queen1"
	icon_living = "spider_queen1"
	icon_dead = "spider_queen_dead"
	pixel_x = -16 * PIXEL_MULTIPLIER
	maxHealth = 500
	health = 500
	melee_damage_lower = 30
	melee_damage_upper = 40
	speed = 6
	projectiletype = /obj/item/projectile/web
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/New()
	..()
	spider_queens += src

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/Destroy()
	..()
	spider_queens -= src

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/check_evolve()
	return 0

/obj/item/projectile/web
	icon_state = "web"
	damage = 5
	damage_type = BRUTE

/obj/item/projectile/web/Bump(atom/A)
	if(!(locate(/obj/effect/spider/stickyweb) in get_turf(src)))
		new /obj/effect/spider/stickyweb(get_turf(src))
	qdel(src)