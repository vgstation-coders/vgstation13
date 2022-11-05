#define MIN_SPIDERS_PER_PLAYER_QUEEN 6
#define MIN_SPIDERS_PER_NPC_QUEEN 10

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
	species_type = /mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider
	search_objects = TRUE
	stat_attack = 2
	var/fed = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/New()
	..()
	add_spell(new /spell/aoe_turf/conjure/web, "spider_spell_ready", /obj/abstract/screen/movable/spell_master/spider)
	add_spell(new /spell/spin_cocoon, "spider_spell_ready", /obj/abstract/screen/movable/spell_master/spider)
	add_spell(new /spell/spider_eggs, "spider_spell_ready", /obj/abstract/screen/movable/spell_master/spider)

/mob/living/simple_animal/hostile/giant_spider/nurse/initialize_rules()
	target_rules.Add(new /datum/fuzzy_ruling/is_mob)
	target_rules.Add(new /datum/fuzzy_ruling/is_obj{weighting = 0.01})
	var/datum/fuzzy_ruling/distance/D = new /datum/fuzzy_ruling/distance
	D.set_source(src)
	target_rules.Add(D)

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/check_evolve()
	if(get_spider_count() >= get_queen_req(MIN_SPIDERS_PER_NPC_QUEEN) && !key && prob(10))	//don't evolve if there's a player inside
		grow_up()
		return 1
	return 0

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/get_spider_count()
	var/result = animal_count[/mob/living/simple_animal/hostile/giant_spider] + animal_count[/mob/living/simple_animal/hostile/giant_spider/hunter] + animal_count[/mob/living/simple_animal/hostile/giant_spider/spiderling] + animal_count[/mob/living/simple_animal/hostile/giant_spider/nurse] + animal_count[/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider]
	return result

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/get_queen_req(var/req = MIN_SPIDERS_PER_PLAYER_QUEEN)
	var/result = (1 + animal_count[/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider]) * req
	return result

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	if(timestopped || istype(loc,/obj/item/device/mobcapsule))
		return
	..()
	if(client && !deny_client_move)
		return 0
	if(!stat && stance == HOSTILE_STANCE_IDLE)
		if(check_evolve())
			return
		if(spin_web(get_turf(src)) && fed > 0)
			lay_eggs()

/mob/living/simple_animal/hostile/giant_spider/nurse/regular_hud_updates()
	..()
	if(client && hud_used)
		if(!hud_used.spider_food_display)
			hud_used.spider_hud()
		hud_used.spider_food_display.maptext_width = WORLD_ICON_SIZE
		hud_used.spider_food_display.maptext_height = WORLD_ICON_SIZE
		if (fed > 0)
			hud_used.spider_food_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>Food:<br><font color='#33FF33'>[fed]</font></div>"
		else
			hud_used.spider_food_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>Food:<br><font color='#FFFF00'>[fed]</font></div>"
		queen_ratio_counter()

/mob/living/simple_animal/hostile/giant_spider/nurse/CanAttack(var/atom/the_target)
	if(isitem(the_target))
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/giant_spider/nurse/AttackingTarget()
	if(isitem(target))
		return spin_cocoon(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat) //Unconscious, or dead
			return spin_cocoon(target)
	return ..()

/mob/living/simple_animal/hostile/giant_spider/nurse/after_unarmed_attack(mob/living/target, damage, damage_type, organ, armor)
	if(target.stat)//target is uncounscious? Let's start spinning a cocoon right away.
		spin_cocoon(target)

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/manual_evolution()
	if (!client)
		return
	if (!isturf(loc))
		to_chat(src,"<span class='warning'>You need to stand in the open before you can grow up.</span>")
		return
	var/spider_count = get_spider_count()
	var/queen_req = get_queen_req(MIN_SPIDERS_PER_PLAYER_QUEEN)
	if (spider_count < queen_req)
		to_chat(src,"<span class='warning'>There aren't enough spiders to warrant a new queen, lay some more eggs first. Cocoon some mobs to get the food you need to lay eggs.</span>")
		return
	grow_up()

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/queen_ratio_counter()
	//giving the spell here so queens don't get it
	if(!(locate(/spell/spider_nurse_evolution) in spell_list))
		add_spell(new /spell/spider_nurse_evolution, "spider_spell_ready", /obj/abstract/screen/movable/spell_master/spider)

	if(!hud_used.spider_queen_counter)
		hud_used.spider_hud()
	hud_used.spider_queen_counter.maptext_width = WORLD_ICON_SIZE
	hud_used.spider_queen_counter.maptext_height = WORLD_ICON_SIZE
	var/spider_count = get_spider_count()
	var/queen_req = get_queen_req(MIN_SPIDERS_PER_PLAYER_QUEEN)
	if (spider_count >= queen_req)
		hud_used.spider_queen_counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><br><font color='#33FF33'>[spider_count]/[queen_req]</font></div>"
	else
		hud_used.spider_queen_counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><br><font color='#FFFF00'>[spider_count]/[queen_req]</font></div>"

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/spin_web(var/turf/T)
	if(!T.has_gravity(src))
		return 0
	if(!locate(/obj/effect/spider/stickyweb) in T)
		new /obj/effect/spider/stickyweb(T)
	return 1

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/lay_eggs()
	if (fed <= 0)
		to_chat(src,"<span class='warning'>You need to eat some fresh viscera before you can lay any egg. Go cocoon a monkey.</span>")
		return
	fed--
	var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
	if(!E)
		visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		if(do_after(src,loc, 50))
			E = locate() in get_turf(src)
			if(!E)
				new /obj/effect/spider/eggcluster(loc)
		else
			fed++
		stop_automated_movement = 0
	else
		to_chat(src,"<span class='warning'>There are already some eggs on this tile, space them out.</span>")

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/spin_cocoon(var/atom/cocoon_target)
	if (!cocoon_target)
		return
	if(locate(/obj/effect/spider/cocoon) in cocoon_target.loc)
		return
	visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
	stop_automated_movement = 1
	if(do_after(src,cocoon_target, 50))
		var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
		var/suffix = ""
		C.pixel_x = cocoon_target.pixel_x
		C.pixel_y = cocoon_target.pixel_y
		for(var/mob/living/M in C.loc)
			if(istype(M, /mob/living/simple_animal/hostile/giant_spider))
				continue
			for (var/atom/movable/AM in M.locked_atoms)
				M.unlock_atom(AM)
			if (M.locked_to)
				M.locked_to.unlock_atom(M)
			suffix = "_mob"
			fed++
			visible_message("<span class='warning'>\the [src] sticks a proboscis into \the [cocoon_target] and secretes a digestive enzyme.</span>")
			M.adjustToxLoss(85)
			M.forceMove(C)
			C.pixel_x = M.pixel_x
			C.pixel_y = M.pixel_y
		for(var/obj/item/I in C.loc)
			I.forceMove(C)
		for(var/obj/structure/S in C.loc)
			if(!S.anchored)
				S.forceMove(C)
				suffix = "_large"
		for(var/obj/machinery/M in C.loc)
			if(!M.anchored)
				M.forceMove(C)
				suffix = "_large"
		if(suffix)
			C.icon_state = pick("cocoon[suffix]1","cocoon[suffix]2","cocoon[suffix]3")
			C.health = initial(C.health)*2
	stop_automated_movement = 0


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
	ranged_cooldown_cap = 2
	projectiletype = /obj/item/projectile/web
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	size = SIZE_HUGE
	delimbable_icon = FALSE

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/check_evolve()
	return 0

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/queen_ratio_counter()
	return

/obj/item/projectile/web
	name = "sticky ball"
	icon_state = "web"
	damage = 0
	damage_type = BRUTE

/obj/item/projectile/web/to_bump(atom/A)
	if (isliving(A))
		forceMove(A.loc)
		setDensity(FALSE)
		invisibility = 101
		kill_count = 0
		var/obj/effect/rooting_trap/stickyweb/web = new (A.loc)
		web.stick_to(A)
		var/mob/living/L = A
		L.take_overall_damage(damage,0)
		to_chat(L, "<span class='danger'>Resist or click the webs on your legs to free yourself.</span>")

	if(!(locate(/obj/effect/spider/stickyweb) in get_turf(src)))
		new /obj/effect/spider/stickyweb(get_turf(src))

	bullet_die()
	qdel(src)

//This override of bump_original_check() causes the projectile to land on turfs clicked instead of flying past them.
//This is often desirable when the projectile has some specific behaviour upon expiration. Such as, in this instance, the spawning of a sticky web
/obj/item/projectile/web/bump_original_check()//Because the proc looks a bit confusing I'll explain what each line does here:
	if(!bumped)								//<-- if we haven't yet bumped into something
		if(loc == get_turf(original))		//<-- and are located on the turf that was 'original'ly clicked (yes the var name is confusing I know, screw projectile code)
			if(!(original in permutated))	//<-- and haven't for some reason bounced-off/portal'd through, etc, off that turf
				to_bump(original)			//<--then let's immediately bump into that turf (even if it's a floor). to_bump() then does the rest.
